load_oops :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('oops.pl'),
    consult('test.pl').

run_oops_tests :-
    load_oops,
    test_beseech,
    test_spend,
    test_powder_check,
    test_hand_1,
    test_hand_2,
    test_hand_3,
    test_hand_4,
    test_hand_5,
    test_hand_6,
    test_hand_7,
    test_culling,
    test_wish_led,
    test_etw,
    test_makemana_goal(_, _).

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

% Hand is a loss, but can take time because of multiple pacts, which could generate the proper CMC
% AND the proper colors but not both
test_hand_5 :-
    HAND = ['Lion\'s Eye Diamond', 'Balustrade Spy', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Dread Return', 'Elvish Spirit Guide', 'Summoner\'s Pact'],
    LIBRARY = ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Cabal Therapy', 'Thassa\'s Oracle',
        'Elvish Spirit Guide', 'Wild Cantor', 'Wild Cantor', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Chancellor of the Tangle'],
    not(hand_wins_(HAND, LIBRARY, [], 1, 0)).

% Should be a loss (after 1 mulligan), but some optimizations resulted in incorrectly labeling it a win
test_hand_6 :-
    HAND = ['Elvish Spirit Guide', 'Summoner\'s Pact', 'Dread Return', 'Simian Spirit Guide', 'Summoner\'s Pact', 'Undercity Informer', 'Chrome Mox'],
    LIBRARY = ['Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Narcomoeba', 'Elvish Spirit Guide', 'Thassa\'s Oracle', 'Cabal Therapy'],
    % Could only be a win if there were a second Dread Return
    hand_wins_(HAND, ['Dread Return'|LIBRARY], [], 1, 0),
    not(hand_wins_(HAND, LIBRARY, [], 1, 0)).

% Should be a win, but was originally flagged as a loss
test_hand_7 :-
    HAND = ['Lotus Petal', 'Narcomoeba', 'Dark Ritual', 'Chrome Mox', 'Balustrade Spy', 'Lotus Petal', 'Narcomoeba'],
    LIBRARY = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba'],
    hand_wins_(HAND, LIBRARY, [], 0, 0),
    % relies on Spy being a sacrificeable creature, so shouldn't work with Informer:
    H2 = ['Lotus Petal', 'Narcomoeba', 'Dark Ritual', 'Chrome Mox', 'Undercity Informer', 'Lotus Petal', 'Narcomoeba'],
    not(hand_wins_(H2, LIBRARY, [], 0, 0)).

% Living Wish with LED should work, if there's a win condition in the sideboard
test_wish_led :-
    HAND = ['Elvish Spirit Guide', 'Living Wish', 'Lion\'s Eye Diamond', 'Elvish Spirit Guide', 'Simian Spirit Guide'],
    LIBRARY = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Narcomoeba'],
    hand_wins_(HAND, LIBRARY, ['Balustrade Spy'], 0, 0),
    hand_wins_(['Chancellor of the Annex'|HAND], LIBRARY, ['Balustrade Spy'], 0, 1), % can add protection
    hand_wins_(['Pact of Negation'|HAND], LIBRARY, ['Balustrade Spy'], 0, 0), % but can't cast Pact for protection
    not(hand_wins_(HAND, LIBRARY, [], 0, _)). % doesn't work without the sideboard

% ETW with storm >= 4 should count as a protected win, unless it requires a Pact
test_etw :-
    HAND = ['Lotus Petal', 'Rite of Flame', 'Mox Opal', 'Elvish Spirit Guide', 'Simian Spirit Guide', 'Empty the Warrens'],
    LIBRARY = ['Elvish Spirit Guide'],
    hand_wins_(['Empty the Warrens'|HAND], LIBRARY, [], 0, 1), % one protection from ETW itself
    hand_wins_(['Chancellor of the Annex'|HAND], LIBRARY, [], 0, 2), % can add protection
    not(hand_wins_(['Pact of Negation'|HAND], LIBRARY, [], 0, 2)), % can't cast Pact for protection
    H2 = ['Lotus Petal', 'Rite of Flame', 'Mox Opal', 'Summoner\'s Pact', 'Simian Spirit Guide', 'Empty the Warrens', 'Empty the Warrens'],
    not(hand_wins_(H2, ['Elvish Spirit Guide'], [], 0, _)). % can't cast Pact for mana

