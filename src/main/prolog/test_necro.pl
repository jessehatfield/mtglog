load_necro :-
    source_file(load_necro, Filename),
    file_directory_name(Filename, Dir),
    working_directory(_, Dir),
    consult('test_oops.pl'),
    load_oops,
    consult('necro.pl').

run_necro_tests :-
    load_necro,
    debug,
    use_module(library(prolog_stack)),
    time(test_cast_necro),
    time(test_necro_no_payoff),
    time(test_necro_cant_cast),
    time(test_necro_borne),
    time(test_necro_valakut),
    time(test_necrologia),
    time(test_leyline),
    time(test_necro_no_win),
    time(test_necro_beseech),
    time(test_showdown),
    time(test_electrodominance),
    time(test_necro_lands),
    time(test_slow),
    time(test_storm),
    format('Necrodominance tests passed.', []).

test_cast_necro :-
    format("\nTest casting Necrodominance from hand or using Beseech\n", []),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Pact of Negation'], [], [], 0, 1, 'Necrodominance'),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Pact of Negation'], [], [], 1, 1, 'Necrodominance'),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Pact of Negation'], [], [], 2, 0, 'Necrodominance'),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Unmask'], [], [], 0, 1, 'Necrodominance'),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Unmask'], [], [], 1, 0, 'Necrodominance'),
    hand_wins_(['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Unmask'], [], [], 2, 0, 'Necrodominance'),
    not(hand_wins_(['Vault of Whispers', 'Cabal Ritual', 'Simian Spirit Guide', 'Elvish Spirit Guide', 'Beseech the Mirror'], [], [], 0, 0)),
    hand_wins_(['Vault of Whispers', 'Cabal Ritual', 'Simian Spirit Guide', 'Elvish Spirit Guide', 'Beseech the Mirror'], ['Necrodominance'], [], 0, 0, 'Beseech->Necro'),
    not(hand_wins_(['Gemstone Mine', 'Cabal Ritual', 'Simian Spirit Guide', 'Elvish Spirit Guide', 'Beseech the Mirror'], ['Necrodominance'], [], 0, 0)),
    not(hand_wins_(['Vault of Whispers', 'Gemstone Mine', 'Cabal Ritual', 'Simian Spirit Guide', 'Beseech the Mirror'], ['Necrodominance'], [], 0, 0)).

