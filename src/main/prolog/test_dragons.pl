run_dragons_tests :-
    load_dragons,
    time(test_cast_dragons),
    time(test_rituals),
    time(test_lands),
    time(test_key),
    time(test_artifacts),
    time(test_slow_dragons).

load_dragons :-
    source_file(load_dragons, Filename),
    file_directory_name(Filename, Dir),
    working_directory(_, Dir),
    consult('test_oops.pl'),
    load_oops.

test_cast_dragons :-
    format("\nTest internal dragons functions.\n", []),
    Hand = ['Lotus Petal', 'Ancient Tomb', 'Seething Song', 'Simian Spirit Guide', 'Elemental Eruption'],
    Mana = [0,0,0,0,0,0,0],
    prune(6, Hand, [], [], [], Mana, 0),
    dragons(Hand, [], Mana, [], 0, [], Sequence, 3, 0, 'Elemental Eruption'),
    dragons(Hand, [], Sequence, 3, 0, 'Elemental Eruption'),
    win_dragons(Hand, [], [], Sequence, 0, 'Elemental Eruption', _{storm: 3, dragons: true}),
    win(Hand, [], [], Sequence, 0, 'Elemental Eruption', _{storm: 3, dragons: true}),
    format("  -> ~w\n", [Sequence]),
    !.

test_rituals :-
    format("\nTest basic sequences involving rituals and Elemental Eruption / Stormscale Scion.\n", []),
    Eruption = 'Elemental Eruption',
    Scion = 'Stormscale Scion',
    Hand = ['Lotus Petal', 'Ancient Tomb', 'Seething Song', 'Simian Spirit Guide', 'Elemental Eruption'],
    hand_wins_(Hand, [], [], 0, 0, Eruption, _{storm: 3, wincon: Eruption, dragons: true}),
    hand_wins_(['Spiritmonger' | Hand], [], [], 1, _, _, _{}),
    not(hand_wins_(Hand, [], [], 1, 0, Eruption, _{wincon: Eruption, storm: 3, dragons: true})),
    Rite = ['Rite of Flame', 'Rite of Flame', 'Mountain', 'Seething Song', 'Stormscale Scion'],
    hand_wins_(Rite, [], [], 0, 0, Scion, _{storm: 4, wincon: Scion, dragons: true}),
    Discard = ['Unmask' | ['Spiritmonger' | Rite ]],
    hand_wins_(Discard, [], [], 0, 1, Scion, _{storm: 5, wincon: Scion, dragons: true}),
    not(hand_wins_(Discard, [], [], 1, 1, _, _{})),
    Pact = ['Pact of Negation' | Rite],
    hand_wins_(Pact, [], [], 0, 0, Scion, _{wincon: Scion, dragons: true}),
    not(hand_wins_(Pact, [], [], 0, 1, _, _{})),
    hand_wins_(['Force of Will' | Pact], [], [], 0, 1, Scion, _{wincon: Scion, dragons: true}).

test_lands :-
    format("\nTest that one-land-per-turn is being correctly observed.\n", []),
    TwoTombs = ['Ancient Tomb', 'Ancient Tomb', 'Seething Song', 'Simian Spirit Guide', 'Elemental Eruption'],
    not(hand_wins_(TwoTombs, [], [], 0, _, _, _{})),
    hand_wins_(['Grim Monolith' | TwoTombs], [], [], 0, 0, 'Elemental Eruption', _{storm: 3, dragons: true}).