% Culling the Weak with various creatures
test_culling :-
    HAND_1 = ['Agadeem\'s Awakening', 'Dark Ritual', 'Undercity Informer', 'Culling the Weak', 'Quirion Sentinel'],
    LIBRARY = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Narcomoeba'],
    not(hand_wins_(HAND_1, LIBRARY, [], 0, 0)),
    HAND_2 = ['Agadeem\'s Awakening', 'Elvish Spirit Guide', 'Elvish Spirit Guide', 'Burning-Tree Emissary', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_2, LIBRARY, [], 0, 0),
    HAND_3 = ['Agadeem\'s Awakening', 'Grief', 'Bridge from Below', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_3, LIBRARY, [], 0, 1),
    HAND_4 = ['Agadeem\'s Awakening', 'Wild Cantor', 'Elvish Spirit Guide', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_4, LIBRARY, [], 0, 0),
    HAND_5 = ['Agadeem\'s Awakening', 'Summoner\'s Pact', 'Spiritmonger', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_5, ['Endurance'|LIBRARY], [], 0, 0),
    hand_wins_(HAND_5, ['Vine Dryad'|LIBRARY], [], 0, 0),
    HAND_6 = ['Agadeem\'s Awakening', 'Summoner\'s Pact', 'Undercity Informer', 'Culling the Weak'],
    not(hand_wins_(HAND_6, ['Endurance'|['Quirion Sentinel'|['Vine Dryad'|LIBRARY]]], [], 0, 0)),
    HAND_7 = ['Agadeem\'s Awakening', 'Summoner\'s Pact', 'Spiritmonger', 'Undercity Informer', 'Culling the Weak', 'Quirion Sentinel'],
    not(hand_wins_(HAND_7, LIBRARY, [], 0, 0)),
    HAND_8 = ['Elvish Spirit Guide', 'Summoner\'s Pact', 'Elvish Spirit Guide', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_8, ['Quirion Sentinel'|LIBRARY], [], 0, 0),
    HAND_9 = ['Phyrexian Walker', 'Lotus Petal', 'Undercity Informer', 'Culling the Weak'],
    hand_wins_(HAND_9, LIBRARY, [], 0, 0),
    HAND_10 = ['Shield Sphere', 'Mox Opal', 'Shield Sphere', 'Balustrade Spy', 'Culling the Weak'],
    hand_wins_(HAND_10, LIBRARY, [], 0, 0),
    HAND_11 = ['Shield Sphere', 'Mox Opal', 'Elvish Spirit Guide', 'Balustrade Spy', 'Culling the Weak'],
    not(hand_wins_(HAND_11, LIBRARY, [], 0, 0)).

% Sacrifice and Burnt Offering with various creatures
test_sacrifice :-
    HAND_1 = ['Agadeem\'s Awakening', 'Dark Ritual', 'Undercity Informer', 'Sacrifice', 'Quirion Sentinel'],
    LIBRARY = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Narcomoeba'],
    not(hand_wins_(HAND_1, LIBRARY, [], 0, 0)),
    % Sacrifice gets enough mana from Vine Dryad, but not Endurance
    HAND_2 = ['Agadeem\'s Awakening', 'Vine Dryad', 'Spiritmonger', 'Undercity Informer', 'Sacrifice'],
    hand_wins_(HAND_2, LIBRARY, [], 0, 0),
    HAND_3 = ['Agadeem\'s Awakening', 'Endurance', 'Spiritmonger', 'Undercity Informer', 'Sacrifice'],
    not(hand_wins_(HAND_3, LIBRARY, [], 0, 0)),
    % Burnt Offering gets enough mana from Vine Dryad, but not Endurance
    HAND_4 = ['Agadeem\'s Awakening', 'Vine Dryad', 'Spiritmonger', 'Undercity Informer', 'Burnt Offering'],
    hand_wins_(HAND_4, LIBRARY, [], 0, 0),
    HAND_5 = ['Agadeem\'s Awakening', 'Endurance', 'Spiritmonger', 'Undercity Informer', 'Burnt Offering'],
    not(hand_wins_(HAND_5, LIBRARY, [], 0, 0)),
    % Endurance hands should work if given one more mana
    hand_wins_(['Simian Spirit Guide'|HAND_3], LIBRARY, [], 0, 0),
    hand_wins_(['Simian Spirit Guide'|HAND_5], LIBRARY, [], 0, 0),
    % Grief hands should also work
    HAND_6 = ['Agadeem\'s Awakening', 'Grief', 'Thoughtseize', 'Sacrifice', 'Balustrade Spy'],
    HAND_7 = ['Agadeem\'s Awakening', 'Grief', 'Thoughtseize', 'Burnt Offering', 'Balustrade Spy'],
    not(hand_wins_(HAND_6, LIBRARY, [], 0, 2)),
    not(hand_wins_(HAND_7, LIBRARY, [], 0, 2)),
    hand_wins_(HAND_6, LIBRARY, [], 0, 1),
    hand_wins_(HAND_7, LIBRARY, [], 0, 1),
    % But none of these should work without a card to pitch
    HAND_8 = ['Agadeem\'s Awakening', 'Grief', 'Vine Dryad', 'Sacrifice', 'Balustrade Spy'],
    HAND_9 = ['Agadeem\'s Awakening', 'Grief', 'Vine Dryad', 'Burnt Offering', 'Balustrade Spy'],
    not(hand_wins_(HAND_8, LIBRARY, [], 0, _)),
    not(hand_wins_(HAND_9, LIBRARY, [], 0, _)),
    % Offering can generate red for Empty, but Sacrifice can't
    HAND_10 = ['Lotus Petal', 'Vine Dryad', 'Summoner\'s Pact', 'Sacrifice', 'Empty the Warrens', 'Manamorphose'],
    HAND_11 = ['Lotus Petal', 'Vine Dryad', 'Summoner\'s Pact', 'Burnt Offering', 'Empty the Warrens', 'Manamorphose'],
    not(hand_wins_(HAND_10, LIBRARY, [], 0, _)),
    hand_wins_(HAND_11, LIBRARY, [], 0, 1).

