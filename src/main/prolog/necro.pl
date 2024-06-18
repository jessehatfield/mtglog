post_necro(START_STATE, PRIOR_SEQ, COMBO_SEQ, METADATA, NECRO) :-
    b_setval(reveal_draws, true),
    % Cast sacrificeable permanents without using them, if possible
    cast_leds(START_STATE, CAST_LED_STATE, PRIOR_SEQ, CAST_LED_SEQ),
    cast_in_order([['Lotus Petal'], ['Wild Cantor']], CAST_LED_STATE, PETAL_STATE, CAST_LED_SEQ, PETAL_SEQ),
    % Empty the mana pool and record that we're in the end step
    end_step_mana(PETAL_STATE, NECRO, END_STEP_SEQ, END_STEP_STATE),
    append(PETAL_SEQ, ['end step'], END_STEP_SEQ),
    % Make any mana you can before drawing cards
    spirit_guides(END_STEP_STATE, SG1_STATE, END_STEP_SEQ, SG1_SEQ),
    sac_leds(SG1_STATE, SAC_LED_STATE, SAC_LED_SEQ),
    sac_all_unused(SAC_LED_STATE, NECRO_STATE, SAC_LED_SEQ, SAC_SEQ),
    % Draw and go off
    N_NECRO_DRAW = 19,
    draw_up_to(N_NECRO_DRAW, NECRO_STATE, DRAW_STATE),
    string_concat("draw ", N_NECRO_DRAW, DRAW_STEP),
    append([SG1_SEQ, SAC_SEQ, [DRAW_STEP]], DRAW_SEQ),
    spirit_guides(DRAW_STATE, SG2_STATE, DRAW_SEQ, SG2_SEQ),
    % Try to complete a combo
    combo_progress(SG2_STATE, SG2_SEQ, PROGRESS),
    combo_ignore_mana(SG2_STATE, _, PROGRESS, POTENTIAL_METADATA),
    (
        POTENTIAL_METADATA.potential_win = false,
        METADATA = POTENTIAL_METADATA.put(_{fizzle: true, kill: none}),
        COMBO_SEQ = SG2_SEQ;
        POTENTIAL_METADATA.potential_win = true,
        execute_combo(SG2_STATE, _, SG2_SEQ, COMBO_SEQ, POTENTIAL_METADATA, METADATA)
    ).

necro_can_powder(HAND, LIBRARY, 0, []) :-
    member('Serum Powder', HAND),
    library_contains_necro_win([], LIBRARY).
necro_can_powder(HAND, LIBRARY, N_BOTTOM, BOTTOM) :-
    N_BOTTOM > 0,
    remove('Serum Powder', HAND, MINUS_POWDER),
    % TODO: return the bottom combinations in some order that minimizes fizzles
    combination(MINUS_POWDER, N_BOTTOM, BOTTOM, _),
    append(LIBRARY, BOTTOM, POWDER_LIBRARY),
    library_contains_necro_win([], POWDER_LIBRARY).
library_contains_necro_win(_, LIBRARY) :-
    (member('Necrodominance', LIBRARY); member('Necrologia', LIBRARY)),
    (
        member('Tendrils of Agony', LIBRARY),
        (
            member('Borne Upon a Wind', LIBRARY);
            member('Leyline of Anticipation', LIBRARY);
            member('Electrodominance', LIBRARY);
            member('Emergence Zone', LIBRARY)
        );
        count('Fateful Showdown', LIBRARY, SHOWDOWNS),
        SHOWDOWNS > 1;
        count('Brain Freeze', LIBRARY, FREEZES),
        FREEZES > 1
    ), !.

cast_leds(STATE1, STATE5, PRIOR_SEQ, COMBINED_SEQ) :-
    % Cast as many LEDs as you have, without using them
    remove_from_hand('Lion\'s Eye Diamond', STATE1, STATE2),
    increment_storm(STATE2, STATE3),
    add_to_board('Lion\'s Eye Diamond_unused', STATE3, STATE4),
    append(PRIOR_SEQ, ['Lion\'s Eye Diamond'], LEDS),
    cast_leds(STATE4, STATE5, LEDS, COMBINED_SEQ).
