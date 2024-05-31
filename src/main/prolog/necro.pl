post_necro(START_STATE, PRIOR_SEQUENCE, DRAW_SEQ, METADATA, NECRO, PAYOFF) :-
    % Cast sacrificeable permanents without using them, if possible
    cast_leds(START_STATE, CAST_LED_STATE, CAST_LED_SEQ),
    cast_in_order([['Lotus Petal'], ['Wild Cantor']], CAST_LED_STATE, PETAL_STATE, CAST_LED_SEQ, PETAL_SEQ),
    % Empty the mana pool and record that we're in the end step
    end_step_mana(PETAL_STATE, NECRO, PAYOFF, PETAL_SEQ, END_STEP_STATE),
    append([PRIOR_SEQUENCE, PETAL_SEQ, ['end step']], END_STEP_SEQ),
    % Make any mana you can before drawing cards
    spirit_guides(END_STEP_STATE, SG1_STATE, END_STEP_SEQ, SG1_SEQ),
    sac_leds(SG1_STATE, SAC_LED_STATE, SAC_LED_SEQ),
    sac_all_unused(SAC_LED_STATE, NECRO_STATE, SAC_LED_SEQ, SAC_SEQ),
    % Draw and go off
    N_NECRO_DRAW = 19,
    draw_up_to(N_NECRO_DRAW, NECRO_STATE, DRAW_STATE),
    string_concat("draw ", N_NECRO_DRAW, DRAW_STEP),
    append([SG1_SEQ, SAC_SEQ, [DRAW_STEP]], DRAW_SEQ),
    spirit_guides(DRAW_STATE, SG2_STATE, DRAW_SEQ, _),
    % TODO work on post-draw logic
    necro_payoff(PAYOFF, SG2_STATE, METADATA).

cast_leds(STATE1, STATE5, ['Lion\'s Eye Diamond'|LEDS]) :-
    % Cast as many LEDs as you have, without using them
    remove_from_hand('Lion\'s Eye Diamond', STATE1, STATE2),
    increment_storm(STATE2, STATE3),
    add_to_board('Lion\'s Eye Diamond_unused', STATE3, STATE4),
    cast_leds(STATE4, STATE5, LEDS).
cast_leds(STATE1, STATE1, []) :-
    not(in_hand('Lion\'s Eye Diamond', STATE1)).

end_step_mana(START_STATE, _, _, _, START_STATE) :-
    % if there's a Leyline, we should have been able to cast everything at instant speed
    on_board(START_STATE, 'Leyline of Anticipation'), !.
end_step_mana(START_STATE, 'Necrologia', _, SEQ, START_STATE) :-
    % if there are no sorceries and our win condition is Necrologia, assume we could have
    % sequenced things to make the mana during the end step, and can leave it floating
    type_max(SEQ, sorcery, 0), !.
end_step_mana(START_STATE, _, _, _, END_STEP_STATE) :-
    % otherwise, assume we have to empty the mana pool and move to the end step
    update_mana(START_STATE, [0,0,0,0,0,0,0], END_STEP_STATE).

spirit_guides(START_STATE, FINAL_STATE, PRIOR_SEQ, FINAL_SEQ) :-
    % Use any Summoner's Pacts to get ESGs
    pact_for_esgs(START_STATE, PACT_STATE, PRIOR_SEQ, PACT_SEQ),
    % Use any other spirit guides in hand
    cast_in_order([['Elvish Spirit Guide'], ['Simian Spirit Guide']], PACT_STATE, FINAL_STATE, PACT_SEQ, FINAL_SEQ).

pact_for_esgs(START_STATE, END_STATE, PRIOR_SEQ, TOTAL_SEQ) :-
    state_hand(START_STATE, START_HAND),
    state_deck(START_STATE, START_DECK),
    count('Elvish Spirit Guide', START_DECK, ESGS_IN_DECK),
    count('Summoner\'s Pact', START_HAND, PACTS_IN_HAND),
    N_PACT_ESGS is min(PACTS_IN_HAND, ESGS_IN_DECK),
    pact_for_esgs(N_PACT_ESGS, START_STATE, END_STATE, PRIOR_SEQ, TOTAL_SEQ).
pact_for_esgs(0, STATE, STATE, PRIOR_SEQ, PRIOR_SEQ).
pact_for_esgs(N, OLD_STATE, NEW_STATE, PRIOR_SEQ, TOTAL_SEQ) :-
    N > 0,
    N2 is N - 1,
    SEQ1 = ['Summoner\'s Pact', 'find Elvish Spirit Guide'],
    cast_from_hand('Summoner\'s Pact', OLD_STATE, INTERMEDIATE_STATE, [], SEQ1),
    append(PRIOR_SEQ, SEQ1, SEQ2),
    pact_for_esgs(N2, INTERMEDIATE_STATE, NEW_STATE, SEQ2, TOTAL_SEQ).

