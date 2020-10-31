% to test: tokens/Bridge/Therapy

example(S) :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
    win(['Summoner\'s Pact', 'Summoner\'s Pact', 'Undercity Informer',
            'Simian Spirit Guide', 'Simian Spirit Guide', 'Summoner\'s Pact'],
        ['Wild Cantor', 'Elvish Spirit Guide', 'Tinder Wall', 'Thassa\'s Oracle',
	 'Dread Return', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba'],
        S).

hand('informer', ['Undercity Informer', 'Elvish Spirit Guide', 'Lotus Petal', 'Dark Ritual']).
hand('spy', ['Balustrade Spy', 'Elvish Spirit Guide', 'Lotus Petal', 'Dark Ritual']).

slice(LIST, 0, [], LIST).
slice([H|T], 1, [H], T).
slice(LIST, N, PREFIX, SUFFIX) :-
    M is N - 1,
    slice(LIST, M, SUB, [NEXT|SUFFIX]),
    append(SUB, [NEXT], PREFIX).

draw(DECK, HAND_SIZE, HAND, LIBRARY) :-
    random_permutation(DECK, SHUFFLED),
    slice(SHUFFLED, HAND_SIZE, HAND, LIBRARY),
    !.

play_hand(HAND, LIBRARY, SB, MIN_PROTECTION, PUT_BACK, MULL_HAND, SEQ, PROTECTION) :-
    combination(HAND, PUT_BACK, BOTTOM, MULL_HAND),
    append(LIBRARY, BOTTOM, MULL_LIBRARY),
    protected_win(MULL_HAND, MULL_LIBRARY, SB, MIN_PROTECTION, 3, SEQ, PROTECTION),
    !.

play_game(DECK, SB, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, FINAL_HAND, SEQ, N_MULLIGANS, PROTECTION, RESULT) :-
    (N_MULLIGANS < GREEDY_MULLIGANS, REQUIRED_PROTECTION is MIN_PROTECTION; N_MULLIGANS >= GREEDY_MULLIGANS, REQUIRED_PROTECTION is 0),
    draw(DECK, 7, HAND, LIBRARY),
    (
        play_hand(HAND, LIBRARY, SB, REQUIRED_PROTECTION, N_MULLIGANS, FINAL_HAND, SEQ, PROTECTION),
        RESULT = 1,
        !;

        MAX_MULLIGANS > N_MULLIGANS,
        NEXT_MULLIGAN is N_MULLIGANS + 1,
        play_game(DECK, SB, MAX_MULLIGANS, REQUIRED_PROTECTION, GREEDY_MULLIGANS, FINAL_HAND, SEQ2, NEXT_MULLIGAN, PROTECTION, RESULT),
        append(['mulligan'], SEQ2, SEQ),
        !;

        N_MULLIGANS >= MAX_MULLIGANS,
        RESULT = 0,
        SEQ = [],
        FINAL_HAND = HAND,
        PROTECTION = -1,
        !
    ), !.
play_game(_, _, _, _, _, _, [], _, -1, 0).

play_game(DECK, SB, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HAND, SEQ, PROTECTION, RESULT) :-
    play_game(DECK, SB, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HAND, SEQ, 0, PROTECTION, RESULT),
%    format('\t~d : ~w\n', [RESULT, SEQ]),
    !.

combination(X, 0, [], X).
combination([H|T], N, [H|CHOICE], REMAINDER) :-
    N > 0,
    M is N - 1,
    combination(T, M, CHOICE, REMAINDER).
combination([H|T], N, CHOICE, [H|REMAINDER]) :-
    N > 0,
    combination(T, N, CHOICE, REMAINDER).

play_games(N, DECK, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HANDS, SEQS, PROT_COUNTS, RESULTS) :-
    play_games(N, DECK, [], HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HANDS, SEQS, PROT_COUNTS, RESULTS).
play_games(1, DECK, SB, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, [HAND], [SEQ], [PROTECTION], RESULT) :-
    MULLIGANS_SO_FAR is 7 - HAND_SIZE,
    play_game(DECK, SB, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HAND, SEQ, MULLIGANS_SO_FAR, PROTECTION, RESULT).
play_games(N, DECK, SB, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, [H1|HANDS2], [SEQ1|SEQS2], [P1|P2], WINS) :-
    MULLIGANS_SO_FAR is 7 - HAND_SIZE,
    N > 1,
    M is N-1,
    play_games(M, DECK, SB, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, HANDS2, SEQS2, P2, WINS2),
    (
        showProgress(INTERVAL),
        (
            M mod INTERVAL > 0;
            format("~w wins out of ~w\n", [WINS2, M])
        )
    ),
    play_game(DECK, SB, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, H1, SEQ1, MULLIGANS_SO_FAR, P1, RESULT),
    WINS is WINS2 + RESULT .

playtest(DECK_NAME, N, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, WINS) :-
    decklist(DECK_NAME, DECK),
    play_games(N, DECK, HAND_SIZE, MAX_MULLIGANS, MIN_PROTECTION, GREEDY_MULLIGANS, _, _, _, WINS),
    P is 100.0 * WINS / N,
    format('~w: ~d / ~d (~1f%)\n', [DECK_NAME, WINS, N, P]).
playtest(DECK_NAME, N, HAND_SIZE, MAX_MULLIGANS, WINS) :-
    playtest(DECK_NAME, N, HAND_SIZE, MAX_MULLIGANS, 0, 0, WINS).

%showProgress(1000).

main :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
    consult('lists.pl'),
    playtest('oracle', 10, 7, 1, _), %33.95
%    playtest('TabaDonk', 1000, _), 18.2%
%    playtest('-jax-', 1000, _), 19.65%
    fail.

test :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
%    consult('lists.pl'),
%    decklist('oracle', DECK),
    LIBRARY = ['UNKNOWN', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Dread Return', 'Elvish Spirit Guide', 'Thassa\'s Oracle'],
    append(LIBRARY, LIBRARY, L2),
    append(L2, L2, L3),
%    testhand(['Balustrade Spy', 'Chrome Mox', 'Turntimber Symbiosis', 'Chancellor of the Annex', 'Dark Ritual', 'Agadeem\'s Awakening'], LIBRARY),
%    testhand(['Balustrade Spy', 'Chrome Mox', 'Turntimber Symbiosis', 'Pact of Negation', 'Dark Ritual', 'Agadeem\'s Awakening'], LIBRARY),
    testhand(['Dark Ritual', 'Dark Ritual', 'Goblin Charbelcher', 'Dark Ritual', 'Agadeem\'s Awakening'], L3),
%    testhand(['Dark Ritual', 'Dark Ritual', 'Goblin Charbelcher', 'Pact of Negation', 'Chancellor of the Annex', 'Dark Ritual', 'Agadeem\'s Awakening'], L3),
%    testhand(['Dark Ritual', 'Dark Ritual', 'Goblin Charbelcher', 'Pact of Negation', 'Lion\'s Eye Diamond', 'Dark Ritual', 'Agadeem\'s Awakening'], L3),
    testhand(['Cabal Therapy', 'Agadeem\'s Awakening', 'Dark Ritual', 'Dark Ritual', 'Balustrade Spy'], LIBRARY),
    testhand(['Cabal Therapy', 'Chrome Mox', 'Agadeem\'s Awakening', 'Dark Ritual', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Balustrade Spy'], LIBRARY),
%    HAND = ['Balustrade Spy', 'Chrome Mox', 'Manamorphose', 'Dark Ritual', 'Elvish Spirit Guide', 'Chancellor of the Tangle'],
    %'Lion\'s Eye Diamond'
%    HAND = ['Wild Cantor', 'Summoner\'s Pact', 'Mox Opal', 'Undercity Informer', 'Undercity Informer', 'Chrome Mox', 'Chrome Mox'],
%    HAND = ['Chancellor of the Tangle', 'Balustrade Spy', 'Grim Monolith', 'Lotus Petal', 'Mox Opal', 'Balustrade Spy', 'Wild Cantor'],
%    HAND = ['Mox Opal', 'Thassa\'s Oracle', 'Lotus Petal', 'Balustrade Spy', 'Dark Ritual', 'Balustrade Spy', 'Wild Cantor'],
%    HAND = ['Balustrade Spy', 'Simian Spirit Guide', 'Narcomoeba', 'Grim Monolith', 'Pyretic Ritual', 'Summoner\'s Pact', 'Balustrade Spy'],
%    HAND = ['Chrome Mox', 'Lion\'s Eye Diamond', 'Pyretic Ritual', 'Undercity Informer', 'Balustrade Spy', 'Chancellor of the Tangle', 'Chancellor of the Tangle'],
%    HAND = ['Simian Spirit Guide', 'Chrome Mox','Seething Song', 'Grim Monolith', 'Lotus Petal', 'Undercity Informer', 'Chrome Mox'],
    !, fail.

testhand(HAND, LIBRARY) :-
    format('~w\n', [HAND]),
    (
        protected_win(HAND, LIBRARY, [], 1, 3, SEQ, PROTECTION),
        format(' -->~w (~wx protection)\n', [SEQ, PROTECTION]);
        format(' fail.\n', [])
    ),
    !.

removeAll([], LIST, LIST).
removeAll([H|T], LIST, RESULT) :-
    remove(H, LIST, SUB),
    removeAll(T, SUB, RESULT).

%main :-
%    current_prolog_flag(argv, Argv),
%    append(_, [--|Av], Argv), !,
%    main(Argv).
