% To test:
% Mox Opal
% land/spells

% To implement:
% Land Grant
% make Manamorphose draw a card (doesn't it already?)
% Culling the Weak
% Wish for mana?
% Cast creatures just for Dread Return (have we done that yet?)
% Multiple Bridge from Below
% Casting the land/spells (e.g. Turntimber Symbiosis)
% Finale of Devastation
% Neoform and Eldritch Evolution

% Placeholder
card('Unknown', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [],
    spell  - -1,
    board  - 0,
    gy     - 0
]).

% Mana generation

card('Elvish Spirit Guide', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 1, 0, 0],
    net    - 1,
    colors - [g],
    types  - [creature],
    spell  - 0,
    board  - 0,
    gy     - 0
]).
card('Simian Spirit Guide', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 1, 0, 0, 0],
    net    - 1,
    colors - [r],
    types  - [creature],
    spell  - 0,
    board  - 0,
    gy     - 0
]).
card('Lotus Petal', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 1,
    colors - [],
    types  - [artifact],
    spell  - 1, 
    board  - 0,
    gy     - 1
]).
card('Chrome Mox', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    best   - [0, 0, 0, 0, 0, 0, 1],
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Mox Opal', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    best   - [0, 0, 0, 0, 0, 0, 1],
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Chancellor of the Tangle', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 1, 0, 0],
    net    - 1,
    colors - [g],
    types  - [creature],
    spell  - 0,
    board  - 0,
    gy     - 0
]).

card('Dark Ritual', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 2,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Cabal Ritual', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 3,
    best   - [0, 0, 5, 0, 0, 0, 0],
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).

card('Rite of Flame', [
    cost   - [0, 0, 0, 1, 0, 0, 0],
    yield  - [0, 0, 0, 2, 0, 0, 0],
    net    - 4,
    best   - [0, 0, 0, 5, 0, 0, 0],
    colors - [r],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Pyretic Ritual', [
    cost   - [0, 0, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 3, 0, 0, 0],
    net    - 1,
    colors - [r],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Desperate Ritual', [
    cost   - [0, 0, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 3, 0, 0, 0],
    net    - 1,
    colors - [r],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Seething Song', [
    cost   - [0, 0, 0, 1, 0, 0, 2],
    yield  - [0, 0, 0, 5, 0, 0, 0],
    net    - 2,
    colors - [r],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Tinder Wall', [
    cost   - [0, 0, 0, 0, 1, 0, 0],
    yield  - [0, 0, 0, 2, 0, 0, 0],
    net    - 1,
    colors - [g],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 1
]).

%card('Lion\'s Eye Diamond', [
%    cost   - [0, 0, 0, 0, 0, 0, 0],
%    yield  - [0, 0, 0, 0, 0, 0, 3],
%    net    - 3,
%    colors - [],
%    types  - [],
%    spell  - 1,
%    board  - 0,
%    gy     - 1
%]).
card('Lion\'s Eye Diamond', DATA) :-
    (
        YIELD = [3, 0, 0, 0, 0, 0, 0];
        YIELD = [0, 3, 0, 0, 0, 0, 0];
        YIELD = [0, 0, 3, 0, 0, 0, 0];
        YIELD = [0, 0, 0, 3, 0, 0, 0];
        YIELD = [0, 0, 0, 0, 3, 0, 0]
    ),
    DATA = [
        cost   - [0, 0, 0, 0, 0, 0, 0],
        yield  - YIELD,
        best   - [0, 0, 0, 0, 0, 0, 3],
        net    - 3,
        colors - [],
        types  - [],
        spell  - 1,
        board  - 0,
        gy     - 1
    ].