sac_leds(STATE1, STATE1, []) :-
    % If there are no LEDs in play, do nothing
    state_board(STATE1, BOARD1),
    delete(BOARD1, 'Lion\'s Eye Diamond_unused', BOARD_SACRIFICE),
    length(BOARD1, SIZE1),
    length(BOARD_SACRIFICE, SIZE2),
    SIZE1 == SIZE2.
sac_leds(STATE1, STATE5, [SAC_STEP]) :-
    % If there are any LEDs in play, sacrifice for UUU, then RRR, then BBB
    state_board(STATE1, BOARD1),
    delete(BOARD1, 'Lion\'s Eye Diamond_unused', BOARD_SACRIFICE),
    length(BOARD1, SIZE1),
    length(BOARD_SACRIFICE, SIZE2),
    N_LEDS is SIZE1 - SIZE2,
    N_LEDS > 0,
    state_hand(STATE1, HAND1),
    state_gy(STATE1, GY1),
    n_copies(N_LEDS, 'Lion\'s Eye Diamond', LED_LIST),
    append([GY1, LED_LIST, HAND1], GY_DISCARD),
    update_board(STATE1, BOARD_SACRIFICE, STATE2),
    update_hand(STATE2, [], STATE3),
    update_gy(STATE3, GY_DISCARD, STATE4),
    state_mana(STATE4, FLOATING),
    add_led_mana(N_LEDS, FLOATING, FINAL_MANA),
    update_mana(STATE4, FINAL_MANA, STATE5),
    string_concat('sac LEDx', N_LEDS, SAC_STEP).

add_led_mana(0, FLOATING, FLOATING).
add_led_mana(N, FLOATING, FINAL) :-
    N > 0,
    N2 is N-1,
    add_led_mana(N2, FLOATING, NEXT),
    (
        % if we don't have blue, add blue
        not(haveU(1, NEXT)),
        u(3, NEXT, FINAL);
        % if we have blue but not red, add red
        haveU(1, NEXT),
        not(haveR(1, NEXT)),
        r(3, NEXT, FINAL);
        % otherwise, add black
        haveU(1, NEXT),
        haveR(1, NEXT),
        b(3, NEXT, FINAL)
    ).

sac_all_unused(START_STATE, START_STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    not(sac_unused(_, START_STATE, _, _)).
sac_all_unused(START_STATE, END_STATE, PRIOR_SEQUENCE, FINAL_SEQUENCE) :-
    sac_unused(_, START_STATE, SAC_STATE, STEP),
    append(PRIOR_SEQUENCE, [STEP], SAC_SEQUENCE),
    sac_all_unused(SAC_STATE, END_STATE, SAC_SEQUENCE, FINAL_SEQUENCE).

sac_unused(UNUSED_NAME, START_STATE, SAC_STATE, STEP) :-
    on_board(UNUSED_NAME, START_STATE),
    card_property(UNUSED_NAME, unused, base, BASE_NAME),
    card_property(BASE_NAME, default, yield, YIELD),
    remove_from_board(UNUSED_NAME, START_STATE, STATE2),
    add_to_grave(BASE_NAME, STATE2, STATE3),
    add_mana_(STATE3, YIELD, SAC_STATE),
    string_concat('sac ', BASE_NAME, STEP).


necro_payoff(leyline, STATE, _{leyline: true, mana: TOTAL_REMAINING_MANA}) :-
    on_board('Leyline of Anticipation', STATE),
    state_mana(STATE, MANA),
    total(MANA, TOTAL_REMAINING_MANA),
    check_win_condition(STATE, 0).

necro_payoff(borne, STATE, _{borne: true, mana: TOTAL_REMAINING_MANA}) :-
    can_cast('Borne Upon a Wind', STATE, BORNE_STATE),
    check_win_condition(BORNE_STATE, 1),
    state_mana(BORNE_STATE, MANA),
    total(MANA, TOTAL_REMAINING_MANA).

necro_payoff(valakut, STATE, _{valakut: true, mana: TOTAL_REMAINING_MANA}) :-
    not(necro_payoff(borne, STATE, _)),
    can_cast('Valakut Awakening', STATE, VALAKUT_STATE),
    state_hand(VALAKUT_STATE, HAND),
    length(HAND, HAND_SIZE),
    VALAKUT_DRAWS is HAND_SIZE + 1,
    check_win_condition(VALAKUT_STATE, VALAKUT_DRAWS),
    state_mana(VALAKUT_STATE, MANA),
    total(MANA, TOTAL_REMAINING_MANA).

necro_payoff(fizzle, STATE, _{fizzle: true, mana: TOTAL_REMAINING_MANA}) :-
    not(necro_payoff(borne, STATE, _)),
    not(necro_payoff(valakut, STATE, _)),
    state_mana(STATE, MANA),
    total(MANA, TOTAL_REMAINING_MANA).

check_win_condition(STATE, _) :-
    in_hand('Tendrils of Agony', STATE), !;
    in_hand('Beseech the Mirror', STATE), !;
    in_hand('Valakut Awakening', STATE), !.
check_win_condition(STATE, 0) :-
    state_hand(STATE, CURRENT_HAND),
    length(CURRENT_HAND, HAND_SIZE),
    delete(CURRENT_HAND, 'Borne Upon a Wind', MINUS_BORNE),
    delete(MINUS_BORNE, 'Manamorphose', MINUS_CANTRIPS),
    length(MINUS_CANTRIPS, SIZE_WITHOUT_CANTRIPS),
    N_CANTRIPS is HAND_SIZE - SIZE_WITHOUT_CANTRIPS,
    N_CANTRIPS > 0,
    update_hand(STATE, MINUS_CANTRIPS, STATE2),
    check_win_condition(STATE2, N_CANTRIPS).
check_win_condition(STATE, N_DRAWS) :-
    N_DRAWS > 0,
    draw_up_to(N_DRAWS, STATE, NEXT_STATE),
    check_win_condition(NEXT_STATE, 0).

can_cast(CARDNAME, START_STATE, CAST_STATE) :-
    (
        % if we have the right mana with the card in hand, then yes
        cast_from_hand(CARDNAME, START_STATE, CAST_STATE),
        !;

        % if we have red or green with Manamorphose in hand, then yes if the card is in hand or on top
        cast_manamorphose(START_STATE, _, MANAMORPHOSE_STATE),
        in_hand(CARDNAME, MANAMORPHOSE_STATE),
        cast_rituals(MANAMORPHOSE_STATE, RITUAL_STATE),
        cast_from_hand(CARDNAME, RITUAL_STATE, CAST_STATE)
    ).

cast_from_hand(CARDNAME, STATE, CAST_STATE) :-
    state_mana(STATE, STARTING_MANA),
    in_hand(CARDNAME, STATE),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cost, CARD, COST),
    spend(COST, STARTING_MANA, REMAINING_MANA),
    remove_from_hand(CARDNAME, STATE, STATE2),
    update_mana(STATE2, REMAINING_MANA, CAST_STATE),
    !.

