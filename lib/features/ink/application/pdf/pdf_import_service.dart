import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:pdfx/pdfx.dart';

import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';

/// Konfiguration für das PDF-Extraktions-LLM.
class PdfExtractionConfig {
  /// Erstellt eine neue Konfiguration.
  const PdfExtractionConfig({
    this.deploymentName = defaultDeploymentName,
    this.resourceName = defaultResourceName,
    this.apiVersion = defaultApiVersion,
    this.maxCompletionTokens = 4096,
  });

  /// Standard-Deployment für PDF-Extraktion.
  static const String defaultDeploymentName = 'gpt-5-nano';
  
  /// Standard-Azure-Ressource.
  static const String defaultResourceName = 'peped-mgjk16o0-eastus2';
  
  /// Standard-API-Version.
  static const String defaultApiVersion = '2025-01-01-preview';

  /// Der Name des Azure OpenAI Deployments.
  final String deploymentName;

  /// Der Name der Azure-Ressource.
  final String resourceName;

  /// Die API-Version.
  final String apiVersion;

  /// Maximale Anzahl an Tokens für die Antwort.
  final int maxCompletionTokens;

  /// Erstellt eine Kopie mit geänderten Werten.
  PdfExtractionConfig copyWith({
    String? deploymentName,
    String? resourceName,
    String? apiVersion,
    int? maxCompletionTokens,
  }) =>
      PdfExtractionConfig(
        deploymentName: deploymentName ?? this.deploymentName,
        resourceName: resourceName ?? this.resourceName,
        apiVersion: apiVersion ?? this.apiVersion,
        maxCompletionTokens: maxCompletionTokens ?? this.maxCompletionTokens,
      );
}

/// Update für die PDF-Hintergrundverarbeitung einer Notiz.
class PdfProcessingUpdate {
  /// Erstellt ein neues Processing-Update.
  const PdfProcessingUpdate({
    required this.noteId,
    required this.currentPage,
    required this.totalPages,
    required this.stage,
    this.extractedText,
    this.error,
  });

  /// Die ID der Notiz, die verarbeitet wird.
  final String noteId;

  /// Die aktuell verarbeitete Seite (1-basiert).
  final int currentPage;

  /// Die Gesamtanzahl der Seiten.
  final int totalPages;

  /// Die aktuelle Verarbeitungsphase.
  final PdfImportStage stage;

  /// Der extrahierte Text (nur bei abgeschlossener Seite).
  final String? extractedText;

  /// Fehlermeldung, falls aufgetreten.
  final String? error;

  /// Prüft, ob die Verarbeitung abgeschlossen ist.
  bool get isComplete => currentPage >= totalPages && stage == PdfImportStage.extracting;

  /// Prüft, ob ein Fehler aufgetreten ist.
  bool get hasError => error != null;
}

/// Ergebnis der PDF-Textextraktion für eine einzelne Seite.
class PdfPageExtractionResult {
  /// Erstellt ein neues Extraktionsergebnis.
  const PdfPageExtractionResult({
    required this.pageNumber,
    required this.extractedText,
    required this.imageBytes,
  });

  /// Die 1-basierte Seitennummer.
  final int pageNumber;

  /// Der vom LLM extrahierte Text.
  final String extractedText;

  /// Die PNG-Bytes des gerenderten Seitenbilds.
  final Uint8List imageBytes;
}

/// Fortschrittsinformationen während der PDF-Verarbeitung.
class PdfImportProgress {
  /// Erstellt eine neue Fortschrittsinformation.
  const PdfImportProgress({
    required this.currentPage,
    required this.totalPages,
    required this.stage,
  });

  /// Die aktuell verarbeitete Seite (1-basiert).
  final int currentPage;

  /// Die Gesamtanzahl der Seiten.
  final int totalPages;

  /// Die aktuelle Verarbeitungsphase.
  final PdfImportStage stage;

