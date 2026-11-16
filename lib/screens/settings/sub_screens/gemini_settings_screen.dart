import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/services/gemini_service.dart';
import '../../../data/services/on_device_ai_service.dart';
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

  void _showLocalModelSelectionSheet(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    final onDeviceAi = ref.read(onDeviceAiServiceProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    'Select On-Device Model',
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
                      'LiteRT-LM',
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
                child: FutureBuilder<Map<String, bool>>(
                  future: onDeviceAi.getInstalledModelsStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final statusMap = snapshot.data ?? {};

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: OnDeviceAiService.availableModels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final m = OnDeviceAiService.availableModels[index];
                        final isSelected = settings.onDeviceModel == m.id ||
                            (settings.onDeviceModel.isEmpty && index == 0);
                        final isDownloaded = statusMap[m.id] == true;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(ctx);
                            settingsNotifier.setOnDeviceModel(m.id);
                            _showFeedback(context, 'Selected local model: ${m.name}');
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              m.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                                color: isSelected
                                                    ? primaryColor
                                                    : (isDark ? Colors.white : AppColors.textPrimary),
                                              ),
                                            ),
                                          ),
                                          if (isDownloaded)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              margin: const EdgeInsets.only(left: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Downloaded',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        m.sizeDescription,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        m.recommendedHardware,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white54 : AppColors.textSecondary.withOpacity(0.8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
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
                  'AI Execution Strategy',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildModeOption(
                        context: context,
                        title: '⚡ Hybrid Auto (Recommended)',
                        subtitle: 'Local SQLite (1ms) → On-Device AI (100ms) → Cloud Gemini (400ms)',
                        value: 'hybrid_auto',
                        groupValue: settings.aiProviderMode,
                        onChanged: (val) => settingsNotifier.setAiProviderMode(val!),
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildModeOption(
                        context: context,
                        title: '📱 On-Device LiteRT-LM (100% Offline)',
                        subtitle: 'Runs local Gemma / Qwen AI models directly on your hardware',
                        value: 'on_device',
                        groupValue: settings.aiProviderMode,
                        onChanged: (val) => settingsNotifier.setAiProviderMode(val!),
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildModeOption(
                        context: context,
                        title: '☁️ Cloud Gemini API',
                        subtitle: 'Uses Google AI Studio cloud API key',
                        value: 'cloud_gemini',
                        groupValue: settings.aiProviderMode,
                        onChanged: (val) => settingsNotifier.setAiProviderMode(val!),
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                if (settings.aiProviderMode != 'cloud_gemini') ...[
                  const SizedBox(height: 24),
                  Text(
                    'On-Device Model Downloader (LiteRT-LM)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildOnDeviceModelDownloader(context, settings, settingsNotifier, primaryColor, isDark),
                  const SizedBox(height: 24),
                  Text(
                    'Offline Concept Search (Embeddings)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEmbeddingModelDownloader(context, settings, settingsNotifier, primaryColor, isDark),
                ],
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

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required Color primaryColor,
    required bool isDark,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : (isDark ? const Color(0xFF27273C) : AppColors.background),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? const Color(0xFF383852) : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnDeviceModelDownloader(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    final onDeviceAi = ref.watch(onDeviceAiServiceProvider);

    return Container(
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
          Row(
            children: [
              Icon(Icons.download_for_offline_rounded, color: primaryColor, size: 24),
              const SizedBox(width: 10),
              Text(
                'On-Device LLM Model',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showLocalModelSelectionSheet(context, settings, settingsNotifier, primaryColor, isDark),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27273C) : AppColors.softYellow.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.memory_rounded, color: Colors.amber.shade800, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Local Model',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to choose a local offline AI.',
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
                        OnDeviceAiService.availableModels.firstWhere(
                          (m) => m.id == settings.onDeviceModel,
                          orElse: () => OnDeviceAiService.availableModels.first,
                        ).name.split(' (')[0], // Only show short name
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
          const SizedBox(height: 24),
          FutureBuilder<bool>(
            future: onDeviceAi.isModelReady(settings.onDeviceModel),
            builder: (context, snapshot) {
              final isReady = snapshot.data ?? false;
              final isThisModelDownloading = onDeviceAi.isDownloading && 
                  (onDeviceAi.downloadStatusText == null || !onDeviceAi.downloadStatusText!.contains('embedding'));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isReady && !isThisModelDownloading) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${OnDeviceAiService.availableModels.firstWhere((m) => m.id == settings.onDeviceModel, orElse: () => OnDeviceAiService.availableModels.first).name.split(' (')[0]} Installed & Ready',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(CupertinoIcons.trash, size: 16, color: Colors.red),
                            onPressed: () async {
                              final activeModelId = OnDeviceAiService.availableModels.any((m) => m.id == settings.onDeviceModel)
                                  ? settings.onDeviceModel
                                  : OnDeviceAiService.availableModels.first.id;
                              
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Delete Model?'),
                                  content: const Text('Are you sure you want to delete this AI model from your device storage?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true), 
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                if (mounted) setState(() {});
                                await onDeviceAi.deleteModel(activeModelId);
                                if (context.mounted) {
                                  if (mounted) setState(() {});
                                  _showFeedback(context, 'Model deleted from device storage.');
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                  if (isThisModelDownloading) ...[
                    LinearProgressIndicator(
                      value: onDeviceAi.downloadProgress,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      color: primaryColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      onDeviceAi.downloadStatusText ?? 'Downloading model...',
                      style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReady ? Colors.green.shade700 : primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        setState(() {});
                        final activeModelId = OnDeviceAiService.availableModels.any((m) => m.id == settings.onDeviceModel)
                            ? settings.onDeviceModel
                            : OnDeviceAiService.availableModels.first.id;
                        final success = await onDeviceAi.installModel(
                          modelId: activeModelId,
                          onProgress: (progress, status) {
                            if (mounted) setState(() {});
                          },
                        );
                        if (context.mounted) {
                          if (mounted) setState(() {});
                          _showFeedback(
                            context,
                            success
                                ? 'Model ready for On-Device AI inference! 🎉'
                                : (onDeviceAi.downloadStatusText ?? 'Model download failed. Please retry.'),
                          );
                        }
                      },
                      icon: Icon(isReady ? Icons.check_circle_outline_rounded : Icons.cloud_download_rounded, size: 20),
                      label: Text(
                        isReady ? '✓ Re-download Model' : 'Download & Prepare Model',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddingModelDownloader(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    final onDeviceAi = ref.watch(onDeviceAiServiceProvider);
    final modelId = OnDeviceAiService.availableEmbeddingModels.first.id;
    final modelName = OnDeviceAiService.availableEmbeddingModels.first.name;
    final modelSize = OnDeviceAiService.availableEmbeddingModels.first.sizeDescription;

    return Container(
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
          Row(
            children: [
              Icon(Icons.search_rounded, color: primaryColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Semantic Search Engine',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Required to search your saved vocabulary by meaning/concept instead of exact spelling.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27273C) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.memory_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$modelName ($modelSize)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: onDeviceAi.isEmbeddingModelReady(modelId),
            builder: (context, snapshot) {
              final isReady = snapshot.data ?? false;

              if (onDeviceAi.isDownloading && onDeviceAi.downloadStatusText != null && onDeviceAi.downloadStatusText!.contains('embedding')) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: onDeviceAi.downloadProgress,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      color: primaryColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      onDeviceAi.downloadStatusText ?? 'Downloading...',
                      style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                );
              }

              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReady ? Colors.green.shade700 : primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (mounted) setState(() {});
                  final success = await onDeviceAi.installEmbeddingModel(
                    modelId: modelId,
                    onProgress: (progress, status) {
                      if (mounted) setState(() {});
                    },
                  );
                  if (context.mounted) {
                    if (mounted) setState(() {});
                    _showFeedback(
                      context,
                      success
                          ? 'Semantic Search Engine is ready! 🎉'
                          : (onDeviceAi.downloadStatusText ?? 'Download failed. Please retry.'),
                    );
                  }
                },
                icon: Icon(isReady ? Icons.check_circle_outline_rounded : Icons.cloud_download_rounded, size: 20),
                label: Text(
                  isReady ? '✓ Search Engine Ready (Re-download)' : 'Download Search Engine',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

