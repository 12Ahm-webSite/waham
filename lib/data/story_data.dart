import '../models/story_models.dart';

const String startSceneId = 'opening_choice';

const Map<String, StoryScene> storyScenes = {
  'opening_choice': StoryScene(
    id: 'opening_choice',
    chapter: ChapterType.prologue,
    kind: SceneKind.story,
    title: 'الاختيار',
    mood: AudioMood.menu,
    text:
        'تقف أمام بابين بلا مقابض، بلا علامات. فقط همس يتسلل إلى وعيك:\n\n'
        '"ما ستختاره الآن سيكتب مصيرك خلال الثماني والأربعين ساعة القادمة. '
        'لا تراجع. لا عودة. الوهم يبدأ من هنا."\n\n'
        'تمد يدك. أي باب تفتحه؟',
    choices: [
      StoryChoice(
        text: 'الباب الأول: المنزل الوردي المطل على البحر',
        nextSceneId: 'house_day',
        isPrimary: true,
        chapterOnePath: ChapterOnePath.house,
      ),
      StoryChoice(
        text: 'الباب الثاني: الطريق الصامت فوق الغيوم',
        nextSceneId: 'road_start',
        chapterOnePath: ChapterOnePath.road,
      ),
    ],
  ),
  'house_day': StoryScene(
    id: 'house_day',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.story,
    title: 'الفصل الأول: المنزل الوردي',
    mood: AudioMood.house,
    text:
        'تستيقظ على وسادة باردة. الجدران وردية، ملساء، وكأنها طليت بلحم حي. '
        'النافذة تطل على بحر هائج يبتلع الأفق. في المطبخ: طبق خبز، كوب ماء، '
        'رائحة عسل قديمة. سرير مرتب بعناية فائضة.\n\n'
        'الشمس دافئة، لكن ظلك على الأرض لا يتحرك معك تماماً.',
    choices: [
      StoryChoice(
        text: 'تفحص المطبخ وتأكل',
        nextSceneId: 'house_dusk',
        isPrimary: true,
        sanityDelta: 8,
        stabilityDelta: 4,
        lore: {LoreEntry.pinkHouseRules},
      ),
      StoryChoice(
        text: 'تتفحص المنزل وتبحث عن مخارج',
        nextSceneId: 'house_dusk',
        awarenessDelta: 8,
        stabilityDelta: -6,
      ),
    ],
  ),
  'house_dusk': StoryScene(
    id: 'house_dusk',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.story,
    title: 'الفصل الأول: الغروب',
    mood: AudioMood.house,
    text:
        'ينطفئ الضوء فجأة. البرد يتسلل عبر الشقوق. تتذكر ما همس به الصوت:\n\n'
        '"لا تفتح أي باب إن سمعت خطوات، أو رأيت ظلاً يمر."\n\n'
        'المنزل يبدو فارغاً الآن. لكن الصمت ثقيل.',
    choices: [
      StoryChoice(
        text: 'تلتزم بالقاعدة: تنام وتغمض عينيك',
        nextSceneId: 'house_transition',
        isPrimary: true,
        sanityDelta: 5,
        stabilityDelta: 6,
        markKeptSilentRule: true,
      ),
      StoryChoice(
        text: 'تتبع الغريزة: تقترب من الممر وتستمع',
        nextSceneId: 'house_encounter_choice',
        awarenessDelta: 10,
        stabilityDelta: -8,
      ),
    ],
  ),
  'house_encounter_choice': StoryScene(
    id: 'house_encounter_choice',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.story,
    title: 'الفصل الأول: الخطوات',
    mood: AudioMood.house,
    text:
        'تسمع خطوة. ثم أخرى. ظل طويل يمر خلف الباب الداخلي. أنفاسك تتقلص '
        'والجدار يبدو أقرب مما ينبغي.',
    choices: [
      StoryChoice(
        text: 'تفتح الباب ببطء',
        nextSceneId: 'house_opened_door',
        isPrimary: true,
        awarenessDelta: 14,
        stabilityDelta: -10,
        lore: {LoreEntry.fadingBoundaries},
        achievements: {AchievementType.silenceBreaker},
        markForbiddenDoorOpened: true,
        markSawEntity: true,
        unlockSharedSymbol: true,
      ),
      StoryChoice(
        text: 'تتراجع وتنزلق تحت السرير',
        nextSceneId: 'house_hidden_symbol',
        sanityDelta: -2,
        awarenessDelta: 6,
        markKeptSilentRule: true,
        unlockSharedSymbol: true,
      ),
    ],
  ),
  'house_opened_door': StoryScene(
    id: 'house_opened_door',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.cutscene,
    title: 'الفصل الأول: المواجهة',
    mood: AudioMood.interlude,
    text:
        'كائن طويل، بلا ملامح واضحة، يقف على بعد خطوتين. لا يهاجم. فقط يحدق. '
        'يرفع يده ويرسم على الجدار رمزاً يشبه عيناً مشقوقة. ثم يذوب في الظلام.',
    choices: [
      StoryChoice(
        text: 'أكمل',
        nextSceneId: 'chapter_one_end',
        isPrimary: true,
      ),
    ],
  ),
  'house_hidden_symbol': StoryScene(
    id: 'house_hidden_symbol',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.cutscene,
    title: 'الفصل الأول: ما لم تره',
    mood: AudioMood.interlude,
    text:
        'تستيقظ على ضوء خافت. الرمز نفسه موجود على الجدار، لكنك لم تره يرسم. '
        'تدرك أن القاعدة لم تمنع حضوره... فقط منعتك من أن تكتمل رؤيته.',
    choices: [
      StoryChoice(
        text: 'أكمل',
        nextSceneId: 'chapter_one_end',
        isPrimary: true,
      ),
    ],
  ),
  'house_transition': StoryScene(
    id: 'house_transition',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.cutscene,
    title: 'الفصل الأول: ليلة صامتة',
    mood: AudioMood.interlude,
    text:
        'تمر الساعات بسلام ثقيل. حين تفتح عينيك تلمح مذكرة عند حافة السرير:\n\n'
        '"قواعد البقاء في المنزل الوردي: لا يؤذيك ما لم تمنحه عينيك كاملاً."\n\n'
        'وعلى الجدار، الرمز المشقوق يتوهج للحظة.',
    choices: [
      StoryChoice(
        text: 'أكمل',
        nextSceneId: 'chapter_one_end',
        isPrimary: true,
        lore: {LoreEntry.pinkHouseRules},
        unlockSharedSymbol: true,
      ),
    ],
  ),
  'road_start': StoryScene(
    id: 'road_start',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.story,
    title: 'الفصل الأول: الطريق الصامت',
    mood: AudioMood.road,
    text:
        'طريق إسفلتي باهت يمتد تحت سماء وردية ثابتة. تحته: بحر غيوم لا نهاية له. '
        'لا رياح. لا طيور. فقط صمت يثقل الأذن.\n\n'
        'أمامك محطة استراحة خشبية صغيرة. على بابها لافتة بالية: '
        '"استرح. لكن لا تنم طويلاً."',
    choices: [
      StoryChoice(
        text: 'تدخل المحطة وتأخذ قسطاً من الراحة',
        nextSceneId: 'road_fog',
        isPrimary: true,
        sanityDelta: 8,
        stabilityDelta: 5,
        lore: {LoreEntry.travelerNotebook},
        markStayedInStation: true,
      ),
      StoryChoice(
        text: 'تتجاهل المحطة وتكمل المشي',
        nextSceneId: 'road_fog',
        awarenessDelta: 8,
        stabilityDelta: -5,
      ),
    ],
  ),
  'road_fog': StoryScene(
    id: 'road_fog',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.story,
    title: 'الفصل الأول: الضباب',
    mood: AudioMood.road,
    text:
        'تمر ساعات. أو هكذا تظن. السماء لا تتغير. الضباب يتحرك بذكاء، '
        'أحياناً يتشكل كوجوه، وأحياناً كأياد تمتد نحوك.\n\n'
        'في الأفق البعيد، يظهر هيكل وردي صغير فوق منحدر. هل هو وهم أم حقيقي؟',
    choices: [
      StoryChoice(
        text: 'تتبع الضباب لتكتشف مصدره',
        nextSceneId: 'road_symbol',
        isPrimary: true,
        awarenessDelta: 12,
        sanityDelta: -4,
        lore: {LoreEntry.fadingBoundaries},
        achievements: {AchievementType.silenceBreaker},
        markTrackedFog: true,
      ),
      StoryChoice(
        text: 'تتجاهله وتتجه نحو الهيكل الوردي',
        nextSceneId: 'road_symbol',
        sanityDelta: 2,
        stabilityDelta: 3,
      ),
    ],
  ),
  'road_symbol': StoryScene(
    id: 'road_symbol',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.cutscene,
    title: 'الفصل الأول: علامة المزامنة',
    mood: AudioMood.interlude,
    text:
        'تقترب من المحطة التالية. على الحائط، نفس الرمز الذي ظهر في المنزل الوردي. '
        'تحت الرمز، كتابة بخط مرتعش:\n\n'
        '"٤٨ ساعة ليست للبقاء. هي للمزامنة."\n\n'
        'الجرس يرن مرة أخرى.',
    choices: [
      StoryChoice(
        text: 'أكمل',
        nextSceneId: 'chapter_one_end',
        isPrimary: true,
        unlockSharedSymbol: true,
      ),
    ],
  ),
  'chapter_one_end': StoryScene(
    id: 'chapter_one_end',
    chapter: ChapterType.chapterOne,
    kind: SceneKind.cutscene,
    title: 'نهاية الفصل الأول',
    mood: AudioMood.interlude,
    text:
        'الرمز يتوهج للحظة. تسمع صوتاً بعيداً يشبه جرساً. العدّاد الوهمي يشير:\n\n'
        '٢٤ ساعة متبقية.\n\n'
        'البوابات تتداخل، والفضاء يتشقق استعداداً لفصل آخر.',
    choices: [
      StoryChoice(
        text: 'ابدأ الفصل الثاني',
        nextSceneId: 'chapter_two_choice',
        isPrimary: true,
        progressStage: 1,
        achievements: {
          AchievementType.firstSurvivor,
          AchievementType.illusionBegins,
        },
      ),
    ],
  ),
  'chapter_two_choice': StoryScene(
    id: 'chapter_two_choice',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: الصحو والاختبار',
    mood: AudioMood.interlude,
    text:
        'اختر باباً.\n'
        'ما ستختاره الآن سيكتب ما تبقى من الدورة.\n'
        'الرمز المشقوق يسبقك هذه المرة، كأنه يتذكر قرارك قبل أن تتخذه.',
    choices: [
      StoryChoice(
        text: 'الباب الأول: النفق المائي',
        nextSceneId: 'aquarium_entry',
        isPrimary: true,
        chapterTwoPath: ChapterTwoPath.aquarium,
      ),
      StoryChoice(
        text: 'الباب الثاني: منارة الصحراء',
        nextSceneId: 'lighthouse_entry',
        chapterTwoPath: ChapterTwoPath.lighthouse,
      ),
    ],
  ),
  'aquarium_entry': StoryScene(
    id: 'aquarium_entry',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: النفق المائي',
    mood: AudioMood.aquarium,
    text:
        'لقد اخترت الحوض المائي. أنت الآن داخل نفق زجاجي تحت سطح البحر. '
        'الزجاج متصدع بشدة، لكنه يصمد. أسماك هائلة تنساب بصمت فوقك. لست وحدك. '
        'هناك شيء خارج الزجاج... يراقبك. يتبعك.\n\n'
        'النفق لا ينتهي. لا طعام هنا، والنوم يكاد يكون مستحيلاً.',
    choices: [
      StoryChoice(
        text: 'استمر في المشي بسرعة',
        nextSceneId: 'aquarium_entity',
        isPrimary: true,
        sanityDelta: -6,
        awarenessDelta: 4,
      ),
      StoryChoice(
        text: 'تفحص التشققات في الزجاج',
        nextSceneId: 'aquarium_entity',
        awarenessDelta: 10,
        lore: {LoreEntry.glassNature},
      ),
    ],
  ),
  'aquarium_entity': StoryScene(
    id: 'aquarium_entity',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: الكيان',
    mood: AudioMood.aquarium,
    text:
        'تتذكر القاعدة:\n\n'
        '"ذلك الكيان لن يتركك أبداً. وإن أبصرت المخلوق داخل النفق يوماً، '
        'فتوقف فوراً واهرب في الاتجاه المعاكس. وكل ما عليك أن ترجو... '
        'ألا يكون قد رآك."\n\n'
        'الظل الآن أقرب من أن يكون مجرد انعكاس.',
    choices: [
      StoryChoice(
        text: 'تتبع الظل بنظرك',
        nextSceneId: 'aquarium_corridor',
        isPrimary: true,
        awarenessDelta: 16,
        sanityDelta: -10,
        lore: {LoreEntry.abyssEyes},
        markSawEntity: true,
      ),
      StoryChoice(
        text: 'تتجنب النظر وتركز على الطريق',
        nextSceneId: 'aquarium_corridor',
        sanityDelta: 6,
        stabilityDelta: 4,
      ),
      StoryChoice(
        text: 'تطبق التحذير: تهرب عكس الاتجاه فوراً',
        nextSceneId: 'aquarium_corridor',
        sanityDelta: 2,
        awarenessDelta: 8,
        achievements: {AchievementType.cautiousSurvivor},
        markSawEntity: true,
      ),
    ],
  ),
  'aquarium_corridor': StoryScene(
    id: 'aquarium_corridor',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: الممر الوردي',
    mood: AudioMood.aquarium,
    text:
        'العداد يشير: ٢٤ ساعة متبقية. النفق يتغير فجأة. الجدران تنحني، '
        'والضوء يتحول إلى وردي باهت. أمامك ممر ضيق ينبعث منه صوت جرس بعيد.',
    choices: [
      StoryChoice(
        text: 'ادخل الممر',
        nextSceneId: 'chapter_two_end',
        isPrimary: true,
        awarenessDelta: 4,
        transitionState: TransitionState.exhaustedAware,
      ),
      StoryChoice(
        text: 'انتظر في الظلام',
        nextSceneId: 'chapter_two_end',
        sanityDelta: -2,
        transitionState: TransitionState.passiveHiding,
      ),
    ],
  ),
  'lighthouse_entry': StoryScene(
    id: 'lighthouse_entry',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: منارة الصحراء',
    mood: AudioMood.lighthouse,
    text:
        'لقد اخترت المنارة. أنت داخل برج حجري في قلب صحراء لا نهائية. الحرارة خانقة، '
        'والسكون يلف المكان. رمال تمتد إلى ما لا نهاية تحت ضوء نهار ثابت. '
        'المنارة توفر مأوى جيداً، وطعاماً، وماء.\n\n'
        'أحياناً يخيل إليك أنك ترى شيئاً في الأفق، لكن ما إن ترمش حتى يختفي.',
    choices: [
      StoryChoice(
        text: 'استرح واكتب في الدفتر',
        nextSceneId: 'lighthouse_mirage',
        isPrimary: true,
        sanityDelta: 10,
        lore: {LoreEntry.lighthouseNotes},
      ),
      StoryChoice(
        text: 'افحص لوحة التحكم والأدوات',
        nextSceneId: 'lighthouse_mirage',
        awarenessDelta: 12,
        stabilityDelta: 4,
      ),
    ],
  ),
  'lighthouse_mirage': StoryScene(
    id: 'lighthouse_mirage',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: السراب',
    mood: AudioMood.lighthouse,
    text:
        'على المكتب الأمامي: لوحة تحكم، أدوات، دفتر وقلم. '
        'خارج الزجاج، الرمال تتحرك كأنها تحفظك عن ظهر قلب.\n\n'
        '"استمتع بإقامتك هنا... ستكون آمناً."',
    choices: [
      StoryChoice(
        text: 'ترمش عمداً لاختبار الرؤية',
        nextSceneId: 'lighthouse_end',
        isPrimary: true,
        awarenessDelta: 10,
        lore: {LoreEntry.repetitionIllusion},
        achievements: {AchievementType.mirageBreaker},
        markIntentionalBlink: true,
      ),
      StoryChoice(
        text: 'تحدق دون رمش',
        nextSceneId: 'lighthouse_end',
        awarenessDelta: 14,
        sanityDelta: -8,
      ),
      StoryChoice(
        text: 'تغلق الستائر وتعزل نفسك',
        nextSceneId: 'lighthouse_end',
        sanityDelta: 6,
        stabilityDelta: 6,
        achievements: {AchievementType.recluse},
        markClosedCurtains: true,
      ),
    ],
  ),
  'lighthouse_end': StoryScene(
    id: 'lighthouse_end',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.story,
    title: 'الفصل الثاني: نهاية الاختبار',
    mood: AudioMood.lighthouse,
    text:
        'العداد يشير: ٢٤ ساعة متبقية. الرمال خارج النافذة تبدأ بالتحرك عكس اتجاه الرياح. '
        'اللوحة تصدر طنيناً منخفضاً. الجرس يرن.',
    choices: [
      StoryChoice(
        text: 'فعّل بروتوكول الطوارئ على اللوحة',
        nextSceneId: 'chapter_two_end',
        isPrimary: true,
        awarenessDelta: 6,
        markEmergencyProtocol: true,
        transitionState: TransitionState.techAnchored,
      ),
      StoryChoice(
        text: 'اخرج لمواجهة السراب',
        nextSceneId: 'chapter_two_end',
        awarenessDelta: 8,
        sanityDelta: -6,
        transitionState: TransitionState.directIllusion,
      ),
    ],
  ),
  'chapter_two_end': StoryScene(
    id: 'chapter_two_end',
    chapter: ChapterType.chapterTwo,
    kind: SceneKind.cutscene,
    title: 'نهاية الفصل الثاني',
    mood: AudioMood.interlude,
    text:
        'يعود الجرس، لكن هذه المرة من داخل رأسك. الفضاء ينهار في خط واحد، '
        'والرمز المشقوق يتحول إلى جرح مضيء يقودك نحو غرفة لا تنتمي لأي مكان.',
    choices: [
      StoryChoice(
        text: 'ادخل الفصل الثالث',
        nextSceneId: 'chapter_three_intro',
        isPrimary: true,
        progressStage: 2,
      ),
    ],
  ),
  'chapter_three_intro': StoryScene(
    id: 'chapter_three_intro',
    chapter: ChapterType.chapterThree,
    kind: SceneKind.story,
    title: 'الفصل الثالث: نقطة التلاشي',
    mood: AudioMood.finalRoom,
    text:
        'ينهار الجدار الزجاجي. تنسحب الرمال. يفيض الماء. تتقاطع الأصوات: '
        'همس النفق، طنين اللوحة، جرس بعيد، ودفقات قلم على ورق.\n\n'
        'أنت الآن في غرفة لا تنتمي إلى مكان. جدرانها مرآة، وسرير، ولوحة تحكم، '
        'ونافذة على لا شيء.\n\n'
        'العداد يتوقف. ٠٠:٠٠.\n\n'
        'صوت يتردد من كل اتجاه:\n'
        '"اكتملت الدورة. الوهم لم يكن سجنك... كان انعكاسك. '
        'الآن تختار: هل تلم الأشلاء، أم تتركها تتهادى في الظل؟"',
    choices: [
      StoryChoice(
        text: 'افحص المرآة بعمق',
        nextSceneId: 'ending_result',
        isPrimary: true,
        finalRoute: FinalRoute.mirror,
      ),
      StoryChoice(
        text: 'اقترب من لوحة التحكم',
        nextSceneId: 'ending_result',
        finalRoute: FinalRoute.panel,
      ),
      StoryChoice(
        text: 'أغلق عينيك واستسلم',
        nextSceneId: 'ending_result',
        finalRoute: FinalRoute.surrender,
      ),
      StoryChoice(
        text: 'اترك الغرفة دون قرار',
        nextSceneId: 'ending_result',
        finalRoute: FinalRoute.observer,
      ),
    ],
  ),
  'ending_result': StoryScene(
    id: 'ending_result',
    chapter: ChapterType.ending,
    kind: SceneKind.ending,
    title: 'النهاية',
    mood: AudioMood.silence,
    text: '',
    choices: [],
  ),
};