  /// Fortschritt als Prozentsatz (0.0 - 1.0).
  double get progress {
    if (totalPages == 0) return 0.0;
    final double pageProgress = (currentPage - 1) / totalPages;
    final double stageOffset = stage == PdfImportStage.rendering ? 0.0 : 0.5;
    final double stageWeight = 0.5 / totalPages;
    return pageProgress + stageOffset + (stage == PdfImportStage.extracting ? stageWeight : 0);
  }
}

/// Die Verarbeitungsphase während des PDF-Imports.
enum PdfImportStage {
  /// PDF-Seite wird in ein Bild gerendert.
  rendering,

  /// Text wird via LLM aus dem Bild extrahiert.
  extracting,
}

/// Service für den Import von PDFs und die Textextraktion via LLM.
///
/// Dieser Service konvertiert PDF-Seiten sequentiell in Bilder und
/// sendet diese an das Azure OpenAI Vision-Modell zur Textextraktion.
class PdfImportService {
  /// Erstellt eine neue Instanz des PDF-Import-Services.
  ///
  /// [functions] ist die Appwrite Functions Instanz für die Authentifizierung.
  /// [config] ermöglicht die Konfiguration des LLM-Modells (optional).
  PdfImportService({
    required Functions functions,
    PdfExtractionConfig config = const PdfExtractionConfig(),
  })  : _config = config,
        _azureService = AzureAssistantApiService(
          functions: functions,
          azureDeploymentName: config.deploymentName,
          azureResourceName: config.resourceName,
          azureApiVersion: config.apiVersion,
        );

  final AzureAssistantApiService _azureService;
  final PdfExtractionConfig _config;

  /// Die aktuelle Konfiguration.
  PdfExtractionConfig get config => _config;

  /// Der System-Prompt für die PDF-Textextraktion.
  /// Kann überschrieben werden, indem ein benutzerdefinierter Prompt
  /// an [importPdf] übergeben wird.
  static const String defaultExtractionPrompt = '''
Du bist ein präziser OCR-Assistent. Deine Aufgabe ist es, den gesamten sichtbaren Text 
aus dem Bild einer PDF-Seite zu extrahieren und originalgetreu wiederzugeben.

Regeln:
1. Extrahiere NUR den Text, der im Bild sichtbar ist
2. Behalte die Struktur bei (Überschriften, Absätze, Listen)
3. Mathematische Formeln notiere in LaTeX-Syntax (\$...\$ für inline, \$\$...\$\$ für Block)
4. Tabellen formatiere mit Markdown-Syntax
5. Füge KEINE Interpretationen, Zusammenfassungen oder Kommentare hinzu
6. Bei unleserlichem Text schreibe [unleserlich]
7. Behalte die Reihenfolge des Textes bei (oben nach unten, links nach rechts)
''';

