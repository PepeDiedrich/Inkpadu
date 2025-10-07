# Appwrite Function: LLM Auth (Azure Token)

Diese Dart-Funktion läuft in Appwrite Functions und erstellt einen kurzlebigen OAuth2-Token für Azure Cognitive Services (OpenAI).

## Environment Variablen (in Appwrite setzen)
- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`

Die Funktion prüft, ob die anfragende Person authentifiziert ist (`x-appwrite-user-id`).

## Rückgabe
```json
{
  "success": true,
  "accessToken": "<bearer-token>",
  "expiresIn": 3599,
  "tokenType": "Bearer"
}
```

## Hinweise
- Scope: `https://cognitiveservices.azure.com/.default`
- Nur für angemeldete Nutzer:innen ausführbar machen.
- Verwende diese Funktion in der Flutter-App mit Appwrite Functions `createExecution`.
