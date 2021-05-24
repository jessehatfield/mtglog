% Oops all spells logic

% Main evaluation function: determine whether a hand can win
play_oops_hand(HAND, LIBRARY, SB, MULLIGANS, INPUT_PARAMS, OUTPUTS) :-
    get_or_default(INPUT_PARAMS, greedy_mulligans, 0, GREEDY_MULLIGANS),
    get_or_default(INPUT_PARAMS, protection, 0, DESIRED_PROTECTION),
    get_or_default(INPUT_PARAMS, wincon, any, REQUIRED_WINCON),
    ((GREEDY_MULLIGANS > MULLIGANS, REQUIRED_PROTECTION is DESIRED_PROTECTION)
    ; (GREEDY_MULLIGANS =< MULLIGANS, REQUIRED_PROTECTION is 0)),
    combination(HAND, MULLIGANS, BOTTOM, MULL_HAND),
    append(LIBRARY, BOTTOM, MULL_LIBRARY),
    protected_win(MULL_HAND, MULL_LIBRARY, SB, REQUIRED_PROTECTION, 3, REQUIRED_WINCON, SEQ, PROTECTION),
    ((PROTECTION >= DESIRED_PROTECTION, IS_PROTECTED = true)
    ; PROTECTION < DESIRED_PROTECTION, IS_PROTECTED = false),
    OUTPUTS = _{sequence:SEQ,protection:PROTECTION,keep:MULL_HAND,isProtected:IS_PROTECTED},
    !.

protected_win(HAND, DECK, SB, MIN_PROTECTION, TARGET_PROTECTION, REQUIRED_WINCON, SEQUENCE, TARGET_PROTECTION) :-
    prune_protection(TARGET_PROTECTION, HAND),
    win_specific(HAND, DECK, SB, REQUIRED_WINCON, SEQUENCE, TARGET_PROTECTION),
    TARGET_PROTECTION >= MIN_PROTECTION.
protected_win(HAND, DECK, SB, MIN_PROTECTION, TARGET_PROTECTION, REQUIRED_WINCON, SEQUENCE, BEST_PROTECTION) :-
    TARGET_PROTECTION > 0,
    TARGET_PROTECTION > MIN_PROTECTION,
    NEW_TARGET is TARGET_PROTECTION-1,
    protected_win(HAND, DECK, SB, MIN_PROTECTION, NEW_TARGET, REQUIRED_WINCON, SEQUENCE, BEST_PROTECTION).
protected_win(HAND, DECK, SB, REQUIRED_WINCON, SEQUENCE, PROTECTION) :-
    protected_win(HAND, DECK, SB, 0, 3, REQUIRED_WINCON, SEQUENCE, PROTECTION).

win_specific(HAND, DECK, SB, any, SEQUENCE, TARGET_PROTECTION) :-
    win(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION).
win_specific(HAND, DECK, SB, oops, SEQUENCE, TARGET_PROTECTION) :-
    win_oops(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION).
win_specific(HAND, DECK, SB, empty, SEQUENCE, TARGET_PROTECTION) :-
    win_empty(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION).

win(HAND, SEQUENCE) :-
    win(HAND, [], SEQUENCE, _).
win(HAND, SEQUENCE, PROTECTION) :-
    win(HAND, [], SEQUENCE, PROTECTION).
win(HAND, DECK, SEQUENCE, PROTECTION) :-
    win(HAND, DECK, [], SEQUENCE, PROTECTION).
win(HAND, DECK, SB, SEQUENCE, PROTECTION) :-
    informer(HAND, DECK, SEQUENCE, PROTECTION);
    spy(HAND, DECK, SEQUENCE, PROTECTION);
    breakfast(HAND, DECK, SEQUENCE, PROTECTION);
    etw(HAND, DECK, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE);
    belcher(HAND, DECK, SEQUENCE, PROTECTION);
    wish_warrens(HAND, DECK, SB, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE);
    wish_spy(HAND, DECK, SB, SEQUENCE, PROTECTION);
    wish_informer(HAND, DECK, SB, SEQUENCE, PROTECTION).
win_oops(HAND, DECK, SB, SEQUENCE, PROTECTION) :-
    informer(HAND, DECK, SEQUENCE, PROTECTION);
    spy(HAND, DECK, SEQUENCE, PROTECTION);
    breakfast(HAND, DECK, SEQUENCE, PROTECTION);
    wish_spy(HAND, DECK, SB, SEQUENCE, PROTECTION);
    wish_informer(HAND, DECK, SB, SEQUENCE, PROTECTION).