  /// Importiert eine PDF-Datei und extrahiert den Text aller Seiten.
  ///
  /// Die Verarbeitung erfolgt sequentiell, um API-Limits zu respektieren.
  /// [pdfBytes] sind die Bytes der PDF-Datei.
  /// [onProgress] wird bei jedem Fortschrittsupdate aufgerufen.
  ///
  /// Gibt eine Liste von [PdfPageExtractionResult] zurück, eine pro Seite.
  Future<List<PdfPageExtractionResult>> importPdf({
    required Uint8List pdfBytes,
    required void Function(PdfImportProgress progress) onProgress,
  }) async {
    debugPrint('[PdfImportService] Opening PDF document...');
    final PdfDocument document = await PdfDocument.openData(pdfBytes);
    final int pageCount = document.pagesCount;
    debugPrint('[PdfImportService] PDF has $pageCount pages');
    final List<PdfPageExtractionResult> results = <PdfPageExtractionResult>[];

    try {
      for (int i = 1; i <= pageCount; i++) {
        debugPrint('[PdfImportService] Processing page $i/$pageCount');
        
        // Phase 1: Seite rendern
        onProgress(PdfImportProgress(
          currentPage: i,
          totalPages: pageCount,
          stage: PdfImportStage.rendering,
        ));

        debugPrint('[PdfImportService] Rendering page $i...');
        final Uint8List imageBytes = await _renderPage(document, i);
        debugPrint('[PdfImportService] Rendered page $i: ${imageBytes.length} bytes');

        // Phase 2: Text extrahieren
        onProgress(PdfImportProgress(
          currentPage: i,
          totalPages: pageCount,
          stage: PdfImportStage.extracting,
        ));

        debugPrint('[PdfImportService] Extracting text from page $i...');
        final String extractedText = await _extractTextFromImage(imageBytes);
        debugPrint('[PdfImportService] Extracted ${extractedText.length} chars from page $i');

        results.add(PdfPageExtractionResult(
          pageNumber: i,
          extractedText: extractedText,
          imageBytes: imageBytes,
        ));
      }
    } finally {
      await document.close();
      debugPrint('[PdfImportService] PDF document closed');
    }

    debugPrint('[PdfImportService] Import complete: ${results.length} pages processed');
    return results;
  }

  /// Rendert eine einzelne PDF-Seite als PNG-Bild.
  Future<Uint8List> _renderPage(PdfDocument document, int pageNumber) async {
    final PdfPage page = await document.getPage(pageNumber);
    
    try {
      // Berechne optimale Auflösung (2x für gute OCR-Qualität)
      const double scale = 2.0;
      final double width = page.width * scale;
      final double height = page.height * scale;

      final PdfPageImage? pageImage = await page.render(
        width: width,
        height: height,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );

      if (pageImage == null) {
        throw Exception('Seite $pageNumber konnte nicht gerendert werden');
      }

      return pageImage.bytes;
    } finally {
      await page.close();
    }
  }

  /// Extrahiert Text aus einem Bild via Azure OpenAI Vision.
  Future<String> _extractTextFromImage(Uint8List imageBytes) async {
    debugPrint('[PdfImportService] Encoding image to base64...');
    final String base64Image = base64Encode(imageBytes);
    debugPrint('[PdfImportService] Base64 length: ${base64Image.length}');

    final List<Map<String, dynamic>> userContent = <Map<String, dynamic>>[
      {
        'type': 'text',
        'text': 'Extrahiere den gesamten Text aus diesem PDF-Seitenbild:',
      },
      {
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/png;base64,$base64Image',
          'detail': 'high',
        },
      },
    ];

    debugPrint('[PdfImportService] Creating Azure request with deployment: ${_config.deploymentName}');
    final AzureAssistantRequest request = AzureAssistantRequest(
      systemPrompt: defaultExtractionPrompt,
      userContent: userContent,
      maxCompletionTokens: _config.maxCompletionTokens,
    );

    final AzureAssistantPreparedRequest preparedRequest =
        _azureService.prepareRequest(request);

    debugPrint('[PdfImportService] Sending request to Azure...');
    try {
      final AzureAssistantResult result = await _azureService.streamCompletion(
        preparedRequest: preparedRequest,
        onStreamUpdate: (text) {
          // Optional: Log streaming progress
        },
      );
      debugPrint('[PdfImportService] Azure response received: ${result.answer.length} chars');
      return result.answer;
    } catch (e, stackTrace) {
      debugPrint('[PdfImportService] Azure API ERROR: $e');
      debugPrint('[PdfImportService] Stack: $stackTrace');
      rethrow;
    }
  }

  /// Prüft, ob der PDF-Import auf der aktuellen Plattform verfügbar ist.
  static bool get isAvailable {
    if (kIsWeb) {
      // Web wird via pdfx mit pdfjs unterstützt
      return true;
    }
    // pdfx unterstützt Android, iOS, macOS, Windows, Linux
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux;
  }
}