cast_manamorphose(STATE, N_MANAMORPHOSE, NEXT_STATE) :-
    state_hand(STATE, HAND),
    count('Manamorphose', HAND, N_MANAMORPHOSE),
    N_MANAMORPHOSE > 0,
    cast_from_hand('Manamorphose', STATE, CAST_STATE),
    remove_n('Manamorphose', N_MANAMORPHOSE, HAND, CAST_HAND, _),
    update_hand(CAST_STATE, CAST_HAND, CAST_ALL_STATE),
    state_mana(CAST_ALL_STATE, CAST_MANA),
    addmana([0, 0, 0, 0, 0, 0, 2], CAST_MANA, REMAINING_MANA),
    update_mana(CAST_STATE, REMAINING_MANA, ADDMANA_STATE),
    draw_up_to(N_MANAMORPHOSE, ADDMANA_STATE, NEXT_STATE).

cast_rituals(STATE1, STATE3) :-
    state_mana(STATE1, [_, _, B, _, _, _, ANY]),
    % if we have at least 2 any-color mana or one black mana, and a Dark Ritual, we can cast it
    (B >= 1; ANY > 1),
    in_hand('Dark Ritual', STATE1),
    makemana('Dark Ritual', STATE1, STATE2, [], _),
    !,
    cast_rituals(STATE2, STATE3).
cast_rituals(STATE1, STATE3) :-
    state_mana(STATE1, [_, _, B, _, _, _, ANY]),
    % if we have 2 any-color mana or one black, and a Cabal Ritual, we can cast it if our total is >= 3
    (B >= 1; ANY > 1),
    state_mana(STATE1, MANA1),
    total(MANA1, TOTAL1),
    TOTAL1 >= 3,
    in_hand('Cabal Ritual', STATE1),
    makemana('Cabal Ritual', STATE1, STATE2, [], _),
    !,
    cast_rituals(STATE2, STATE3).
cast_rituals(STATE1, STATE1) :-
    % do nothing if we don't have any rituals
    not(in_hand('Dark Ritual', STATE1)),
    not(in_hand('Cabal Ritual', STATE1));
    % or don't have mana to cast them
    state_mana(STATE1, [_, _, B, _, _, _, ANY]),
    B < 1,
    ANY < 2;
    % or we have dark ritual mana with only cabal
    not(in_hand('Dark Ritual', STATE1)),
    state_mana(STATE1, MANA1),
    total(MANA1, TOTAL1),
    TOTAL1 < 3.
