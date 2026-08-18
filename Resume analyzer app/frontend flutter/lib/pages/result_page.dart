import 'package:flutter/material.dart';

import '../main.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class ResultPage extends StatelessWidget {
  final AnalysisResponse response;
  final String jobRole;
  final int vacancy;

  const ResultPage({
    super.key,
    required this.response,
    required this.jobRole,
    required this.vacancy,
  });

  @override
  Widget build(BuildContext context) {
    final results = response.results;
    final withinCapacity = results.take(vacancy).toList();
    final beyondCapacity = results.length > vacancy ? results.sublist(vacancy) : <CandidateResult>[];

    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          const FloatingBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Complete',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ranked ${response.totalResumes} resume${response.totalResumes == 1 ? '' : 's'} for $jobRole.',
                          style: TextStyle(fontSize: 14, color: AppColors.outline),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Text('Candidate Ranking',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.tertiary.withOpacity(0.2)),
                              ),
                              child: Text(
                                '$vacancy VACANC${vacancy == 1 ? 'Y' : 'IES'}',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.tertiary, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (results.isEmpty)
                          _buildEmptyState()
                        else ...[
                          ...withinCapacity.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CandidateCard(rank: entry.key + 1, candidate: entry.value, highlighted: entry.key == 0),
                                ),
                              ),
                          if (beyondCapacity.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('CANDIDATES BEYOND CAPACITY',
                                      style: TextStyle(fontSize: 11, color: AppColors.outline, letterSpacing: 1)),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...beyondCapacity.asMap().entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Opacity(
                                      opacity: 0.55,
                                      child: _CandidateCard(rank: vacancy + entry.key + 1, candidate: entry.value, highlighted: false),
                                    ),
                                  ),
                                ),
                          ],
                        ],
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            icon: Icon(Icons.refresh, color: AppColors.primary, size: 18),
                            label: Text('Start New Analysis', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
          ),
          Icon(Icons.hub_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text('AI Resume Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.outline, size: 32),
          const SizedBox(height: 12),
          Text('No results returned by the server.', style: TextStyle(color: AppColors.outline)),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final int rank;
  final CandidateResult candidate;
  final bool highlighted;

  const _CandidateCard({required this.rank, required this.candidate, required this.highlighted});

  Color get _ringColor {
    if (candidate.score >= 85) return AppColors.primary;
    if (candidate.score >= 60) return AppColors.secondary;
    return AppColors.outline;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          if (highlighted)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: AppColors.tertiary),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              candidate.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: highlighted ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RANK $rank',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: highlighted ? AppColors.primary : AppColors.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Analyzed resume', style: TextStyle(fontSize: 13, color: AppColors.outline)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ScoreRing(score: candidate.score, color: _ringColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double score;
  final Color color;
  final double size;

  const _ScoreRing({required this.score, required this.color, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _RingPainter(progress: clamped / 100, color: color)),
          Text('${clamped.round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const start = -3.141592653589793 / 2;
    final sweep = 2 * 3.141592653589793 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}