cast_leds(STATE1, STATE1, PRIOR_SEQ, PRIOR_SEQ) :-
    not(in_hand('Lion\'s Eye Diamond', STATE1)).

end_step_mana(START_STATE, _, _, START_STATE) :-
    % if there's a Leyline, we should have been able to cast everything at instant speed
    on_board('Leyline of Anticipation', START_STATE), !.
end_step_mana(START_STATE, 'Necrologia', SEQ, START_STATE) :-
    % if there are no sorceries and our win condition is Necrologia, assume we could have
    % sequenced things to make the mana during the end step, and can leave it floating
    type_max(SEQ, sorcery, 0), !.
end_step_mana(START_STATE, _, _, END_STEP_STATE) :-
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
    (
        exile_grave(STATE3), STATE4 = STATE3;
        not(exile_grave(STATE3)), update_gy(STATE3, GY_DISCARD, STATE4)
    ),
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

% Initialize combo metadata from a given game state 
combo_progress(STATE, SEQ, _{damage: 0, flash: false}) :-
    not(on_board('Leyline of Anticipation', STATE)),
    not(member('Borne Upon a Wind', SEQ)).
combo_progress(STATE, SEQ, _{damage: 0, flash: true}) :-
    on_board('Leyline of Anticipation', STATE);
    member('Borne Upon a Wind', SEQ).

valakut_wheel(COMBO, HAND, WHEEL, KEEP) :-
    % hold on to a Tendrils if we have it
    remove_first_opt('Tendrils of Agony', HAND, WHEEL1, KEEP1),
    (
        % if we don't have a Tendrils, try to keep a Beseech
        KEEP1 = [],
        remove_first_opt('Beseech the Mirror', HAND, WHEEL2, KEEP2);
        % otherwise, no need
        KEEP1 = ['Tendrils of Agony'],
        KEEP2 = [],
        WHEEL2 = WHEEL1
    ),
    (
        % hold on to a Borne if we don't have flash
        COMBO.flash = false,
        remove_first_opt('Borne Upon a Wind', WHEEL2, WHEEL3, KEEP3);
        % otherwise, no need
        COMBO.flash = true,
        KEEP3 = [],
        WHEEL3 = WHEEL2
    ),
    append([KEEP1, KEEP2, KEEP3], KEEP),
    WHEEL = WHEEL3.

cantrip_ignore_mana(START_STATE, FINAL_STATE, START_COMBO, FINAL_COMBO) :-
    state_hand(START_STATE, START_HAND),
    take_all(START_HAND, ['Manamorphose', 'Borne Upon a Wind'], TAKEN, REMAINDER),
    (
        member('Borne Upon a Wind', TAKEN),
        UPDATED_COMBO = START_COMBO.put(_{potential_flash: true});
        not(member('Borne Upon a Wind', TAKEN)),
        UPDATED_COMBO = START_COMBO
    ),
    length(TAKEN, N),
    (
        N > 0,
        update_hand(START_STATE, REMAINDER, TAKE_STATE),
        draw_up_to(N, TAKE_STATE, DRAW_STATE),
        cantrip_ignore_mana(DRAW_STATE, FINAL_STATE, UPDATED_COMBO, FINAL_COMBO);
        N = 0,
        FINAL_STATE = START_STATE,
        FINAL_COMBO = START_COMBO
    ).

