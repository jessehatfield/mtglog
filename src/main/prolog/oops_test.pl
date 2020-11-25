load_oops :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
    consult('test.pl').

run_oops_tests :-
    load_oops,
    test_informerCombo,
    test_hand_1.

% Should be a simple win, but can take up to 5 minutes to process because of trivial choices
test_hand_1 :-
    LIBRARY = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'],
    HAND = ['Simian Spirit Guide', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Balustrade Spy', 'Lotus Petal', 'Elvish Spirit Guide', 'Lotus Petal'],
    hand_wins_(HAND, LIBRARY, [], 0, 0).

hand_wins_(HAND, LIBRARY, SB, MULLIGANS, PROTECTION) :-
    format('~w\n', [HAND]),
    play_oops_hand(HAND, LIBRARY, SB, MULLIGANS, _{protection:1}, OUTPUTS),
    format(' -->~w (~wx protection)\n', [OUTPUTS.sequence, OUTPUTS.protection]),
    PROTECTION is OUTPUTS.protection.

% Should be easy to verify a win, since no mana generation is necessary, but takes a long time somehow
test_informerCombo :-
    H1 = ['Simian Spirit Guide', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Balustrade Spy', 'Lotus Petal', 'Elvish Spirit Guide', 'Lotus Petal'],
    D1 = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'],
    informerCombo(H1, ['Balustrade Spy'], D1, [], [0,0,0,0,0,0,0], [], _, _).
