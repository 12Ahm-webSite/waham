import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_models.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import '../widgets/choice_button.dart';
import '../widgets/star_background.dart';
import 'endings_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  AudioMood? _lastMood;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _advance(StoryChoice choice) async {
    await _fadeCtrl.reverse();
    final service = ref.read(gameServiceProvider);
    final shouldPulse = choice.unlockSharedSymbol;
    service.makeChoice(choice);
    if (shouldPulse) {
      await AudioService.instance.playSymbolPulse();
    }
    await _fadeCtrl.forward();
  }

  void _syncAudio(AudioMood mood) {
    if (_lastMood == mood) return;
    _lastMood = mood;
    AudioService.instance.playMood(mood);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameServiceProvider);
    final scene = game.currentScene;
    _syncAudio(game.currentMood);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        body: StarBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _TopBar(game: game),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _StatusPanel(game: game),
                              const SizedBox(height: 16),
                              _StoryCard(game: game),
                              const SizedBox(height: 18),
                              if (game.currentLore.isNotEmpty) ...[
                                _LorePanel(lore: game.currentLore.toList()),
                                const SizedBox(height: 18),
                              ],
                              _buildActions(scene, game),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(StoryScene scene, GameService game) {
    if (game.isEnding) {
      final ending = game.currentEnding;
      return Column(
        children: [
          if (ending != null)
            _EndingBadge(
              label: ending.label,
              emoji: ending.emoji,
            ),
          const SizedBox(height: 14),
          ChoiceButton(
            text: 'ابدأ دورة جديدة',
            isPrimary: true,
            onPressed: () {
              ref.read(gameServiceProvider).startNewRun();
            },
          ),
          const SizedBox(height: 12),
          ChoiceButton(
            text: 'استعرض النهايات والمذكرات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EndingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          ChoiceButton(
            text: 'عودة إلى القائمة',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < scene.choices.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          ChoiceButton(
            text: scene.choices[i].text,
            isPrimary: scene.choices[i].isPrimary,
            onPressed: () => _advance(scene.choices[i]),
          ),
        ],
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final GameService game;

  const _TopBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.home_outlined,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  game.chapterLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  game.currentScene.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF12122A),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              game.countdownLabel,
              style: const TextStyle(
                color: Color(0xFFFFB3C1),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final GameService game;

  const _StatusPanel({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Meter(label: 'السلامة', value: game.sanity, color: const Color(0xFF7DD3FC)),
              const SizedBox(width: 10),
              _Meter(label: 'الوعي', value: game.awareness, color: const Color(0xFFF9A8D4)),
              const SizedBox(width: 10),
              _Meter(label: 'الاستقرار', value: game.stability, color: const Color(0xFF86EFAC)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(
                text: game.chapterOnePath == ChapterOnePath.house
                    ? 'المسار الأول: المنزل'
                    : game.chapterOnePath == ChapterOnePath.road
                        ? 'المسار الأول: الطريق'
                        : 'لم يبدأ بعد',
              ),
              _MiniChip(
                text: game.chapterTwoPath == ChapterTwoPath.aquarium
                    ? 'المسار الثاني: النفق'
                    : game.chapterTwoPath == ChapterTwoPath.lighthouse
                        ? 'المسار الثاني: المنارة'
                        : 'الفصل الثاني بانتظارك',
              ),
              if (game.sharedSymbolUnlocked) const _MiniChip(text: 'الرمز المشقوق مفعل'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final GameService game;

  const _StoryCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final ending = game.currentEnding;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101028),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: game.isEnding && ending != null
              ? _endingColor(ending).withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (game.isEnding && ending != null
                    ? _endingColor(ending)
                    : Colors.black)
                .withValues(alpha: 0.18),
            blurRadius: 34,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        game.sceneDisplayText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 17,
          height: 2,
        ),
      ),
    );
  }

  Color _endingColor(EndingType ending) {
    switch (ending) {
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
}

class _LorePanel extends StatelessWidget {
  final List<LoreEntry> lore;

  const _LorePanel({required this.lore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المذكرات المفتوحة في هذه الدورة',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in lore.take(3)) ...[
            Text(
              '• ${entry.title}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              entry.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _EndingBadge extends StatelessWidget {
  final String label;
  final String emoji;

  const _EndingBadge({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: const Color(0xFF171734),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Meter({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;

  const _MiniChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: const Color(0xFF171734),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: 12,
        ),
      ),
    );
  }
}
