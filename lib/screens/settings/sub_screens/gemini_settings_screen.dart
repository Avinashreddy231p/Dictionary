import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../data/services/gemini_service.dart';
import '../../../theme/app_colors.dart';

class GeminiSettingsScreen extends ConsumerStatefulWidget {
  const GeminiSettingsScreen({super.key});

  @override
  ConsumerState<GeminiSettingsScreen> createState() => _GeminiSettingsScreenState();
}

class _GeminiSettingsScreenState extends ConsumerState<GeminiSettingsScreen> {
  late TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialKey = ref.read(settingsProvider).geminiApiKey;
    _keyController = TextEditingController(text: initialKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showModelSelectionSheet(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    final geminiService = ref.read(geminiServiceProvider);
    final futureModels = geminiService.fetchAvailableModels(apiKey: settings.geminiApiKey);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Supported AI Model',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Live API Models',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<GeminiModelInfo>>(
                  future: futureModels,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final liveModels = snapshot.data ?? [];
                    if (liveModels.isEmpty) {
                      return const Center(
                        child: Text('No supported models found for this API Key.'),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: liveModels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final m = liveModels[index];
                        final isSelected = settings.geminiModel == m.id ||
                            (settings.geminiModel.isEmpty && index == 0);

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(ctx);
                            settingsNotifier.setGeminiModel(m.id);
                            _showFeedback(context, 'Selected model: ${m.name}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.12)
                                  : (isDark ? const Color(0xFF27273C) : AppColors.background),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : (isDark ? const Color(0xFF383852) : AppColors.border),
                                width: isSelected ? 2 : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: isSelected
                                              ? primaryColor
                                              : (isDark ? Colors.white : AppColors.textPrimary),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${m.id} • ${m.description}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    String modelDisplayName = settings.geminiModel.isNotEmpty ? settings.geminiModel : 'gemini-1.5-flash';
    if (modelDisplayName.startsWith('models/')) {
      modelDisplayName = modelDisplayName.substring(7);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Assistant & Gemini Engine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Gemini AI Features',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Power mnemonics, nuances & custom practice sentences',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.geminiAiEnabled,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        settingsNotifier.setGeminiAiEnabled(val);
                        _showFeedback(
                          context,
                          val ? 'Gemini AI Assistant enabled' : 'Gemini AI Assistant disabled',
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (settings.geminiAiEnabled) ...[
                const SizedBox(height: 24),
                Text(
                  'Credentials & Configuration',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Gemini API Key',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Get from Google AI Studio (aistudio.google.com)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _keyController,
                        obscureText: _obscureKey,
                        onChanged: (val) {
                          settingsNotifier.setGeminiApiKey(val.trim());
                        },
                        decoration: InputDecoration(
                          hintText: 'Paste API Key here...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Icon(
                              Icons.vpn_key_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscureKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureKey = !_obscureKey;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.content_paste_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                                onPressed: () async {
                                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                                  if (data != null && data.text != null) {
                                    final text = data.text!.trim();
                                    _keyController.text = text;
                                    settingsNotifier.setGeminiApiKey(text);
                                    if (context.mounted) {
                                      _showFeedback(context, 'Pasted API Key from Clipboard');
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: primaryColor.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                await Clipboard.setData(const ClipboardData(text: 'https://aistudio.google.com/app/api-keys'));
                                if (context.mounted) {
                                  _showFeedback(context, 'Link copied to Clipboard: aistudio.google.com/app/api-keys');
                                }
                              },
                              icon: Icon(Icons.launch_rounded, size: 16, color: primaryColor),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Get API Key',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2C2C40) : const Color(0xFF2C2C3E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                      final key = _keyController.text.trim();
                                      if (key.isEmpty) {
                                        _showFeedback(context, 'Please enter or paste a Gemini API key');
                                        return;
                                      }
                                      setState(() => _isSaving = true);
                                      await settingsNotifier.setGeminiApiKey(key);
                                      final geminiService = ref.read(geminiServiceProvider);
                                      final testResult = await geminiService.testApiKey(key, model: settings.geminiModel);
                                      setState(() => _isSaving = false);
                                      if (context.mounted) {
                                        if (testResult.success) {
                                          final activeModel = testResult.workingModel ?? settings.geminiModel;
                                          if (testResult.workingModel != null && testResult.workingModel != settings.geminiModel) {
                                            await settingsNotifier.setGeminiModel(testResult.workingModel!);
                                          }
                                          if (context.mounted) {
                                            _showFeedback(context, 'Connected successfully to Gemini $activeModel! ✨');
                                          }
                                        } else {
                                          _showFeedback(context, testResult.errorMessage != null ? 'Connection failed: ${testResult.errorMessage}' : 'Key Saved. Connection failed - please check Key.');
                                        }
                                      }
                                    },
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.bolt_rounded, size: 18),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isSaving ? 'Testing...' : 'Test Connection',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      InkWell(
                        onTap: () => _showModelSelectionSheet(context, settings, settingsNotifier, primaryColor, isDark),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF27273C) : AppColors.softYellow.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.science_rounded, color: Colors.amber.shade800, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Model',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to select live supported model.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? primaryColor.withOpacity(0.25) : AppColors.softPurple,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    modelDisplayName,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : primaryColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