combo_ignore_mana(START_STATE, FINAL_STATE, START_COMBO, FINAL_COMBO) :-
    (FLASH = START_COMBO.get(potential_flash); FLASH = START_COMBO.flash),
    POTENTIAL_COMBO = START_COMBO.put(_{potential_flash: FLASH}),
    cantrip_ignore_mana(START_STATE, CANTRIP_STATE, POTENTIAL_COMBO, CANTRIP_COMBO),
    (
        % we've already done 20 damage
        DAMAGE = CANTRIP_COMBO.get(potential_damage),
        DAMAGE >= 20,
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: true}),
        FINAL_STATE = CANTRIP_STATE, !;
        % we have flash and Tendrils in hand
        CANTRIP_COMBO.potential_flash = true,
        in_hand('Tendrils of Agony', CANTRIP_STATE),
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: true, potential_kill: tendrils}), !;
        % we have flash, Beseech in hand, and Tendrils in deck
        CANTRIP_COMBO.potential_flash = true,
        in_hand('Beseech the Mirror', CANTRIP_STATE),
        in_deck('Tendrils of Agony', CANTRIP_STATE),
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: true, potential_kill: tendrils}), !;
        % we have Electrodominance and Tendrils both in hand
        in_hand('Electrodominance', CANTRIP_STATE),
        in_hand('Tendrils of Agony', CANTRIP_STATE),
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: true, potential_kill: tendrils}), !;
        % we have Electrodominance and Beseech both in hand and Tendrils in deck
        in_hand('Electrodominance', CANTRIP_STATE),
        in_hand('Beseech the Mirror', CANTRIP_STATE),
        in_deck('Tendrils of Agony', CANTRIP_STATE),
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: true, potential_kill: tendrils}), !;
        % if we have none of the above but access to Emergence Zone, add flash and recurse
        CANTRIP_COMBO.potential_flash = false,
        (
            remove_from_hand('Crop Rotation', CANTRIP_STATE, ROTATE_STATE),
            remove_from_deck('Emergence Zone', ROTATE_STATE, EMERGE_STATE);
            remove_from_board('Emergence Zone_untapped', CANTRIP_STATE, EMERGE_STATE)
        ),
        combo_ignore_mana(EMERGE_STATE, FINAL_STATE, CANTRIP_COMBO.put(_{potential_flash: true}), FINAL_COMBO), !;
        % if we have none of the above but Valakut in hand, use it and recurse
        state_hand(CANTRIP_STATE, CANTRIP_HAND),
        remove_first('Valakut Awakening', CANTRIP_HAND, VALAKUT_HAND),
        valakut_wheel(CANTRIP_COMBO, VALAKUT_HAND, WHEEL, KEEP),
        update_hand(CANTRIP_STATE, KEEP, BOTTOM_STATE),
        length(WHEEL, N),
        N1 is N + 1,
        draw_up_to(N1, BOTTOM_STATE, DRAW_STATE),
        combo_ignore_mana(DRAW_STATE, FINAL_STATE, CANTRIP_COMBO, FINAL_COMBO);
        % if we have none of the above but Showdown in hand, use it, track max damage, and recurse if less than 20
        in_hand('Fateful Showdown', CANTRIP_STATE),
        state_hand(CANTRIP_STATE, CANTRIP_HAND),
        length(CANTRIP_HAND, N),
        N1 is N - 1,
        N1 > 0,
        update_hand(CANTRIP_STATE, [], DISCARD_STATE),
        draw_up_to(N1, DISCARD_STATE, DRAW_STATE),
        (D = CANTRIP_COMBO.get(potential_damage), !; D = 0),
        UPDATED_DAMAGE is D + N1,
        SHOWDOWN_COMBO = CANTRIP_COMBO.put(_{potential_kill: showdown, potential_damage: UPDATED_DAMAGE}),
        combo_ignore_mana(DRAW_STATE, FINAL_STATE, SHOWDOWN_COMBO, FINAL_COMBO), !;
        % if we have none of the above at all, record a fizzle
        FINAL_STATE = CANTRIP_STATE,
        FINAL_COMBO = CANTRIP_COMBO.put(_{potential_win: false})
    ).

