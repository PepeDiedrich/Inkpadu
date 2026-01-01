import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';

/// Konfiguration für das PDF-Extraktions-LLM.
class PdfExtractionConfig {
  /// Erstellt eine neue Konfiguration.
  /// 
  /// [maxCompletionTokens] ist auf 16384 gesetzt, um auch sehr textreiche
  /// PDF-Seiten vollständig extrahieren zu können, ohne dass die Antwort
  /// abgeschnitten wird.
  const PdfExtractionConfig({
    this.deploymentName = defaultDeploymentName,
    this.resourceName = defaultResourceName,
    this.apiVersion = defaultApiVersion,
    this.maxCompletionTokens = 16384,
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
    this.parsedTasks,
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

  /// Die erkannten Aufgaben (nur bei stage == parsingTasks und Abschluss).
  final List<String>? parsedTasks;

  /// Fehlermeldung, falls aufgetreten.
  final String? error;

  /// Prüft, ob die Verarbeitung abgeschlossen ist.
  bool get isComplete => stage == PdfImportStage.parsingTasks && parsedTasks != null;

  /// Prüft, ob ein Fehler aufgetreten ist.
  bool get hasError => error != null;
}

/// Ergebnis der PDF-Textextraktion für eine einzelne Seite.
class PdfPageExtractionResult {
  /// Erstellt ein neues Extraktionsergebnis.
  const PdfPageExtractionResult({
    required this.pageNumber,
    required this.extractedText,
  });

  /// Die 1-basierte Seitennummer.
  final int pageNumber;

  /// Der vom LLM extrahierte Text.
  final String extractedText;
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
    // 80% für Rendering + Extraktion, 20% für Aufgaben-Parsing
    final double pageProgress = (currentPage - 1) / totalPages;
    final double stageOffset = stage == PdfImportStage.rendering ? 0.0 : 0.4;
    final double stageWeight = 0.4 / totalPages;
    if (stage == PdfImportStage.parsingTasks) {
      return 0.8 + 0.2; // 100% wenn parsingTasks erreicht
    }
    return (pageProgress + stageOffset + (stage == PdfImportStage.extracting ? stageWeight : 0)) * 0.8;
  }
}

/// Die Verarbeitungsphase während des PDF-Imports.
enum PdfImportStage {
  /// PDF-Seite wird in ein Bild gerendert.
  rendering,

  /// Text wird via LLM aus dem Bild extrahiert.
  extracting,

  /// Aufgaben werden aus dem extrahierten Text erkannt.
  parsingTasks,
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

  /// Der System-Prompt für die Aufgaben-Erkennung aus extrahiertem PDF-Text.
  static const String taskExtractionPrompt = '''
Du bist ein Assistent zur Erkennung von Aufgaben in Dokumenten. Deine Aufgabe ist es,
einzelne Aufgaben aus dem gegebenen Text zu identifizieren und als JSON-Array zurückzugeben.

Erkenne Aufgaben anhand typischer Muster:
- Nummerierte Aufgaben: "1.", "2.", "1)", "2)", "a)", "b)", "i.", "ii."
- Schlüsselwörter: "Aufgabe", "Exercise", "Problem", "Übung", "Frage", "Question", "Task"
- Aufzählungszeichen mit Inhalt: "•", "-", "*" gefolgt von einer Aufgabenstellung

Regeln:
1. Gib NUR ein valides JSON-Array zurück, keine anderen Texte
2. Jedes Array-Element ist der vollständige Text EINER Aufgabe (inkl. Teilaufgaben)
3. Behalte mathematische Formeln in LaTeX-Syntax
4. Wenn keine Aufgaben erkannt werden, gib ein leeres Array zurück: []
5. Fasse zusammengehörige Teilaufgaben (a, b, c) unter der Hauptaufgabe zusammen
6. Entferne Seitenzahlen, Kopf-/Fußzeilen und irrelevante Metadaten

Beispiel-Ausgabe:
["Aufgabe 1: Berechne den Wert von x^2 + 2x - 3 = 0", "Aufgabe 2: a) Zeichne den Graphen b) Bestimme die Nullstellen"]
''';

  /// Importiert eine PDF-Datei und extrahiert den Text aller Seiten.
  ///
  /// Die Verarbeitung erfolgt in Batches, um API-Limits zu respektieren und
  /// gleichzeitig die Geschwindigkeit durch parallele Extraktion zu erhöhen.
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
    final int pageCount = document.pages.length;
    debugPrint('[PdfImportService] PDF has $pageCount pages');
    final List<PdfPageExtractionResult> results = <PdfPageExtractionResult>[];

