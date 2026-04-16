enum ChapterType { prologue, chapterOne, chapterTwo, chapterThree, ending }

enum SceneKind { story, cutscene, ending }

enum ChapterOnePath { house, road }

enum ChapterTwoPath { aquarium, lighthouse }

enum FinalRoute { mirror, panel, surrender, observer }

enum EndingType {
  integration,
  eternalIllusion,
  deliberateBreak,
  silentObserver,
  crossedCycle,
  invertedReflection,
}

enum LoreEntry {
  pinkHouseRules,
  travelerNotebook,
  fadingBoundaries,
  glassNature,
  abyssEyes,
  lighthouseNotes,
  repetitionIllusion,
  syncProtocol,
  selfReflection,
}

enum AchievementType {
  firstSurvivor,
  silenceBreaker,
  silentFollower,
  illusionBegins,
  cautiousSurvivor,
  mirageBreaker,
  recluse,
  fullyAware,
  awareLoop,
  beyondMirror,
  illusionCollector,
}

enum AudioMood {
  menu,
  house,
  road,
  interlude,
  aquarium,
  lighthouse,
  finalRoom,
  endingHope,
  endingLoop,
  endingBreak,
  endingObserver,
  silence,
}

enum TransitionState {
  exhaustedAware,
  passiveHiding,
  techAnchored,
  directIllusion,
}

class StoryChoice {
  final String text;
  final String nextSceneId;
  final bool isPrimary;
  final int sanityDelta;
  final int awarenessDelta;
  final int stabilityDelta;
  final Set<LoreEntry> lore;
  final Set<AchievementType> achievements;
  final bool markForbiddenDoorOpened;
  final bool markSawEntity;
  final bool markTrackedFog;
  final bool markIntentionalBlink;
  final bool markEmergencyProtocol;
  final bool markKeptSilentRule;
  final bool markStayedInStation;
  final bool markClosedCurtains;
  final bool unlockSharedSymbol;
  final ChapterOnePath? chapterOnePath;
  final ChapterTwoPath? chapterTwoPath;
  final TransitionState? transitionState;
  final FinalRoute? finalRoute;
  final int? progressStage;

  const StoryChoice({
    required this.text,
    required this.nextSceneId,
    this.isPrimary = false,
    this.sanityDelta = 0,
    this.awarenessDelta = 0,
    this.stabilityDelta = 0,
    this.lore = const <LoreEntry>{},
    this.achievements = const <AchievementType>{},
    this.markForbiddenDoorOpened = false,
    this.markSawEntity = false,
    this.markTrackedFog = false,
    this.markIntentionalBlink = false,
    this.markEmergencyProtocol = false,
    this.markKeptSilentRule = false,
    this.markStayedInStation = false,
    this.markClosedCurtains = false,
    this.unlockSharedSymbol = false,
    this.chapterOnePath,
    this.chapterTwoPath,
    this.transitionState,
    this.finalRoute,
    this.progressStage,
  });
}

class StoryScene {
  final String id;
  final ChapterType chapter;
  final SceneKind kind;
  final String title;
  final String text;
  final List<StoryChoice> choices;
  final AudioMood mood;
  final EndingType? endingType;

  const StoryScene({
    required this.id,
    required this.chapter,
    required this.kind,
    required this.title,
    required this.text,
    required this.choices,
    required this.mood,
    this.endingType,
  });
}

extension EndingTypeUi on EndingType {
  String get label {
    switch (this) {
      case EndingType.integration:
        return 'الاندماج الكامل';
      case EndingType.eternalIllusion:
        return 'الوهم الأبدي';
      case EndingType.deliberateBreak:
        return 'الكسر المتعمد';
      case EndingType.silentObserver:
        return 'المراقب الصامت';
      case EndingType.crossedCycle:
        return 'الدورة المتقاطعة';
      case EndingType.invertedReflection:
        return 'الانعكاس المقلوب';
    }
  }

