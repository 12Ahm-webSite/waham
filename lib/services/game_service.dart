import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/story_data.dart';
import '../models/story_models.dart';

final gameServiceProvider = ChangeNotifierProvider<GameService>((ref) {
  return GameService();
});

class GameService extends ChangeNotifier {
  GameService() {
    _loadMetaProgress();
    startNewRun(notify: false);
  }

  static const _endingsKey = 'unlocked_endings_v2';
  static const _achievementsKey = 'unlocked_achievements_v2';
  static const _loreArchiveKey = 'lore_archive_v2';

  final Set<EndingType> _unlockedEndings = {};
  final Set<AchievementType> _unlockedAchievements = {};
  final Set<LoreEntry> _loreArchive = {};
  final Set<LoreEntry> _currentLore = {};
  final List<String> _history = [];

  String _currentSceneId = startSceneId;
  int _sanity = 58;
  int _awareness = 42;
  int _stability = 52;
  int _progressStage = 0;

  ChapterOnePath? _chapterOnePath;
  ChapterTwoPath? _chapterTwoPath;
  TransitionState? _transitionState;
  FinalRoute? _finalRoute;
  EndingType? _currentEnding;

  bool _sharedSymbolUnlocked = false;
  bool _openedForbiddenDoorChapterOne = false;
  bool _trackedFog = false;
  bool _intentionalBlink = false;
  bool _emergencyProtocol = false;
  bool _keptSilentRule = false;
  bool _stayedInStation = false;
  bool _closedCurtains = false;