execute_combo(START_STATE, FINAL_STATE, START_SEQ, FINAL_SEQ, START_COMBO, FINAL_COMBO) :-
    % if we've already done 20 damage, we're done
    DAMAGE = START_COMBO.get(damage),
    DAMAGE >= 20,
    FINAL_COMBO = START_COMBO.put(_{lethal: true, fizzle: false}),
    FINAL_STATE = START_STATE, !;

    % if we don't have access to a win condition, it's over
    state_hand(START_STATE, HAND),
    intersection(['Tendrils of Agony', 'Fateful Showdown'], HAND, []),
    (
        intersection(['Beseech the Mirror', 'Manamorphose', 'Borne Upon a Wind', 'Valakut Awakening'], HAND, []), !;
        state_deck(START_STATE, LIBRARY),
        intersection(['Tendrils of Agony', 'Electrodominance'], LIBRARY, []), !
    ),
    FINAL_COMBO = START_COMBO.put(_{fizzle: true, kill: none}),
    !;

    % if we have flash and Tendrils, try to cast it and terminate, recording storm*2 damage
    START_COMBO.flash = true,
    in_hand('Tendrils of Agony', START_STATE),
    prune_(4, START_STATE),
    makemana_goal('Tendrils of Agony', START_STATE, MANA_STATE, START_SEQ, MANA_SEQ),
    (
        storm_up(9, 'Tendrils of Agony', MANA_STATE, STORM_STATE, MANA_SEQ, STORM_SEQ),
        cast_one(['Tendrils of Agony'], STORM_STATE, FINAL_STATE, STORM_SEQ, FINAL_SEQ),
        LETHAL = true,
        !;
        cast_one(['Tendrils of Agony'], MANA_STATE, FINAL_STATE, MANA_SEQ, FINAL_SEQ),
        LETHAL = false
    ),
    state_storm(FINAL_STATE, STORM),
    TENDRILS_DAMAGE is STORM * 2,
    FINAL_COMBO = START_COMBO.put(_{kill:tendrils, damage:TENDRILS_DAMAGE, lethal:LETHAL, fizzle: false, followup: true}),
    !;

    % if Borne is in hand and we don't have flash, try to cast Borne before recursing
    START_COMBO.flash = false,
    make_mana_and_cast('Borne Upon a Wind', START_STATE, BORNE_STATE, START_SEQ, BORNE_SEQ),
    execute_combo(BORNE_STATE, FINAL_STATE, BORNE_SEQ, FINAL_SEQ, START_COMBO.put(_{flash:true, followup: true, borne: true}), FINAL_COMBO),
    !;

    % if Emergence Zone is on board and untapped and we don't have flash, activate before recursing
    START_COMBO.flash = false,
    on_board('Emergence Zone_untapped', START_STATE),
    activate_emergence_zone(START_STATE, EMERGE_STATE, START_SEQ, EMERGE_SEQ),
    execute_combo(EMERGE_STATE, FINAL_STATE, EMERGE_SEQ, FINAL_SEQ, START_COMBO.put(_{flash:true, followup: true, emerge: true}), FINAL_COMBO),
    !;

    % if Emergence Zone is in the deck and we have Crop Rotation, find it and activate before recursing
    START_COMBO.flash = false,
    in_hand('Crop Rotation', START_STATE),
    in_deck('Emergence Zone', START_STATE),
    make_mana_and_cast('Crop Rotation', START_STATE, ROTATE_STATE, START_SEQ, ROTATE_SEQ),
    activate_emergence_zone(ROTATE_STATE, EMERGE_STATE, ROTATE_SEQ, EMERGE_SEQ),
    execute_combo(EMERGE_STATE, FINAL_STATE, EMERGE_SEQ, FINAL_SEQ, START_COMBO.put(_{flash:true, followup: true, emerge: true}), FINAL_COMBO),
    !;

    % if Manamorphose is in hand, try to cast it before recursing
    make_mana_and_cast('Manamorphose', START_STATE, MM_STATE, START_SEQ, MM_SEQ),
    execute_combo(MM_STATE, FINAL_STATE, MM_SEQ, FINAL_SEQ, START_COMBO, FINAL_COMBO),
    !;

    % if we have flash and Beseech in hand, and Tendrils in deck, cast Beseech
    START_COMBO.flash = true,
    in_hand('Beseech the Mirror', START_STATE),
    in_deck('Tendrils of Agony', START_STATE),
    prune_(4, START_STATE),
    makemana_goal('Beseech the Mirror', START_STATE, MANA_STATE, START_SEQ, MANA_SEQ),
    (
        storm_up(8, 'Beseech the Mirror', MANA_STATE, STORM_STATE, MANA_SEQ, STORM_SEQ),
        LETHAL = true,
        !;
        STORM_STATE = MANA_STATE,
        STORM_SEQ = MANA_SEQ,
        LETHAL = false
    ),
    cast_beseech('Tendrils of Agony', STORM_STATE, BARGAIN_STATE, STORM_SEQ, BARGAIN_SEQ, _),
    cast_free('Tendrils of Agony', BARGAIN_STATE, FINAL_STATE, BARGAIN_SEQ, FINAL_SEQ),
    state_storm(FINAL_STATE, STORM),
    TENDRILS_DAMAGE is STORM * 2,
    FINAL_COMBO = START_COMBO.put(_{kill:tendrils, damage:TENDRILS_DAMAGE, lethal:LETHAL, followup: true}),
    !;

    % if we have Electrodominance and Tendrils, try to cast it and terminate, recording storm*2 + 4 + X damage
    in_hand('Tendrils of Agony', START_STATE),
    in_hand('Electrodominance', START_STATE),
    prune_(6, START_STATE),
    makemana_goal('Electrodominance', 4, START_STATE, MANA_STATE, START_SEQ, MANA_SEQ),
    in_hand('Tendrils of Agony', MANA_STATE),
    (
        storm_up(6, 'Tendrils of Agony', MANA_STATE, STORM_STATE, MANA_SEQ, STORM_SEQ),
        in_hand('Tendrils of Agony', STORM_STATE),
        cast_from_hand('Electrodominance', 4, STORM_STATE, ELECTRO_STATE, STORM_SEQ, ELECTRO_SEQ),
        !;
        cast_from_hand('Electrodominance', 4, MANA_STATE, ELECTRO_STATE, MANA_SEQ, ELECTRO_SEQ)
    ),
    cast_free('Tendrils of Agony', ELECTRO_STATE, FINAL_STATE, ELECTRO_SEQ, FINAL_SEQ),
    state_storm(FINAL_STATE, STORM),
    state_mana(FINAL_STATE, EXTRA_MANA),
    TENDRILS_DAMAGE is STORM * 2,
    total(EXTRA_MANA, ADD_DAMAGE),
    ELECTRO_DAMAGE is 4 + ADD_DAMAGE,
    TOTAL_DAMAGE is TENDRILS_DAMAGE + ELECTRO_DAMAGE,
    (TOTAL_DAMAGE >= 20, LETHAL = true; TOTAL_DAMAGE < 20, LETHAL = false),
    FINAL_COMBO = START_COMBO.put(_{kill:tendrils, damage:TOTAL_DAMAGE, lethal:LETHAL, fizzle: false, followup: true}),
    !;

    % if we have Electrodominance and Beseech in hand, and Tendrils in deck, chain all three
    in_hand('Electrodominance', START_STATE),
    in_hand('Beseech the Mirror', START_STATE),
    in_deck('Tendrils of Agony', START_STATE),
    prune_(6, START_STATE),
    makemana_goal('Electrodominance', 4, START_STATE, MANA_STATE, START_SEQ, MANA_SEQ),
    in_hand('Beseech the Mirror', MANA_STATE),
    (
        storm_up(5, 'Beseech the Mirror', MANA_STATE, STORM_STATE, MANA_SEQ, STORM_SEQ),
        in_hand('Beseech the Mirror', STORM_STATE),
        cast_from_hand('Electrodominance', 4, STORM_STATE, ELECTRO_STATE, STORM_SEQ, ELECTRO_SEQ),
        !;
        cast_from_hand('Electrodominance', 4, MANA_STATE, ELECTRO_STATE, MANA_SEQ, ELECTRO_SEQ)
    ),
    cast_beseech_free('Tendrils of Agony', ELECTRO_STATE, BARGAIN_STATE, ELECTRO_SEQ, BARGAIN_SEQ, _),
    cast_free('Tendrils of Agony', BARGAIN_STATE, FINAL_STATE, BARGAIN_SEQ, FINAL_SEQ),
    state_storm(FINAL_STATE, STORM),
    TENDRILS_DAMAGE is STORM * 2,
    state_mana(FINAL_STATE, EXTRA_MANA),
    total(EXTRA_MANA, ADD_DAMAGE),
    ELECTRO_DAMAGE is 4 + ADD_DAMAGE,
    TOTAL_DAMAGE is TENDRILS_DAMAGE + ELECTRO_DAMAGE,
    (TOTAL_DAMAGE >= 20, LETHAL = true; TOTAL_DAMAGE < 20, LETHAL = false),
    FINAL_COMBO = START_COMBO.put(_{kill:tendrils, damage:TOTAL_DAMAGE, lethal:LETHAL, fizzle: false, followup: true}),
    !;

    % if we can cast Valakut, make mana and then try with the new hand
    make_mana_and_cast('Valakut Awakening', START_STATE, VALAKUT_CAST_STATE, START_SEQ, VALAKUT_CAST_SEQ),
    state_hand(VALAKUT_CAST_STATE, VALAKUT_CAST_HAND),
    state_deck(VALAKUT_CAST_STATE, VALAKUT_CAST_DECK),
    valakut_wheel(START_COMBO, VALAKUT_CAST_HAND, WHEEL, KEEP),
    append(VALAKUT_CAST_DECK, WHEEL, VALAKUT_WHEEL_DECK),
    length(WHEEL, N),
    update_deck(VALAKUT_CAST_STATE, VALAKUT_WHEEL_DECK, VALAKUT_BOTTOM_STATE),
    update_hand(VALAKUT_BOTTOM_STATE, KEEP, VALAKUT_WHEEL_STATE),
    draw(N, VALAKUT_WHEEL_STATE, VALAKUT_DRAW_STATE),
    string_concat('valakut draw ', N, VALAKUT_DRAW_STEP),
    append(VALAKUT_CAST_SEQ, [VALAKUT_DRAW_STEP], VALAKUT_DRAW_SEQ),
    execute_combo(VALAKUT_DRAW_STATE, FINAL_STATE, VALAKUT_DRAW_SEQ, FINAL_SEQ, START_COMBO.put(_{valakut: true, followup: true}), FINAL_COMBO),
    !;

    % If we can cast Showdown, make mana and cast it, then try again unless we've done enough damage
    showdown_mana(START_STATE, RED_STATE, START_SEQ, RED_SEQ),
    make_mana_and_cast('Fateful Showdown', RED_STATE, SHOWDOWN_CAST_STATE, RED_SEQ, SHOWDOWN_CAST_SEQ),
    state_hand(SHOWDOWN_CAST_STATE, SHOWDOWN_CAST_HAND),
    length(SHOWDOWN_CAST_HAND, N),
    update_hand(SHOWDOWN_CAST_STATE, [], SHOWDOWN_DISCARD_STATE),
    draw(N, SHOWDOWN_DISCARD_STATE, SHOWDOWN_DRAW_STATE),
    string_concat('Showdown draw/damage ', N, SHOWDOWN_DRAW_STEP),
    append(SHOWDOWN_CAST_SEQ, [SHOWDOWN_DRAW_STEP], SHOWDOWN_DRAW_SEQ),
    (D = START_COMBO.get(damage), !; D = 0),
    UPDATED_DAMAGE is D + N,
    SHOWDOWN_COMBO = START_COMBO.put(_{kill:showdown, damage:UPDATED_DAMAGE, followup: true, showdown: true}),
    execute_combo(SHOWDOWN_DRAW_STATE, FINAL_STATE, SHOWDOWN_DRAW_SEQ, FINAL_SEQ, SHOWDOWN_COMBO, FINAL_COMBO);

    % if we can't do any of these things, we fizzle
    FINAL_COMBO = START_COMBO.put(_{fizzle: true, kill: none}).