  String get emoji {
    switch (this) {
      case EndingType.integration:
        return '🌅';
      case EndingType.eternalIllusion:
        return '🌑';
      case EndingType.deliberateBreak:
        return '🫥';
      case EndingType.silentObserver:
        return '👁️';
      case EndingType.crossedCycle:
        return '🔄';
      case EndingType.invertedReflection:
        return '🪞';
    }
  }
}

extension LoreEntryUi on LoreEntry {
  String get title {
    switch (this) {
      case LoreEntry.pinkHouseRules:
        return 'قواعد المنزل الوردي';
      case LoreEntry.travelerNotebook:
        return 'دفتر المسافر';
      case LoreEntry.fadingBoundaries:
        return 'تلاشي الحدود';
      case LoreEntry.glassNature:
        return 'طبيعة الزجاج';
      case LoreEntry.abyssEyes:
        return 'عيون الأعماق';
      case LoreEntry.lighthouseNotes:
        return 'ملاحظات المنارة';
      case LoreEntry.repetitionIllusion:
        return 'وهم التكرار';
      case LoreEntry.syncProtocol:
        return 'بروتوكول المزامنة';
      case LoreEntry.selfReflection:
        return 'انعكاس الذات';
    }
  }

  String get description {
    switch (this) {
      case LoreEntry.pinkHouseRules:
        return 'لا يؤذيك الكائن ما دمت لا تمنحه نظرة كاملة.';
      case LoreEntry.travelerNotebook:
        return 'محاولات سابقة تصف الـ 48 ساعة كمصيدة وعي.';
      case LoreEntry.fadingBoundaries:
        return 'المسارات ليست منفصلة، بل طبقات فوق المكان نفسه.';
      case LoreEntry.glassNature:
        return 'التشققات تتبع شكل الخوف البشري ولا تنكسر صدفة.';
      case LoreEntry.abyssEyes:
        return 'ما يطاردك ليس خارج الزجاج، بل جزء انفصل عنك.';
      case LoreEntry.lighthouseNotes:
        return 'الصفحات مكتوبة بخطك قبل أن تحمل القلم.';
      case LoreEntry.repetitionIllusion:
        return 'الوقت يكرر نفسه حين لا يراقبه أحد.';
      case LoreEntry.syncProtocol:
        return 'الدورة ليست زمناً، بل معايرة وعي متكررة.';
      case LoreEntry.selfReflection:
        return 'الكيان والسراب وجهان لذات واحدة ممزقة.';
    }
  }
}

extension AchievementTypeUi on AchievementType {
  String get label {
    switch (this) {
      case AchievementType.firstSurvivor:
        return 'الناجي الأول';
      case AchievementType.silenceBreaker:
        return 'كاسر الصمت';
      case AchievementType.silentFollower:
        return 'المطيع الصامت';
      case AchievementType.illusionBegins:
        return 'الوهم يبدأ';
      case AchievementType.cautiousSurvivor:
        return 'الناجي الحذر';
      case AchievementType.mirageBreaker:
        return 'كاسر السراب';
      case AchievementType.recluse:
        return 'المعتزل';
      case AchievementType.fullyAware:
        return 'كامل الوعي';
      case AchievementType.awareLoop:
        return 'حلقة واعية';
      case AchievementType.beyondMirror:
        return 'ما وراء المرآة';
      case AchievementType.illusionCollector:
        return 'جامع الأوهام';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementType.firstSurvivor:
        return '🕰️';
      case AchievementType.silenceBreaker:
        return '👁️‍🗨️';
      case AchievementType.silentFollower:
        return '🤫';
      case AchievementType.illusionBegins:
        return '🚪';
      case AchievementType.cautiousSurvivor:
        return '🛡️';
      case AchievementType.mirageBreaker:
        return '👁️';
      case AchievementType.recluse:
        return '🌙';
      case AchievementType.fullyAware:
        return '🌅';
      case AchievementType.awareLoop:
        return '🔄';
      case AchievementType.beyondMirror:
        return '🪞';
      case AchievementType.illusionCollector:
        return '📖';
    }
  }
}