test_necro_no_payoff :-
    format("\nTest post-Necrodominance logic where no Borne or Valakut can be found\n", []),
    LIBRARY = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Lotus Petal', 'Tendrils of Agony', 'Manamorphose',
        'Elvish Spirit Guide', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Chrome Mox', % draw off manamorphose
        'Borne Upon a Wind',
        'Valakut Awakening',
        'Elvish Spirit Guide' % search with Pact
    ],
    HAND_WITH_PACT = ['Gemstone Mine', 'Dark Ritual', 'Pact of Negation', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    hand_wins_(HAND_WITH_PACT, LIBRARY, [], 0, 1, 'Necrodominance', _{fizzle: true}).

test_necro_cant_cast :-
    format("\nTest post-Necrodominance logic where Borne or Valakut exist but can't be cast\n", []),
    LIBRARY = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Lotus Petal', 'Tendrils of Agony', 'Borne Upon a Wind',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Elvish Spirit Guide' % search with Pact
    ],
    HAND_WITH_PACT = ['Gemstone Mine', 'Dark Ritual', 'Pact of Negation', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    hand_wins_(HAND_WITH_PACT, LIBRARY, [], 0, 1, 'Necrodominance', _{fizzle: true}),
    % this one has LED for mana, but we guess blue and can't cast Valakut
    HAND_WITH_LED = ['Gemstone Mine', 'Lion\'s Eye Diamond', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    NEEDS_RED = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Pact of Negation',
        'Chancellor of the Annex', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Cabal Ritual', 'Vault of Whispers', 'Tendrils of Agony', 'Gemstone Mine',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror'
    ],
    hand_wins_(HAND_WITH_LED, NEEDS_RED, [], 0, 0, 'Necrodominance', _{fizzle: true}).

test_necro_borne :-
    format("\nTest post-Necrodominance logic where Borne should be cast, even if Valakut is an option\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    DRAW_BORNE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Beseech the Mirror',
        'Vault of Whispers' % draw with Manamorphose
    ],
    hand_wins_(['Dark Ritual'|HAND_WITH_PACT], DRAW_BORNE, [], 0, 1, 'Necrodominance', _{flash: true, kill: tendrils, lethal: true}), !,
    CANTRIP_BORNE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Rite of Flame',
        'Summoner\'s Pact', 'Gemstone Mine', 'Elvish Spirit Guide', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Chrome Mox', 'Beseech the Mirror',
        'Borne Upon a Wind', % draw with Manamorphose
        'Elvish Spirit Guide' % search with Pact
    ],
    hand_wins_(HAND_WITH_PACT, CANTRIP_BORNE, [], 0, 1, 'Necrodominance', _{flash: true, kill: tendrils, lethal: true}),
    LIBRARY_3MANA = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Borne Upon a Wind',
        'Vault of Whispers', % draw with Manamorphose
        'Elvish Spirit Guide' % search with pact for 3 mana
    ], % can only get to 3 post-borne, so can't win
    hand_wins_(HAND_WITH_PACT, LIBRARY_3MANA, [], 0, 1, 'Necrodominance', _{flash: true, fizzle: true}),
    append(LIBRARY_3MANA, [
        'Pact of Negation', 'Dark Ritual', 'Leyline of Sanctity', 'Chrome Mox', 'Simian Spirit Guide',
        'Beseech the Mirror', 'Chancellor of the Tangle'
    ], LIBRARY_VALAKUT), % with extra cards in deck, Valakut can work
    hand_wins_(HAND_WITH_PACT, LIBRARY_VALAKUT, [], 0, 1, 'Necrodominance', _{flash: true, kill: tendrils, lethal: true}),
    HAND_NEEDS_PETAL = ['Gemstone Mine', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    DECK_NEEDS_PETAL = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Beseech the Mirror', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Tendrils of Agony', 'Vault of Whispers',
        'Valakut Awakening', 'Chrome Mox', 'Borne Upon a Wind', 'Beseech the Mirror',
        'Lotus Petal'
    ],
    hand_wins_(HAND_NEEDS_PETAL, DECK_NEEDS_PETAL, [], 0, 0, 'Necrodominance', _{fizzle: true}),
    hand_wins_(['Lotus Petal'|HAND_NEEDS_PETAL], DECK_NEEDS_PETAL, [], 0, 0, 'Necrodominance', _{flash: true, kill: tendrils, lethal: true}),
    hand_wins_(['Lion\'s Eye Diamond'|HAND_NEEDS_PETAL], DECK_NEEDS_PETAL, [], 0, 0, 'Necrodominance', _{flash: true, kill: tendrils, lethal: true}).

