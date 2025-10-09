// Shared Azure token retrieval logic for the Appwrite function.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Handles the Azure OAuth2 token request and builds the Appwrite response.
Future<dynamic> handleRequest(dynamic context) async {
	final dynamic req = _contextMember(context, 'req');
	final dynamic res = _contextMember(context, 'res');

	if (req == null || res == null) {
		stderr.writeln('Appwrite RuntimeContext ohne req/res erhalten: $context');
		return {
			'success': false,
			'error': 'Invalid runtime context: missing request/response objects.',
		};
	}

	final env = Platform.environment;
	final String? tenantId = env['AZURE_TENANT_ID'];
	final String? clientId = env['AZURE_CLIENT_ID'];
	final String? clientSecret = env['AZURE_CLIENT_SECRET'];

	if (tenantId == null || clientId == null || clientSecret == null) {
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
					'expiresIn': body['expires_in'],
					'tokenType': body['token_type'],
				},
			);
		}

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

dynamic _contextMember(dynamic context, String key) {
	if (context == null) {
		return null;
	}

	if (context is Map) {
		return context[key];
	}

	try {
		switch (key) {
			case 'req':
				return context.req;
			case 'res':
				return context.res;
		}
	} catch (_) {
		// Ignorieren, wir probieren unten weiter
	}

	return null;
}
