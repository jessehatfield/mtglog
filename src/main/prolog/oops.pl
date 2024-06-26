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
    protected_win(MULL_HAND, MULL_LIBRARY, SB, REQUIRED_PROTECTION, 3, REQUIRED_WINCON, SEQ, PROTECTION, WINCON, METADATA),
    ((PROTECTION >= DESIRED_PROTECTION, IS_PROTECTED = true)
    ; PROTECTION < DESIRED_PROTECTION, IS_PROTECTED = false),
    OUTPUTS = METADATA.put(_{sequence:SEQ,protection:PROTECTION,keep:MULL_HAND,isProtected:IS_PROTECTED,wincon:WINCON}),
    !.

protected_win(HAND, DECK, SB, MIN_PROTECTION, TARGET_PROTECTION, REQUIRED_WINCON, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA) :-
    prune_protection(TARGET_PROTECTION, HAND),
    win_specific(HAND, DECK, SB, REQUIRED_WINCON, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA),
    TARGET_PROTECTION >= MIN_PROTECTION.
protected_win(HAND, DECK, SB, MIN_PROTECTION, TARGET_PROTECTION, REQUIRED_WINCON, SEQUENCE, BEST_PROTECTION, WINCON, METADATA) :-
    TARGET_PROTECTION > 0,
    TARGET_PROTECTION > MIN_PROTECTION,
    NEW_TARGET is TARGET_PROTECTION-1,
    protected_win(HAND, DECK, SB, MIN_PROTECTION, NEW_TARGET, REQUIRED_WINCON, SEQUENCE, BEST_PROTECTION, WINCON, METADATA).
protected_win(HAND, DECK, SB, REQUIRED_WINCON, SEQUENCE, PROTECTION, WINCON) :-
    protected_win(HAND, DECK, SB, 0, 3, REQUIRED_WINCON, SEQUENCE, PROTECTION, WINCON).

win_specific(HAND, DECK, SB, any, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA) :-
    win(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA).
win_specific(HAND, DECK, SB, any, SEQUENCE, TARGET_PROTECTION, WINCON, _{}) :-
    win(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, WINCON).
win_specific(HAND, DECK, SB, oops, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA) :-
    win_oops(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA).
win_specific(HAND, DECK, SB, empty, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA) :-
    win_empty(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, WINCON, METADATA).

win(HAND, SEQUENCE) :-
    win(HAND, [], SEQUENCE, _).
win(HAND, SEQUENCE, PROTECTION) :-
    win(HAND, [], SEQUENCE, PROTECTION).