% Eldritch Evolution with various creatures
test_eldritch :-
    LIBRARY_1 = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Narcomoeba'],
    LIBRARY_2 = ['Undercity Informer'|LIBRARY_1],
    LIBRARY_3 = ['Balustrade Spy'|LIBRARY_1],
    HAND_1 = ['Elvish Spirit Guide', 'Simian Spirit Guide', 'Simian Spirit Guide', 'Burning-Tree Emissary', 'Eldritch Evolution'],
    not(hand_wins_(HAND_1, LIBRARY_1, [], 0, 0)),
    not(hand_wins_(HAND_1, LIBRARY_2, [], 0, 0)),
    hand_wins_(HAND_1, LIBRARY_3, [], 0, 0),
    HAND_2 = ['Elvish Spirit Guide', 'Elvish Spirit Guide', 'Simian Spirit Guide', 'Elvish Spirit Guide', 'Tinder Wall', 'Eldritch Evolution'],
    not(hand_wins_(HAND_2, LIBRARY_1, [], 0, 0)),
    not(hand_wins_(HAND_2, LIBRARY_2, [], 0, 0)),
    not(hand_wins_(HAND_2, LIBRARY_3, [], 0, 0)),
    HAND_3 = ['Simian Spirit Guide'|HAND_2],
    not(hand_wins_(HAND_3, LIBRARY_1, [], 0, 0)),
    hand_wins_(HAND_3, LIBRARY_2, [], 0, 0),
    not(hand_wins_(HAND_3, LIBRARY_3, [], 0, 0)),
    HAND_4 = ['Summoner\'s Pact', 'Elvish Spirit Guide', 'Chancellor of the Tangle', 'Simian Spirit Guide', 'Eldritch Evolution'],
    not(hand_wins_(HAND_4, LIBRARY_1, [], 0, 0)),
    not(hand_wins_(HAND_4, LIBRARY_2, [], 0, 0)),
    not(hand_wins_(HAND_4, LIBRARY_3, [], 0, 0)),
    LIBRARY_4 = ['Vine Dryad'|LIBRARY_3],
    hand_wins_(HAND_4, LIBRARY_4, [], 0, 0).