test_necro_valakut :-
    format("\nTest post-Necrodominance logic where Borne is not an option but Valakut is\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    RITUAL = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Dark Ritual',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Cabal Ritual', 'Vault of Whispers', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Gemstone Mine' % draw with Manamorphose
    ],
    hand_wins_(HAND_WITH_PACT, RITUAL, [], 0, 1, 'Necrodominance', _{fizzle: true}),
    append(RITUAL, [
        'Leyline of Sanctity', 'Simian Spirit Guide', 'Borne Upon a Wind', 'Manamorphose', 'Cabal Ritual', 'Chrome Mox'
    ], DRAW_TENDRILS),
    hand_wins_(HAND_WITH_PACT, DRAW_TENDRILS, [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: true}),
    NO_BLUE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Elvish Spirit Guide',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Gemstone Mine', 'Borne Upon a Wind', 'Tendrils of Agony', 'Borne Upon a Wind',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Elvish Spirit Guide' % search with Pact
    ],
    hand_wins_(HAND_WITH_PACT, NO_BLUE, [], 0, 1, 'Necrodominance', _{fizzle: true}),
    append(NO_BLUE, [
        'Manamorphose', 'Simian Spirit Guide', 'Cabal Ritual', 'Chrome Mox'
    ], DRAW_BLUE), % one short of Tendrils mana (since Cabal Ritual can't have Threshold)
    hand_wins_(HAND_WITH_PACT, DRAW_BLUE, [], 0, 1, 'Necrodominance', _{fizzle: true}),
    hand_wins_(HAND_WITH_PACT, ['Chrome Mox'|DRAW_BLUE], [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: true}),
    NO_BORNE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Elvish Spirit Guide',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Gemstone Mine', 'Manamorphose', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Elvish Spirit Guide', % search with Pact
        'Gemstone Mine', 'Gemstone Mine' % draw with Manamorphose
    ],
    hand_wins_(HAND_WITH_PACT, NO_BORNE, [], 0, 1, 'Necrodominance', _{fizzle: true}),
    append(NO_BORNE, [
        'Borne Upon a Wind', 'Simian Spirit Guide', 'Dark Ritual', 'Lotus Petal'
    ], DRAW_BORNE),
    hand_wins_(HAND_WITH_PACT, DRAW_BORNE, [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: true}),
    HAND_WITH_RITUAL = ['Gemstone Mine', 'Dark Ritual', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    NEEDS_RITUAL = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Pact of Negation',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Cabal Ritual', 'Vault of Whispers', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror',
        'Gemstone Mine' % draw with Manamorphose
    ],
    hand_wins_(HAND_WITH_RITUAL, NEEDS_RITUAL, [], 0, 0, 'Necrodominance', _{fizzle: true}),
    append(NEEDS_RITUAL, [
        'Simian Spirit Guide', 'Manamorphose', 'Chrome Mox', 'Borne Upon a Wind', 'Lotus Petal'
    ], DRAW_BORNE_MM),
    hand_wins_(HAND_WITH_RITUAL, DRAW_BORNE_MM, [], 0, 0, 'Necrodominance', _{kill: tendrils, lethal: true}),
    % this one has two LEDs for mana, so we should be able to make red
    HAND_WITH_LED = ['Gemstone Mine', 'Lion\'s Eye Diamond', 'Lion\'s Eye Diamond', 'Necrodominance', 'Beseech the Mirror', 'Dark Ritual'],
    NEEDS_RED = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Pact of Negation',
        'Chancellor of the Annex', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Pact of Negation',
        'Summoner\'s Pact', 'Cabal Ritual', 'Vault of Whispers', 'Tendrils of Agony', 'Gemstone Mine',
        'Valakut Awakening', 'Summoner\'s Pact', 'Beseech the Mirror', 'Beseech the Mirror'
    ],
    hand_wins_(HAND_WITH_LED, NEEDS_RED, [], 0, 0, 'Necrodominance', _{fizzle: true}),
    append(NEEDS_RED, [
        'Simian Spirit Guide', 'Chrome Mox', 'Borne Upon a Wind'
    ], DRAW_BORNE_2),
    hand_wins_(HAND_WITH_LED, DRAW_BORNE_2, [], 0, 0, 'Necrodominance', _{kill: tendrils, lethal: true}).