win(HAND, DECK, SEQUENCE, PROTECTION) :-
    win(HAND, DECK, [], SEQUENCE, PROTECTION, _).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Undercity Informer') :-
    informer(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Balustrade Spy') :-
    spy(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Destroy the Evidence') :-
    destroy(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Lively Dirge') :-
    dirge_spy(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, WINCON) :-
    entomb_reanimate(HAND, DECK, SEQUENCE, PROTECTION, WINCON).
win(HAND, DECK, _, SEQUENCE, PROTECTION, WINCON) :-
    discard_reanimate(HAND, DECK, SEQUENCE, PROTECTION, WINCON).
win(HAND, DECK, _, SEQUENCE, PROTECTION, breakfast) :-
    breakfast(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Empty the Warrens') :-
    etw(HAND, DECK, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE).
win(HAND, DECK, _, SEQUENCE, PROTECTION, belcher) :-
    belcher(HAND, DECK, SEQUENCE, PROTECTION).
win(HAND, DECK, SB, SEQUENCE, PROTECTION, 'Wish->Empty') :-
    wish_warrens(HAND, DECK, SB, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE).
win(HAND, DECK, SB, SEQUENCE, PROTECTION, 'Wish->Spy') :-
    wish_spy(HAND, DECK, SB, SEQUENCE, PROTECTION).
win(HAND, DECK, SB, SEQUENCE, PROTECTION, 'Wish->Informer') :-
    wish_informer(HAND, DECK, SB, SEQUENCE, PROTECTION).
win(HAND, DECK, SB, SEQUENCE, PROTECTION, 'Eldritch->Informer') :-
    ee_informer(HAND, DECK, SB, SEQUENCE, PROTECTION).
win(HAND, DECK, SB, SEQUENCE, PROTECTION, 'Eldritch->Spy') :-
    ee_spy(HAND, DECK, SB, SEQUENCE, PROTECTION).
win(HAND, DECK, _, SEQUENCE, PROTECTION, 'Beseech->Spy', METADATA) :-
    beseech_spy(HAND, DECK, SEQUENCE, PROTECTION, METADATA).

win_oops(HAND, DECK, SB, SEQUENCE, PROTECTION, WINCON, _{}) :-
    member([
        'Undercity Informer',
        'Balustrade Spy',
        'Destroy the Evidence',
        'Lively Dirge',
        'Breakfast',
        'Wish->Spy',
        'Wish->Informer',
        'Beseech->Spy',
        'Entomb->Reanimate',
        'Lively Dirge->Reanimate',
        'Thoughtseize->Reanimate',
        'Unmask->Reanimate'
    ], WINCON),
    (
        win(HAND, DECK, SB, SEQUENCE, PROTECTION, WINCON);
        win(HAND, DECK, SB, SEQUENCE, PROTECTION, WINCON, _)
    ),
    !.

win_empty(HAND, DECK, SB, SEQUENCE, PROTECTION, WINCON, _{}) :-
    etw(HAND, DECK, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE), WINCON is 'Empty the Warrens';
    wish_warrens(HAND, DECK, SB, SEQUENCE, STORM, PROTECTION), STORM >= 4, canpass(SEQUENCE), WINCON is 'Wish->Empty'.

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
    member_or_tutor('Undercity Informer', H1, D1),
    prune(4, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    informer_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    not(contains_spellsonly(SEQUENCE)),
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
    member_or_tutor('Undercity Informer', START_HAND, START_DECK),
    informer_mill(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

spy(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member_or_tutor('Balustrade Spy', H1, D1),
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
    member_or_tutor('Balustrade Spy', START_HAND, START_DECK),
    spy_mill(START_HAND, [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

destroy(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    destroy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
destroy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member_or_tutor('Destroy the Evidence', H1, D1),
    type_threshold(1, land, H1),
    prune(5, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, ['Destroy the Evidence'|B1], D1, G1, M1, [], _, _),
    % Then attempt it for real
    destroy_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
destroy_mill(H1, B1, M1, G1, S1, D1, H3, B3, M3, G3, S2, D2, SEQUENCE_PRIOR, SEQUENCE_FINAL, PROTECTION) :-
    prune(5, H1, B1, G1, M1),
    % Make 4B mana, cast
    makemana_goal('Destroy the Evidence', [H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, PROTECTION], SEQUENCE_PRIOR, SEQUENCE2),
    remove('Destroy the Evidence', H2, H3),
    spend([0, 0, 1, 0, 0, 0, 4], M2, M3),
    remove_first_type(land, B2, B3, REMOVED_LAND),
    append(SEQUENCE2, ['Destroy the Evidence'], SEQUENCE_FINAL),
    append(G2, [REMOVED_LAND, 'Destroy the Evidence'], G3).
destroy_mill(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    member_or_tutor('Destroy the Evidence', START_HAND, START_DECK),
    destroy_mill(START_HAND, [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

beseech_spy(START_HAND, START_DECK, SEQUENCE, PROTECTION, EXTRAS) :-
    beseech_spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION, EXTRAS).
beseech_spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION, EXTRAS) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member_or_tutor('Beseech the Mirror', H1, D1),
    member('Balustrade Spy', D1),
    prune(4, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, ['Balustrade Spy'|B1], D1, G1, M1, [], _, _),
    % Then attempt it for real
    beseech_spy_mill(H1, B1, M1, G1, S1, D1, H2, B2, M2, G2, _, D2, [], SEQUENCE1, P1, SACRIFICE),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    EXTRAS = _{bargain:SACRIFICE},
    !.
beseech_spy_mill(H1, B1, M1, G1, S1, D1, H5, B6, M5, G5, S5, D5, SEQUENCE_PRIOR, SEQUENCE_FINAL, PROTECTION, SACRIFICE) :-
    prune(4, H1, B1, G1, M1),
    member('Balustrade Spy', D1),
    % Make 1BBB mana, cast
    makemana_goal('Beseech the Mirror', [H1, B1, M1, G1, S1, D1, 0], STATE2, SEQUENCE_PRIOR, SEQUENCE2),
    remove_from_hand('Beseech the Mirror', STATE2, STATE3),
    spend_([0, 0, 3, 0, 0, 0, 1], STATE3, STATE4),
    beseech_bargain('Balustrade Spy', STATE4, [H5, B5, M5, G5, S5, D5, PROTECTION], SEQUENCE_SAC, SACRIFICE),
    append(SEQUENCE2, SEQUENCE_SAC, SEQUENCE3),
    append(SEQUENCE3, ['Balustrade Spy'], SEQUENCE_FINAL),
    append(B5, ['Balustrade Spy'], B6).
beseech_spy_mill(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    member_or_tutor('Beseech the Mirror', START_HAND, START_DECK),
    beseech_spy_mill(START_HAND, [0,0,0,0,0,0,0], [], 0, START_DECK, _, _, _, _, _, [], SEQUENCE, PROTECTION),
    !.

dirge_spy(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    dirge_spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
dirge_spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member_or_tutor('Lively Dirge', H1, D1),
    member('Balustrade Spy', D1),
    prune(5, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, ['Balustrade Spy'|B1], D1, G1, M1, [], _, _),
    % Then attempt it for real
    dirge_spy_mill([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, _, D2, P1], [], SEQUENCE1),
    informerCombo(H2, B2, D2, G2, M2, SEQUENCE1, SEQUENCE, P2),
    PROTECTION is P1 + P2,
    !.
dirge_spy_mill(STATE1, STATE_FINAL, SEQUENCE_PRIOR, SEQUENCE_FINAL) :-
    % STATE1 == [H1, B1, M1, G1, S1, D1, P1]
    prune_(5, STATE1),
    % Make 4B mana, cast
    makemana_goal('Lively Dirge', win, STATE1, STATE2, SEQUENCE_PRIOR, SEQUENCE2),
    remove_from_hand('Lively Dirge', STATE2, STATE3),
    spend_([0, 0, 1, 0, 0, 0, 4], STATE3, STATE4),
    remove_from_deck('Balustrade Spy', STATE4, STATE5),
    add_to_board('Balustrade Spy', STATE5, STATE6),
    add_to_grave('Lively Dirge', STATE6, STATE7),
    increment_storm(STATE7, STATE_FINAL),
    append(SEQUENCE2, ['Lively Dirge->Balustrade Spy'], SEQUENCE_FINAL).

entomb_reanimate(START_HAND, START_DECK, SEQUENCE, PROTECTION, WINCON) :-
    entomb_reanimate([START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, 0], SEQUENCE, PROTECTION, WINCON).
entomb_reanimate(START_STATE, SEQUENCE, PROTECTION, WINCON) :-
    % Check that the pieces exist in hand
    role_in_hand(START_STATE, entomb, ENTOMB),
    role_in_hand(START_STATE, animate, ANIMATE),
    in_deck('Balustrade Spy', START_STATE),
    % Check for the total mana optimistically
    card_property(ENTOMB, entomb, cmc, ENTOMB_CMC),
    card_property(ANIMATE, animate, cmc, ANIMATE_CMC),
    REQUIRED_CMC is ENTOMB_CMC + ANIMATE_CMC,
    prune_(REQUIRED_CMC, START_STATE),
    % Check that the combo would work if we could get the Spy in play
    canInformer(START_STATE),
    add_to_board('Balustrade Spy', START_STATE, HYPOTHETICAL_STATE),
    informerCombo(HYPOTHETICAL_STATE, [], _, _),
    % Then look for actual sequences to generate the mana and combo
    card_property(ENTOMB, entomb, cost, ENTOMB_COST),
    card_property(ANIMATE, animate, cost, ANIMATE_COST),
    makemana_goal(ENTOMB, entomb, START_STATE, STATE2, [], SEQUENCE1),
    spend_(ENTOMB_COST, STATE2, STATE3),
    deck_to_grave('Balustrade Spy', STATE3, STATE4),
    hand_to_grave(ENTOMB, STATE4, STATE5),
    append(SEQUENCE1, [ENTOMB], ENTOMB_SEQUENCE),
    makemana_goal(ANIMATE, animate, STATE5, STATE6, [], SEQUENCE2),
    spend_(ANIMATE_COST, STATE6, STATE7),
    grave_to_board('Balustrade Spy', STATE7, STATE8),
    hand_to_grave(ANIMATE, STATE8, STATE9),
    append(SEQUENCE2, [ANIMATE], ANIMATE_SEQUENCE),
    append(ENTOMB_SEQUENCE, ANIMATE_SEQUENCE, SEQUENCE3),
    append(SEQUENCE3, ['->Balustrade Spy'], MILL_SEQUENCE),
    informerCombo(STATE9, MILL_SEQUENCE, SEQUENCE, P2),
    state_protection(START_STATE, P1),
    PROTECTION is P1 + P2,
    string_concat(ENTOMB, '->', ENTOMB_PART),
    string_concat(ENTOMB_PART, ANIMATE, WINCON).

discard_reanimate(START_HAND, START_DECK, SEQUENCE, PROTECTION, WINCON) :-
    discard_reanimate([START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, 0], SEQUENCE, PROTECTION, WINCON).
discard_reanimate(START_STATE, SEQUENCE, PROTECTION, WINCON) :-
    % Check that the pieces exist in hand
    role_in_hand(START_STATE, self_discard, DISCARD),
    role_in_hand(START_STATE, animate, ANIMATE),
    first_in_hand(['Balustrade Spy', 'Undercity Informer'], START_STATE, SPY),
    % Check for the total mana optimistically
    card_property_default(DISCARD, self_discard, cmc, 0, DISCARD_CMC),
    card_property(ANIMATE, animate, cmc, ANIMATE_CMC),
    (
        SPY = 'Balustrade Spy',
        REQUIRED_CMC is DISCARD_CMC + ANIMATE_CMC,
        prune_(REQUIRED_CMC, START_STATE);
        SPY = 'Undercity Informer',
        REQUIRED_CMC is DISCARD_CMC + ANIMATE_CMC + 1,
        prune_(REQUIRED_CMC, START_STATE)
    ),
    % Check that the combo would work if we could get the Spy/Informer in play
    canInformer(START_STATE),
    (
        SPY = 'Balustrade Spy',
        add_to_board(SPY, START_STATE, HYPOTHETICAL_STATE),
        informerCombo(HYPOTHETICAL_STATE, [], _, _);
        SPY = 'Undercity Informer',
        informerCombo(START_STATE, [], _, _)
    ),
    % Then look for actual sequences to generate the mana and combo
    card_property_default(DISCARD, self_discard, cost, [0, 0, 0, 0, 0, 0, 0], DISCARD_COST),
    card_property(ANIMATE, animate, cost, ANIMATE_COST),
    makemana_goal(DISCARD, self_discard, START_STATE, STATE2, [], SEQUENCE1),
    spend_(DISCARD_COST, STATE2, STATE3),
    remove_from_hand(DISCARD, STATE3, STATE4),
    cast(DISCARD, _, SEQUENCE_CAST_DISCARD, STATE4, STATE5, _),
    hand_to_grave(SPY, STATE5, STATE6),
    atomic_list_concat([DISCARD, ' self (', SPY, ')'], DISCARD_STEP),
    append(SEQUENCE1, [DISCARD_STEP], DISCARD_SEQUENCE_PARTIAL),
    append(DISCARD_SEQUENCE_PARTIAL, SEQUENCE_CAST_DISCARD, DISCARD_SEQUENCE),
    makemana_goal(ANIMATE, animate, STATE6, STATE7, [], SEQUENCE2),
    spend_(ANIMATE_COST, STATE7, STATE8),
    remove_from_hand(ANIMATE, STATE8, STATE9),
    cast(ANIMATE, _, SEQUENCE_CAST_ANIMATE, STATE9, STATE10, _),
    grave_to_board(SPY, STATE10, STATE11),
    append(SEQUENCE2, [ANIMATE|SEQUENCE_CAST_ANIMATE], ANIMATE_SEQUENCE),
    append(DISCARD_SEQUENCE, ANIMATE_SEQUENCE, SEQUENCE3),
    (
        % If we reanimated a Spy, mill happens automatically
        SPY = 'Balustrade Spy',
        MILL_STATE = STATE11,
        MILL_SEQUENCE = SEQUENCE3;
        % If the best we could do was Informer, make 1 more mana and activate
        SPY = 'Undercity Informer',
        makemana_cost_goal([0,0,0,0,0,0,1], [], STATE11, REANIMATE_STATE, SEQUENCE3, ACTIVATE_SEQUENCE),
        spend_generic(1, REANIMATE_STATE, MILL_STATE),
        append(ACTIVATE_SEQUENCE, ['activate'], MILL_SEQUENCE)
    ),
    informerCombo(MILL_STATE, MILL_SEQUENCE, SEQUENCE, P2),
    state_protection(START_STATE, P1),
    PROTECTION is P1 + P2,
    atomic_list_concat([DISCARD_STEP, '->', ANIMATE], WINCON).

breakfast(START_HAND, START_DECK, SEQUENCE, PROTECTION) :-
    breakfast(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
breakfast(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    member_or_tutor('Cephalid Illusionist', H1, D1),
    member_or_tutor('Shuko', H1, D1),
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
    member_or_tutor('Shuko', START_HAND, START_DECK),
    member_or_tutor('Cephalid Illusionist', START_HAND, START_DECK),
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
    not(contains_spellsonly(SEQUENCE)),
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

ee_informer(START_HAND, START_DECK, _, SEQUENCE, PROTECTION) :-
    member('Undercity Informer', START_DECK),
    ee_informer(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
ee_informer(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Eldritch Evolution', H1),
    prune(3, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Eldritch Evolution', H2, H3),
    spend([0, 0, 0, 0, 2, 0, 1], M2, M3),
    sacrifice_creature(CREATURE, [H3, B2, M3, G2, S2, D2, P2], [H4, B3, M4, G3, S3, D3, P3], SAC_SEQUENCE),
    append(SEQUENCE1, ['Eldritch Evolution'], SEQUENCE2),
    append(SEQUENCE2, SAC_SEQUENCE, SEQUENCE3),
    append(SEQUENCE3, ['-> Undercity Informer'], SEQUENCE4),
    % Creature should cost >= 1
    card(CREATURE, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cmc, CARD, CMC),
    CMC >= 1,
    remove('Undercity Informer', D3, D4),
    % Make 1 more, activate
    makemana([H4, B3, M4, G3, S3, D4, P3], [H5, B4, M5, G4, _, D5, P4], SEQUENCE4, SEQUENCE5),
    spendGeneric(1, M5, M6),
    informerCombo(H5, B4, D5, ['Undercity Informer'|G4], M6, SEQUENCE5, SEQUENCE, P5),
    not(contains_spellsonly(SEQUENCE)),
    PROTECTION is P4 + P5,
    !.

ee_spy(START_HAND, START_DECK, _, SEQUENCE, PROTECTION) :-
    member('Balustrade Spy', START_DECK),
    ee_spy(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION).
ee_spy(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION) :-
    % Verify that its possible in the best case scenario for mana sequencing
    member('Eldritch Evolution', H1),
    prune(3, H1, B1, G1, M1),
    canInformer(H1, G1, D1),
    informerCombo(H1, B1, D1, G1, M1, [], _, _),
    % Then attempt it for real
    makemana([H1, B1, M1, G1, S1, D1, 0], [H2, B2, M2, G2, S2, D2, P2], [], SEQUENCE1),
    remove('Eldritch Evolution', H2, H3),
    spend([0, 0, 0, 0, 2, 0, 1], M2, M3),
    sacrifice_creature(CREATURE, [H3, B2, M3, G2, S2, D2, P2], [H4, B3, M4, G3, _, D3, P3], SAC_SEQUENCE),
    append(SEQUENCE1, ['Eldritch Evolution'], SEQUENCE2),
    append(SEQUENCE2, SAC_SEQUENCE, SEQUENCE3),
    append(SEQUENCE3, ['-> Balustrade Spy'], SEQUENCE4),
    % Creature should cost >= 2
    card(CREATURE, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cmc, CARD, CMC),
    CMC >= 2,
    remove('Balustrade Spy', D3, D4),
    informerCombo(H4, ['Balustrade Spy'|B3], D4, G3, M4, SEQUENCE4, SEQUENCE, P4),
    PROTECTION is P3 + P4,
    !.

informerCombo([HAND, BOARD, MANA, GRAVEYARD, _, LIBRARY, _], PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    informerCombo(HAND, BOARD, LIBRARY, GRAVEYARD, MANA, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION).

informerCombo(HAND, BOARD, LIBRARY, START_GY, MANA, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    zone_type_count(BOARD, creature, START_CREATURES),
    informerCombo(HAND, BOARD, LIBRARY, START_GY, MANA, START_CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION).
informerCombo(HAND, START_BOARD, LIBRARY, START_GY, MANA, START_CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    % Mill the deck and make Narcomoebas
    count('Narcomoeba', LIBRARY, N_MOEBAS),
    CREATURES is START_CREATURES + N_MOEBAS,
    append(START_GY, LIBRARY, GY_TRIGGER),
    remove_all('Narcomoeba', GY_TRIGGER, GY, MOEBAS),
    append(START_BOARD, MOEBAS, BOARD),
    informer_win(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION),
    !.
informer_win(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    informer_win_dr(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION);
    informer_win_cast(HAND, BOARD, GY, MANA, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION).
informer_win_dr(HAND, BOARD, GY, MANA, CREATURES, PRIOR_SEQUENCE, TOTAL_SEQUENCE, PROTECTION) :-
    % Do anything we might need to before DR. In addition to total number of
    % creatures, track how many are tokens (should be zero at this point).
    flashback(
        HAND, BOARD, GY, MANA, CREATURES, 0,
        NEXT_HAND, NEXT_BOARD, NEXT_GY, NEXT_MANA, NEXT_CREATURES, _,
        FLASHBACK_SEQUENCE),
    % Cast Dread Return and win the game
    NEXT_CREATURES > 2,
    member('Dread Return', NEXT_GY),
    member('Thassa\'s Oracle', NEXT_GY),
    append(PRIOR_SEQUENCE, FLASHBACK_SEQUENCE, S3),
    append(S3, ['DR->Oracle'], INTERMEDIATE_SEQUENCE),
    finalize([NEXT_HAND, NEXT_BOARD, NEXT_MANA, NEXT_GY, 0, [], 0], [_, _, _, _, _, _, PROTECTION], INTERMEDIATE_SEQUENCE, TOTAL_SEQUENCE, _).
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
canInformer([HAND, _, _, GY, _, DECK, _]) :- canInformer(HAND, GY, DECK).

haveCard(NAME, [H | T]) :-
    member(NAME, H);
    haveCard(NAME, T).

% Given a hand and library, make sure the library contains enough cards to win
library_contains_win(_, LIBRARY) :-
    member('Dread Return', LIBRARY),
    member('Thassa\'s Oracle', LIBRARY),
    count('Narcomoeba', LIBRARY, MOEBAS),
    count('Bridge from Below', LIBRARY, BRIDGES),
    count('Poxwalkers', LIBRARY, POXWALKERS),
    count('Cabal Therapy', LIBRARY, THERAPIES),
    (
        MOEBAS >= 3;
        MOEBAS == 2, BRIDGES + POXWALKERS >= 2, THERAPIES >= 1;
        MOEBAS == 1, BRIDGES + POXWALKERS >= 3, THERAPIES >= 1;
        MOEBAS == 1, BRIDGES == 1, POXWALKERS == 1, THERAPIES >= 2
    ).

sacrifice_creature('Poxwalkers', BOARD, NEXT_BOARD) :-
    take('Poxwalkers', BOARD, NEXT_BOARD).
sacrifice_creature(CREATURE, BOARD, NEXT_BOARD) :-
    dif('Poxwalkers', CREATURE),
    remove_first_type(creature, BOARD, NEXT_BOARD, CREATURE).

flashback(HAND, BOARD, GY, MANA, CREATURES, TOKENS, HAND, BOARD, GY, MANA, CREATURES, TOKENS, []).
flashback(HAND, BOARD, GY, MANA, CREATURES, TOKENS, END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, SEQUENCE) :-
    % Bring back a Phantasmagorian
    member('Phantasmagorian', GY),
    take(X, HAND, H2),
    take(Y, H2, H3),
    take(Z, H3, H4),
    append(GY, [X, Y, Z], NEXT_GY),
    flashback(['Phantasmagorian'|H4], BOARD, NEXT_GY, BOARD, MANA, CREATURES, TOKENS,
        END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Phantasmagorian' | S2];

    % Flashback a Cabal Therapy with a non-token, get Bridge tokens and Poxwalkers
    remove('Cabal Therapy', GY, GY2),
    count('Bridge from Below', GY2, BRIDGES),
    sacrifice_creature(SACRIFICE, BOARD, B2),
    append(GY2, [SACRIFICE], GY3),
    count('Poxwalkers', GY3, N_POXWALKERS),
    CREATURES > 0,
    CREATURES > TOKENS,
    NEXT_TOKENS is TOKENS + BRIDGES,
    NEXT_CREATURES is CREATURES + BRIDGES + N_POXWALKERS - 1,
    remove_all('Poxwalkers', GY3, GY4, POXWALKERS),
    append(B2, POXWALKERS, NEXT_BOARD),
    remove_all(_, HAND, NEXT_HAND, REMOVED),
    append(GY4, REMOVED, NEXT_GY),
    flashback(NEXT_HAND, NEXT_BOARD, NEXT_GY, MANA, NEXT_CREATURES, NEXT_TOKENS,
        END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Cabal Therapy with a non-token, get Poxwalkers
    %remove('Cabal Therapy', GY, NEXT_GY),
    %CREATURES > 0,
    %CREATURES > TOKENS,
    %NEXT_CREATURES is CREATURES - 1,
    %remove_all(_, HAND, NEXT_HAND, REMOVED),
    %append(NEXT_GY, REMOVED, FINAL_GY),
    %flashback(NEXT_HAND, FINAL_GY, MANA, NEXT_CREATURES, TOKENS,
    %    END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    %SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Cabal Therapy with a token, get Poxwalkers
    remove('Cabal Therapy', GY, GY2),
    count('Poxwalkers', GY2, N_POXWALKERS),
    CREATURES > 0,
    TOKENS > 0,
    NEXT_CREATURES is CREATURES + N_POXWALKERS - 1,
    NEXT_TOKENS is TOKENS - 1,
    remove_all('Poxwalkers', GY2, GY3, POXWALKERS),
    append(BOARD, POXWALKERS, NEXT_BOARD),
    remove_all(_, HAND, NEXT_HAND, REMOVED),
    append(GY3, REMOVED, NEXT_GY),
    flashback(NEXT_HAND, NEXT_BOARD, NEXT_GY, MANA, NEXT_CREATURES, NEXT_TOKENS,
        END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
    SEQUENCE = ['Cabal Therapy' | S2];

    % Flashback a Lingering Souls
    remove('Lingering Souls', GY, NEXT_GY),
    spend([0,0,1,0,0,0,1], MANA, NEXT_MANA),
    SEQUENCE = ['Lingering Souls'],
    NEXT_CREATURES = CREATURES + 2,
    NEXT_TOKENS = TOKENS + 2,
    flashback(HAND, BOARD, NEXT_GY, NEXT_MANA, NEXT_CREATURES, NEXT_TOKENS,
        END_HAND, END_BOARD, END_GY, END_MANA, END_CREATURES, END_TOKENS, S2),
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

can_powder(HAND, LIBRARY, 0, []) :-
    member('Serum Powder', HAND),
    library_contains_win([], LIBRARY).
can_powder(HAND, LIBRARY, N_BOTTOM, BOTTOM) :-
    N_BOTTOM > 0,
    remove('Serum Powder', HAND, MINUS_POWDER),
    combination(MINUS_POWDER, N_BOTTOM, BOTTOM, _),
    append(LIBRARY, BOTTOM, POWDER_LIBRARY),
    library_contains_win([], POWDER_LIBRARY).