win_empty(HAND, DECK, SB, SEQUENCE, PROTECTION) :-
    etw(HAND, DECK, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE);
    wish_warrens(HAND, DECK, SB, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE).

belcher(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    belcher(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
belcher(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    member('Goblin Charbelcher', H1),
    prune(7, H1, B1, G1),
    % Make 4 mana, cast
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Goblin Charbelcher', H2, H3),
    append(B2, ['Goblin Charbelcher'], B3),
    spendGeneric(4, M2, M3),
    append(SEQUENCE1, ['Goblin Charbelcher'], SEQUENCE2),
    % Make 3 more, activate
    makemana([H3, B3, M3, G2, S2, D2, P2], [_, _, M4, _, _, _, PROTECTION], SEQUENCE2, SEQUENCE3),
    append(SEQUENCE2, SEQUENCE3, SEQUENCE),
    spendGeneric(3, M4, _),
    !.

% Can mill deck; might not win.
mill(HAND, SEQUENCE) :-
    mill(HAND, [], SEQUENCE).
mill(HAND, DECK, SEQUENCE) :-
    mill(HAND, DECK, [], SEQUENCE).
mill(HAND, DECK, SB, SEQUENCE) :-
    informer_mill(HAND, DECK, SEQUENCE);
    spy_mill(HAND, DECK, SEQUENCE);
    breakfast_mill(HAND, DECK, SEQUENCE);
    wish_informer_mill(HAND, DECK, SB, SEQUENCE).

% Has win condition, may not be able to use it.
win_condition(HAND, SB, CARD) :-
    CARD = 'Undercity Informer', member(CARD, HAND);
    CARD = 'Balustrade Spy', member(CARD, HAND);
    CARD = 'Breakfast Combo', member('Cephalid Illusionist', HAND), member('Shuko', HAND);
    CARD = 'Goblin Charbelcher', member(CARD, HAND);
    CARD = 'Living Wish', member(CARD, HAND), member('Undercity Informer', SB);
    CARD = 'Living Wish', member(CARD, HAND), member('Balustrade Spy', SB);
    CARD = 'Empty the Warrens', member(CARD, HAND).

% Various ways to win

informer(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    informer(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
informer(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Undercity Informer', H1),
    prune(4, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    informer_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
informer_mill(H1, B1, M1, G1, S1, D1, H4, B3, M5, G3, S3, D3, SEQUENCE_PRIOR, SEQUENCE_FINAL, PROTECTION) :-
    prune(4, H1, B1, G1, M1),
    % Make 2B mana, cast
    makemana_goal('Undercity Informer', [H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], SEQUENCE_PRIOR, SEQUENCE2),
    remove('Undercity Informer', H2, H3),
    spend([0, 0, 1, 0, 0, 0, 2], M2, M3),
    append(SEQUENCE2, ['Undercity Informer'], SEQUENCE3),
    % Make 1 more, activate
    makemana([H3, B2, M3, G2, S2, D2, P2], [H4, B3, M4, G3, S3, D3, PROTECTION], SEQUENCE3, SEQUENCE4),
    append(SEQUENCE3, SEQUENCE4, SEQUENCE_FINAL),
    spendGeneric(1, M4, M5).
informer_mill(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    member('Undercity Informer', START_HAND),
    informer_mill(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

spy(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Balustrade Spy', H1),
    prune(4, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, ['Balustrade Spy'|B1], D1, G1, M1, [], _, _),
    % Then attempt it for real
    spy_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
spy_mill(H1, B1, M1, G1, S1, D1, H3, B3, M3, G2, S2, D2, SEQUENCE_PRIOR, SEQUENCE_FINAL, PROTECTION) :-
    prune(4, H1, B1, G1, M1),
    % Make 3B mana, cast
    makemana_goal('Balustrade Spy', [H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, PROTECTION], SEQUENCE_PRIOR, SEQUENCE2),
    remove('Balustrade Spy', H2, H3),
    spend([0, 0, 1, 0, 0, 0, 3], M2, M3),
    append(SEQUENCE2, ['Balustrade Spy'], SEQUENCE_FINAL),
    append(B2, ['Balustrade Spy'], B3).
spy_mill(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    member('Balustrade Spy', START_HAND),
    spy_mill(START_HAND, [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

breakfast(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    breakfast(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
breakfast(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    member('Cephalid Illusionist', H1),
    member('Shuko', H1),
    canInformer(H1, G1, D1),
    breakfast_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
breakfast_mill(H1, B1, M1, G1, S1, D1, H4, B3, M3, G2, S2, D2, SEQUENCE_PRIOR, SEQUENCE_FINAL, PROTECTION) :-
    prune(3, H1, B1, G1, M1),
    % Make 2U, cast combo
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, PROTECTION], SEQUENCE_PRIOR, SEQUENCE2),
    remove('Shuko', H2, H3),
    remove('Cephalid Illusionist', H3, H4),
    spend([0, 1, 0, 0, 0, 0, 2], M2, M3),
    append(SEQUENCE2, ['Shuko', 'Cephalid Illusionist'], SEQUENCE_FINAL),
    append(B2, ['Shuko', 'Cephalid Illusionist'], B3).
breakfast_mill(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    member('Shuko', START_HAND),
    member('Cephalid Illusionist', START_HAND),
    breakfast_mill(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

etw(START_HAND, START_DECK, SEQUENCE, STORM, PROTECTION) :-
    etw(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, STORM, PROTECTION).
etw(H1, B1, M1, G1, S1, D1, SEQUENCE, STORM, PROTECTION) :-
    member('Empty the Warrens', H1),
    prune(4, H1, B1, G1, M1),
    % Make 3R mana, cast
    makemana_goal('Empty the Warrens', [H1, B1, M1, G1, S1, D1, 0], [H2, _, M2, _, S2, _, P1], [], SEQUENCE1),
    remove('Empty the Warrens', H2, _),
    spend([0, 0, 0, 1, 0, 0, 3], M2, _),
    STORM is S2 + 1,
    PROTECTION is P1 + 1, % count an ETW win as protected
    append(SEQUENCE1, ['Empty the Warrens'], SEQUENCE),
    !.

wish_warrens(START_HAND, START_DECK, SB, SEQUENCE, STORM, PROTECTION) :-
    member('Empty the Warrens', SB),
    wish_warrens(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, STORM, PROTECTION).
wish_warrens(H1, B1, M1, G1, S1, D1, SEQUENCE, STORM, PROTECTION) :-
    member('Burning Wish', H1),
    prune(6, H1, B1, G1, M1),
    % Cast Burning Wish
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Burning Wish', H2, H3),
    spend([0, 0, 0, 1, 0, 0, 1], M2, M3),
    S3 is S2 + 1,
    append(SEQUENCE1, ['Burning Wish'], SEQUENCE2),
    % Cast ETW
    makemana([H3, B2, M3, G2, S3, D2, P2], [_, _, M4, _, S4, _, P3], SEQUENCE2, SEQUENCE3),
    spend([0, 0, 0, 1, 0, 0, 3], M4, _),
    STORM is S4 + 1,
    PROTECTION is P3 + 1, % count an ETW win as protected
    append(SEQUENCE3, ['Empty the Warrens'], SEQUENCE),
    !.

wish_spy(START_HAND, START_DECK, SB, SEQUENCE, PROTECTION) :-
    member('Balustrade Spy', SB),
    wish_spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
wish_spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Living Wish', H1),
    prune(6, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    % Cast Living Wish
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Living Wish', H2, H3),
    spend([0, 0, 0, 0, 1, 0, 1], M2, M3),
    S3 is S2 + 1,
    append(SEQUENCE1, ['Living Wish'], SEQUENCE2),
    % Cast Spy
    makemana([H3, B2, M3, G2, S3, D2, P2], [H4, B3, M4, G3, _, D3, P3], SEQUENCE2, SEQUENCE3),
    spend([0, 0, 1, 0, 0, 0, 3], M4, M5),
    append(SEQUENCE3, ['Balustrade Spy'], SEQUENCE4),
    informerCombo(H4, B3, D3, G3, M5, SEQUENCE4, SEQUENCE, P4),
    PROTECTION is P3 + P4,
    !.

wish_informer(START_HAND, START_DECK, SB, SEQUENCE, PROTECTION) :-
    member('Undercity Informer', SB),
    wish_informer(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
wish_informer(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Living Wish', H1),
    prune(6, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    wish_informer_mill(H1, B1, M1, G1, S1, D1, 0, H2, B2, M2, G2, _, D2, SEQUENCE_MILL, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE_MILL, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
wish_informer_mill(H1, B1, M1, G1, S1, D1, P1, H5, B4, M7, G4, S5, D4, P4, SEQUENCE) :-
    prune(6, H1, B1, G1, M1),
    % Cast Living Wish
    makemana([H1, B1, M1, G1, S1, D1, P1], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Living Wish', H2, H3),
    spend([0, 0, 0, 0, 1, 0, 1], M2, M3),
    S3 is S2 + 1,
    append(SEQUENCE1, ['Living Wish'], SEQUENCE2),
    % Cast Informer
    makemana([H3, B2, M3, G2, S3, D2, P2], [H4, B3, M4, G3, S4, D3, P3], SEQUENCE2, SEQUENCE3),
    spend([0, 0, 1, 0, 0, 0, 2], M4, M5),
    append(SEQUENCE3, ['Undercity Informer'], SEQUENCE4),
    % Make 1 more, activate
    makemana([H4, B3, M5, G3, S4, D3, P3], [H5, B4, M6, G4, S5, D4, P4], SEQUENCE4, SEQUENCE),
    spendGeneric(1, M6, M7).
wish_informer_mill(START_HAND, START_DECK, SB, SEQUENCE) :-
    member('Undercity Informer', SB),
    member('Living Wish', START_HAND),
    wish_informer_mill(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE),
    !.

informerCombo(HAND, BOARD, LIBRARY, START_GY, MANA, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    zone_type_count(BOARD, creature, START_CREATURES),
    informerCombo(HAND, BOARD, LIBRARY, START_GY, MANA, START_CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION).
informerCombo(HAND, BOARD, LIBRARY, START_GY, MANA, START_CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    % Mill the deck and make Narcomoebas
    count('Narcomoeba', LIBRARY, MOEBAS),
    CREATURES is START_CREATURES + MOEBAS,
    append(START_GY, LIBRARY, GY),
    informer_win(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION),
    !.
informer_win(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    informer_win_dr(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION);
    informer_win_cast(HAND, BOARD, GY, MANA, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION).
informer_win_dr(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    % Do anything we might need to before DR. In addition to total number of
    % creatures, track how many are tokens (should be zero at this point).
    flashback(HAND, GY, MANA, CREATURES, 0,
        NEXT_HAND, NEXT_GY, NEXT_MANA, NEXT_CREATURES, _,
        FLASHBACK_SEQUENCE),
    % Cast Dread Return and win the game
    NEXT_CREATURES > 2,
    member('Dread Return', NEXT_GY),
    member('Thassa\'s Oracle', NEXT_GY),
    append(PRIOR_SEQUENCE, FLASHBACK_SEQUENCE, S3),
    append(S3, ['DR->Oracle'], INTERMEDIATE_SEQUENCE),
    finalize([NEXT_HAND, BOARD, NEXT_MANA, NEXT_GY, 0, [], 0], [_, _, _, _, _, _, PROTECTION], INTERMEDIATE_SEQUENCE, TOTAL_SEQUENCE, _).
informer_win_cast(H1, B1, G1, M1, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    % Cast the win condition from your hand instead
    member('Thassa\'s Oracle', H1),
    prune(2, H1, B1, G1, M1),
    % Make UU, cast
    % (storm doesn't matter here so just reset it -- inputs need to be bound)
    makemana([H1, B1, M1, G1, 0, [], 0], [H2, B2, M2, G2, _, D2, PROTECTION1], PRIOR_SEQUENCE, S2),
    spend([0, 2, 0, 0, 0, 0, 0], M2, M3),
    remove('Thassa\'s Oracle', H2, H3),
    append(S2, ['Oracle'], INTERMEDIATE_SEQUENCE),
    finalize([H3, B2, M3, G2, 0, D2, PROTECTION1], [_, _, _, _, _, _, PROTECTION], INTERMEDIATE_SEQUENCE, TOTAL_SEQUENCE, _).

finalize(STATE, STATE, SEQ, SEQ, 0) :-
    state_hand(STATE, HAND),
    hand_maxprotection(HAND, 0).
finalize(STATE1, FINAL_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE, P_DELTA) :-
    finalize(STATE1, FINAL_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE),
    state_protection(STATE1, P1),
    state_protection(FINAL_STATE, P2),
    P_DELTA = P2 - P1,
    (P2 > P1; P1 > P2).
finalize(STATE, STATE, SEQ, SEQ, 0).
finalize(STATE, STATE, SEQ, SEQ) :-
    state_hand(STATE, HAND),
    hand_maxprotection(HAND, 0).
finalize(STATE1, FINAL_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    makemana(STATE1, STATE2, PRIOR_SEQUENCE, [H|T]),
    append(PRIOR_SEQUENCE, [H|T], SEQ3),
    finalize(STATE2, FINAL_STATE, SEQ3, TOTAL_SEQUENCE).
finalize(STATE, STATE, SEQ, SEQ).

% Check the existance of a dread-returnable win condition
canInformer(HAND, GY, DECK) :-
    haveCard('Dread Return', [HAND, GY, DECK]),
    haveCard('Thassa\'s Oracle', [HAND, GY, DECK]).

haveCard(NAME, [H | T]) :-
    member(NAME, H);
    haveCard(NAME, T).

% Given a hand and library, make sure the library contains enough cards to win
library_contains_win(_, LIBRARY) :-
    member('Dread Return', LIBRARY),
    member('Thassa\'s Oracle', LIBRARY),
    count('Narcomoeba', LIBRARY, MOEBAS),
    count('Bridge from Below', LIBRARY, BRIDGES),
    count('Cabal Therapy', LIBRARY, THERAPIES),
    (
        MOEBAS >= 3;
        MOEBAS == 2, BRIDGES >= 2, THERAPIES >= 1;
        MOEBAS == 1, BRIDGES >= 3, THERAPIES >= 1
    ).

flashback(HAND, GY, MANA, CREATURES, TOKENS, HAND, GY, MANA, CREATURES, TOKENS, []).
flashback(HAND, GY, MANA, CREATURES, TOKENS, END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, SEQUENCE) :-
    % Bring back a Phantasmagorian
    member('Phantasmagorian', GY),
    take(X, HAND, H2),
    take(Y, H2, H3),
    take(Z, H3, H4),
    append(GY, [X, Y, Z], NEXT_GY),
    flashback(['Phantasmagorian'|H4], NEXT_GY, MANA, CREATURES, TOKENS,
        END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Phantasmagorian' | S2];

    % Flashback a Cabal Therapy with a non-token, get a Bridge token
    remove('Cabal Therapy', GY, NEXT_GY),
    member('Bridge from Below', GY),
    CREATURES > 0,
    CREATURES > TOKENS,
    NEXT_TOKENS is TOKENS + 1,
    remove_all(_, HAND, NEXT_HAND, REMOVED),
    append(NEXT_GY, REMOVED, FINAL_GY),
    flashback(NEXT_HAND, FINAL_GY, MANA, CREATURES, NEXT_TOKENS,
        END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Cabal Therapy with a non-token, don't get a Bridge token
    remove('Cabal Therapy', GY, NEXT_GY),
    CREATURES > 0,
    CREATURES > TOKENS,
    NEXT_CREATURES is CREATURES - 1,
    remove_all(_, HAND, NEXT_HAND, REMOVED),
    append(NEXT_GY, REMOVED, FINAL_GY),
    flashback(NEXT_HAND, FINAL_GY, MANA, NEXT_CREATURES, TOKENS,
        END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Cabal Therapy with a token
    remove('Cabal Therapy', GY, NEXT_GY),
    CREATURES > 0,
    TOKENS > 0,
    NEXT_CREATURES is CREATURES - 1,
    NEXT_TOKENS is TOKENS - 1,
    remove_all(_, HAND, NEXT_HAND, REMOVED),
    append(NEXT_GY, REMOVED, FINAL_GY),
    flashback(NEXT_HAND, FINAL_GY, MANA, NEXT_CREATURES, NEXT_TOKENS,
        END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Lingering Souls
    remove('Lingering Souls', GY, NEXT_GY),
    spend([0,0,1,0,0,0,1], MANA, NEXT_MANA),
    SEQUENCE = ['Lingering Souls'],
    NEXT_CREATURES = CREATURES + 2,
    NEXT_TOKENS = TOKENS + 2,
    flashback(HAND, NEXT_GY, NEXT_MANA, NEXT_CREATURES, NEXT_TOKENS,
        END_HAND, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Lingering Souls' | S2].

remove_all(_, [], [], []).
remove_all(H, [H|T], NEXT, [H|R2]) :-
    remove_all(H, T, NEXT, R2).
remove_all(ITEM, [H|T], [H|T2], REMOVED) :-
    dif(ITEM, H),
    remove_all(ITEM, T, T2, REMOVED).

canpass(SEQUENCE) :-
    not(member('Pact of Negation', SEQUENCE)),
    not(member('Summoner\'s Pact', SEQUENCE)).

hand_maxprotection([], 0).
hand_maxprotection([H|T], P) :-
    protection(H, P1),
    hand_maxprotection(T, P2),
    P is P1 + P2.
