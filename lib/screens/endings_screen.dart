import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_models.dart';
import '../services/game_service.dart';
import '../widgets/star_background.dart';

class EndingsScreen extends ConsumerWidget {
  const EndingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameServiceProvider);
    final unlockedEndings = game.unlockedEndings;
    final achievements = game.unlockedAchievements;
    final lore = game.loreArchive;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        body: StarBackground(
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white.withValues(alpha: 0.62),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'أرشيف الوهم',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _OverviewCard(game: game),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final type = EndingType.values[index];
                        final unlocked = unlockedEndings.contains(type);
                        return _EndingCard(type: type, unlocked: unlocked);
                      },
                      childCount: EndingType.values.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.84,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _Section(
                      title: 'الإنجازات',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AchievementType.values.map((achievement) {
                          final unlocked = achievements.contains(achievement);
                          return _ArchiveChip(
                            leading: achievement.emoji,
                            title: achievement.label,
                            unlocked: unlocked,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    child: _Section(
                      title: 'المذكرات المؤرشفة',
                      child: Column(
                        children: LoreEntry.values.map((entry) {
                          final unlocked = lore.contains(entry);
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? const Color(0xFF12122C)
                                  : const Color(0xFF0A0A18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: unlocked
                                    ? const Color(0xFFFF8DA1).withValues(alpha: 0.24)
                                    : Colors.white10,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unlocked ? entry.title : 'مذكرة مغلقة',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: unlocked ? 1 : 0.4,
                                    ),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  unlocked
                                      ? entry.description
                                      : 'أكمل دورات أكثر لفتح هذا الأثر السردي.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: unlocked ? 0.64 : 0.24,
                                    ),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final GameService game;

  const _OverviewCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final endingProgress = game.unlockedEndings.length / game.totalEndings;
    final achievementProgress =
        game.unlockedAchievements.length / game.totalAchievements;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101028),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التقدم الجماعي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          _ProgressLine(
            label: 'النهايات',
            valueText: '${game.unlockedEndings.length} / ${game.totalEndings}',
            value: endingProgress,
          ),
          const SizedBox(height: 12),
          _ProgressLine(
            label: 'الإنجازات',
            valueText:
                '${game.unlockedAchievements.length} / ${game.totalAchievements}',
            value: achievementProgress,
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;

  const _ProgressLine({
    required this.label,
    required this.valueText,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8DA1)),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101028),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EndingCard extends StatelessWidget {
  final EndingType type;
  final bool unlocked;

  const _EndingCard({required this.type, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color = _colorOf(type);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.08) : const Color(0xFF0A0A18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.35) : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? type.emoji : '🔒',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 12),
          Text(
            unlocked ? type.label : 'نهاية مخفية',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white24,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            unlocked ? _endingDescription(type) : 'اكتشف المزيد من المسارات لفتحها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked
                  ? color.withValues(alpha: 0.86)
                  : Colors.white.withValues(alpha: 0.22),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorOf(EndingType type) {
    switch (type) {
      case EndingType.integration:
        return const Color(0xFF34D399);
      case EndingType.eternalIllusion:
        return const Color(0xFF9CA3AF);
      case EndingType.deliberateBreak:
        return const Color(0xFFF97316);
      case EndingType.silentObserver:
        return const Color(0xFF60A5FA);
      case EndingType.crossedCycle:
        return const Color(0xFFA78BFA);
      case EndingType.invertedReflection:
        return const Color(0xFFFF8DA1);
    }
  }

  String _endingDescription(EndingType type) {
    switch (type) {
      case EndingType.integration:
        return 'ترميم الذات والخروج بذاكرة كاملة.';
      case EndingType.eternalIllusion:
        return 'استسلام هادئ داخل حلم لا ينتهي.';
      case EndingType.deliberateBreak:
        return 'تحطيم الدورة بثمن محو الذاكرة.';
      case EndingType.silentObserver:
        return 'التحول إلى الشاهد الذي يراقب الناجين.';
      case EndingType.crossedCycle:
        return 'حلقة واعية بين النفق والمنارة.';
      case EndingType.invertedReflection:
        return 'الحقيقة السرية خلف المرآة وكسر الجدار الرابع.';
    }
  }
}

class _ArchiveChip extends StatelessWidget {
  final String leading;
  final String title;
  final bool unlocked;

  const _ArchiveChip({
    required this.leading,
    required this.title,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: unlocked ? const Color(0xFF181833) : const Color(0xFF0A0A18),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFF8DA1).withValues(alpha: 0.24)
              : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(leading),
          const SizedBox(width: 8),
          Text(
            unlocked ? title : 'إنجاز مغلق',
            style: TextStyle(
              color: Colors.white.withValues(alpha: unlocked ? 1 : 0.32),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
