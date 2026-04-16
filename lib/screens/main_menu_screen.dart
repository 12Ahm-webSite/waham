import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_models.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import '../widgets/star_background.dart';
import 'endings_screen.dart';
import 'game_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    AudioService.instance.playMood(AudioMood.menu);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    ref.read(gameServiceProvider).startNewRun();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameServiceProvider);
    final unlocked = game.unlockedEndings.length;
    final loreCount = game.loreArchive.length;
    final achievementCount = game.unlockedAchievements.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        body: StarBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EndingsScreen(),
                          ),
                        );
                      },
                      child: const Text('النهايات والمذكرات'),
                    ),
                  ),
                  const Spacer(),
                  ScaleTransition(
                    scale: _pulse,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFF8DA1), Color(0xFF4C1D95)],
                              stops: [0.2, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8DA1)
                                    .withValues(alpha: 0.24),
                                blurRadius: 42,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'و',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'وهم',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ثلاثة فصول. عداد وعي. ست نهايات متشابكة.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.58),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF0B0B1F),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'النهايات المفتوحة',
                          value: '$unlocked / ${game.totalEndings}',
                        ),
                        const SizedBox(height: 10),
                        _StatRow(
                          label: 'الإنجازات',
                          value: '$achievementCount / ${game.totalAchievements}',
                        ),
                        const SizedBox(height: 10),
                        _StatRow(
                          label: 'المذكرات المؤرشفة',
                          value: '$loreCount / ${LoreEntry.values.length}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MenuButton(
                    label: 'ابدأ دورة جديدة',
                    icon: '🚪',
                    isPrimary: true,
                    onPressed: _startGame,
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'استعرض النهايات والمقتطفات',
                    icon: '📖',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EndingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(gameServiceProvider).resetMetaProgress(),
                    child: Text(
                      'مسح التقدم الجماعي',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
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
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final String icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFFFF8DA1), Color(0xFF7C3AED)],
                  )
                : null,
            color: widget.isPrimary ? null : const Color(0xFF11112B),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : const Color(0xFFFF8DA1).withValues(alpha: 0.45),
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF8DA1).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
