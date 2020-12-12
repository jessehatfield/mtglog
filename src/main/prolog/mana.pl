% Base case: make no mana, nothing changes.
makemana(START_STATE, START_STATE, _, []).

% Recursive case: play one card.
makemana([START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
	[END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
	PRIOR_SEQUENCE,
	[NAME | T]) :-
    member(NAME, START_HAND),
    check_timing(NAME, PRIOR_SEQUENCE),
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cost, CARD, COST),
    remove(NAME, START_HAND, NEXT_HAND),
    append(PRIOR_SEQUENCE, [NAME], CAST_SEQUENCE),
    spend(COST, START_MANA, NEXT_MANA),
    cast(NAME, YIELD,
    	[NEXT_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    	[CAST_HAND, CAST_BOARD, CAST_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION]),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    makemana([CAST_HAND, CAST_BOARD, RESULT_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION],
	[END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
        CAST_SEQUENCE,
	T).

check_timing(CARDNAME, ALREADY_CAST) :-
    check_castfirst(CARDNAME, ALREADY_CAST),
    check_castlast(CARDNAME, ALREADY_CAST).
check_castfirst(CARDNAME, ALREADY_CAST) :-
    not(castfirst(CARDNAME));
    castfirst(CARDNAME), onlycastfirst(ALREADY_CAST).
onlycastfirst([]).
onlycastfirst([H | T]) :-
    castfirst(H), onlycastfirst(T).
check_castlast(CARDNAME, ALREADY_CAST) :-
    castlast(CARDNAME);
    not(castlast(CARDNAME)), nocastlast(ALREADY_CAST).
nocastlast([]).
nocastlast([H | T]) :-
    not(castlast(H)), nocastlast(T).

makemana_goal(TARGET_CARD_NAME, START_STATE, START_STATE, PRIOR_SEQUENCE, PRIOR_SEQUENCE) :-
    check_timing(TARGET_CARD_NAME, PRIOR_SEQUENCE),
    state_hand(START_STATE, HAND),
    member(TARGET_CARD_NAME, HAND),
    % Require that we have the mana to cast the card
    card(TARGET_CARD_NAME, TARGET_CARD_DATA),
    list_to_assoc(TARGET_CARD_DATA, TARGET_CARD),
    get_assoc(cost, TARGET_CARD, TARGET_COST),
    state_mana(START_STATE, START_MANA),
    spend(TARGET_COST, START_MANA, _).
makemana_goal(TARGET_CARD_NAME,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
	[END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
        PRIOR_SEQUENCE,
	COMBINED_SEQUENCE) :-
    % Verify that we have the target and could theoretically get the mana and colors to cast it
    member(TARGET_CARD_NAME, START_HAND),
    card(TARGET_CARD_NAME, TARGET_CARD_DATA),
    list_to_assoc(TARGET_CARD_DATA, TARGET_CARD),
    get_assoc(cost, TARGET_CARD, TARGET_COST),
    total(TARGET_COST, TARGET_CMC),
    prune(TARGET_CMC, START_HAND, START_BOARD, START_GY, START_MANA),
    total_color_gain(START_HAND, COLORED_MANA_HAND),
    (
        addmana(COLORED_MANA_HAND, START_MANA, COLORED_MANA_MAX),
        spend(TARGET_COST, COLORED_MANA_MAX, _),
        !
    ),
    % Attempt to do so by casting one card and recursing
    member(NAME, START_HAND),
    check_timing(NAME, PRIOR_SEQUENCE),
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cost, CARD, COST),
    spend(COST, START_MANA, NEXT_MANA),
    remove(NAME, START_HAND, NEXT_HAND),
    append(PRIOR_SEQUENCE, [NAME], INTERMEDIATE_SEQUENCE),
    cast(NAME, YIELD,
    	[NEXT_HAND, START_BOARD, NEXT_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    	[CAST_HAND, CAST_BOARD, CAST_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION]),
    addmana(YIELD, CAST_MANA, RESULT_MANA),
    makemana_goal(TARGET_CARD_NAME,
        [CAST_HAND, CAST_BOARD, RESULT_MANA, CAST_GY, CAST_STORM, CAST_DECK, CAST_PROTECTION],
	[END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
        INTERMEDIATE_SEQUENCE,
	COMBINED_SEQUENCE).

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
%    prune(TARGET_CMC, START_HAND, START_BOARD, START_GY, START_MANA),
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

state_hand([HAND, _, _, _, _, _, _], HAND).
state_board([_, BOARD, _, _, _, _, _], BOARD).
state_mana([_, _, MANA, _, _, _, _], MANA).
state_gy([_, _, _, GY, _, _, _], GY).
state_storm([_, _, _, _, STORM, _, _], STORM).
state_deck([_, _, _, _, _, DECK, _], DECK).
state_protection([_, _, _, _, _, _, PROTECTION], PROTECTION).
update_hand( [_, B, M, G, S, D], H, [H, B, M, G, S, D]).
update_board([H, _, M, G, S, D], B, [H, B, M, G, S, D]).
update_mana( [H, B, _, G, S, D], M, [H, B, M, G, S, D]).
update_gy(   [H, B, M, _, S, D], G, [H, B, M, G, S, D]).
update_storm([H, B, M, G, _, D], S, [H, B, M, G, S, D]).
update_deck( [H, B, M, G, S, _], D, [H, B, M, G, S, D]).

% Require that the maximum sum of mana is at least a certain amount, even in the
% best situations for the various cards.
prune(TOTAL_MANA, _, _, _) :- TOTAL_MANA < 1, !.
prune(TOTAL_MANA, [H | T], BOARD, GY) :-
    TOTAL_MANA < 1, !;
    maxnet(H, [H|T], BOARD, GY, NET),
    REMAINDER is TOTAL_MANA - NET,
    prune(REMAINDER, T, [H|BOARD], [H|GY]).
prune(TOTAL_MANA, HAND, BOARD, GY, FLOATING) :-
    total(FLOATING, CMC),
    DIFFERENCE is TOTAL_MANA - CMC,
    prune(DIFFERENCE, HAND, BOARD, GY).
total([], 0).
total([H | T], SUM) :-
    total(T, PARTIAL),
    SUM is H + PARTIAL.
% Require that the total possible protection is at least a certain number
prune_protection(MIN_PROTECTION, []) :-
    MIN_PROTECTION < 1.
prune_protection(MIN_PROTECTION, [H|T]) :-
    card(H, DATA),
    list_to_assoc(DATA, CARD),
    (
        get_assoc(protection, CARD, P),
        REMAINDER is MIN_PROTECTION - P,
        prune_protection(REMAINDER, T);
        not(get_assoc(protection, CARD, _)),
        prune_protection(MIN_PROTECTION, T)
    ).

color_gain(NAME, GAIN) :-
    max_yield(NAME, [YW, YU, YB, YR, YG, YC | Y_REST]),
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(cost, CARD, [W, U, B, R, G, _, ANY | _]),
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
