load_oops :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
    consult('test.pl').

run_oops_tests :-
    load_oops,
    test_spend,
    test_makemana_goal(_, _),
    test_hand_1,
    test_hand_2,
    test_hand_3,
    test_hand_4.

% Should be a simple win, but can take up to 5 minutes to process because of trivial choices
test_hand_1 :-
    LIBRARY = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'],
    HAND = ['Simian Spirit Guide', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Balustrade Spy', 'Lotus Petal', 'Elvish Spirit Guide', 'Lotus Petal'],
    hand_wins_(HAND, LIBRARY, [], 0, 0).

% Should be a simple loss if protection is required, but took several minutes in test run
test_hand_2 :-
    LIBRARY = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'],
    HAND = ['Lion\'s Eye Diamond', 'Lotus Petal', 'Thoughtseize', 'Agadeem\'s Awakening', 'Summoner\'s Pact', 'Undercity Informer', 'Chrome Mox'],
    not(hand_wins_(HAND, LIBRARY, [], 0, 1)),
    hand_wins_(HAND, LIBRARY, [], 0, 0).

% Should be a win, can take over a minute
test_hand_3 :-
    LIBRARY = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle', 'Wild Cantor'],
    HAND = ['Undercity Informer', 'Sea Gate Restoration', 'Pact of Negation', 'Simian Spirit Guide', 'Elvish Spirit Guide', 'Summoner\'s Pact', 'Lion\'s Eye Diamond'],
    hand_wins_(HAND, LIBRARY, [], 0, 0).

% Should work if Narcomoeba+Oracle in hand isn't a problem: if the deck has Bridge+Therapy, if the
% deck has a second Oracle, or if we took a mulligan; shouldn't work otherwise
test_hand_4 :-
    HAND = ['Narcomoeba', 'Thassa\'s Oracle', 'Lotus Petal', 'Lotus Petal', 'Undercity Informer', 'Cabal Ritual', 'Cabal Ritual'],
    not(hand_wins_(HAND, ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide'], [], 0, 0)),
    not(hand_wins_(HAND, ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Bridge from Below'], [], 0, 0)),
    hand_wins_(HAND, ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'], [], 0, 0),
    hand_wins_(HAND, ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide'], [], 1, 0),
    hand_wins_(HAND, ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Bridge from Below', 'Cabal Therapy'], [], 0, 0).

hand_wins_(HAND, LIBRARY, SB, MULLIGANS, PROTECTION) :-
    format('~w\n', [HAND]),
    play_oops_hand(HAND, LIBRARY, SB, MULLIGANS, _{protection:1}, OUTPUTS),
    format(' -->~w (~wx protection)\n', [OUTPUTS.sequence, OUTPUTS.protection]),
    PROTECTION is OUTPUTS.protection.

% Goal-oriented mana generation should be relatively quick despite many trivial options
test_makemana_goal(STATE, SEQUENCE) :-
    HAND = ['Lion\'s Eye Diamond', 'Lotus Petal', 'Thoughtseize', 'Agadeem\'s Awakening', 'Summoner\'s Pact', 'Undercity Informer', 'Chrome Mox'],
    makemana_goal('Undercity Informer', [HAND, [], [0,0,0,0,0,0,0], [], 0, ['Elvish Spirit Guide'], 0], STATE, [], SEQUENCE).

% There is redundancy here with the order it consumes mana, but at least it doesn't spend the any-color
test_spend :-
    spendGeneric(2, [0,0,1,0,1,0,1], [0,0,0,0,0,0,1]),
    not(spendGeneric(2, [0,0,1,0,1,0,1], [0,0,0,0,1,0,0])),
    not(spendGeneric(2, [0,0,1,0,1,0,1], [0,0,1,0,0,0,0])),
    spend([0,0,1,0,0,0,2], [0,0,2,0,1,0,2], [0,0,0,0,0,0,2]),
    not(spend([0,0,1,0,0,0,2], [0,0,2,0,1,0,2], [0,0,1,0,0,0,1])),
    not(spend([0,0,1,0,0,0,2], [0,0,2,0,1,0,2], [0,0,0,0,1,0,1])),
    not(spend([0,0,1,0,0,0,2], [0,0,2,0,1,0,2], [0,0,1,0,1,0,0])).