  Future<void> _loadMetaProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _unlockedEndings
        ..clear()
        ..addAll(
          (prefs.getStringList(_endingsKey) ?? [])
              .map(_endingFromName)
              .whereType<EndingType>(),
        );
      _unlockedAchievements
        ..clear()
        ..addAll(
          (prefs.getStringList(_achievementsKey) ?? [])
              .map(_achievementFromName)
              .whereType<AchievementType>(),
        );
      _loreArchive
        ..clear()
        ..addAll(
          (prefs.getStringList(_loreArchiveKey) ?? [])
              .map(_loreFromName)
              .whereType<LoreEntry>(),
        );
      _refreshCollectorAchievement();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveMetaProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _endingsKey,
        _unlockedEndings.map((e) => e.name).toList(),
      );
      await prefs.setStringList(
        _achievementsKey,
        _unlockedAchievements.map((e) => e.name).toList(),
      );
      await prefs.setStringList(
        _loreArchiveKey,
        _loreArchive.map((e) => e.name).toList(),
      );
    } catch (_) {}
  }

  StoryScene get currentScene => storyScenes[_currentSceneId]!;
  Set<EndingType> get unlockedEndings => Set.unmodifiable(_unlockedEndings);
  Set<AchievementType> get unlockedAchievements =>
      Set.unmodifiable(_unlockedAchievements);
  Set<LoreEntry> get loreArchive => Set.unmodifiable(_loreArchive);
  Set<LoreEntry> get currentLore => Set.unmodifiable(_currentLore);
  int get totalEndings => EndingType.values.length;
  int get totalAchievements => AchievementType.values.length;
  int get sanity => _sanity;
  int get awareness => _awareness;
  int get stability => _stability;
  int get progressStage => _progressStage;
  ChapterOnePath? get chapterOnePath => _chapterOnePath;
  ChapterTwoPath? get chapterTwoPath => _chapterTwoPath;
  TransitionState? get transitionState => _transitionState;
  FinalRoute? get finalRoute => _finalRoute;
  EndingType? get currentEnding => _currentEnding;
  bool get isEnding => currentScene.kind == SceneKind.ending;
  bool get sharedSymbolUnlocked => _sharedSymbolUnlocked;

  String get countdownLabel {
    switch (_progressStage) {
      case 0:
        return '48:00';
      case 1:
        return '24:00';
      case 2:
        return '00:00';
      default:
        return '--:--';
    }
  }

  String get chapterLabel {
    switch (currentScene.chapter) {
      case ChapterType.prologue:
        return 'المقدمة';
      case ChapterType.chapterOne:
        return 'الفصل الأول';
      case ChapterType.chapterTwo:
        return 'الفصل الثاني';
      case ChapterType.chapterThree:
        return 'الفصل الثالث';
      case ChapterType.ending:
        return 'الخاتمة';
    }
  }

  String get sceneDisplayText {
    if (currentScene.id == 'chapter_three_intro') {
      final buffer = StringBuffer(currentScene.text);
      buffer.write('\n\n');
      if (_awareness >= 70 && _loreArchive.length >= 3) {
        buffer.write(
          'صفحة تنفصل من الدفتر بخطك: "لست هنا لأنك ضائع. أنت هنا لأنك رفضت أن تكتمل."\n\n',
        );
      }
      if (_sanity <= 30) {
        buffer.write(
          'جدران الغرفة تتشقق. الهمس يصبح مألوفاً: "لا تخف من الكسر. بعض الأشياء لا تلتئم إلا بعد أن تتحطم."\n\n',
        );
      }
      if (_chapterTwoPath == ChapterTwoPath.aquarium &&
          _transitionState == TransitionState.exhaustedAware) {
        buffer.write('الكيان يقف قرب المرآة بوضوح كامل هذه المرة، لكنه لا يهاجم. يمد يده.\n\n');
      }
      if (_chapterTwoPath == ChapterTwoPath.lighthouse &&
          _transitionState == TransitionState.techAnchored) {
        buffer.write(
          'لوحة التحكم تضيء تلقائياً وتعرض خريطة دورة الـ 48 ساعة كاملة كأنها تنتظرك.\n\n',
        );
      }
      if (_sharedSymbolUnlocked) {
        buffer.write('الرمز المشقوق ينبض على السقف للحظة ثم يختفي داخل انعكاسك.');
      }
      return buffer.toString().trim();
    }

    if (currentScene.id == 'ending_result') {
      return endingNarration(_currentEnding);
    }

    return currentScene.text;
  }

  AudioMood get currentMood {
    if (currentScene.id != 'ending_result') {
      return currentScene.mood;
    }
    switch (_currentEnding) {
      case EndingType.integration:
        return AudioMood.endingHope;
      case EndingType.eternalIllusion:
        return AudioMood.endingLoop;
      case EndingType.deliberateBreak:
        return AudioMood.endingBreak;
      case EndingType.silentObserver:
        return AudioMood.endingObserver;
      case EndingType.crossedCycle:
        return AudioMood.endingLoop;
      case EndingType.invertedReflection:
        return AudioMood.endingObserver;
      case null:
        return AudioMood.silence;
    }
  }

  void startNewRun({bool notify = true}) {
    _currentSceneId = startSceneId;
    _currentEnding = null;
    _history.clear();
    _currentLore.clear();
    _sanity = 58;
    _awareness = 42;
    _stability = 52;
    _progressStage = 0;
    _chapterOnePath = null;
    _chapterTwoPath = null;
    _transitionState = null;
    _finalRoute = null;
    _sharedSymbolUnlocked = false;
    _openedForbiddenDoorChapterOne = false;
    _trackedFog = false;
    _intentionalBlink = false;
    _emergencyProtocol = false;
    _keptSilentRule = false;
    _stayedInStation = false;
    _closedCurtains = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> resetMetaProgress() async {
    _unlockedEndings.clear();
    _unlockedAchievements.clear();
    _loreArchive.clear();
    startNewRun(notify: false);
    await _saveMetaProgress();
    notifyListeners();
  }

  void makeChoice(StoryChoice choice) {
    _history.add(_currentSceneId);

    _sanity = _clampMeter(_sanity + choice.sanityDelta);
    _awareness = _clampMeter(_awareness + choice.awarenessDelta);
    _stability = _clampMeter(_stability + choice.stabilityDelta);

    if (choice.chapterOnePath != null) {
      _chapterOnePath = choice.chapterOnePath;
    }
    if (choice.chapterTwoPath != null) {
      _chapterTwoPath = choice.chapterTwoPath;
    }
    if (choice.transitionState != null) {
      _transitionState = choice.transitionState;
    }
    if (choice.finalRoute != null) {
      _finalRoute = choice.finalRoute;
    }
    if (choice.progressStage != null) {
      _progressStage = choice.progressStage!;
    }

    _openedForbiddenDoorChapterOne |= choice.markForbiddenDoorOpened;
    _trackedFog |= choice.markTrackedFog;
    _intentionalBlink |= choice.markIntentionalBlink;
    _emergencyProtocol |= choice.markEmergencyProtocol;
    _keptSilentRule |= choice.markKeptSilentRule;
    _stayedInStation |= choice.markStayedInStation;
    _closedCurtains |= choice.markClosedCurtains;
    _sharedSymbolUnlocked |= choice.unlockSharedSymbol;

    for (final lore in choice.lore) {
      _currentLore.add(lore);
      _loreArchive.add(lore);
    }

    for (final achievement in choice.achievements) {
      _unlockedAchievements.add(achievement);
    }

    _currentSceneId = choice.nextSceneId;

    if (_currentSceneId == 'chapter_two_choice') {
      _evaluateChapterOneAchievements();
    }

    if (_currentSceneId == 'chapter_three_intro') {
      _unlockAutomaticChapterThreeLore();
    }

    if (_currentSceneId == 'ending_result') {
      _currentEnding = _evaluateEnding();
      _unlockedEndings.add(_currentEnding!);
      _unlockEndingAchievements(_currentEnding!);
    }

    _refreshCollectorAchievement();
    unawaited(_saveMetaProgress());
    notifyListeners();
  }

  void _unlockAutomaticChapterThreeLore() {
    if (_awareness >= 50) {
      _currentLore.add(LoreEntry.syncProtocol);
      _loreArchive.add(LoreEntry.syncProtocol);
    }

    if (_loreArchive.contains(LoreEntry.glassNature) &&
        _loreArchive.contains(LoreEntry.repetitionIllusion)) {
      _currentLore.add(LoreEntry.selfReflection);
      _loreArchive.add(LoreEntry.selfReflection);
    }
  }

  void _evaluateChapterOneAchievements() {
    if (_keptSilentRule && !_openedForbiddenDoorChapterOne && !_trackedFog) {
      _unlockedAchievements.add(AchievementType.silentFollower);
    }
  }

  void _unlockEndingAchievements(EndingType ending) {
    switch (ending) {
      case EndingType.integration:
        _unlockedAchievements.add(AchievementType.fullyAware);
      case EndingType.crossedCycle:
        _unlockedAchievements.add(AchievementType.awareLoop);
      case EndingType.invertedReflection:
        _unlockedAchievements.add(AchievementType.beyondMirror);
      case EndingType.eternalIllusion:
      case EndingType.deliberateBreak:
      case EndingType.silentObserver:
        break;
    }
  }

  void _refreshCollectorAchievement() {
    if (_unlockedEndings.length >= 5) {
      _unlockedAchievements.add(AchievementType.illusionCollector);
    }
  }

  EndingType _evaluateEnding() {
    final loreCount = _loreArchive.length;
    final balance = (_awareness - _sanity).abs();
    final observerRoute = _finalRoute == FinalRoute.observer;
    final surrenderRoute = _finalRoute == FinalRoute.surrender;
    final mirrorOrPanel =
        _finalRoute == FinalRoute.mirror || _finalRoute == FinalRoute.panel;

    if (observerRoute &&
        !_openedForbiddenDoorChapterOne &&
        _intentionalBlink &&
        loreCount >= 7 &&
        balance <= 5) {
      return EndingType.invertedReflection;
    }

    if (_awareness >= 65 &&
        _sanity >= 50 &&
        loreCount >= 3 &&
        mirrorOrPanel) {
      return EndingType.integration;
    }

    if (_awareness >= 80 &&
        _sanity <= 35 &&
        _finalRoute == FinalRoute.panel &&
        _emergencyProtocol) {
      return EndingType.deliberateBreak;
    }

    if (observerRoute &&
        _awareness >= 50 &&
        _awareness <= 65 &&
        _sanity >= 40 &&
        _sanity <= 60 &&
        _loreArchive.contains(LoreEntry.fadingBoundaries)) {
      return EndingType.silentObserver;
    }

    if (_chapterTwoPath == ChapterTwoPath.aquarium &&
        _transitionState == TransitionState.passiveHiding &&
        _awareness >= 45 &&
        _awareness <= 60 &&
        (surrenderRoute || observerRoute)) {
      return EndingType.crossedCycle;
    }

    if (_sanity <= 40 && surrenderRoute && !_openedForbiddenDoorChapterOne) {
      return EndingType.eternalIllusion;
    }

    if (_finalRoute == FinalRoute.panel && _awareness > _sanity) {
      return EndingType.deliberateBreak;
    }

    if (observerRoute) {
      return EndingType.silentObserver;
    }

    if (surrenderRoute) {
      return EndingType.crossedCycle;
    }

    return EndingType.integration;
  }

  String endingNarration(EndingType? ending) {
    switch (ending) {
      case EndingType.integration:
        return 'تلمس المرآة. لا تنكسر. تنصهر. الجدران تتلاشى. الماء يصبح هواءً. '
            'الرمال تصبح أرضاً. تفتح عينيك في غرفة عادية، بضوء حقيقي وذاكرة كاملة.\n\n'
            'الوهم كان جرحاً، وأنت اخترت أن تلتئم.';
      case EndingType.eternalIllusion:
        return 'تستسلم. الغرفة تتسع وتصبح دافئة. الكيان يجلس بجانبك، والسراب يهدأ. '
            '٤٨ ساعة تبدأ من جديد، لكن هذه المرة بلا ألم ولا خوف.\n\n'
            'أنت جزء من الحلم الآن. وإلى الأبد.';
      case EndingType.deliberateBreak:
        return 'تضغط الأزرار. المرآة تتشقق. الماء ينفجر. الرمال تطير. '
            'تخرج من الدورة، لكن اسمك ووجهك يذوبان في الضوء.\n\n'
            'الوهم كُسر، لكنك كُسرت معه. الحرية هنا بثمن الذاكرة.';
      case EndingType.silentObserver:
        return 'تبتعد. لا تلمس. لا تتدخل. المرآة تعكس وجهك ثم تعكس ما وراءه.\n\n'
            'تفهم فجأة: لست الشخص الذي يحلم. أنت الحلم نفسه. الكيان، السراب، الهمس.\n\n'
            'أنت هنا لتراقب من يحاول النجاة... وتبتسم.';
      case EndingType.crossedCycle:
        return 'الجدران تتبدل. مرة زجاج، مرة رمال، مرة ماء، مرة ضوء. '
            '٤٨ ساعة لا تنتهي ولا تبدأ من جديد، بل تستمر في التداخل.\n\n'
            'أنت في النفق والمنارة في آن واحد. الوعي واضح، لكن الخروج مستحيل.';
      case EndingType.invertedReflection:
        return 'المرآة تنعكس للخلف. ترى نفسك خارج الغرفة. ترى الشاشة. ترى يدك تمسك الهاتف.\n\n'
            'تدرك: الوهم لم يكن داخل القصة. أنت كنت الوهم الذي يلعب بها.\n\n'
            'تضغط على زر الإعادة. لكن هذه المرة... الدور لك.';
      case null:
        return 'النهاية لم تتشكل بعد.';
    }
  }

  int _clampMeter(int value) => value.clamp(0, 100);

  EndingType? _endingFromName(String name) {
    try {
      return EndingType.values.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  AchievementType? _achievementFromName(String name) {
    try {
      return AchievementType.values.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  LoreEntry? _loreFromName(String name) {
    try {
      return LoreEntry.values.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }
}
