// Appwrite Dart Function: Fordert einen temporären Azure OAuth2-Token an
// und gibt ihn an den Client zurück. Die Azure-Credentials werden über
// Umgebungsvariablen bereitgestellt und NICHT im Code gespeichert.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Appwrite entrypoint
///
/// Erwartet die folgenden Umgebungsvariablen (in Appwrite Funktion setzen):
/// - AZURE_TENANT_ID
/// - AZURE_CLIENT_ID
/// - AZURE_CLIENT_SECRET
///
/// Sicherheit:
/// - Prüft, ob die Anfrage von einem angemeldeten Appwrite-User kommt
///   (Header: `x-appwrite-user-id`).
Future<void> main(dynamic req, dynamic res) async {
	// 1) Secrets aus den Env Vars lesen
	final env = Platform.environment;
	final String? tenantId = env['AZURE_TENANT_ID'];
	final String? clientId = env['AZURE_CLIENT_ID'];
	final String? clientSecret = env['AZURE_CLIENT_SECRET'];

	if (tenantId == null || clientId == null || clientSecret == null) {
		// Log für Server
		stderr.writeln(
			'Azure Credentials fehlen: AZURE_TENANT_ID/CLIENT_ID/CLIENT_SECRET',
		);
		return res.json(
			{
				'success': false,
				'error': 'Server-side configuration error. Missing Azure credentials.',
			},
			statusCode: 500,
		);
	}

	// 2) Nur authentifizierten Benutzern erlauben
		final String? userId = req.headers['x-appwrite-user-id'] as String?;
	if (userId == null || userId.isEmpty) {
		return res.json(
			{
				'success': false,
				'error': 'User not authenticated.',
			},
			statusCode: 401,
		);
	}

	try {
		// 3) Token bei Microsoft anfragen (Client Credentials Flow)
		final Uri tokenUrl = Uri.parse(
			'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token',
		);

		final http.Response response = await http.post(
			tokenUrl,
			headers: const {
				'Content-Type': 'application/x-www-form-urlencoded',
			},
			body: {
				'client_id': clientId,
				'scope': 'https://cognitiveservices.azure.com/.default',
				'client_secret': clientSecret,
				'grant_type': 'client_credentials',
			},
		);

		if (response.statusCode == 200) {
			final Map<String, dynamic> body =
					json.decode(response.body) as Map<String, dynamic>;
			final String? accessToken = body['access_token'] as String?;

			if (accessToken == null || accessToken.isEmpty) {
				stderr.writeln('Azure-Response ohne access_token: ${response.body}');
				return res.json(
					{
						'success': false,
						'error': 'Azure response missing access_token.',
					},
					statusCode: 502,
				);
			}

			return res.json(
				{
					'success': true,
					'accessToken': accessToken,
					// Optional: kurze Ablaufzeit weitergeben, falls vorhanden
					'expiresIn': body['expires_in'],
					'tokenType': body['token_type'],
				},
			);
		}

		// Fehlerfall durchreichen
		stderr.writeln('Azure Token-Fehler (${response.statusCode}): ${response.body}');
		return res.json(
			{
				'success': false,
				'error': 'Failed to retrieve token from Azure.',
				'details': response.body,
			},
			statusCode: response.statusCode,
		);
	} catch (e, st) {
		stderr.writeln('Unerwarteter Fehler bei Token-Anfrage: $e\n$st');
		return res.json(
			{
				'success': false,
				'error': 'An unexpected error occurred.',
			},
			statusCode: 500,
		);
	}
}