test_necrologia :-
    format("\nTest post-Necrologia logic\n", []),
    HAND = ['Gemstone Mine', 'Dark Ritual', 'Lotus Petal', 'Necrologia', 'Simian Spirit Guide', 'Rite of Flame'],
    DECK = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Dark Ritual',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Cabal Ritual',
        'Summoner\'s Pact', 'Rite of Flame', 'Vault of Whispers', 'Tendrils of Agony', 'Manamorphose',
        'Valakut Awakening', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Beseech the Mirror',
        'Gemstone Mine' % draw with Manamorphose
    ],
    hand_wins_(HAND, DECK, [], 0, 0, 'Necrologia', _{flash: true, kill: tendrils, lethal: true}),
    NO_MANAMORPHOSE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Elvish Spirit Guide', 'Dark Ritual',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Tendrils of Agony', 'Cabal Ritual',
        'Summoner\'s Pact', 'Rite of Flame', 'Vault of Whispers', 'Tendrils of Agony', 'Gemstone Mine',
        'Valakut Awakening', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Beseech the Mirror'
    ],
    hand_wins_(HAND, NO_MANAMORPHOSE, [], 0, 0, 'Necrologia', _{fizzle: true}),
    hand_wins_(['Lotus Petal'|HAND], NO_MANAMORPHOSE, [], 0, 0, 'Necrologia', _{flash: true}),
    hand_wins_(['Lion\'s Eye Diamond'|HAND], NO_MANAMORPHOSE, [], 0, 0, 'Necrologia', _{flash: true}).

test_leyline :-
    format("\nTest Leyline of Anticipation\n", []),
    HAND = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Dark Ritual', 'Leyline of Anticipation'],
    DECK = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Chancellor of the Annex', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Tendrils of Agony',
        'Leyline of Anticipation', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Chancellor of the Annex'
    ],
    hand_wins_(HAND, DECK, [], 0, 1, 'Necrodominance', _{kill: tendrils, sequence: ['Leyline of Anticipation'|_], lethal: false}),
    DECK2 = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Lion\'s Eye Diamond', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of the Void', 'Tendrils of Agony',
        'Leyline of Anticipation', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Dark Ritual'
    ],
    hand_wins_(HAND, DECK2, [], 0, 1, 'Necrodominance', _{kill: tendrils, sequence: ['Leyline of Anticipation'|_], lethal: true}).

test_necro_no_win :-
    format("\nTest situations where we can cast Borne or Valakut but then have no way to continue\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Dark Ritual'],
    DRAW_BORNE = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Vault of Whispers', 'Summoner\'s Pact', 'Chancellor of the Annex', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Manamorphose',
        'Leyline of Anticipation', 'Summoner\'s Pact', 'Borne Upon a Wind', 'Chancellor of the Annex',
        'Vault of Whispers', % draw with Manamorphose
        'Leyline of Anticipation', % draw with Borne
        'Tendrils of Agony' % can't get there
    ],
    hand_wins_(HAND_WITH_PACT, DRAW_BORNE, [], 0, 1, 'Necrodominance', _{fizzle: true}).

test_necro_beseech :-
    format("\nTest situations where we can Beseech for Tendrils\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Dark Ritual'],
    DRAW_BORNE_BESEECH = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Beseech the Mirror', 'Summoner\'s Pact', 'Chancellor of the Annex', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Manamorphose',
        'Leyline of Anticipation', 'Cabal Therapy', 'Borne Upon a Wind', 'Dark Ritual',
        'Vault of Whispers', % draw with Manamorphose
        'Leyline of Anticipation', % draw with Borne
        'Tendrils of Agony' % can't get there
    ],
    format('test1:\n', []),
    hand_wins_(HAND_WITH_PACT, DRAW_BORNE_BESEECH, [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: true}),
    BARGAIN_NECRO = [
        'Gemstone Mine', 'Elvish Spirit Guide', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Beseech the Mirror', 'Summoner\'s Pact', 'Chancellor of the Annex', 'Pact of Negation',
        'Simian Spirit Guide', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Manamorphose',
        'Leyline of Anticipation', 'Cabal Therapy', 'Borne Upon a Wind', 'Dark Ritual',
        'Vault of Whispers', % draw with Manamorphose
        'Leyline of Anticipation', % draw with Borne
        'Tendrils of Agony' % can't get there
    ],
    format('test2:\n', []),
    hand_wins_(HAND_WITH_PACT, BARGAIN_NECRO, [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: false}), % can't get to 10 storm
    format('test3:\n', []),
    hand_wins_(['Unmask'|HAND_WITH_PACT], BARGAIN_NECRO, [], 0, 1, 'Necrodominance', _{kill: tendrils, lethal: true}),
    NECROLOGIA_HAND = ['Gemstone Mine', 'Pact of Negation', 'Necrologia', 'Dark Ritual', 'Dark Ritual'],
    format('test4:\n', []),
    hand_wins_(NECROLOGIA_HAND, BARGAIN_NECRO, [], 0, 1, 'Necrologia', _{fizzle: true}).

