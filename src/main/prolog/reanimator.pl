% Reanimator logic

% Main evaluation function: determine whether a hand can reanimate a creature on turn 1
play_reanimator_hand(HAND, LIBRARY, SB, MULLIGANS, INPUT_PARAMS, OUTPUTS) :-
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
    reanimate(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, _).
win_specific(HAND, DECK, SB, TARGET_CREATURE, SEQUENCE, TARGET_PROTECTION) :-
    reanimate(HAND, DECK, SB, SEQUENCE, TARGET_PROTECTION, TARGET_CREATURE).

reanimate(HAND, SEQUENCE, TARGET) :-
    reanimate(HAND, [], SEQUENCE, _, TARGET).
reanimate(HAND, SEQUENCE, PROTECTION, TARGET) :-
    reanimate(HAND, [], SEQUENCE, PROTECTION, TARGET).
reanimate(HAND, DECK, SEQUENCE, PROTECTION, TARGET) :-
    reanimate(HAND, DECK, [], SEQUENCE, PROTECTION, TARGET).
reanimate(HAND, DECK, _, SEQUENCE, PROTECTION, TARGET) :-
    entomb_reanimate(HAND, DECK, SEQUENCE, PROTECTION, TARGET).

entomb_reanimate(START_HAND, START_DECK, SEQUENCE, PROTECTION, TARGET) :-
    entomb_reanimate(START_HAND, [], [0,0,0,0,0,0,0], [], 0, START_DECK, SEQUENCE, PROTECTION, TARGET).
entomb_reanimate(H1, B1, M1, G1, S1, D1, SEQUENCE, PROTECTION, ANIMATE_TARGET) :-
    STATE1 = [H1, B1, M1, G1, S1, D1, 0],
    member('Entomb', H1),
    contains_animate(H1, ANIMATE_SPELL, ANIMATE_CMC, ANIMATE_COST),
    TOTAL_COST = 2 + ANIMATE_CMC,
    prune(TOTAL_COST, H1, B1, G1),
    contains_animate_target(D1, ANIMATE_TARGET),
    % Make B mana, cast Entomb
    makemana(STATE1, STATE2, [], SEQUENCE1),
    remove_from_hand('Entomb', STATE2, STATE3),
    remove_from_deck(ANIMATE_TARGET, STATE3, STATE4),
    add_to_graveyard(ANIMATE_TARGET, STATE4, STATE5),
    add_to_graveyard('Entomb', STATE5, STATE6),
    spend_mana([0, 0, 1, 0, 0, 0, 0], STATE6, STATE7),
    atom_concat('Entomb->', ANIMATE_TARGET, ENTOMB_STEP),
    append(SEQUENCE1, [ENTOMB_STEP], SEQUENCE2),
    % Make more mana, cast animate spell
    makemana(STATE7, [_, _, M2, _, _, _, PROTECTION], SEQUENCE2, SEQUENCE3),
    spend(ANIMATE_COST, M2, _),
    append(SEQUENCE2, SEQUENCE3, SEQUENCE_4),
    atom_concat('->', ANIMATE_TARGET, TARGET_EXPR),
    atom_concat(ANIMATE_SPELL, TARGET_EXPR, ANIMATE_STEP),
    append(SEQUENCE_4, [ANIMATE_STEP], SEQUENCE),
    !.

contains_animate(HAND, CARDNAME, ANIMATE_CMC, ANIMATE_COST) :-
    animate_spell(CARDNAME),
    member(CARDNAME, HAND),
    cmc(CARDNAME, ANIMATE_CMC),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cost, CARD, ANIMATE_COST).

contains_animate_target(DECK, CARDNAME) :-
    animate_target(CARDNAME),
    member(CARDNAME, DECK).

remove_from_hand(CARD, [H1, B1, M1, G1, S1, D1, P1], [H2, B1, M1, G1, S1, D1, P1]) :-
    remove(CARD, H1, H2).
remove_from_deck(CARD, [H1, B1, M1, G1, S1, D1, P1], [H1, B1, M1, G1, S1, D2, P1]) :-
    remove(CARD, D1, D2).
add_to_graveyard(CARD, [H1, B1, M1, G1, S1, D1, P1], [H1, B1, M1, G2, S1, D1, P1]) :-
    append(G1, [CARD], G2).
spend_mana(MANA, [H1, B1, M1, G1, S1, D1, P1], [H1, B1, M2, G1, S1, D1, P1]) :-
    spend(MANA, M1, M2).
