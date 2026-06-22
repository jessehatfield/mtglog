% Base case: make no mana, nothing changes.
makemana(START_STATE, START_STATE, X, X).

% Recursive case: play or activate one card.
makemana(START_STATE, END_STATE, PRIOR_SEQUENCE, NEXT_SEQUENCE) :-
    (   state_hand(START_STATE, START_HAND),
        member(NAME, START_HAND)
    ;   state_gy(START_STATE, START_GY),
        member(NAME, START_GY),
        card(NAME, _, flashback)
    ;   state_board(START_STATE, START_BOARD),
        member(NAME, START_BOARD),
        activates(NAME, _)
    ),
    makemana(NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, NEXT_SEQUENCE).

% Recursive case: play a specific card.
makemana(NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_from_hand(NAME, START_STATE, CAST_STATE, PRIOR_SEQUENCE, CAST_SEQUENCE),
    makemana(CAST_STATE, END_STATE, CAST_SEQUENCE, TOTAL_SEQUENCE).

% Recursive case: play a specific mode of a specific card.
makemana(NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_from_hand(NAME, _, START_STATE, CAST_STATE, PRIOR_SEQUENCE, CAST_SEQUENCE),
    makemana(CAST_STATE, END_STATE, CAST_SEQUENCE, TOTAL_SEQUENCE).

% Recursive case: use an activated ability.
makemana(NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    activate_from_board(NAME, START_STATE, ACTIVATE_STATE, PRIOR_SEQUENCE, ACTIVATE_SEQUENCE),
    makemana(ACTIVATE_STATE, END_STATE, ACTIVATE_SEQUENCE, TOTAL_SEQUENCE).

% Recursive case: play a card with Flashback from the graveyard.
makemana(NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_from_graveyard(NAME, START_STATE, CAST_STATE, PRIOR_SEQUENCE, CAST_SEQUENCE),
    makemana(CAST_STATE, END_STATE, CAST_SEQUENCE, TOTAL_SEQUENCE).

storm_up(TARGET_STORM, _, START_STATE, START_STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    state_storm(START_STATE, START_STORM),
    START_STORM >= TARGET_STORM,
    !.
storm_up(TARGET_STORM, STORM_CARD, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_in_order([['Lotus Petal'], ['Chrome Mox'], ['Summoner\'s Pact']], START_STATE, STATE2, PRIOR_SEQUENCE, SEQ2),
    state_storm(STATE2, STORM2),
    (
        STORM2 >= TARGET_STORM,
        END_STATE = STATE2,
        TOTAL_SEQUENCE = SEQ2,
        !;
        storm_up_general(TARGET_STORM, STORM_CARD, STATE2, END_STATE, SEQ2, TOTAL_SEQUENCE)
    ).
storm_up_general(TARGET_STORM, _, START_STATE, START_STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    state_storm(START_STATE, START_STORM),
    START_STORM >= TARGET_STORM,
    !.
storm_up_general(TARGET_STORM, STORM_CARD, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    prune_storm(TARGET_STORM, START_STATE),
    card_property(STORM_CARD, default, cost, TARGET_COST),
    total(TARGET_COST, TARGET_CMC),
    state_storm(START_STATE, START_STORM),
    START_STORM < TARGET_STORM,
    state_hand(START_STATE, START_HAND),
    list_to_set(START_HAND, UNIQUE_CARDS),
    member(CARD_NAME, UNIQUE_CARDS),
    cast_from_hand(CARD_NAME, START_STATE, CAST_STATE, PRIOR_SEQUENCE, CAST_SEQUENCE),
    in_hand(STORM_CARD, CAST_STATE),
    prune_(TARGET_CMC, CAST_STATE, CAST_SEQUENCE),
    storm_up_general(TARGET_STORM, STORM_CARD, CAST_STATE, END_STATE, CAST_SEQUENCE, TOTAL_SEQUENCE).

storm_up_and_cast(TARGET_STORM, STORM_CARD, START_STATE, END_STATE, START_SEQ, END_SEQ) :-
    storm_up(TARGET_STORM, STORM_CARD, START_STATE, STORM_STATE, START_SEQ, STORM_SEQ),
    makemana_goal(STORM_CARD, STORM_STATE, MANA_STATE, STORM_SEQ, MANA_SEQ),
    cast_one([STORM_CARD], MANA_STATE, END_STATE, MANA_SEQ, END_SEQ).

cast_from_hand(NAME,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE) :-
     cast_from_hand(NAME, MODE,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE),
    dif(MODE, flashback).

cast_from_hand(NAME,
        MODE,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE) :-
    check_timing(NAME, PRIOR_SEQUENCE),
    card_property(NAME, MODE, cost, COST),
    remove_first(NAME, START_HAND, NEXT_HAND),
    spend(COST, START_MANA, NEXT_MANA),
    diff_mana(START_MANA, NEXT_MANA, SPENT_MANA),
    cast(NAME, MODE, YIELD, EXTRA_STEPS,
        [NEXT_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        CAST_STATE,
        PRIOR_SEQUENCE,
        SPENT_MANA),
    append(PRIOR_SEQUENCE, [NAME|EXTRA_STEPS], TOTAL_SEQUENCE),
    state_mana(CAST_STATE, CAST_MANA),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    update_mana(CAST_STATE, RESULT_MANA, END_STATE).

activate_from_board(NAME,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE) :-
    member(NAME, START_BOARD),
    card(NAME, CAST_DATA),
    list_to_assoc(CAST_DATA, CARD),
    get_assoc(activate, CARD, ACTIVATED_NAME),
    card(ACTIVATED_NAME, ACTIVATION_DATA),
    list_to_assoc(ACTIVATION_DATA, ACTIVATION_CARD),
    check_timing(ACTIVATED_NAME, PRIOR_SEQUENCE),
    get_assoc(cost, ACTIVATION_CARD, COST),
    spend(COST, START_MANA, NEXT_MANA),
    diff_mana(START_MANA, NEXT_MANA, SPENT_MANA),
    specialcast(ACTIVATED_NAME, default, YIELD,
        [START_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        ACTIVATE_STATE,
        PRIOR_SEQUENCE,
        SPENT_MANA,
        EXTRA_STEPS),
    append(PRIOR_SEQUENCE, EXTRA_STEPS, TOTAL_SEQUENCE),
    state_mana(ACTIVATE_STATE, ACTIVATE_MANA),
    addmana(YIELD, ACTIVATE_MANA, RESULT_MANA),
    update_mana(ACTIVATE_STATE, RESULT_MANA, END_STATE).

cast_from_graveyard(NAME,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE) :-
    card(NAME, _, flashback),
    check_timing(NAME, PRIOR_SEQUENCE),
    card_property(NAME, flashback, cost, COST),
    remove_first(NAME, START_GY, NEXT_GY),
    spend(COST, START_MANA, NEXT_MANA),
    diff_mana(START_MANA, NEXT_MANA, SPENT_MANA),
    cast(NAME, flashback, YIELD, EXTRA_STEPS,
        [START_HAND, START_BOARD, NEXT_MANA, NEXT_GY, START_STORM, START_DECK, START_PROTECTION],
        CAST_STATE,
        PRIOR_SEQUENCE,
        SPENT_MANA),
    append(PRIOR_SEQUENCE, [NAME|EXTRA_STEPS], TOTAL_SEQUENCE),
    state_mana(CAST_STATE, CAST_MANA),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    update_mana(CAST_STATE, RESULT_MANA, END_STATE).

% Cast a single card for free, ignoring timing
cast_free(NAME,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        END_STATE,
        PRIOR_SEQUENCE,
        TOTAL_SEQUENCE) :-
    remove_first(NAME, START_HAND, NEXT_HAND),
    cast(NAME, YIELD, EXTRA_STEPS,
        [NEXT_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        CAST_STATE,
        PRIOR_SEQUENCE,
        [0, 0, 0, 0, 0, 0, 0]),
    append(PRIOR_SEQUENCE, [NAME|EXTRA_STEPS], TOTAL_SEQUENCE),
    state_mana(CAST_STATE, CAST_MANA),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    update_mana(CAST_STATE, RESULT_MANA, END_STATE).

check_timing(CARDNAME, ALREADY_CAST) :-
    check_pregame(CARDNAME, ALREADY_CAST),
    check_counter_timing(CARDNAME, ALREADY_CAST),
    check_instant_speed(CARDNAME, ALREADY_CAST),
    check_land_sac(CARDNAME, ALREADY_CAST).
check_sequence_timing([], _).
check_sequence_timing([H|T], ALREADY_CAST) :-
    check_timing(H, ALREADY_CAST),
    append(ALREADY_CAST, [H], INTERMEDIATE),
    check_sequence_timing(T, INTERMEDIATE).
check_pregame(CARDNAME, ALREADY_CAST) :-
    not(has_role(CARDNAME, pregame));
    has_role(CARDNAME, pregame), all_have_role(ALREADY_CAST, pregame).
% Counterspells should be cast immediately after the combo card, in any order
check_counter_timing(CARDNAME, LIST) :-
    not(has_role(CARDNAME, counterspell));
    has_role(CARDNAME, counterspell),
    last(LIST, PREV_CARD),
    (has_role(PREV_CARD, combo); has_role(PREV_CARD, counterspell)).
instant_speed(CARDNAME) :-
    istype(CARDNAME, instant), !;
    member(CARDNAME, ['Elvish Spirit Guide', 'Simian Spirit Guide']).
check_instant_speed(CARDNAME, SEQUENCE) :-
    not(member('end step', SEQUENCE)), !;
    not(istype(CARDNAME, land)),
    (
        member('Leyline of Anticipation', SEQUENCE), !;
        member('Borne Upon a Wind', SEQUENCE), !;
        member('activate Emergence Zone', SEQUENCE), !;
        instant_speed(CARDNAME), !
    ).
check_land_sac(CARDNAME, SEQUENCE) :-
    not(istype(CARDNAME, land));
    istype(CARDNAME, land),
    not(member('Crop Rotation', SEQUENCE)).

makemana_goal(TARGET_CARD_NAME, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    makemana_goal(TARGET_CARD_NAME, default, START_STATE, END_STATE, PRIOR_SEQUENCE, TOTAL_SEQUENCE).
makemana_goal(TARGET_CARD_NAME, TARGET_MODE, START_STATE, END_STATE, PRIOR_SEQUENCE, COMBINED_SEQUENCE) :-
    card_property(TARGET_CARD_NAME, TARGET_MODE, cost, TARGET_COST),
    makemana_cost_goal(TARGET_COST, [TARGET_CARD_NAME], START_STATE, END_STATE, PRIOR_SEQUENCE, COMBINED_SEQUENCE).

makemana_cost_goal(TARGET_COST, TARGET_CARDS, START_STATE, START_STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    check_sequence_timing(TARGET_CARDS, PRIOR_SEQUENCE),
    state_hand(START_STATE, HAND),
    subset(TARGET_CARDS, HAND),
    % Require that we have the mana
    state_mana(START_STATE, START_MANA),
    spend(TARGET_COST, START_MANA, _).
makemana_cost_goal(TARGET_COST, TARGET_CARDS,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
        PRIOR_SEQUENCE,
    COMBINED_SEQUENCE) :-
    % Verify that we could theoretically get the mana, colors, and required cards (if any)
    all_member_or_tutor(TARGET_CARDS, START_HAND, START_DECK),
    total(TARGET_COST, TARGET_CMC),
    %zone_type_count(PRIOR_SEQUENCE, land, 1, LAND_DROPS),
    zone_type_count(PRIOR_SEQUENCE, land, LAND_DROPS),
    prune(TARGET_CMC, START_HAND, START_BOARD, START_GY, START_DECK, START_MANA, LAND_DROPS),
    total_color_gain(START_HAND, COLORED_MANA_HAND),
    possible_activations(START_BOARD, POSSIBLE_ACTIVATIONS),
    total_color_gain(POSSIBLE_ACTIVATIONS, COLORED_MANA_BOARD),
    possible_activations_gy(START_GY, POSSIBLE_ACTIVATIONS_GY),
    total_color_gain(POSSIBLE_ACTIVATIONS_GY, COLORED_MANA_GY),
    (
        addmana(COLORED_MANA_HAND, COLORED_MANA_BOARD, COLORED_MANA_HAND_BOARD),
        addmana(COLORED_MANA_HAND_BOARD, COLORED_MANA_GY, COLORED_MANA_GAIN),
        addmana(COLORED_MANA_GAIN, START_MANA, COLORED_MANA_MAX),
        spend(TARGET_COST, COLORED_MANA_MAX, _),
        !
    ),
    (   % Attempt to do so by casting one card and recursing
        remove_first(NAME, START_HAND, NEXT_HAND),
        check_timing(NAME, PRIOR_SEQUENCE),
        card_property(NAME, MODE, cost, COST),
        dif(MODE, flashback),
        spend(COST, START_MANA, NEXT_MANA),
        diff_mana(START_MANA, NEXT_MANA, SPENT_MANA),
        cast(NAME, MODE, YIELD, EXTRA_STEPS,
            [NEXT_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
            [CAST_HAND, CAST_BOARD, CAST_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION],
            PRIOR_SEQUENCE,
            SPENT_MANA),
        append(PRIOR_SEQUENCE, [NAME|EXTRA_STEPS], INTERMEDIATE_SEQUENCE)
    ;   % Or activating something
        (   member(NAME, START_BOARD),
            card(NAME, ON_BOARD_DATA),
            list_to_assoc(ON_BOARD_DATA, CARD),
            get_assoc(activate, CARD, ACTIVATED_NAME)
        ;   member(NAME, START_GY),
            card(NAME, GY_CARD_DATA),
            list_to_assoc(GY_CARD_DATA, CARD),
            get_assoc(activate_gy, CARD, ACTIVATED_NAME)
        ),
        card(ACTIVATED_NAME, ACTIVATION_DATA),
        list_to_assoc(ACTIVATION_DATA, ACTIVATION_CARD),
        check_timing(ACTIVATED_NAME, PRIOR_SEQUENCE),
        get_assoc(cost, ACTIVATION_CARD, COST),
        spend(COST, START_MANA, NEXT_MANA),
        diff_mana(START_MANA, NEXT_MANA, SPENT_MANA),
        specialcast(ACTIVATED_NAME, default, YIELD,
            [START_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
            [CAST_HAND, CAST_BOARD, CAST_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION],
            PRIOR_SEQUENCE,
            SPENT_MANA,
            EXTRA_STEPS),
        append(PRIOR_SEQUENCE, EXTRA_STEPS, INTERMEDIATE_SEQUENCE)
    ),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    makemana_cost_goal(TARGET_COST, TARGET_CARDS,
        [CAST_HAND, CAST_BOARD, RESULT_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
        INTERMEDIATE_SEQUENCE,
    COMBINED_SEQUENCE).

% Cast any single card from a set
cast_one(SET, STATE1, STATE2, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    member(CARD, SET),
    cast_from_hand(CARD, STATE1, STATE2, PRIOR_SEQUENCE, TOTAL_SEQUENCE).
cast_one_opt(SET, STATE1, STATE2, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_one(SET, STATE1, STATE2, PRIOR_SEQUENCE, TOTAL_SEQUENCE).
cast_one_opt(_, STATE, STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE).

% Cast as many cards from a given set as we can, in any order
cast_all(SET, STATE1, STATE3, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    % Recursive case: cast one, then repeat
    cast_one(SET, STATE1, STATE2, PRIOR_SEQUENCE, INTERMEDIATE_SEQUENCE),
    cast_all(SET, STATE2, STATE3, INTERMEDIATE_SEQUENCE, TOTAL_SEQUENCE).
cast_all(SET, STATE1, STATE1, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    % Base case: do nothing if we can't cast any
    not(cast_one(SET, STATE1, _, PRIOR_SEQUENCE, _)), !.

% Cast a series of equivalent sets of cards in a row
cast_in_order([SET1 | T], STATE1, STATE3, PRIOR_SEQUENCE, TOTAL_SEQUENCE) :-
    cast_all(SET1, STATE1, STATE2, PRIOR_SEQUENCE, INTERMEDIATE_SEQUENCE),
    cast_in_order(T, STATE2, STATE3, INTERMEDIATE_SEQUENCE, TOTAL_SEQUENCE).
cast_in_order([], STATE1, STATE1, PRIOR_SEQUENCE, PRIOR_SEQUENCE).

% if a given card is in hand, try to make enough mana and then cast it
make_mana_and_cast(TARGET_CARD_NAME, START_STATE, END_STATE, PRIOR_SEQ, TOTAL_SEQ) :-
    in_hand(TARGET_CARD_NAME, START_STATE),
    makemana_goal(TARGET_CARD_NAME, START_STATE, MANA_STATE, PRIOR_SEQ, MANA_SEQ),
    cast_one([TARGET_CARD_NAME], MANA_STATE, END_STATE, MANA_SEQ, TOTAL_SEQ).

% Goal-directed base case: succeed if the target is still there and the mana is already floating.
%makemana_goal(TARGET_CARD_NAME, START_STATE, START_STATE, []) :-
%    state_hand(START_STATE, START_HAND),
%    state_mana(START_STATE, START_MANA),
%    member(TARGET_CARD_NAME, START_HAND),
%    card(TARGET_CARD_NAME, TARGET_DATA),
%    list_to_assoc(TARGET_DATA, TARGET_CARD),
%    get_assoc(cost, TARGET_CARD, TARGET_MANA),
%    spend(TARGET_MANA, START_MANA, _).
% Recursive case: play one card.
%makemana_goal(TARGET_CARD_NAME, START_STATE, END_STATE, [NAME | T]) :-
%    state_hand(START_STATE, START_HAND),
%    state_gy(START_STATE, START_GY),
%    state_mana(START_STATE, START_MANA),
%    % First, make sure the target is in hand and theoretically castable
%    member(TARGET_CARD_NAME, START_HAND),
%    card(TARGET_CARD_NAME, TARGET_DATA),
%    list_to_assoc(TARGET_DATA, TARGET_CARD),
%    get_assoc(cost, TARGET_CARD, TARGET_MANA),
%    total(TARGET_MANA, TARGET_CMC),
%    prune(TARGET_CMC, START_HAND, START_BOARD, START_GY, START_DECK, START_MANA),
%    format('goal: make ~d to cast ~s :: ~w\n', [TARGET_CMC, TARGET_CARD_NAME, START_STATE]),
%    % Then play another card and recurse
%    member(NAME, START_HAND),
%    format('attempting with ~w\n', [NAME]),
%    card(NAME, DATA),
%    list_to_assoc(DATA, CARD),
%    get_assoc(spell, CARD, IS_SPELL),
%    IS_SPELL >= 0,
%    get_assoc(cost, CARD, COST),
%    remove(NAME, START_HAND, NEXT_HAND),
%    spend(COST, START_MANA, NEXT_MANA),
%    update_hand(START_STATE, NEXT_HAND, INT_STATE),
%    update_mana(INT_STATE, NEXT_MANA, NEXT_STATE),
%    cast(NAME, YIELD, NEXT_STATE, CAST_STATE),
%    state_mana(CAST_STATE, CAST_MANA),
%    addmana(YIELD, CAST_MANA, RESULT_MANA),
%    update_mana(CAST_STATE, RESULT_MANA, RECURSE_STATE),
%    makemana_goal(TARGET_CARD_NAME, RECURSE_STATE, END_STATE, T).

empty_state([[], [], [0,0,0,0,0,0,0], [], 0, [], 0]).
state_hand([HAND, _, _, _, _, _, _], HAND).
state_board([_, BOARD, _, _, _, _, _], BOARD).
state_mana([_, _, MANA, _, _, _, _], MANA).
state_gy([_, _, _, GY, _, _, _], GY).
state_storm([_, _, _, _, STORM, _, _], STORM).
state_deck([_, _, _, _, _, DECK, _], DECK).
state_protection([_, _, _, _, _, _, PROTECTION], PROTECTION).
update_hand( [_, B, M, G, S, D], H, [H, B, M, G, S, D]).
update_hand( [_, B, M, G, S, D, P], H, [H, B, M, G, S, D, P]).
update_board([H, _, M, G, S, D], B, [H, B, M, G, S, D]).
update_board([H, _, M, G, S, D, P], B, [H, B, M, G, S, D, P]).
update_mana( [H, B, _, G, S, D], M, [H, B, M, G, S, D]).
update_mana( [H, B, _, G, S, D, P], M, [H, B, M, G, S, D, P]).
update_gy(   [H, B, M, _, S, D], G, [H, B, M, G, S, D]).
update_gy(   [H, B, M, _, S, D, P], G, [H, B, M, G, S, D, P]).
update_storm([H, B, M, G, _, D], S, [H, B, M, G, S, D]).
update_storm([H, B, M, G, _, D, P], S, [H, B, M, G, S, D, P]).
update_deck( [H, B, M, G, S, _], D, [H, B, M, G, S, D]).
update_deck( [H, B, M, G, S, _, P], D, [H, B, M, G, S, D, P]).
update_protection([H, B, M, G, S, D, _], P, [H, B, M, G, S, D, P]).
start_state(Hand, Library, [Hand, [], [0,0,0,0,0,0,0], [], 0, Library, 0]).

apply_to_hand(FUNCTION, STATE1, STATE2) :-
    state_hand(STATE1, HAND1),
    call(FUNCTION, HAND1, HAND2),
    update_hand(STATE1, HAND2, STATE2).

% Require that the maximum sum of mana is at least a certain amount, even in the
% best situations for the various cards.
prune(TOTAL_MANA, _, _, _, _, _) :- TOTAL_MANA < 1, !.
prune(TOTAL_MANA, [H | T], BOARD, GY, LIBRARY, 0) :-
    % base case: target already reached.
    TOTAL_MANA < 1, !;
    % recursive case (play land)
    istype(H, land),
    maxnet(H, [H|T], BOARD, GY, LIBRARY, NET),
    REMAINDER is TOTAL_MANA - NET,
    prune(REMAINDER, T, [H|BOARD], GY, LIBRARY, 1), !.
prune(TOTAL_MANA, [H | T], BOARD, GY, LIBRARY, LANDS) :-
    % base case: target already reached.
    TOTAL_MANA < 1, !;
    % recursive case (play nonland)
    not(istype(H, land)),
    maxnet(H, [H|T], BOARD, GY, LIBRARY, NET),
    REMAINDER is TOTAL_MANA - NET,
    % add to the board, but if it has an ability, assume that was taken into account and add the used version
    (   activates(H, ONBOARD)
    ;   not(activates(H, _)), ONBOARD = H
    ),
    prune(REMAINDER, T, [ONBOARD|BOARD], [H|GY], LIBRARY, LANDS), !;
    % recursive case (skip): if it's a land, consider skipping it
    istype(H, land),
    prune(TOTAL_MANA, T, BOARD, GY, LIBRARY, LANDS), !.
prune(TOTAL_MANA, HAND, BOARD, GY, LIBRARY, LANDS) :-
    % recursive case (activate permanent)
    remove_first(UNUSED_NAME, BOARD, BOARD2),
    activates(UNUSED_NAME, ACTIVATED_NAME),
    append(BOARD2, [ACTIVATED_NAME], BOARD3),
    maxnet(ACTIVATED_NAME, HAND, BOARD3, GY, LIBRARY, NET),
    REMAINDER is TOTAL_MANA - NET,
    prune(REMAINDER, HAND, BOARD3, GY, LIBRARY, LANDS), !.

prune(TOTAL_MANA, HAND, BOARD, GY, LIBRARY, FLOATING, LANDS) :-
    total(FLOATING, CMC),
    DIFFERENCE is TOTAL_MANA - CMC,
    prune(DIFFERENCE, HAND, BOARD, GY, LIBRARY, LANDS).

prune(TOTAL_MANA, [H, B, M, G, _, D, _]) :-
    prune(TOTAL_MANA, H, B, G, D, M, 0).

% Require that the total possible protection is at least a certain number
prune_protection(MIN_PROTECTION, []) :-
   MIN_PROTECTION < 1, !.
prune_protection(MIN_PROTECTION, [H|T]) :-
    card_key_value_default(H, protection, IS_PROTECTION, 0),
    card_key_value_default(H, find_protection, FIND_PROTECTION, 0),
    PROTECTION is max(IS_PROTECTION, FIND_PROTECTION),
    MIN_REMAINING is MIN_PROTECTION - PROTECTION,
    prune_protection(MIN_REMAINING, T).

prune_storm(REQUIRED, STATE) :-
    state_hand(STATE, HAND),
    state_storm(STATE, CURRENT_STORM),
    map_list_to_pairs(card_storm, HAND, PAIRS),
    pairs_keys(PAIRS, STORM_LIST),
    total(STORM_LIST, HAND_STORM),
    MAX_STORM is CURRENT_STORM + HAND_STORM,
    MAX_STORM >= REQUIRED.

color_gain(NAME, GAIN) :-
    max_yield(NAME, [YW, YU, YB, YR, YG, YC | Y_REST]),
    card_property(NAME, _, cost, [W, U, B, R, G, _, ANY | _]),
    spendExact([W, U, B, R, G, 0, 0], [YW, YU, YB, YR, YG, 0, 0], [GW, GU, GB, GR, GG | _], REMAINDER),
    total(REMAINDER, 0),
    (
        YC > ANY, GC is YC - ANY, !;
        ANY >= YC, GC = 0
    ),
    append([GW, GU, GB, GR, GG, GC], Y_REST, GAIN),
    !;
    GAIN = [0, 0, 0, 0, 0, 0, 0].

total_color_gain([], [0, 0, 0, 0, 0, 0, 0]).
total_color_gain([H|T], GAIN) :-
    color_gain(H, CARD_GAIN),
    total_color_gain(T, REST_GAIN),
    list_sum(CARD_GAIN, REST_GAIN, GAIN),
    !.

list_sum([], [], []).
list_sum([H1|T1], [H2|T2], [H3|T3]) :-
    H3 is H1 + H2,
    list_sum(T1, T2, T3).
list_sum(X, [], X).
list_sum([], X, X).

% Add N of any one color from the mana pool.
anycolor(0, START_MANA, START_MANA) :- !.
anycolor(N, START_MANA, END_MANA) :-
    w(N, START_MANA, END_MANA);
    u(N, START_MANA, END_MANA);
    b(N, START_MANA, END_MANA);
    r(N, START_MANA, END_MANA);
    g(N, START_MANA, END_MANA).
% Add N of a particular color (or colorless).
w(N, START_MANA, END_MANA) :-
    addExact([N,0,0,0,0,0,0], START_MANA, END_MANA).
u(N, START_MANA, END_MANA) :-
    addExact([0,N,0,0,0,0,0], START_MANA, END_MANA).
b(N, START_MANA, END_MANA) :-
    addExact([0,0,N,0,0,0,0], START_MANA, END_MANA).
r(N, START_MANA, END_MANA) :-
    addExact([0,0,0,N,0,0,0], START_MANA, END_MANA).
g(N, START_MANA, END_MANA) :-
    addExact([0,0,0,0,N,0,0], START_MANA, END_MANA).
c(N, START_MANA, END_MANA) :-
    addExact([0,0,0,0,0,N,0], START_MANA, END_MANA).
% Add specific quantities of anything.
addExact([], [], []).
addExact([H_N | T_N], [H_S | T_S], [H_E | T_E]) :-
    H_E is H_S + H_N,
    addExact(T_N, T_S, T_E).
% Add any combination of specific and any color mana.
addmana([W,U,B,R,G,C,GENERIC], START_MANA, END_MANA) :-
    addExact([W,U,B,R,G,C,GENERIC], START_MANA, END_MANA).
%    anycolor(GENERIC, NEXT_MANA, END_MANA).

% Require N of a particular color.
haveW(N, START_MANA) :-
    havemana([N,0,0,0,0,0,0], START_MANA).
haveU(N, START_MANA) :-
    havemana([0,N,0,0,0,0,0], START_MANA).
haveB(N, START_MANA) :-
    havemana([0,0,N,0,0,0,0], START_MANA).
haveR(N, START_MANA) :-
    havemana([0,0,0,N,0,0,0], START_MANA).
haveG(N, START_MANA) :-
    havemana([0,0,0,0,N,0,0], START_MANA).
havemana([], _).
havemana([H_N | T_N], [H_S | T_S]) :-
    H_S >= H_N,
    havemana(T_N, T_S).

% Remove N of any one color from the mana pool.
spendAny(N, START_MANA, END_MANA) :-
    spendC(N, START_MANA, END_MANA);
    spendW(N, START_MANA, END_MANA);
    spendU(N, START_MANA, END_MANA);
    spendB(N, START_MANA, END_MANA);
    spendR(N, START_MANA, END_MANA);
    spendG(N, START_MANA, END_MANA).
% Only spend any-color mana as generic mana if it's the only option
spendAny(N, [W,U,B,R,G,C,A], END_MANA) :-
    N > W,
    N > U,
    N > B,
    N > R,
    N > G,
    N > C,
    spendA(N, [W,U,B,R,G,C,A], END_MANA).
% Spend N of any combination of colors
spendGeneric(N, [W,U,B,R,G,C,A], [W2,U2,B2,R2,G2,C2,A]) :-
    total([W,U,B,R,G,C], TOTAL_SPECIFIC),
    TOTAL_SPECIFIC >= N,
    subtract_total_(N, [W,U,B,R,G,C], [W2,U2,B2,R2,G2,C2]).
% any-color mana should only be used if the rest isn't enough
spendGeneric(N, [W,U,B,R,G,C,A], [0,0,0,0,0,0,A2]) :-
    total([W,U,B,R,G,C], TOTAL_SPECIFIC),
    REMAINDER is N - TOTAL_SPECIFIC,
    REMAINDER > 0, A >= REMAINDER,
    A2 is A - REMAINDER.

subtract_total_(0, LST, LST).
subtract_total_(N, [H|T], [H2|T2]) :-
    N > 0,
    H > 0,
    DECREMENT is H - 1,
    N2 is N - 1,
    subtract_total_(N2, [DECREMENT|T], [H2|T2]).
subtract_total_(N, [H|T], [H|T2]) :-
    N > 0,
    subtract_total_(N, T, T2).

% Don't backtrack when we choose what color to spend.
spendArbitraryAny(N, START_MANA, END_MANA) :-
    spendC(N, START_MANA, END_MANA), !;
    spendW(N, START_MANA, END_MANA), !;
    spendU(N, START_MANA, END_MANA), !;
    spendB(N, START_MANA, END_MANA), !;
    spendR(N, START_MANA, END_MANA), !;
    spendG(N, START_MANA, END_MANA), !;
    spendA(N, START_MANA, END_MANA).
spendArbitraryGeneric(0, START_MANA, START_MANA).
spendArbitraryGeneric(N, START_MANA, END_MANA) :-
    spendArbitraryAny(1, START_MANA, ONE_LESS),
    K is N-1,
    spendArbitraryGeneric(K, ONE_LESS, END_MANA).
% Spend N of a particular color, or colorless, or mana that can be any color.
spendW(N, START_MANA, END_MANA) :-
    spendExact([N,0,0,0,0,0], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendU(N, START_MANA, END_MANA) :-
    spendExact([0,N,0,0,0,0], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendB(N, START_MANA, END_MANA) :-
    spendExact([0,0,N,0,0,0], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendR(N, START_MANA, END_MANA) :-
    spendExact([0,0,0,N,0,0], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendG(N, START_MANA, END_MANA) :-
    spendExact([0,0,0,0,N,0], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendC(N, START_MANA, END_MANA) :-
    spendExact([0,0,0,0,0,N], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).
spendA(N, START_MANA, END_MANA) :-
    spendExact([0,0,0,0,0,0,N], START_MANA, END_MANA, REMAINDER), total(REMAINDER, 0).

% Spend specific quantities of anything.
spendExact([], X, X, []).
spendExact([H_N | T_N], [H_S | T_S], [H_E | T_E], [H_R | T_R]) :-
    (H_S >= H_N, H_E is H_S - H_N, H_R = 0;
    H_N > H_S, H_R is H_N - H_S, H_E = 0),

    spendExact(T_N, T_S, T_E, T_R).
% Spend mana that can be used as any color.
spendAnyColor([0, 0, 0, 0, 0 | _], X, X).
spendAnyColor([W, U, B, R, G | _],
%spendAnyColor([W, U, B, R, G | TT],
              [SW, SU, SB, SR, SG, SC, ANY1 | ST],
              [SW, SU, SB, SR, SG, SC, ANY3 | ST]) :-
    ANY1 > 0,
    total([W, U, B, R, G], TOTAL_NEEDED),
    TOTAL_NEEDED > 0,
    ANY3 is ANY1 - TOTAL_NEEDED,
    ANY3 >= 0.

% Spend specific and/or generic mana.
spend([W, U, B, R, G, C, GENERIC], START_MANA, END_MANA) :-
    spendExact([W,U,B,R,G,C,0], START_MANA, M2, TARGET2),
    noColorless(TARGET2),
    spendAnyColor(TARGET2, M2, M3),
    spendGeneric(GENERIC, M3, END_MANA).
% Hack for optional {R/G} hybrid element:
spend([W, U, B, R, G, C, GENERIC, HYBRID], START_MANA, END_MANA) :-
    spendExact([W,U,B,R,G,C,0], START_MANA, M2, TARGET2),
    noColorless(TARGET2),
    spendHybrid(HYBRID, M2, M3),
    spendAnyColor(TARGET2, M3, M4),
    spendGeneric(GENERIC, M4, END_MANA).
spendHybrid(0, START_MANA, START_MANA).
spendHybrid(N, START_MANA, END_MANA) :-
    spendR(1, START_MANA, M2),
    M is N - 1,
    spendHybrid(M, M2, END_MANA);
    spendG(1, START_MANA, M2),
    M is N - 1,
    spendHybrid(M, M2, END_MANA).
noColorless([_, _, _, _, _, 0 | _]).

% Get the exact mana spent
diff_mana([], [], []).
diff_mana([H|T], [], [H|T]).
diff_mana([H | T1], [H | T2], [0 | T3]) :-
    diff_mana(T1, T2, T3).
diff_mana([H1 | T1], [H2 | T2], [H3 | T3]) :-
    H1 > H2,
    H3 is H1 - H2,
    diff_mana(T1, T2, T3).

spendArbitraryHybrid(0, START_MANA, START_MANA).
spendArbitraryHybrid(N, START_MANA, END_MANA) :-
    spendR(1, START_MANA, M2),
    M is N - 1,
    spendArbitraryHybrid(M, M2, END_MANA), !;
    spendG(1, START_MANA, M2),
    M is N - 1,
    spendArbitraryHybrid(M, M2, END_MANA).
spendArbitrary([W, U, B, R, G, C, GENERIC, HYBRID], START_MANA, END_MANA) :-
    spendArbitraryExact([W,U,B,R,G,C], START_MANA, M2),
    spendArbitraryHybrid(HYBRID, M2, M3),
    spendArbitraryGeneric(GENERIC, M3, END_MANA).
spendArbitrary([W, U, B, R, G, C, GENERIC], START_MANA, END_MANA) :-
    spendExact([W,U,B,R,G,C,0], START_MANA, M2, REMAINDER),
    noColorless(REMAINDER),
    spendAnyColor(REMAINDER, M2, M3),
    spendArbitraryGeneric(GENERIC, M3, END_MANA).


% Convenience methods for dealing with state tuples
spend_(MANA, [H, B, M1, G, S, D, P], [H, B, M2, G, S, D, P]) :- spend(MANA, M1, M2).
spend_generic(MANA, [H, B, M1, G, S, D, P], [H, B, M2, G, S, D, P]) :- spendGeneric(MANA, M1, M2).
remove_from_board(CARDNAME, [H, B1, M, G, S, D, P], [H, B2, M, G, S, D, P]) :- remove_first(CARDNAME, B1, B2).
remove_from_hand(CARDNAME, [H1, B, M, G, S, D, P], [H2, B, M, G, S, D, P]) :- remove_first(CARDNAME, H1, H2).
remove_from_deck(CARDNAME, [H, B, M, G, S, D1, P], [H, B, M, G, S, D2, P]) :- remove_first(CARDNAME, D1, D2).
remove_from_grave(CARDNAME, [H, B, M, G1, S, D, P], [H, B, M, G2, S, D, P]) :- remove_first(CARDNAME, G1, G2).
add_to_hand(CARDNAME, [H, B, M, G, S, D, P], [[CARDNAME|H], B, M, G, S, D, P]).
add_to_board(CARDNAME, [H, B, M, G, S, D, P], [H, [CARDNAME|B], M, G, S, D, P]).
add_to_grave(CARDNAME, [H, B, M, G, S, D, P], [H, B, M, [CARDNAME|G], S, D, P]) :- not(exile_grave([H, B, M, G, S, D, P])).
add_to_grave(_, STATE, STATE) :- exile_grave(STATE).
add_to_deck(CARDNAME, [H, B, M, G, S, D, P], [H, B, M, G, S, [CARDNAME|D], P]).
increment_storm([H, B, M, G, S1, D, P], [H, B, M, G, S2, D, P]) :- S2 is S1 + 1.
deck_to_board(CARDNAME, STATE1, STATE3) :- remove_from_deck(CARDNAME, STATE1, STATE2), add_to_board(CARDNAME, STATE2, STATE3).
deck_to_grave(CARDNAME, STATE1, STATE3) :- remove_from_deck(CARDNAME, STATE1, STATE2), add_to_grave(CARDNAME, STATE2, STATE3).
hand_to_grave(CARDNAME, STATE1, STATE3) :- remove_from_hand(CARDNAME, STATE1, STATE2), add_to_grave(CARDNAME, STATE2, STATE3).
board_to_grave(CARDNAME, STATE1, STATE3) :- remove_from_board(CARDNAME, STATE1, STATE2), add_to_grave(CARDNAME, STATE2, STATE3).
grave_to_board(CARDNAME, STATE1, STATE3) :- remove_from_grave(CARDNAME, STATE1, STATE2), add_to_board(CARDNAME, STATE2, STATE3).
hand_to_board(CARDNAME, STATE1, STATE3) :- remove_from_hand(CARDNAME, STATE1, STATE2), add_to_board(CARDNAME, STATE2, STATE3).

prune_(MANA, [H, B, M, G, _, L, _]) :-
    zone_type_count(B, land, LANDS),
    prune(MANA, H, B, G, L, M, LANDS).
prune_(MANA, [H, B, M, G, _, L, _], SEQ) :-
    zone_type_count(SEQ, land, LANDS),
    prune(MANA, H, B, G, L, M, LANDS).

add_mana_(STATE1, M, STATE2) :-
    state_mana(STATE1, M1),
    addmana(M1, M, M2),
    update_mana(STATE1, M2, STATE2).

take_n(LIST, 0, [], LIST).
take_n(LIST, N, LIST, []) :- length(LIST, N).
take_n(LIST, N, TAKEN, REMAINDER) :-
    N > 0,
    length(LIST, LENGTH),
    LENGTH >= N,
    length(TAKEN, N),
    append(TAKEN, REMAINDER, LIST).

draw(N, START_STATE, END_STATE) :-
    state_deck(START_STATE, D1),
    state_hand(START_STATE, H1),
    take_n(D1, N, DRAWN, D2),
    append(H1, DRAWN, H2),
    update_deck(START_STATE, D2, STATE2),
    update_hand(STATE2, H2, END_STATE).
draw_up_to(N, START_STATE, END_STATE) :-
    state_deck(START_STATE, DECK),
    length(DECK, DECK_SIZE),
    N_DRAW is min(N, DECK_SIZE),
    draw(N_DRAW, START_STATE, END_STATE).

in_hand(CARDNAME, [HAND, _, _, _, _, _, _]) :- member(CARDNAME, HAND).
hand_or_tutor(CARDNAME, [HAND, _, _, _, _, DECK, _]) :- member_or_tutor(CARDNAME, HAND, DECK).
in_deck(CARDNAME, [_, _, _, _, _, DECK, _]) :- member(CARDNAME, DECK).
on_board(CARDNAME, [_, BOARD, _, _, _, _, _]) :- member(CARDNAME, BOARD).

first_in_hand([H|_], STATE, H) :- in_hand(H, STATE).
first_in_hand([H|T], STATE, CARD) :-
    dif(H, CARD),
    first_in_hand(T, STATE, CARD).

role_in_hand(STATE, ROLE, CARDNAME) :-
    in_hand(CARDNAME, STATE),
    has_role(CARDNAME, ROLE).