card('Grim Monolith', [
    cost   - [0, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 3, 0],
    net    - 1,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

card('Manamorphose', [
    cost   - [0, 0, 0, 0, 0, 0, 1, 1],
    yield  - [0, 0, 0, 0, 0, 0, 2],
    net    - 0,
    colors - [r,g],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Wild Cantor', [
    cost   - [0, 0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 0,
    colors - [r,g],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Burning-Tree Emissary', [
    cost   - [0, 0, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 1, 1, 0, 0],
    net    - 0,
    colors - [r,g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

card('Summoner\'s Pact', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    colors - [g],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    % Best-case scenario is optimistic -- Wild Cantor can produce any color if given spare {R/G}
    best   - [0, 0, 0, 0, 0, 0, 1]
]).

% Generic land/spell pattern
card(NAME, [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - YIELD,
    net    - 1,
    colors - [COLOR],
    types  - [land],
    spell  - 0,
    board  - 1,
    gy     - 0
]) :- landspell(NAME, COLOR, YIELD).

%card(NAME, DATA) :-
%    (
%        NAME=x, COLOR=w, YIELD = [1, 0, 0, 0, 0, 0, 0];
%        NAME=x, COLOR=u, YIELD = [0, 1, 0, 0, 0, 0, 0];
%        NAME=x, COLOR=b, YIELD = [0, 0, 1, 0, 0, 0, 0];
%        NAME=x, COLOR=r, YIELD = [0, 0, 0, 1, 0, 0, 0];
%        NAME=x, COLOR=g, YIELD = [0, 0, 0, 0, 1, 0, 0]
%    ),
%    DATA = [
%        cost   - [0, 0, 0, 0, 0, 0, 0],
%        yield  - YIELD,
%        net    - 1,
%        colors - [COLOR],
%        types  - [land],
%        spell  - 0,
%        board  - 0,
%        gy     - 0
%    ].

% Win conditions

card('Undercity Informer', [
    cost   - [0, 0, 1, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Balustrade Spy', [
    cost   - [0, 0, 1, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - -1,
    board  - 1,
    gy     - 0
]).
card('Cephalid Illusionist', [
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [creature],
    spell  - -1,
    board  - 1,
    gy     - 0
]).
card('Shuko', [
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Empty the Warrens', [
    cost   - [0, 0, 0, 1, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [sorcery],
    spell  - -1,
    board  - 0,
    gy     - 1
]).
card('Burning Wish', [
    cost   - [0, 0, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [sorcery],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Living Wish', [
    cost   - [0, 0, 0, 0, 1, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [sorcery],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Goblin Charbelcher', [
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

% Cards used in the combo

card('Narcomoeba', [
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Dread Return', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Phantasmagorian', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Cabal Therapy', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Lingering Souls', [
    cost   - [1, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Street Wraith', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - 0,
    board  - 0,
    gy     - 1
]).
card('Bridge from Below', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [enchantment],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Thassa\'s Oracle', [
    cost   - [0, 2, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

% Protection spells
card('Pact of Negation', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1
]).
card('Force of Will', [
    cost   - [0, 2, 0, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1
]).
card('Misdirection', [
    cost   - [0, 2, 0, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1
]).
card('Unmask', [
    cost   - [0, 0, 1, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Chancellor of the Annex', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [creature],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1
]).
card('Thoughtseize', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Veil of Summer', [
    cost   - [0, 0, 0, 0, 1, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Silence', [
    cost   - [1, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Orim\'s Chant', [
    cost   - [1, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1
]).
card('Defense Grid', [
    cost   - [0, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0,
    protection - 1
]).

% Cards we don't cast but might search for for Chrome Mox
card('Spiritmonger', [
    cost   - [0, 0, 1, 0, 1, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [bg],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('The Mimeoplasm', [
    cost   - [0, 1, 1, 0, 1, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [ubg],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).

% Special non-real cards
% Negative storm means uncastable

card('Chancellor of the Tangle_used', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Chancellor of the Annex_used', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).

% Mark which cards need to be cast at the start or end of the sequence
castfirst('Chancellor of the Annex').
castfirst('Chancellor of the Tangle').
castlast('Pact of Negation').
castlast('Force of Will').
castlast('Misdirection').

% Concrete instantiations of the land/spell pattern
landspell('Emeria\'s Call', w, [1, 0, 0, 0, 0, 0, 0]).
landspell('Sea Gate Restoration', u, [0, 1, 0, 0, 0, 0, 0]).
landspell('Agadeem\'s Awakening', b, [0, 0, 1, 0, 0, 0, 0]).
landspell('Shatterskull Smashing', r, [0, 0, 0, 1, 0, 0, 0]).
landspell('Turntimber Symbiosis', g, [0, 0, 0, 0, 1, 0, 0]).

% Special rules for casting / making mana

specialcast(NAME, YIELD, OLD_STATE, NEW_STATE) :-
    NAME == 'Lion\'s Eye Diamond', led(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Cabal Ritual', cabal(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Chrome Mox', cmox(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Mox Opal', opal(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Rite of Flame', rite(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Chancellor of the Tangle', chancellor(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Summoner\'s Pact', spact(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Manamorphose', cantrip('Manamorphose', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Street Wraith', cantrip('Street Wraith', YIELD, OLD_STATE, NEW_STATE);
%    NAME == 'Gitaxian Probe', cantrip('Gitaxian Probe', YIELD, OLD_STATE, NEW_STATE). (banned)
    NAME == 'Unmask', pitch('Unmask', b, YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Force of Will', pitch('Force of Will', u, YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Misdirection', pitch('Misdirection', u, YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Chancellor of the Annex', chancellor_annex(YIELD, OLD_STATE, NEW_STATE).

led(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [[], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Lion\'s Eye Diamond', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, NEXT_GY, END_STORM, END_DECK, PROTECTION]),
    append(NEXT_GY, NEXT_HAND, END_GY).

cabal(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    not(threshold(START_GY)),
    normalcast('Cabal Ritual', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).
cabal([0,0,5,0,0,0,0],
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    threshold(START_GY),
    normalcast('Cabal Ritual', _,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).

cmox(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Chrome Mox', _,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]),
    % Imprint a card:
    append(X, [IMPRINT | Y], NEXT_HAND),
    append(X, Y, END_HAND),
    card(IMPRINT, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(colors, CARD, COLORS),
    chrome_color(COLORS, YIELD).
chrome_color([H|T], YIELD) :-
    chrome_color(H, YIELD);
    chrome_color(T, YIELD).
chrome_color(w, [1, 0, 0, 0, 0, 0, 0]).
chrome_color(u, [0, 1, 0, 0, 0, 0, 0]).
chrome_color(b, [0, 0, 1, 0, 0, 0, 0]).
chrome_color(r, [0, 0, 0, 1, 0, 0, 0]).
chrome_color(g, [0, 0, 0, 0, 1, 0, 0]).

opal(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Mox Opal', _,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, NEXT_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]),
    legend_rule('Mox Opal', NEXT_BOARD, END_BOARD),
    opalyield(END_HAND, END_BOARD, YIELD).
opalyield(HAND, BOARD, [0, 0, 0, 0, 0, 0, 1]) :- metalcraft(HAND, BOARD).
opalyield(_, _, [0, 0, 0, 0, 0, 0, 0]).

rite([0, 0, 0, R, 0, 0, 0],
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Rite of Flame', _,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]),
    count('Rite of Flame', START_GY, N),
    R is N + 2.

chancellor(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [['Chancellor of the Tangle_used'|END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    START_STORM is 0,
    % Remove, but add a useless version back in
    normalcast('Chancellor of the Tangle', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).

spact(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [[CARDNAME | NEXT_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Summoner\'s Pact', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(colors, CARD, COLORS),
    get_assoc(types, CARD, TYPES),
    member(g, COLORS),
    member(creature, TYPES),
    remove(CARDNAME, NEXT_DECK, END_DECK).

cantrip(NAME, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [["Draw" | END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast(NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, [ _ | END_DECK], PROTECTION]).

% Special rules for protection spells

pitch(NAME, COLOR, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION]) :-
    normalcast(NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION]),
    % Pitch a card of the same color:
    append(X, [PITCH | Y], NEXT_HAND),
    append(X, Y, END_HAND),
    card(PITCH, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(colors, CARD, COLORS),
    member(COLOR, COLORS).

chancellor_annex(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [['Chancellor of the Annex_used'|END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION]) :-
    % Remove, but add a useless version back in
    START_STORM is 0,
    normalcast('Chancellor of the Annex', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION]).


% Misc. rules

legend_rule(CARD_NAME, UNCHANGED, UNCHANGED) :-
    count(CARD_NAME, UNCHANGED, N),
    N < 2.
legend_rule(CARD_NAME, BEFORE, AFTER) :-
    count(CARD_NAME, BEFORE, N),
    N > 1,
    remove(CARD_NAME, BEFORE, NEXT),
    legend_rule(CARD_NAME, NEXT, AFTER).

istype(CARDNAME, TYPE) :-
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    member(TYPE, TYPES).
metalcraft_possible(HAND, BOARD) :-
    append(HAND, BOARD, EVERYTHING),
    type_threshold(3, artifact, EVERYTHING).
metalcraft(HAND, BOARD) :-
    % for Petal and LED, we treat them as if they're not permanents, so count
    % them from the hand, assuming we can cast them ahead of time if necessary
    count('Lotus Petal', HAND, NPETAL),
    count('Lion\'s Eye Diamond', HAND, NLED),
    REMAINING is 3 - NPETAL - NLED,
    type_threshold(REMAINING, artifact, BOARD).
type_threshold(0, _, _).
type_threshold(N, TYPE, [CARDNAME|T]) :-
    N < 1;
    istype(CARDNAME, TYPE),
    M is N-1,
    type_threshold(M, TYPE, T);
    type_threshold(N, TYPE, T).
type_max(N, _, []) :-
    N >= 0.
type_max(N, TYPE, [CARDNAME|T]) :-
    not(istype(CARDNAME, TYPE)),
    type_max(N, TYPE, T);
    N > 0,
    istype(CARDNAME, TYPE),
    M is N-1,
    type_max(M, TYPE, T).

% General rules for casting

cast(NAME, YIELD, OLD_STATE, NEW_STATE) :-
    specialcast(NAME, YIELD, OLD_STATE, NEW_STATE);
    not(specialcast(NAME, _, OLD_STATE, _)),
    normalcast(NAME, YIELD, OLD_STATE, NEW_STATE).

normalcast(NAME, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [START_HAND, END_BOARD, START_MANA, END_GY, END_STORM, START_DECK, END_PROTECTION]) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(spell, CARD, SPELLS),
    SPELLS >= 0,
    get_assoc(yield, CARD, YIELD),
    get_assoc(gy, CARD, GY),
    get_assoc(board, CARD, BOARD),
    END_STORM is START_STORM + SPELLS,
    yard(NAME, START_GY, END_GY, GY),
    board(NAME, START_BOARD, END_BOARD, BOARD),
    type_max(1, land, END_BOARD),
    protection(NAME, ADDITIONAL_PROTECTION),
    END_PROTECTION is START_PROTECTION + ADDITIONAL_PROTECTION.
yard(_, START_GY, START_GY, 0).
yard(NAME, START_GY, END_GY, 1) :-
    append(START_GY, [NAME], END_GY).
board(_, START_BOARD, START_BOARD, 0).
board(NAME, START_BOARD, END_BOARD, 1) :-
    append(START_BOARD, [NAME], END_BOARD).
threshold(GRAVEYARD) :-
    length(GRAVEYARD, N),
    N >= 7.

maxnet(NAME, MAX) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(net, CARD, MAX), !;
    MAX = 0.

maxnet(NAME, HAND, BOARD, GY, MAX) :-
    % easy to get max yield for rite of flame
    NAME == 'Rite of Flame',
    count('Rite of Flame', GY, IN_GY),
    count('Rite of Flame', HAND, IN_HAND),
    MAX is IN_GY + IN_HAND, % includes self, so net >= 1
    !;
    % or for mox opal
    NAME == 'Mox Opal',
    (metalcraft_possible(HAND, BOARD), MAX is 1, !; MAX is 0),
    !;
    % for everything else just use the base number
    maxnet(NAME, MAX).

max_yield(NAME, MAX) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    (
        get_assoc(best, CARD, MAX), !;
        not(get_assoc(best, CARD, _)), get_assoc(yield, CARD, MAX)
    ), !;
    MAX = [0, 0, 0, 0, 0, 0, 0].

% Misc. utility

count(_, [], 0).
count(ITEM, [H|T], N) :-
    not(H == ITEM),
    count(ITEM, T, N).
count(ITEM, [ITEM|T], N) :-
    count(ITEM, T, N1),
    N is N1 + 1.

remove(ITEM, [ITEM | T], T) :- !.
remove(ITEM, [H | T], [H | REMOVED]) :-
    remove(ITEM, T, REMOVED).

take(ITEM, [ITEM | T], T).
take(ITEM, [H | T], [H | TAKEN]) :-
    take(ITEM, T, TAKEN).

protection(NAME, N) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    (
        get_assoc(protection, CARD, N), !;
        not(get_assoc(protection, CARD, _)), N is 0
    ).