showdown_mana(START_STATE, FINAL_STATE, PRIOR_SEQ, FINAL_SEQ) :-
    % Cast instant-speed rituals maximizing red mana
    spirit_guides(START_STATE, SG_STATE, PRIOR_SEQ, SG_SEQ),
    state_mana(SG_STATE, [W, U, B, R, G, C, A]),
    POTENTIAL_R is R + A,
    OTHER is W + U + G + C,
    (
        % Dark Ritual can always be cast for B, or cast for any color mana if we don't need red
        (B > 0; B = 0, A > 0, POTENTIAL_R > 2),
        cast_one(['Dark Ritual'], SG_STATE, NEXT_STATE, SG_SEQ, NEXT_SEQ),
        showdown_mana(NEXT_STATE, FINAL_STATE, NEXT_SEQ, FINAL_SEQ);

        % Only cast Cabal Ritual if we can do it without consuming red
        (B > 1; B = 1, OTHER > 0),
        cast_one(['Cabal Ritual'], SG_STATE, NEXT_STATE, SG_SEQ, NEXT_SEQ),
        state_mana(NEXT_STATE, [_, _, _, NEXT_R, _, _, NEXT_A]),
        NEXT_POTENTIAL_R is NEXT_R + NEXT_A,
        NEXT_POTENTIAL_R = NEXT_R,
        showdown_mana(NEXT_STATE, FINAL_STATE, NEXT_SEQ, FINAL_SEQ);

        % Cast Manamorphose no matter what, but spend non-red if possible
        cast_one(['Manamorphose'], SG_STATE, NEXT_STATE, SG_SEQ, NEXT_SEQ),
        state_mana(NEXT_STATE, [_, _, _, NEXT_R, _, _, NEXT_A]),
        NEXT_POTENTIAL_R is NEXT_R + NEXT_A,
        (OTHER = 0; NEXT_POTENTIAL_R > POTENTIAL_R),
        showdown_mana(NEXT_STATE, FINAL_STATE, NEXT_SEQ, FINAL_SEQ);

        % Cast red rituals no matter what
        cast_in_order([['Desperate Ritual'], ['Pyretic Ritual']], SG_STATE, NEXT_STATE, SG_SEQ, NEXT_SEQ),
        state_mana(NEXT_STATE, [_, _, _, NEXT_R, _, _, _]),
        NEXT_R > R,
        showdown_mana(NEXT_STATE, FINAL_STATE, NEXT_SEQ, FINAL_SEQ);

        % If none of the above, finish.
        FINAL_STATE = SG_STATE,
        FINAL_SEQ = SG_SEQ
    ).

cast_beseech_free(TARGET, START_STATE, END_STATE, SEQUENCE_PRIOR, SEQUENCE_FINAL, SACRIFICE) :-
    remove_from_hand('Beseech the Mirror', START_STATE, STATE2),
    beseech_bargain(TARGET, STATE2, STATE3, SEQUENCE_SAC, SACRIFICE),
    append(SEQUENCE_PRIOR, SEQUENCE_SAC, SEQUENCE_FINAL),
    increment_storm(STATE3, END_STATE).

activate_emergence_zone(START_STATE, EMERGE_STATE, START_SEQ, EMERGE_SEQ) :-
    board_to_grave('Emergence Zone_untapped', START_STATE, SAC_STATE),
    spend_([0, 0, 0, 0, 0, 0, 1], SAC_STATE, EMERGE_STATE),
    append(START_SEQ, ['activate Emergence Zone'], EMERGE_SEQ).
