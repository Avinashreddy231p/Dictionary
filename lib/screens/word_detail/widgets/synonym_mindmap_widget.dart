import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';

enum MindmapNodeType { synonym, antonym, pairing }

class MindmapNode {
  final String label;
  final MindmapNodeType type;

  MindmapNode({required this.label, required this.type});
}

class SynonymMindmapWidget extends StatelessWidget {
  final String headword;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> pairings;

  const SynonymMindmapWidget({
    super.key,
    required this.headword,
    required this.synonyms,
    required this.antonyms,
    required this.pairings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<MindmapNode> nodes = [];
    for (var s in synonyms.take(5)) {
      nodes.add(MindmapNode(label: s, type: MindmapNodeType.synonym));
    }
    for (var a in antonyms.take(3)) {
      nodes.add(MindmapNode(label: a, type: MindmapNodeType.antonym));
    }
    for (var p in pairings.take(3)) {
      nodes.add(MindmapNode(label: p, type: MindmapNodeType.pairing));
    }

    if (nodes.isEmpty) return const SizedBox.shrink();

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
          Row(
            children: [
              Icon(CupertinoIcons.circle_grid_hex_fill,
                  color: theme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Interactive Word Mindmap',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap any connected node to explore related words.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendTag(context, 'Synonym', Colors.green),
              const SizedBox(width: 12),
              _buildLegendTag(context, 'Antonym', Colors.redAccent),
              const SizedBox(width: 12),
              _buildLegendTag(context, 'Pairing', Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 20),

          // Canvas & Radial Graph
          SizedBox(
            height: 280,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final center = Offset(
                    constraints.maxWidth / 2, constraints.maxHeight / 2);
                final radius = min(constraints.maxWidth, constraints.maxHeight) * 0.38;

                final List<Offset> positions = [];
                final count = nodes.length;

                for (int i = 0; i < count; i++) {
                  final angle = (2 * pi / count) * i - (pi / 2);
                  final x = center.dx + radius * cos(angle);
                  final y = center.dy + radius * sin(angle);
                  positions.add(Offset(x, y));
                }

                return Stack(
                  children: [
                    // Connecting Lines
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _MindmapLinesPainter(
                        center: center,
                        positions: positions,
                        lineColor: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),

                    // Central Headword Node
                    Positioned(
                      left: center.dx - 55,
                      top: center.dy - 25,
                      child: Container(
                        width: 110,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          headword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Satellite Node Buttons
                    for (int i = 0; i < count; i++) ...[
                      Positioned(
                        left: positions[i].dx - 45,
                        top: positions[i].dy - 18,
                        child: _buildSatelliteNode(
                          context,
                          nodes[i],
                          isDark,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendTag(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSatelliteNode(
      BuildContext context, MindmapNode node, bool isDark) {
    Color bg;
    Color border;

    switch (node.type) {
      case MindmapNodeType.synonym:
        bg = Colors.green.withOpacity(isDark ? 0.25 : 0.15);
        border = Colors.green;
        break;
      case MindmapNodeType.antonym:
        bg = Colors.redAccent.withOpacity(isDark ? 0.25 : 0.15);
        border = Colors.redAccent;
        break;
      case MindmapNodeType.pairing:
        bg = Colors.blueAccent.withOpacity(isDark ? 0.25 : 0.15);
        border = Colors.blueAccent;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final cleanWord = node.label.split(' ').last;
        context.push('/word/$cleanWord');
      },
      child: Container(
        width: 90,
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(
          node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: border,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MindmapLinesPainter extends CustomPainter {
  final Offset center;
  final List<Offset> positions;
  final Color lineColor;

  _MindmapLinesPainter({
    required this.center,
    required this.positions,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final pos in positions) {
      canvas.drawLine(center, pos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindmapLinesPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.positions != positions;
  }
}