test_showdown :-
    format("\nTest situations where we cast one or more Fateful Showdowns\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Dark Ritual', 'Lotus Petal'],
    ONE_SHOWDOWN = [
        'Gemstone Mine', 'Lotus Petal', 'Necrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Beseech the Mirror', 'Simian Spirit Guide', 'Dark Ritual', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Fateful Showdown',
        'Leyline of Anticipation', 'Cabal Therapy', 'Tendrils of Agony', 'Dark Ritual'
    ],
    append(ONE_SHOWDOWN, [
        'Vault of Whispers', 'Manamorphose', 'Necrodominance', 'Elvish Spirit Guide', 'Leyline of Anticipation',
        'Dark Ritual', 'Tendrils of Agony', 'Thoughtseize', 'Chancellor of the Annex', 'Fateful Showdown',
        'Chrome Mox', 'Pact of Negation', 'Beseech the Mirror', 'Necrodominance', 'Unmask'
    ], TWO_SHOWDOWNS),
    n_copies(14, 'Island', FINAL_DRAW),
    append(TWO_SHOWDOWNS, FINAL_DRAW, TWO_SHOWDOWNS_DRAW),
    append(ONE_SHOWDOWN, [
        'Vault of Whispers', 'Unmask', 'Necrodominance', 'Elvish Spirit Guide', 'Leyline of Anticipation',
        'Dark Ritual', 'Tendrils of Agony', 'Thoughtseize', 'Chancellor of the Annex', 'Fateful Showdown',
        'Chrome Mox', 'Pact of Negation', 'Beseech the Mirror', 'Necrodominance'
    ], UNCASTABLE),
    hand_wins_(HAND_WITH_PACT, ONE_SHOWDOWN, [], 0, 1, 'Necrodominance', _{fizzle: true, potential_win: true}),
    hand_wins_(HAND_WITH_PACT, TWO_SHOWDOWNS, [], 0, 1, 'Necrodominance', _{fizzle: true, potential_win: true, potential_kill: showdown}),
    hand_wins_(HAND_WITH_PACT, TWO_SHOWDOWNS_DRAW, [], 0, 1, 'Necrodominance', _{fizzle: false, kill: showdown, lethal: true}),
    hand_wins_(HAND_WITH_PACT, UNCASTABLE, [], 0, 1, 'Necrodominance', _{fizzle: true, potential_win: true, potential_kill: showdown}).

test_electrodominance :-
    format("\nTest situations where we can Electrodominance into another win\n", []),
    HAND_WITH_PACT = ['Gemstone Mine', 'Pact of Negation', 'Necrodominance', 'Dark Ritual', 'Lotus Petal'],
    ELECTRODOMINANCE_TENDRILS = [
        'Gemstone Mine', 'Lotus Petal', 'Electrodominance', 'Chancellor of the Annex', 'Unmask',
        'Elvish Spirit Guide', 'Manamorphose', 'Elvish Spirit Guide', 'Dark Ritual', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Vault of Whispers', 'Chrome Mox',
        'Leyline of Anticipation', 'Cabal Therapy', 'Vault of Whispers', 'Gemstone Mine',
        'Tendrils of Agony' % draw with Manamorphose
    ],
    ELECTRODOMINANCE_ALONE = [
        'Gemstone Mine', 'Lotus Petal', 'Electrodominance', 'Chancellor of the Annex', 'Unmask',
        'Simian Spirit Guide', 'Beseech the Mirror', 'Simian Spirit Guide', 'Dark Ritual', 'Summoner\'s Pact',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Leyline of Anticipation', 'Chrome Mox',
        'Leyline of Anticipation', 'Summoner\'s Pact', 'Vault of Whispers', 'Gemstone Mine'
    ],
    append(ELECTRODOMINANCE_ALONE, ['Tendrils of Agony'], ELECTRODOMINANCE_BESEECH),
    hand_wins_(HAND_WITH_PACT, ELECTRODOMINANCE_TENDRILS, [], 0, 1, 'Necrodominance', _{fizzle: false, kill: tendrils, lethal: false, damage: 18}),
    hand_wins_(HAND_WITH_PACT, ELECTRODOMINANCE_ALONE, [], 0, 1, 'Necrodominance', _{fizzle: true, potential_win: false}),
    hand_wins_(HAND_WITH_PACT, ELECTRODOMINANCE_BESEECH, [], 0, 1, 'Necrodominance', _{fizzle: false, kill: tendrils, lethal: true, damage: 24}).

test_necro_lands :-
    format("\nTest situations involving Crop Rotation or other land tricks\n", []),
    HAND = ['Gemstone Mine', 'Necrodominance', 'Dark Ritual'],
    NO_ROTATION_TARGET = [
        'Gemstone Mine', 'Lotus Petal', 'Crop Rotation', 'Chancellor of the Annex', 'Unmask',
        'Elvish Spirit Guide', 'Borne Upon a Wind', 'Elvish Spirit Guide', 'Dark Ritual', 'Emergence Zone',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Vault of Whispers', 'Chrome Mox',
        'Tendrils of Agony', 'Cabal Therapy', 'Vault of Whispers', 'Gemstone Mine',
        'Leyline of Sanctity', % draw with Borne if we can cast it
        'Vault of Whispers' % can make black but we need blue for Borne
    ],
    append(NO_ROTATION_TARGET, ['Gemstone Mine'], ROTATE_FOR_BLUE),
    hand_wins_(HAND, NO_ROTATION_TARGET, [], 0, 0, 'Necrodominance', _{fizzle: true, potential_win: true, potential_kill: tendrils}),
    hand_wins_(HAND, ROTATE_FOR_BLUE, [], 0, 0, 'Necrodominance', _{fizzle: false, kill: tendrils, lethal: true}),
    EMERGE = [
        'Gemstone Mine', 'Lotus Petal', 'Crop Rotation', 'Chancellor of the Annex', 'Unmask',
        'Elvish Spirit Guide', 'Rite of Flame', 'Vault of Whispers', 'Dark Ritual', 'Pact of Negation',
        'Chrome Mox', 'Gemstone Mine', 'Elvish Spirit Guide', 'Vault of Whispers', 'Chrome Mox',
        'Tendrils of Agony', 'Cabal Therapy', 'Vault of Whispers', 'Gemstone Mine',
        'Emergence Zone' % find with Crop Rotation
    ],
    hand_wins_(HAND, EMERGE, [], 0, 0, 'Necrodominance', _{fizzle: false, kill: tendrils, lethal: true}),
    EMERGE_HAND = ['Gemstone Mine', 'Necrodominance', 'Dark Ritual', 'Emergence Zone', 'Lotus Petal'],
    NO_FLASH = [
        'Gemstone Mine', 'Lotus Petal', 'Cabal Ritual', 'Chancellor of the Annex', 'Unmask',
        'Elvish Spirit Guide', 'Cabal Therapy', 'Pact of Negation', 'Dark Ritual', 'Emergence Zone',
        'Chrome Mox', 'Gemstone Mine', 'Pact of Negation', 'Vault of Whispers', 'Chrome Mox',
        'Tendrils of Agony', 'Cabal Therapy', 'Vault of Whispers', 'Gemstone Mine'
    ],
    hand_wins_(EMERGE_HAND, NO_FLASH, [], 0, 0, 'Necrodominance', _{fizzle: false, kill: tendrils, lethal: true}).

test_slow :-
    format("\nTest a combo turn with several branching decisions\n", []),
    HAND = ['Simian Spirit Guide', 'Necrodominance', 'Summoner\'s Pact', 'Cabal Ritual', 'Manamorphose', 'Chancellor of the Annex', 'Lotus Petal'],
    LIBRARY = [
        'Necrodominance', 'Cabal Ritual', 'Borne Upon a Wind', 'Beseech the Mirror', 'Elvish Spirit Guide',
        'Beseech the Mirror', 'Chancellor of the Annex', 'Cabal Ritual', 'Elvish Spirit Guide', 'Dark Ritual',
        'Simian Spirit Guide', 'Dark Ritual', 'Valakut Awakening', 'Valakut Awakening', 'Gemstone Mine',
        'Dark Ritual', 'Pact of Negation', 'Simian Spirit Guide', 'Pact of Negation', % Necro should draw up to here
        'Lotus Petal', % or here if we Pact/Manamorphose
        'Lotus Petal', % or here if we do both
        'Borne Upon a Wind', 'Gemstone Mine', 'Summoner\'s Pact',
        'Necrodominance', 'Vault of Whispers', 'Summoner\'s Pact', 'Vault of Whispers', 'Cabal Ritual',
        'Beseech the Mirror', 'Summoner\'s Pact', 'Lotus Petal', 'Simian Spirit Guide', 'Pact of Negation',
        'Vault of Whispers', 'Elvish Spirit Guide', 'Manamorphose', 'Chrome Mox', 'Borne Upon a Wind',
        'Pact of Negation', 'Tendrils of Agony', 'Chancellor of the Annex', 'Gemstone Mine', 'Manamorphose',
        'Chancellor of the Annex', 'Dark Ritual', 'Elvish Spirit Guide', 'Valakut Awakening', 'Wild Cantor',
        'Vault of Whispers', 'Beseech the Mirror', 'Necrodominance', 'Manamorphose'],
        hand_wins_(HAND, LIBRARY, [], 0, 1, 'Necrodominance', _{kill: tendrils}).

test_storm :-
    format("\nTest logic to storm up to a target value\n", []),
    HAND = [
        'Lotus Petal', 'Cabal Ritual', 'Chancellor of the Annex', 'Unmask',
        'Cabal Therapy', 'Pact of Negation', 'Dark Ritual',
        'Chrome Mox', 'Pact of Negation', 'Chrome Mox',
        'Tendrils of Agony', 'Cabal Therapy', 'Vault of Whispers', 'Gemstone Mine'
    ],
    START_STATE = [HAND, ['Gemstone Mine'], [0,0,0,0,0,0,0], [], 2, [], 0],
    START_SEQ = ['Gemstone Mine', 'Dark Ritual', 'Necrodominance'],
    storm_up(9, 'Tendrils of Agony', START_STATE, _, START_SEQ, _), !,
    storm_up_and_cast(9, 'Tendrils of Agony', START_STATE, _, START_SEQ, _), !,
    % Could get to 10 but only by pitching Tendrils to Unmask
    storm_up(10, 'Pact of Negation', START_STATE, _, START_SEQ, _), !,
    not(storm_up(10, 'Tendrils of Agony', START_STATE, _, START_SEQ, _)), !,
    not(storm_up_and_cast(10, 'Tendrils of Agony', START_STATE, _, START_SEQ, _)), !.