    try {
      // Batch-Größe für parallele Extraktion
      const int batchSize = 4;

      for (int i = 1; i <= pageCount; i += batchSize) {
        final int end = (i + batchSize - 1).clamp(1, pageCount);
        debugPrint('[PdfImportService] Processing batch: pages $i to $end');

        // 1. Render images for the batch (Sequentially to be safe with PDF plugin)
        final Map<int, Uint8List> batchImages = {};
        for (int pageNum = i; pageNum <= end; pageNum++) {
          onProgress(PdfImportProgress(
            currentPage: pageNum,
            totalPages: pageCount,
            stage: PdfImportStage.rendering,
          ));

          debugPrint('[PdfImportService] Rendering page $pageNum...');
          batchImages[pageNum] = await _renderPage(document, pageNum);
        }

        // 2. Extract text for the batch (Parallel)
        final List<Future<PdfPageExtractionResult>> extractionFutures = [];
        for (int pageNum = i; pageNum <= end; pageNum++) {
          extractionFutures.add(() async {
            onProgress(PdfImportProgress(
              currentPage: pageNum,
              totalPages: pageCount,
              stage: PdfImportStage.extracting,
            ));

            debugPrint('[PdfImportService] Extracting text from page $pageNum...');
            final String extractedText = await _extractTextFromImage(batchImages[pageNum]!);
            debugPrint('[PdfImportService] Extracted ${extractedText.length} chars from page $pageNum');

            return PdfPageExtractionResult(
              pageNumber: pageNum,
              extractedText: extractedText,
            );
          }());
        }

        // Wait for all extractions in this batch to complete
        final List<PdfPageExtractionResult> batchResults = await Future.wait(extractionFutures);
        results.addAll(batchResults);
      }
    } finally {
      await document.dispose();
      debugPrint('[PdfImportService] PDF document closed');
    }

    debugPrint('[PdfImportService] Import complete: ${results.length} pages processed');
    return results;
  }