test_key :-
    format("\nTest building blocks of Voltaic Key logic.\n", []),
    % Untap Grim Monolith to add two colorless
    MonolithSequence = ['Ancient Tomb', 'Grim Monolith', 'Voltaic Key'],
    TwoC = [0, 0, 0, 0, 0, 2, 0],
    FourC = [0, 0, 0, 0, 0, 4, 0],
    StartState = [[], MonolithSequence, TwoC, [], 2, [], 0],
    activate_from_board('Voltaic Key', StartState, UntapMonolithState, MonolithSequence, UntapMonolithSequence),
    makemana('Voltaic Key', StartState, UntapMonolithState, MonolithSequence, UntapMonolithSequence),
    UntapMonolithBoard = ['Ancient Tomb', 'Grim Monolith', 'Voltaic Key_tapped'],
    append(MonolithSequence, ['untap Grim Monolith'], UntapMonolithSequence),
    UntapMonolithState = [[], UntapMonolithBoard, FourC, [], 2, [], 0],
    % Untap Mox Opal to filter G -> any color
    OpalSequence = ['Great Furnace', 'Manifold Key', 'Mox Opal', 'Elvish Spirit Guide'],
    GX = [0, 0, 0, 0, 1, 0, 1],
    XX = [0, 0, 0, 0, 0, 0, 2],
    OpalState = [[], ['Great Furnace', 'Manifold Key', 'Mox Opal'], GX, [], 2, [], 0],
    makemana('Manifold Key', OpalState, UntapOpalState, OpalSequence, UntapOpalSequence),
    UntapOpalBoard = ['Great Furnace', 'Mox Opal', 'Manifold Key_tapped'],
    append(OpalSequence, ['untap Mox Opal'], UntapOpalSequence),
    UntapOpalState = [[], UntapOpalBoard, XX, [], 2, [], 0],
    % Another Mox Opal scenario
    makemana([['The One Ring'],['Shield Sphere','Chrome Mox','Mox Opal','Grim Monolith','Voltaic Key'],[0,0,0,0,0,2,0],[],5,[],0],
        _,
        ['Shield Sphere','Chrome Mox','imprint Elemental Eruption','Mox Opal','Grim Monolith','Voltaic Key'],
        RingSequence),
    member('The One Ring', RingSequence),
    % Untap Chrome Mox to filter colorless -> appropriate options 
    ChromeSequence = ['City of Traitors', 'Manifold Key', 'Chrome Mox', 'imprint Spiritmonger'],
    BC = [0, 0, 1, 0, 0, 1, 0],
    GC = [0, 0, 0, 0, 1, 1, 0],
    BB = [0, 0, 2, 0, 0, 0, 0],
    GG = [0, 0, 0, 0, 2, 0, 0],
    BG = [0, 0, 1, 0, 1, 0, 0],
    UB = [0, 1, 1, 0, 0, 0, 0],
    ChromeStateB = [[], ['City of Traitors', 'Manifold Key', 'Chrome Mox'], BC, [], 2, [], 0],
    ChromeStateG = [[], ['City of Traitors', 'Manifold Key', 'Chrome Mox'], GC, [], 2, [], 0],
    makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, BB, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, BG, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, BC, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, GC, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateG, [[], UntapChromeBoard, GG, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateG, [[], UntapChromeBoard, BG, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateG, [[], UntapChromeBoard, BC, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    makemana('Manifold Key', ChromeStateG, [[], UntapChromeBoard, GC, [], 2, [], 0], ChromeSequence, UntapChromeSequence),
    not(makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, GG, [], 2, [], 0], ChromeSequence, UntapChromeSequence)),
    not(makemana('Manifold Key', ChromeStateG, [[], UntapChromeBoard, BB, [], 2, [], 0], ChromeSequence, UntapChromeSequence)),
    not(makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, TwoC, [], 2, [], 0], ChromeSequence, UntapChromeSequence)),
    not(makemana('Manifold Key', ChromeStateB, [[], UntapChromeBoard, UB, [], 2, [], 0], ChromeSequence, UntapChromeSequence)),
    append(ChromeSequence, ['untap Chrome Mox'], UntapChromeSequence),
    UntapChromeBoard = ['City of Traitors', 'Chrome Mox', 'Manifold Key_tapped'],
    % Try with goal-directed mana generation:
    MonolithKeyState = [['The One Ring'], MonolithSequence, TwoC, [], 2, [], 0],
    FourGeneric = [0, 0, 0, 0, 0, 0, 4],
    makemana_cost_goal(FourGeneric, ['The One Ring'], MonolithKeyState, RingManaState, MonolithSequence, UntapMonolithSequence),
    RingManaState = [['The One Ring'], ['Ancient Tomb', 'Grim Monolith', 'Voltaic Key_tapped'], FourC, [], 2, [], 0],
    !.

