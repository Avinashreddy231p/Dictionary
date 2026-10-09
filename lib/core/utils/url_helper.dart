import 'package:url_launcher/url_launcher.dart';

Future<void> launchGoogleDefinition(String word) async {
  final cleanWord = word.trim();
  if (cleanWord.isEmpty) return;

  final url = Uri.parse('https://www.google.com/search?q=meaning+of+${Uri.encodeComponent(cleanWord)}');
  try {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  } catch (_) {
    try {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (_) {}
  }
}