  /// Rendert eine einzelne PDF-Seite als PNG-Bild.
  Future<Uint8List> _renderPage(PdfDocument document, int pageNumber) async {
    final PdfPage page = document.pages[pageNumber - 1];
    
    try {
      // Berechne optimale Auflösung (2x für gute OCR-Qualität)
      const double scale = 2.0;
      final double width = page.width * scale;
      final double height = page.height * scale;

      final image = await page.render(
        width: width.toInt(),
        height: height.toInt(),
        backgroundColor: 0xFFFFFFFF,
      );

      if (image == null) {
        throw Exception('Seite $pageNumber konnte nicht gerendert werden');
      }

      // Konvertiere Raw-Pixel (BGRA) zu PNG
      final img.Image pImage = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: image.pixels.buffer,
        numChannels: 4,
        order: img.ChannelOrder.bgra,
      );

      // Encode to PNG
      return img.encodePng(pImage);
    } finally {
      // page.dispose(); // pdfrx pages don't need explicit dispose usually
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
      reasoningEffort: 'low',
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
      return true;
    }
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux;
  }

  /// Extrahiert einzelne Aufgaben aus dem kombinierten PDF-Text via Azure OpenAI.
  ///
  /// Bei API-Fehlern wird automatisch auf Regex-basiertes Parsing zurückgefallen.
  /// Gibt eine Liste von Aufgaben-Strings zurück. Bei leerer Liste oder Fehler
  /// wird der gesamte Text als einzelne "Aufgabe" zurückgegeben.
  Future<List<String>> extractTasksFromText(String combinedText) async {
    if (combinedText.trim().isEmpty) {
      return <String>[];
    }

    debugPrint('[PdfImportService] Extracting tasks from ${combinedText.length} chars...');

    try {
      final List<Map<String, dynamic>> userContent = <Map<String, dynamic>>[
        {
          'type': 'text',
          'text': 'Extrahiere alle Aufgaben aus dem folgenden Text und gib sie als JSON-Array zurück:\n\n$combinedText',
        },
      ];

      final AzureAssistantRequest request = AzureAssistantRequest(
        systemPrompt: taskExtractionPrompt,
        userContent: userContent,
        maxCompletionTokens: _config.maxCompletionTokens,
        reasoningEffort: 'low',
      );

      final AzureAssistantPreparedRequest preparedRequest =
          _azureService.prepareRequest(request);

      final AzureAssistantResult result = await _azureService.streamCompletion(
        preparedRequest: preparedRequest,
        onStreamUpdate: (_) {},
      );

      debugPrint('[PdfImportService] Task extraction response: ${result.answer.length} chars');

      // Parse JSON-Array aus der Antwort
      final List<String> tasks = _parseTasksFromJson(result.answer);
      
      if (tasks.isNotEmpty) {
        debugPrint('[PdfImportService] Azure extracted ${tasks.length} tasks');
        return tasks;
      }

      // Fallback auf Regex wenn keine Aufgaben erkannt wurden
      debugPrint('[PdfImportService] No tasks from Azure, trying regex fallback...');
      return _extractTasksWithRegex(combinedText);
    } catch (e, stackTrace) {
      debugPrint('[PdfImportService] Task extraction ERROR: $e');
      debugPrint('[PdfImportService] Stack: $stackTrace');
      
      // Fallback auf Regex bei API-Fehler
      debugPrint('[PdfImportService] Using regex fallback due to error...');
      return _extractTasksWithRegex(combinedText);
    }
  }

  /// Parst ein JSON-Array aus der Azure-Antwort.
  List<String> _parseTasksFromJson(String response) {
    try {
      // Versuche zuerst, die Antwort direkt als JSON zu parsen
      String jsonString = response.trim();
      
      // Entferne mögliche Markdown-Code-Blöcke
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      } else if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      // Finde das JSON-Array in der Antwort
      final int startIndex = jsonString.indexOf('[');
      final int endIndex = jsonString.lastIndexOf(']');
      
      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        debugPrint('[PdfImportService] No valid JSON array found in response');
        return <String>[];
      }

      jsonString = jsonString.substring(startIndex, endIndex + 1);
      
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }
      
      return <String>[];
    } catch (e) {
      debugPrint('[PdfImportService] JSON parsing error: $e');
      return <String>[];
    }
  }

  /// Regex-basierter Fallback für Aufgaben-Erkennung.
  ///
  /// Erkennt typische Aufgaben-Muster wie:
  /// - "Aufgabe 1:", "Aufgabe 1.", "Aufgabe 1)"
  /// - "1.", "2.", "1)", "2)"
  /// - "a)", "b)", "a.", "b."
  /// - "Exercise", "Problem", "Übung", "Frage"
  List<String> _extractTasksWithRegex(String text) {
    debugPrint('[PdfImportService] Extracting tasks with regex...');
    
    final List<String> tasks = <String>[];

    // Vereinfachter Ansatz: Splitte nach Aufgaben-Markern
    final RegExp markerPattern = RegExp(
      r'(?:^|\n)' // Zeilenanfang
      r'\s*'
      r'(?:'
        r'(?:Aufgabe|Exercise|Problem|Übung|Frage|Question|Task)\s*[:\.]?\s*\d*[:\.]?\s*' // Keyword
        r'|'
        r'\d+\s*[.):]\s+' // Nummerierung
      r')',
      multiLine: true,
      caseSensitive: false,
    );

    final Iterable<RegExpMatch> matches = markerPattern.allMatches(text);
    final List<int> positions = matches.map((m) => m.start).toList();
    
    if (positions.isEmpty) {
      // Keine Aufgaben-Marker gefunden - gesamten Text als eine Aufgabe zurückgeben
      final String trimmed = text.trim();
      if (trimmed.isNotEmpty) {
        debugPrint('[PdfImportService] No task markers found, returning full text as single task');
        return <String>[trimmed];
      }
      return <String>[];
    }

    // Extrahiere Text zwischen den Markern
    for (int i = 0; i < positions.length; i++) {
      final int start = positions[i];
      final int end = i + 1 < positions.length ? positions[i + 1] : text.length;
      
      String taskText = text.substring(start, end).trim();
      
      // Entferne führende Whitespace nach Zeilenumbrüchen
      taskText = taskText.replaceAll(RegExp(r'\n\s+'), '\n');
      
      if (taskText.isNotEmpty) {
        tasks.add(taskText);
      }
    }

    debugPrint('[PdfImportService] Regex extracted ${tasks.length} tasks');
    return tasks;
  }
}
