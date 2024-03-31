load_reanimator :-
    consult('mana.pl'),
    consult('cards.pl'),
    consult('reanimator_cards.pl'),
    consult('reanimator.pl').

run_reanimator_tests :-
    load_reanimator,
    test_hand_1.

test_hand_1 :-
    LIBRARY = ['UNKNOWN', 'Griselbrand', 'Inkwell Leviathan'],
    HAND = ['Simian Spirit Guide', 'Lotus Petal', 'Dark Ritual', 'Entomb', 'Animate Dead', 'Chancellor of the Annex'],
    hand_wins_(HAND, LIBRARY, 0, 1).

hand_wins_(HAND, LIBRARY, MULLIGANS, PROTECTION) :-
    format('~w\n', [HAND]),
    play_reanimator_hand(HAND, LIBRARY, [], MULLIGANS, _{protection:1}, OUTPUTS),
    format(' -->~w (~wx protection)\n', [OUTPUTS.sequence, OUTPUTS.protection]),
    PROTECTION is OUTPUTS.protection.