% Hands with castable and uncastable pitch spells
test_pitch :-
    LIBRARY_1 = ['Narcomoeba', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Narcomoeba', 'Cabal Therapy'],
    LIBRARY_2 = ['Narcomoeba', 'Thassa\'s Oracle', 'Narcomoeba', 'Narcomoeba', 'Cabal Therapy'], % needs to Therapy DR
    LIBRARY_3 = ['Narcomoeba', 'Dread Return', 'Narcomoeba', 'Narcomoeba', 'Cabal Therapy'], % needs to Therapy TO
    HAND_1 = ['Balustrade Spy', 'Thassa\'s Oracle', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Force of Will'],
    HAND_2 = ['Balustrade Spy', 'Thassa\'s Oracle', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Misdirection'],
    HAND_3 = ['Balustrade Spy', 'Thassa\'s Oracle', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Unmask'],
    HAND_4 = ['Balustrade Spy', 'Thassa\'s Oracle', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Grief'],
    hand_wins_(HAND_1, LIBRARY_1, [], 0, 1),
    hand_wins_(HAND_2, LIBRARY_1, [], 0, 1),
    not(hand_wins_(HAND_3, LIBRARY_1, [], 0, 1)),
    not(hand_wins_(HAND_4, LIBRARY_1, [], 0, 1)),
    hand_wins_(HAND_3, LIBRARY_1, [], 0, 0),
    hand_wins_(HAND_4, LIBRARY_1, [], 0, 0),
    not(hand_wins_(HAND_1, LIBRARY_2, [], 0, _)),
    not(hand_wins_(HAND_2, LIBRARY_2, [], 0, _)),
    not(hand_wins_(HAND_3, LIBRARY_2, [], 0, _)),
    not(hand_wins_(HAND_4, LIBRARY_2, [], 0, _)),
    not(hand_wins_(HAND_1, LIBRARY_3, [], 0, 1)),
    not(hand_wins_(HAND_2, LIBRARY_3, [], 0, 1)),
    not(hand_wins_(HAND_3, LIBRARY_3, [], 0, 1)),
    not(hand_wins_(HAND_4, LIBRARY_3, [], 0, 1)),
    hand_wins_(HAND_1, LIBRARY_3, [], 0, 0),
    hand_wins_(HAND_2, LIBRARY_3, [], 0, 0),
    hand_wins_(HAND_3, LIBRARY_3, [], 0, 0),
    hand_wins_(HAND_4, LIBRARY_3, [], 0, 0),
    HAND_5 = ['Balustrade Spy', 'Dread Return', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Force of Will'],
    HAND_6 = ['Balustrade Spy', 'Dread Return', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Misdirection'],
    HAND_7 = ['Balustrade Spy', 'Dread Return', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Unmask'],
    HAND_8 = ['Balustrade Spy', 'Dread Return', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Grief'],
    not(hand_wins_(HAND_5, LIBRARY_1, [], 0, 1)),
    not(hand_wins_(HAND_6, LIBRARY_1, [], 0, 1)),
    hand_wins_(HAND_5, LIBRARY_1, [], 0, 0),
    hand_wins_(HAND_6, LIBRARY_1, [], 0, 0),
    hand_wins_(HAND_7, LIBRARY_1, [], 0, 1),
    hand_wins_(HAND_8, LIBRARY_1, [], 0, 1),
    not(hand_wins_(HAND_5, LIBRARY_2, [], 0, 1)),
    not(hand_wins_(HAND_6, LIBRARY_2, [], 0, 1)),
    not(hand_wins_(HAND_7, LIBRARY_2, [], 0, 1)),
    not(hand_wins_(HAND_8, LIBRARY_2, [], 0, 1)),
    hand_wins_(HAND_5, LIBRARY_2, [], 0, 0),
    hand_wins_(HAND_6, LIBRARY_2, [], 0, 0),
    hand_wins_(HAND_7, LIBRARY_2, [], 0, 0),
    hand_wins_(HAND_8, LIBRARY_2, [], 0, 0),
    not(hand_wins_(HAND_5, LIBRARY_3, [], 0, _)),
    not(hand_wins_(HAND_6, LIBRARY_3, [], 0, _)),
    not(hand_wins_(HAND_7, LIBRARY_3, [], 0, _)),
    not(hand_wins_(HAND_8, LIBRARY_3, [], 0, _)),
    HAND_9 = ['Balustrade Spy', 'Dread Return', 'Lotus Petal', 'Dark Ritual', 'Simian Spirit Guide', 'Force of Will', 'Unmask'],
    not(hand_wins_(HAND_9, LIBRARY_1, [], 0, 2)),
    not(hand_wins_(HAND_9, LIBRARY_2, [], 0, 2)),
    not(hand_wins_(HAND_9, LIBRARY_3, [], 0, 2)),
    hand_wins_(HAND_9, LIBRARY_1, [], 0, 1),
    not(hand_wins_(HAND_9, LIBRARY_2, [], 0, 1)),
    hand_wins_(HAND_9, LIBRARY_2, [], 0, 0),
    not(hand_wins_(HAND_9, LIBRARY_3, [], 0, _)),
    hand_wins_(['The Mimeoplasm'|HAND_9], LIBRARY_1, [], 0, 2),
    not(hand_wins_(['The Mimeoplasm'|HAND_9], LIBRARY_2, [], 0, 2)),
    hand_wins_(['The Mimeoplasm'|HAND_9], LIBRARY_2, [], 0, 1),
    not(hand_wins_(['The Mimeoplasm'|HAND_9], LIBRARY_3, [], 0, _)).

% Once Upon a Time
test_once :-
    LIBRARY_1 = ['Chancellor of the Tangle', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Balustrade Spy', 'Narcomoeba', 'Narcomoeba'],
    LIBRARY_2 = ['Simian Spirit Guide'|LIBRARY_1],
    HAND_1 = ['Elvish Spirit Guide', 'Simian Spirit Guide', 'Lotus Petal', 'Lotus Petal', 'Once Upon a Time'],
    HAND_2 = ['Elvish Spirit Guide', 'Simian Spirit Guide', 'Undercity Informer', 'Lotus Petal', 'Once Upon a Time'],
    not(hand_wins_(HAND_1, LIBRARY_2, [], 0, 0)),
    not(hand_wins_(HAND_2, LIBRARY_1, [], 0, 0)),
    hand_wins_(HAND_2, LIBRARY_2, [], 0, 0),
    hand_wins_(HAND_1, LIBRARY_1, [], 0, 0),
    LIBRARY_PROTECT = ['Chancellor of the Tangle', 'Grief', 'Thassa\'s Oracle', 'Dread Return', 'Narcomoeba', 'Balustrade Spy', 'Narcomoeba', 'Narcomoeba'],
    HAND_3 = ['Elvish Spirit Guide', 'Dark Ritual', 'Agadeem\'s Awakening', 'Agadeem\'s Awakening', 'Balustrade Spy', 'Once Upon a Time'],
    hand_wins_(HAND_3, LIBRARY_PROTECT, [], 0, 1),
    reverse(LIBRARY_PROTECT, LIBRARY_REVERSED),
    hand_wins_(HAND_3, LIBRARY_REVERSED, [], 0, 0),
    not(hand_wins_(HAND_3, LIBRARY_REVERSED, [], 0, 1)).

% Beseech the Mirror
test_beseech :-
    LIBRARY = ['Balustrade Spy', 'Narcomoeba', 'Narcomoeba', 'Thassa\'s Oracle', 'Dread Return'],
    HAND = ['Beseech the Mirror', 'Dark Ritual', 'Agadeem\'s Awakening', 'Elvish Spirit Guide'],
    not(hand_wins_(HAND, LIBRARY, [], 0, 0)),
    hand_wins_(['Chrome Mox'|HAND], LIBRARY, [], 0, 0),
    hand_wins_(['Mox Opal'|HAND], LIBRARY, [], 0, 0),
    hand_wins_(['Lotus Petal'|HAND], LIBRARY, [], 0, 0).

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

test_powder_check :-
    ONE_MOEBA = ['Pact of Negation', 'Agadeem\'s Awakening', 'Summoner\'s Pact',
        'Cabal Ritual', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Narcomoeba',
        'Wild Cantor', 'Bridge from Below', 'Dark Ritual', 'Chrome Mox', 'Chrome Mox', 'Chrome Mox',
        'Elvish Spirit Guide', 'Dread Return', 'Serum Powder', 'Lotus Petal', 'Undercity Informer',
        'Pact of Negation', 'Balustrade Spy', 'Undercity Informer', 'Elvish Spirit Guide',
        'Cabal Ritual', 'Simian Spirit Guide', 'Turntimber Symbiosis', 'Elvish Spirit Guide',
        'Cabal Therapy', 'Agadeem\'s Awakening', 'Chrome Mox', 'Lotus Petal', 'Dread Return',
        'Pact of Negation', 'Thassa\'s Oracle', 'Agadeem\'s Awakening', 'Lotus Petal',
        'Balustrade Spy', 'Lotus Petal', 'Cabal Ritual', 'Agadeem\'s Awakening',
        'Simian Spirit Guide', 'Dark Ritual', 'Simian Spirit Guide', 'Balustrade Spy',
        'Dark Ritual', 'Undercity Informer'],
    not(library_contains_win([], ONE_MOEBA)),
    TWO_MOEBAS = ['Narcomoeba'|ONE_MOEBA],
    not(library_contains_win([], TWO_MOEBAS)),
    library_contains_win([], ['Narcomoeba'|TWO_MOEBAS]),
    TWO_BRIDGES = ['Bridge from Below'|ONE_MOEBA],
    not(library_contains_win([], TWO_BRIDGES)),
    library_contains_win([], ['Narcomoeba'|TWO_BRIDGES]),
    library_contains_win([], ['Bridge from Below'|TWO_BRIDGES]),
    ONLY_MOEBAS = ['Pact of Negation', 'Agadeem\'s Awakening', 'Summoner\'s Pact',
        'Cabal Ritual', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Narcomoeba',
        'Wild Cantor', 'Dark Ritual', 'Chrome Mox', 'Chrome Mox', 'Chrome Mox',
        'Elvish Spirit Guide', 'Narcomoeba', 'Serum Powder', 'Lotus Petal', 'Undercity Informer',
        'Pact of Negation', 'Balustrade Spy', 'Undercity Informer', 'Elvish Spirit Guide',
        'Cabal Ritual', 'Simian Spirit Guide', 'Turntimber Symbiosis', 'Elvish Spirit Guide',
        'Cabal Therapy', 'Agadeem\'s Awakening', 'Chrome Mox', 'Lotus Petal', 'Narcomoeba',
        'Pact of Negation', 'Agadeem\'s Awakening', 'Lotus Petal', 'Balustrade Spy', 'Lotus Petal',
        'Cabal Ritual', 'Agadeem\'s Awakening', 'Simian Spirit Guide', 'Dark Ritual',
        'Simian Spirit Guide', 'Balustrade Spy', 'Dark Ritual', 'Undercity Informer'],
    not(library_contains_win([], ONLY_MOEBAS)),
    not(library_contains_win([], ['Dread Return'|ONLY_MOEBAS])),
    not(library_contains_win([], ['Bridge from Below'|ONLY_MOEBAS])),
    not(library_contains_win([], ['Thassa\'s Oracle'|ONLY_MOEBAS])),
    not(library_contains_win([], ['Bridge from Below'|['Thassa\'s Oracle'|ONLY_MOEBAS]])),
    not(library_contains_win([], ['Bridge from Below'|['Dread Return'|ONLY_MOEBAS]])),
    library_contains_win([], ['Thassa\'s Oracle'|['Dread Return'|ONLY_MOEBAS]]),
    NO_THERAPY = ['Pact of Negation', 'Agadeem\'s Awakening', 'Summoner\'s Pact',
        'Cabal Ritual', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Summoner\'s Pact', 'Narcomoeba',
        'Wild Cantor', 'Bridge from Below', 'Dark Ritual', 'Chrome Mox', 'Chrome Mox', 'Chrome Mox',
        'Elvish Spirit Guide', 'Dread Return', 'Serum Powder', 'Lotus Petal', 'Undercity Informer',
        'Pact of Negation', 'Balustrade Spy', 'Undercity Informer', 'Elvish Spirit Guide',
        'Cabal Ritual', 'Simian Spirit Guide', 'Turntimber Symbiosis', 'Elvish Spirit Guide',
        'Narcomoeba', 'Agadeem\'s Awakening', 'Chrome Mox', 'Lotus Petal', 'Dread Return',
        'Pact of Negation', 'Thassa\'s Oracle', 'Agadeem\'s Awakening', 'Lotus Petal',
        'Balustrade Spy', 'Lotus Petal', 'Cabal Ritual', 'Agadeem\'s Awakening',
        'Simian Spirit Guide', 'Dark Ritual', 'Simian Spirit Guide', 'Balustrade Spy',
        'Dark Ritual', 'Undercity Informer'],
    not(library_contains_win([], NO_THERAPY)),
    not(library_contains_win([], ['Bridge from Below'|NO_THERAPY])),
    not(library_contains_win([], ['Cabal Therapy'|NO_THERAPY])),
    library_contains_win([], ['Narcomoeba'|NO_THERAPY]),
    library_contains_win([], ['Bridge from Below'|['Cabal Therapy'|NO_THERAPY]]).