test_artifacts :-
    format("\nTest hands involving different kinds of logic involving artifacts.\n", []),
    OneRed = ['Ancient Tomb', 'Grim Monolith', 'Voltaic Key', 'Simian Spirit Guide', 'Elemental Eruption'],
    not(hand_wins_(['Elvish Spirit Guide' | OneRed], [], [], 0, _, _, _{})),
    hand_wins_(['Mox Opal' | OneRed], [], [], 0, 0, 'Elemental Eruption', _{storm: 4, dragons: true}),
    OpalKey = ['Manifold Key', 'Mox Opal', 'Dark Ritual', 'Seething Song', 'Cabal Ritual', 'Elemental Eruption'],
    not(hand_wins_(['Plains' | OpalKey], [], [], 0, _, _, _{})),
    hand_wins_(['Ancient Den' | OpalKey], [], [], 0, 0, 'Elemental Eruption', _{storm: 6, dragons: true}),
    NoMetalcraft = ['Grim Monolith', 'Voltaic Key', 'The One Ring', 'Mox Opal', 'Chrome Mox', 'Elemental Eruption'],
    not(hand_wins_([NoMetalcraft], [], [], 0, _, _, _{})),
    hand_wins_(['Shield Sphere' | NoMetalcraft], [], [], 0, 0, 'The One Ring', _{ring: true}),
    not(hand_wins_(['Shield Sphere' | NoMetalcraft], [], [], 0, _, 'Elemental Eruption', _{})).


test_slow_dragons :-
    format("\nTest hands that have come up in experiments that were slow to evaluate.\n", []),
    Hand1 = ['Force of Will', 'Ancient Den', 'Dragonscale Scion', 'Shield Sphere', 'Emeria\'s Call', 'Pentad Prism', 'Elemental Eruption'],
    not(hand_wins_(Hand1, [], [], 2, _, _, _{})),
    Hand2 = ['Ancient Tomb', 'Chancellor of the Annex', 'Shield Sphere', 'Pentad Prism', 'Dragonscale Scion', 'Pentad Prism', 'Witch Enchanter'],
    not(hand_wins_(Hand2, [], [], 2, _, _, _{})),
    Hand3 = ['Pentad Prism', 'Sink into Stupor', 'Pentad Prism', 'Irencrag Feat', 'Elemental Eruption', 'Elemental Eruption', 'Force of Will'],
    Library = ['Shield Sphere'', ''Tinder Wall', 'Sundering Eruption', 'Dragonscale Scion', 'Ancient Tomb', 'Veil of Summer', 'Pinnacle Monk', 'Ancient Tomb', 'Rite of Flame', 'Force of Will',
        'Dragonscale Scion', 'Rite of Flame', 'Chancellor of the Annex', 'Silence', 'Chancellor of the Annex', 'Ancient Tomb', 'Thoughtseize', 'Dragonscale Scion', 'Elemental Eruption', 'Chancellor of the Tangle',
        'Shield Sphere', 'Sundering Eruption', 'Tree of Tales', 'Sink into Stupor', 'Sink into Stupor', 'Disciple of Freyalise', 'Witch Enchanter', 'Thoughtseize', 'Veil of Summer', 'Disciple of Freyalise',
        'Silence', 'Disciple of Freyalise', 'Chancellor of the Annex', 'Elemental Eruption', 'Great Furnace', 'Ancient Tomb', 'Pinnacle Monk', 'Force of Will', 'Force of Will', 'Sundering Eruption',
        'Shield Sphere', 'Thoughtseize', 'Rite of Flame', 'Disciple of Freyalise', 'Tinder Wall', 'Chancellor of the Annex', 'Thoughtseize', 'Rite of Flame', 'Dragonscale Scion', 'Pinnacle Monk',
        'Sundering Eruption', 'Tinder Wall', 'Pinnacle Monk'],
    not(hand_wins_(Hand3, Library, [], 0, _, _, _{})),
    Hand4 = ['Lotus Petal', 'Thoughtseize', 'Manifold Key', 'Elemental Eruption', 'Simian Spirit Guide', 'Ancient Tomb', 'Mox Opal'],
    not(hand_wins_(Hand4, [], [], 0, _, _, _{})).
