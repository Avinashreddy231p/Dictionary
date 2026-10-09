import 'package:flutter/foundation.dart';

class N8nConfig {
  /// The active n8n environment name ('dev', 'staging', or 'prod').
  static const String environment = String.fromEnvironment(
    'N8N_ENV',
    defaultValue: kReleaseMode ? 'prod' : 'dev',
  );

  /// Default webhook URLs for each flavor environment.
  static const Map<String, String> defaultWebhookUrls = {
    'dev': 'https://dev.n8n.example.com/webhook/dictionary-events',
    'staging': 'https://staging.n8n.example.com/webhook/dictionary-events',
    'prod': 'https://n8n.example.com/webhook/dictionary-events',
  };

  /// The active n8n Webhook URL.
  static String get defaultWebhookUrl {
    const compileTimeUrl = String.fromEnvironment('N8N_WEBHOOK_URL');
    if (compileTimeUrl.isNotEmpty) {
      return compileTimeUrl;
    }
    return defaultWebhookUrls[environment] ?? defaultWebhookUrls['dev']!;
  }
}
