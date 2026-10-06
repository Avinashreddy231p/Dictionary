import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  late stt.SpeechToText _speech;
  late AnimationController _pulseController;

  bool _speechEnabled = false;
  bool _isPlayingNative = false;
  bool _isListening = false;
  bool _hasVerified = false;
  bool _isPlayingUser = false;

  int _score = 0;
  String _recognizedWords = '';
  String? _userAudioPath;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (err) {
          if (mounted && _isListening) {
            _evaluateAndFinishSpeech();
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
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _speech.stop();
      _audioRecorder.dispose();
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

    // 1. Request Android OS Runtime Microphone Permission
    bool hasPermission = false;
    try {
      hasPermission = await _audioRecorder.hasPermission();
    } catch (_) {}

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required. Please grant microphone access.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 2. Initialize Speech Recognizer
    if (!_speechEnabled) {
      final available = await _speech.initialize();
      _speechEnabled = available;
    }

    try {
      final docDir = await getApplicationDocumentsDirectory();
      _userAudioPath = '${docDir.path}/user_voice_${widget.headword.toLowerCase()}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _userAudioPath!,
      );
    } catch (_) {}

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _hasVerified = false;
    });

    if (_speechEnabled) {
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
          listenFor: const Duration(seconds: 6),
          pauseFor: const Duration(seconds: 2),
          localeId: 'en_US',
        );
      } catch (_) {}
    }
  }

  void _evaluateAndFinishSpeech() async {
    try {
      await _speech.stop();
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (_) {}

    if (!mounted) return;

    final spoken = _recognizedWords.trim().toLowerCase();
    final target = widget.headword.trim().toLowerCase();

    if (spoken.isEmpty) {
      // Strict microphone check: No speech detected from device microphone
      HapticFeedback.vibrate();
      setState(() {
        _isListening = false;
        _hasVerified = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No microphone speech detected. Please speak "${widget.headword}" clearly.'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Strict Levenshtein edit distance accuracy score calculation
    final dist = _levenshteinDistance(spoken, target);
    final maxLen = max(spoken.length, target.length);
    double sim = maxLen == 0 ? 1.0 : (1.0 - (dist / maxLen));

    if (spoken.contains(target) || target.contains(spoken)) {
      sim = max(sim, 0.85);
    }

    final calculatedScore = (sim * 100).toInt().clamp(10, 100);

    HapticFeedback.heavyImpact();

    setState(() {
      _isListening = false;
      _hasVerified = true;
      _score = calculatedScore;
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

  void _playUserAudio() async {
    setState(() => _isPlayingUser = true);
    try {
      if (_userAudioPath != null && await File(_userAudioPath!).exists()) {
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.setFilePath(_userAudioPath!);
        await _audioPlayer.setSpeed(_playbackSpeed);
        await _audioPlayer.play();
      } else {
        _playNativeAudio();
      }
    } catch (_) {
      _playNativeAudio();
    }
    if (mounted) setState(() => _isPlayingUser = false);
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
                color: (_score >= 70 ? Colors.green : Colors.orange.shade800).withOpacity(isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _score >= 70 ? Colors.green : Colors.orange.shade800, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _score >= 70 ? Colors.green : Colors.orange.shade800,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_score >= 70 ? CupertinoIcons.checkmark : CupertinoIcons.exclamationmark, color: Colors.white, size: 20),
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
                                _score >= 90
                                    ? 'Excellent! 🎉'
                                    : (_score >= 70 ? 'Great Job! 👍' : 'Try Again! 👂'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: _score >= 70 ? Colors.green : Colors.orange.shade800,
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
                                color: _score >= 70 ? Colors.green : Colors.orange.shade800,
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
                                color: (_score >= 70 ? Colors.green : Colors.orange).withOpacity(0.2),
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
                                      color: _score >= 70 ? Colors.green : Colors.orange.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(_score >= 70 ? Icons.check : Icons.circle, size: 12, color: _score >= 70 ? Colors.green : Colors.orange.shade800),
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

                // Live Audio Waveform Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(24, (index) {
                    final isActive = _isListening || _isPlayingNative || _isPlayingUser;
                    final height = isActive
                        ? 10.0 + (index % 5) * 7.0
                        : 6.0 + (index % 3) * 3.0;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? Colors.redAccent
                            : (_hasVerified ? Colors.green : theme.primaryColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          if (_hasVerified) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isPlayingUser ? null : _playUserAudio,
                icon: _isPlayingUser
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                      )
                    : const Icon(CupertinoIcons.play_arrow_solid, size: 18),
                label: const Text(
                  'Listen to My Practice Audio',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
