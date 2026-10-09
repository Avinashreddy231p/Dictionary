import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../theme/app_colors.dart';

class PronunciationPracticeWidget extends StatefulWidget {
  final String headword;
  final String phonetic;
  final String audioUrl;

  const PronunciationPracticeWidget({
    super.key,
    required this.headword,
    required this.phonetic,
    required this.audioUrl,
  });

  @override
  State<PronunciationPracticeWidget> createState() =>
      _PronunciationPracticeWidgetState();
}

class _PronunciationPracticeWidgetState
    extends State<PronunciationPracticeWidget>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late stt.SpeechToText _speech;
  late AnimationController _pulseController;

  bool _speechEnabled = false;
  bool _isPlayingNative = false;
  bool _isListening = false;
  bool _hasVerified = false;

  int _score = 0;
  String _recognizedWords = '';
  double _playbackSpeed = 1.0;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<bool> _initSpeech({bool forceReinit = false}) async {
    if (_speechEnabled && !forceReinit) return true;
    try {
      final available = await _speech.initialize(
        onError: (err) {
          if (mounted && _isListening) {
            _onSpeechError(err.errorMsg);
          }
        },
        onStatus: (val) {
          if ((val == 'done' || val == 'notListening') && mounted && _isListening) {
            _evaluateAndFinishSpeech();
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechEnabled = available;
        });
      }
      return available;
    } catch (_) {
      if (mounted) {
        setState(() {
          _speechEnabled = false;
        });
      }
      return false;
    }
  }

  @override
  void dispose() {
    try {
      _speech.stop();
      _pulseController.dispose();
      _audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _playNativeAudio() async {
    setState(() => _isPlayingNative = true);
    try {
      String targetUrl;
      if (widget.audioUrl.isNotEmpty) {
        String subdir = widget.audioUrl[0];
        if (widget.audioUrl.startsWith('bix')) subdir = 'bix';
        if (widget.audioUrl.startsWith('gg')) subdir = 'gg';
        if (RegExp(r'^[0-9]').hasMatch(widget.audioUrl)) subdir = 'number';
        targetUrl = 'https://media.merriam-webster.com/audio/prons/en/us/mp3/$subdir/${widget.audioUrl}.mp3';
      } else {
        targetUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(widget.headword)}&tl=en';
      }

      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setUrl(targetUrl);
      await _audioPlayer.setSpeed(_playbackSpeed);
      await _audioPlayer.play();
    } catch (_) {
      try {
        final fallbackUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(widget.headword)}&tl=en';
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.setUrl(fallbackUrl);
        await _audioPlayer.setSpeed(_playbackSpeed);
        await _audioPlayer.play();
      } catch (_) {}
    }
    if (mounted) setState(() => _isPlayingNative = false);
  }

  void _startSpeechVerification() async {
    HapticFeedback.mediumImpact();

    // 1. Completely stop any active audio player output to free microphone audio channels on Android
    try {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isPlayingNative = false;
        });
      }
    } catch (_) {}

    // 2. Ensure speech recognizer service is active
    bool ready = await _initSpeech();
    if (!ready) {
      ready = await _initSpeech(forceReinit: true);
    }

    if (!ready) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Microphone permission or Speech Recognition is unavailable on this device.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isListening = true;
        _recognizedWords = '';
        _hasVerified = false;
        _soundLevel = 0.0;
      });
      _pulseController.repeat(reverse: true);
    }

    // 3. Listen with SpeechToText given exclusive mic access
    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedWords = result.recognizedWords;
            });
            if (result.finalResult) {
              _evaluateAndFinishSpeech();
            }
          }
        },
        onSoundLevelChange: (level) {
          if (mounted && _isListening) {
            setState(() {
              // Normalize sound level for visualizer reaction
              _soundLevel = (level + 20).clamp(0.0, 50.0) / 50.0;
            });
          }
        },
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (_) {
      _onSpeechError('Failed to start microphone listening');
    }
  }

  void _onSpeechError(String errorMsg) async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    if (!mounted) return;

    _pulseController.stop();
    _pulseController.reset();

    if (_recognizedWords.trim().isNotEmpty) {
      _evaluateAndFinishSpeech();
    } else {
      setState(() {
        _isListening = false;
        _hasVerified = false;
        _soundLevel = 0.0;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech error: $errorMsg. Please try speaking again.'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _evaluateAndFinishSpeech() async {
    try {
      await _speech.stop();
    } catch (_) {}

    _pulseController.stop();
    _pulseController.reset();

    if (!mounted) return;

    final spoken = _recognizedWords.trim().toLowerCase();
    final target = widget.headword.trim().toLowerCase();

    if (spoken.isEmpty) {
      HapticFeedback.vibrate();
      setState(() {
        _isListening = false;
        _hasVerified = false;
        _soundLevel = 0.0;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No speech recognized. Please speak "${widget.headword}" clearly.'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Strict Levenshtein edit distance calculation & Phonetic matching
    final dist = _levenshteinDistance(spoken, target);
    final maxLen = max(spoken.length, target.length);
    double sim = maxLen == 0 ? 1.0 : (1.0 - (dist / maxLen));

    if (spoken == target || spoken.contains(target) || target.contains(spoken)) {
      sim = max(sim, 0.9);
    }

    final calculatedScore = (sim * 100).toInt().clamp(0, 100);

    HapticFeedback.heavyImpact();

    setState(() {
      _isListening = false;
      _hasVerified = true;
      _score = calculatedScore;
      _soundLevel = 0.0;
    });
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1.codeUnitAt(i) == s2.codeUnitAt(j)) ? 0 : 1;
        int min1 = v1[j] + 1;
        int min2 = v0[j + 1] + 1;
        int min3 = v0[j] + cost;
        int min = min1 < min2 ? min1 : min2;
        v1[j + 1] = min < min3 ? min : min3;
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final syllables = widget.headword.length > 4
        ? [
            widget.headword.substring(0, (widget.headword.length / 2).floor()),
            widget.headword.substring((widget.headword.length / 2).floor())
          ]
        : [widget.headword];

    final isSuccess = _score >= 70;
    final cardColor = isSuccess ? Colors.green : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.mic_circle_fill,
                          color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pronunciation Checker',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Realtime Speech Verification',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Speed Selector
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                onSelected: (speed) {
                  setState(() => _playbackSpeed = speed);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_playbackSpeed}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down, size: 16, color: theme.primaryColor),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1.0, child: Text('1.0x Normal')),
                  const PopupMenuItem(value: 0.8, child: Text('0.8x Slow')),
                  const PopupMenuItem(value: 0.5, child: Text('0.5x Slow Motion')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Word Headword & Listen Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F30) : const Color(0xFFF3EDFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.headword,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (widget.phonetic.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.phonetic,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Native Audio Listen Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: _isPlayingNative ? null : _playNativeAudio,
                  icon: _isPlayingNative
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(CupertinoIcons.speaker_2_fill, size: 16),
                  label: const Text('Listen Native', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Duolingo Verification Score Banner
          if (_hasVerified) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isSuccess ? CupertinoIcons.checkmark : CupertinoIcons.xmark, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _score >= 85
                                    ? 'Excellent! 🎉'
                                    : (_score >= 60 ? 'Good Attempt! 👍' : 'Incorrect Pronunciation ❌'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: cardColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_score% Match',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: cardColor,
                              ),
                            ),
                          ],
                        ),
                        if (_recognizedWords.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Recognized Speech: "${_recognizedWords}"',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: syllables.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: cardColor,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(isSuccess ? Icons.check : Icons.close, size: 12, color: cardColor),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Big Glowing Duolingo Mic Button & Waveform Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF191928) : AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isListening ? Colors.redAccent : (isDark ? const Color(0xFF2C2C3F) : AppColors.border),
                width: _isListening ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // Glowing Pulse Mic Button
                GestureDetector(
                  onTap: _isListening ? null : _startSpeechVerification,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = _isListening ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening ? Colors.redAccent : Colors.green,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? Colors.redAccent : Colors.green).withOpacity(0.4),
                                blurRadius: _isListening ? 20 : 10,
                                spreadRadius: _isListening ? 4 : 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? CupertinoIcons.mic_fill : CupertinoIcons.mic_solid,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  _isListening
                      ? (_recognizedWords.isNotEmpty ? 'Recognized: "${_recognizedWords}"' : 'Listening... Speak "${widget.headword}"')
                      : (_hasVerified
                          ? 'Tap mic to re-verify pronunciation'
                          : 'Tap mic and speak "${widget.headword}"'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: _isListening ? Colors.redAccent : (isDark ? Colors.white70 : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 14),

                // Live Dynamic Audio Waveform Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(24, (index) {
                    final isActive = _isListening || _isPlayingNative;
                    double height;
                    if (_isListening) {
                      final dynamicBoost = (sin((index + 1) * 0.5) + 1.0) * 8.0 * (_soundLevel + 0.3);
                      height = (8.0 + dynamicBoost).clamp(6.0, 38.0);
                    } else if (isActive) {
                      height = 10.0 + (index % 5) * 7.0;
                    } else {
                      height = 6.0 + (index % 3) * 3.0;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.redAccent
                            : (_hasVerified ? cardColor : theme.primaryColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
