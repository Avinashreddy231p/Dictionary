import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LegalTermsScreen extends StatefulWidget {
  final int initialTabIndex; // 0 for Privacy Policy, 1 for Terms of Service

  const LegalTermsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalTermsScreen> createState() => _LegalTermsScreenState();
}

class _LegalTermsScreenState extends State<LegalTermsScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textColor = isDark ? const Color(0xFFD0CAEF) : AppColors.textSecondary;
    final unselectedTabColor = isDark ? const Color(0xFFA6B0C3) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedTab == 0 ? 'Privacy Policy' : 'Terms of Service',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Segmented Control Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1B2A) : const Color(0xFFEFEFF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C40) : const Color(0xFFE2E2E8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark ? const Color(0xFF2E2C44) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: _selectedTab == 0
                                    ? primaryColor
                                    : unselectedTabColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark ? const Color(0xFF2E2C44) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: _selectedTab == 1
                                    ? primaryColor
                                    : unselectedTabColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _selectedTab == 0
                    ? _buildPrivacyPolicy(context, isDark, primaryColor, titleColor, textColor)
                    : _buildTermsOfService(context, isDark, primaryColor, titleColor, textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy(
      BuildContext context, bool isDark, Color primaryColor, Color titleColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(
          icon: CupertinoIcons.shield_fill,
          title: 'Privacy First Architecture',
          subtitle:
              'Last updated: May 2025 • Your vocabulary history, search queries, and learning metrics are stored locally on your device.',
          isDark: isDark,
          primaryColor: primaryColor,
          titleColor: titleColor,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('1. Information We Collect', titleColor),
        _buildParagraph(
          'Dictionary is designed as a local-first application. We prioritize your privacy and minimize data transmission.',
          textColor,
        ),
        _buildBulletPoint('Local Database:', 'Your saved words, custom collections, quiz scores, and search history are stored directly in your device’s SQLite storage.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Voice Input & Audio:', 'When using voice search or pronunciation practice, audio is processed transiently on your device or via platform speech recognition APIs. Audio recordings are never saved to our servers.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Optional AI Features:', 'When AI mnemonics or nuance breakdowns are enabled, the specific word query is transmitted securely to Google Gemini API to generate smart explanations.', primaryColor, titleColor, textColor),
        
        const SizedBox(height: 24),
        _buildSectionTitle('2. How Your Data Is Used', titleColor),
        _buildParagraph(
          'We use locally stored information strictly to deliver core dictionary features, track your learning streaks, and render custom theme preferences.',
          textColor,
        ),
        _buildBulletPoint('Zero Third-Party Selling:', 'We never sell, trade, or monetize your search history or personal vocabulary data.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Analytics & Crash Diagnostics:', 'Non-identifiable error logs may be generated locally to assist in troubleshooting application bugs.', primaryColor, titleColor, textColor),

        const SizedBox(height: 24),
        _buildSectionTitle('3. Device Permissions', titleColor),
        _buildParagraph('Dictionary requests device permissions solely to support user-initiated actions:', textColor),
        _buildBulletPoint('Microphone:', 'Enables voice search and speech pronunciation scoring.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Network & Internet:', 'Required to fetch definitions from Merriam-Webster, Datamuse, and optional Gemini AI endpoints.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Bluetooth:', 'Enables wireless audio playback for word pronunciations.', primaryColor, titleColor, textColor),

        const SizedBox(height: 24),
        _buildSectionTitle('4. Your Rights & Control', titleColor),
        _buildParagraph(
          'You retain total ownership of your dictionary data. You can export your saved vocabulary to Anki CSV format or permanently wipe all local history at any time from Settings → Storage & Data.',
          textColor,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTermsOfService(
      BuildContext context, bool isDark, Color primaryColor, Color titleColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(
          icon: CupertinoIcons.doc_plaintext,
          title: 'Terms of Service',
          subtitle:
              'Effective Date: May 2025 • Please read these terms carefully before using the Dictionary application.',
          isDark: isDark,
          primaryColor: primaryColor,
          titleColor: titleColor,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('1. Acceptance of Terms', titleColor),
        _buildParagraph(
          'By downloading, installing, or accessing the Dictionary application, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, please discontinue use of the app.',
          textColor,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('2. License & Intellectual Property', titleColor),
        _buildParagraph(
          'Dictionary grants you a revocable, non-exclusive, non-transferable, limited license to download and use the application strictly for personal, non-commercial educational purposes in accordance with these terms.',
          textColor,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('3. Dictionary Content & Linguistic Data', titleColor),
        _buildParagraph(
          'Linguistic definitions, phonetics, and etymologies are sourced from verified open databases (including Merriam-Webster and Datamuse). While we strive for maximum accuracy, dictionary entries are provided "as is" for general educational and reference purposes.',
          textColor,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('4. User Conduct & Acceptable Use', titleColor),
        _buildBulletPoint('Fair Usage:', 'You agree not to exploit dictionary APIs, automated scraping, or perform actions that disrupt service availability for others.', primaryColor, titleColor, textColor),
        _buildBulletPoint('Custom Content:', 'You are responsible for any custom notes or custom word lists you create within the app.', primaryColor, titleColor, textColor),

        const SizedBox(height: 24),
        _buildSectionTitle('5. Disclaimer of Liability', titleColor),
        _buildParagraph(
          'To the maximum extent permitted by applicable law, Dictionary and its developers shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use the application or dictionary databases.',
          textColor,
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('6. Modifications to Terms', titleColor),
        _buildParagraph(
          'We reserve the right to update or modify these Terms of Service at any time to reflect software enhancements or legal updates. Continued use of the app constitutes acceptance of revised terms.',
          textColor,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeaderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color primaryColor,
    required Color titleColor,
  }) {
    final subtitleColor = isDark ? const Color(0xFFC2BAE8) : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C42) : const Color(0xFFEBEBF0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: titleColor,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String label, String detail, Color primaryColor, Color titleColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: textColor, height: 1.45),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: TextStyle(fontWeight: FontWeight.w800, color: titleColor),
                  ),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
