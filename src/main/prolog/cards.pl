% To test:
% Mox Opal
% land/spells

% To implement:
% Land Grant
% make Manamorphose draw a card (doesn't it already?)
% Wish for mana?
% Cast creatures just for Dread Return (have we done that yet?)
% Multiple Bridge from Below
% Casting the land/spells (e.g. Turntimber Symbiosis)
% Finale of Devastation
% Once Upon a Time

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
    gy     - 1,
    options - true
]).
card('Tinder Wall_unused', [
    cost   - [0, 0, 0, 0, 1, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 1,
    restricted - true
]).
card('Culling the Weak', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 4, 0, 0, 0, 0],
    net    - 3,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    best   - [0, 0, 4, 0, 0, 0, 0],
    restricted - true
]).
card('Sacrifice', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    best   - [0, 0, 4, 0, 0, 0, 0],
    restricted - true
]).
card('Burnt Offering', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    best   - [0, 0, 4, 4, 0, 0, 0],
    restricted - true
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
    colors - [r, g],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 1,
    options - true
]).
card('Wild Cantor_unused', [
    cost   - [0, 0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r, g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 1,
    restricted - true
]).
card('Burning-Tree Emissary', [
    cost   - [0, 0, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 1, 1, 0, 0],
    net    - 0,
    colors - [r, g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 2
]).
card('Quirion Sentinel', [
    cost   - [0, 0, 0, 0, 1, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 0,
    colors - [g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 2
]).
card('Priest of Gix', [
    cost   - [0, 0, 1, 0, 0, 0, 2],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 3
]).
card('Priest of Urabrask', [
    cost   - [0, 0, 0, 1, 0, 0, 2],
    yield  - [0, 0, 0, 3, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 3
]).
card('Vine Dryad', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 4,
    restricted -true
]).

card(NAME, [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - COLORS,
    types  - TYPES,
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 0
]) :- free_permanent(NAME, TYPES, COLORS).

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

card('Once Upon a Time', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    colors - [g],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    % Best-case scenario is optimistic -- Wild Cantor can produce any color if given spare {R/G}
    best   - [0, 0, 0, 0, 0, 0, 1],
    restricted - true,
    find_protection - 1
]).
card('Once Upon a Time_nonfree', [
    cost   - [0, 0, 0, 0, 1, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    % Best-case scenario is optimistic -- Wild Cantor can produce any color if given spare {R/G}
    best   - [0, 0, 0, 0, 0, 0, 1],
    restricted - true
]).

card('Eldritch Evolution', [
    cost   - [0, 0, 0, 0, 2, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    colors - [g],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Neoform', [
    cost   - [0, 1, 0, 0, 1, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 1,
    colors - [u, g],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).

card('Beseech the Mirror', [
    cost   - [0, 0, 3, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
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
    gy     - 1,
    protection - 1
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
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1,
    restricted - true
]).
card('Misdirection', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1,
    restricted - true
]).
card('Unmask', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1,
    restricted - true
]).
card('Grief', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 4,
    protection - 1,
    restricted - true
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
card('Leyline of Lifeforce', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [enchantment],
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
card('Nature\'s Claim', [
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
card('Foundation Breaker', [
    cost   - [0, 0, 0, 0, 1, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [creature],
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

% Cards we don't directly use but might search for for Chrome Mox or otherwise use
card('Spiritmonger', [
    cost   - [0, 0, 1, 0, 1, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b, g],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('The Mimeoplasm', [
    cost   - [0, 1, 1, 0, 1, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u, b, g],
    types  - [creature],
    spell  - -1,
    board  - 0,
    gy     - 0
]).
card('Endurance', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 3,
    protection - 0,
    restricted - true
]).
card('Memory\'s Journey', [
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - -1,
    board  - 0,
    gy     - 0
]).

card('Serum Powder', [
    cost   - [0, 0, 0, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 1, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
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

card_key_value_default(CARDNAME, KEY, VALUE, DEFAULT) :-
    card(CARDNAME, DATA),
    carddata_key_value_default(DATA, KEY, VALUE, DEFAULT).
carddata_key_value_default([KEY - VALUE | _], KEY, VALUE, _).
carddata_key_value_default([HKEY - _ | T], KEY, VALUE, DEFAULT) :-
    dif(HKEY, KEY),
    carddata_key_value_default(T, KEY, VALUE, DEFAULT).
carddata_key_value_default([], _, DEFAULT, DEFAULT).

% Mark which cards need to be cast at the start or end of the sequence
castfirst('Chancellor of the Annex').
castfirst('Chancellor of the Tangle').
castfirst('Leyline of Lifeforce').
castlast('Pact of Negation').
castlast('Force of Will').
castlast('Misdirection').

% Concrete instantiations of the land/spell pattern
landspell('Emeria\'s Call', w, [1, 0, 0, 0, 0, 0, 0]).
landspell('Sea Gate Restoration', u, [0, 1, 0, 0, 0, 0, 0]).
landspell('Agadeem\'s Awakening', b, [0, 0, 1, 0, 0, 0, 0]).
landspell('Shatterskull Smashing', r, [0, 0, 0, 1, 0, 0, 0]).
landspell('Turntimber Symbiosis', g, [0, 0, 0, 0, 1, 0, 0]).

% Concrete instantiations of the free permanent pattern
free_permanent('Shield Sphere', [artifact, creature], []).
free_permanent('Phyrexian Walker', [artifact, creature], []).
free_permanent('Ornithopter', [artifact, creature], []).
free_permanent('Memnite', [artifact, creature], []).

% Special rules for casting / making mana

specialcast(NAME, YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS) :-
    NAME == 'Culling the Weak', culling(YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS);
    NAME == 'Sacrifice', sacrifice(YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS);
    NAME == 'Burnt Offering', burnt_offering(YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS).
specialcast(NAME, YIELD, OLD_STATE, NEW_STATE, []) :-
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
    NAME == 'Chancellor of the Annex', chancellor_annex(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Wild Cantor', cantor_unused(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Tinder Wall', tinder_unused(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Once Upon a Time', once_upon_a_time(YIELD, OLD_STATE, NEW_STATE).
specialcast(NAME, YIELD, OLD_STATE, NEW_STATE, [STEP]) :-
    (
        NAME == 'Unmask', pitch('Unmask', b, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Grief', pitch('Grief', b, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Endurance', pitch('Endurance', g, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Force of Will', pitch('Force of Will', u, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Misdirection', pitch('Misdirection', u, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Vine Dryad', pitch('Vine Dryad', g, YIELD, OLD_STATE, NEW_STATE, PITCH)
    ), atom_concat('pitch ', PITCH, STEP).

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
    remove_first(IMPRINT, NEXT_HAND, END_HAND),
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

cantor_unused(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Wild Cantor_unused', YIELD,
        [['Wild Cantor_unused'|START_HAND], START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).
tinder_unused(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Tinder Wall_unused', YIELD,
        [['Tinder Wall_unused'|START_HAND], START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).

culling(YIELD, START_STATE, END_STATE, STEPS) :-
    sacrifice_creature_instant(_, START_STATE, NEXT_STATE, STEPS),
    normalcast('Culling the Weak', YIELD, NEXT_STATE, END_STATE).
sacrifice([0, 0, CMC, 0, 0, 0, 0], START_STATE, END_STATE, STEPS) :-
    sacrifice_creature_instant(CREATURE, START_STATE, NEXT_STATE, STEPS),
    cmc(CREATURE, CMC),
    normalcast('Sacrifice', _, NEXT_STATE, END_STATE).
burnt_offering([0, 0, B, R, 0, 0, 0], START_STATE, END_STATE, STEPS) :-
    sacrifice_creature_instant(CREATURE, START_STATE, NEXT_STATE, SACRIFICE_STEPS),
    cmc(CREATURE, CMC),
    normalcast('Burnt Offering', _, NEXT_STATE, END_STATE),
    between(0, CMC, B),
    R is CMC - B,
    concat_n(b, B, BS),
    concat_n(r, R, RS),
    atom_concat(BS, RS, DISTRIBUTION),
    append(SACRIFICE_STEPS, [DISTRIBUTION], STEPS).

concat_n(_, 0, '').
concat_n(ATOM, 1, ATOM).
concat_n(ATOM, N, RESULT) :-
    N > 1,
    M is N - 1,
    concat_n(ATOM, M, NEXT),
    atom_concat(ATOM, NEXT, RESULT).

cmc(CARDNAME, CMC) :-
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    (
        get_assoc(cmc, CARD, CMC);
        (
            get_assoc(cost, CARD, COST),
            total(COST, CMC)
        )
    ).

sacrifice_creature(CARDNAME,
    [HAND, START_BOARD, MANA, START_GY, STORM, DECK, PROTECTION],
    [HAND, END_BOARD, MANA, [CARDNAME|START_GY], STORM, DECK, PROTECTION],
    [SACRIFICE_STEP]) :-
    remove_first(CARDNAME, START_BOARD, END_BOARD),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    member(creature, TYPES),
    atom_concat('sacrifice ', CARDNAME, SACRIFICE_STEP).

sacrifice_creature_instant(CARD_NAME,
    [START_HAND, BOARD, MANA, GY, STORM, DECK, PROTECTION],
    END_STATE,
    STEPS) :-
    (CARD_NAME = 'Grief' ; CARD_NAME = 'Endurance'),
    remove_first(CARD_NAME, START_HAND, NEXT_HAND),
    specialcast(CARD_NAME, _, [NEXT_HAND, BOARD, MANA, GY, STORM, DECK, PROTECTION], END_STATE, CAST_STEPS),
    atom_concat('sacrifice ', CARD_NAME, SACRIFICE_STEP),
    append(CAST_STEPS, [SACRIFICE_STEP], STEPS).
sacrifice_creature_instant(CARDNAME, START_STATE, END_STATE, STEPS) :-
    sacrifice_creature(CARDNAME, START_STATE, END_STATE, STEPS).

sacrifice_bargain(CARDNAME,
    [HAND, START_BOARD, MANA, START_GY, STORM, DECK, PROTECTION],
    [HAND, END_BOARD, MANA, [CARDNAME|START_GY], STORM, DECK, PROTECTION],
    [SACRIFICE_STEP]) :-
    remove_first(CARDNAME, START_BOARD, END_BOARD),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    (member(token, TYPES); member(artifact, TYPES); member(enchantment, TYPES)),
    atom_concat('sacrifice ', CARDNAME, SACRIFICE_STEP).

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
    remove_first(CARDNAME, NEXT_DECK, END_DECK).

cantrip(NAME, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [["Draw" | END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast(NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, [ _ | END_DECK], PROTECTION]).

append_n([], [], _, []).
append_n([], List, 0, List).
append_n([H], Remainder, 1, [H|Remainder]).
append_n([H|TSublist], Remainder, N, [H|TCombinedList]) :-
    N > 0,
    M is N - 1,
    append_n(TSublist, Remainder, M, TCombinedList).

once_upon_a_time(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, 0, START_DECK, PROTECTION],
    [[CARDNAME | NEXT_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Once Upon a Time', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, 0, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
    append_n(TOP, REMAINDER, 5, NEXT_DECK),
    member(CARDNAME, TOP),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    member(creature, TYPES),
    remove_first(CARDNAME, TOP, MINUS_CHOSEN),
    append(REMAINDER, MINUS_CHOSEN, END_DECK).
% TODO: for performance reasons, ignoring a) option to OUAT without finding something; b) ability to cast a second one for 1G
%once_upon_a_time(YIELD,
%    [START_HAND, START_BOARD, START_MANA, START_GY, 0, START_DECK, PROTECTION],
%    [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
%    normalcast('Once Upon a Time', YIELD,
%        [START_HAND, START_BOARD, START_MANA, START_GY, 0, START_DECK, PROTECTION],
%        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
%    append_n(TOP, REMAINDER, 5, NEXT_DECK),
%    append(REMAINDER, TOP, END_DECK).
%once_upon_a_time(YIELD,
%    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%    [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
%    START_STORM > 0,
%    normalcast('Once Upon a Time_nonfree', YIELD,
%        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
%    append_n(TOP, REMAINDER, 5, NEXT_DECK),
%    append(REMAINDER, TOP, END_DECK).
%once_upon_a_time(YIELD,
%    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%    [[CARDNAME | NEXT_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
%    START_STORM > 0,
%    normalcast('Once Upon a Time_nonfree', YIELD,
%        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
%    append_n(TOP, REMAINDER, 5, NEXT_DECK),
%    member(CARDNAME, TOP),
%    card(CARDNAME, DATA),
%    list_to_assoc(DATA, CARD),
%    get_assoc(types, CARD, TYPES),
%    member(creature, TYPES),
%    remove_first(CARDNAME, TOP, MINUS_CHOSEN),
%    append(REMAINDER, MINUS_CHOSEN, END_DECK).

beseech_nocast(YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [[CARDNAME | NEXT_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Beseech the Mirror', YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION]),
    remove_first(CARDNAME, NEXT_DECK, END_DECK).
beseech_bargain(CARDNAME,
    START_STATE,
    [[CARDNAME | NEXT_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION],
    ['Beseech the Mirror' | STEPS]) :-
    normalcast('Beseech the Mirror', _, START_STATE, CAST_STATE),
    sacrifice_bargain(_, CAST_STATE, [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION], STEPS),
    remove_first(CARDNAME, NEXT_DECK, END_DECK).

% Special rules for protection spells

pitch(NAME, COLOR, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, END_PROTECTION],
    PITCH) :-
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
isnottype(CARDNAME, TYPE) :-
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    not_member(TYPE, TYPES).
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
zone_type_count([], _, 0).
zone_type_count([H|T], TYPE, COUNT) :-
    zone_type_count(T, TYPE, N),
    istype(H, TYPE),
    COUNT is N+1.
zone_type_count([H|T], TYPE, COUNT) :-
    zone_type_count(T, TYPE, COUNT),
    isnottype(H, TYPE).

% General rules for casting

cast(NAME, YIELD, STEPS, OLD_STATE, NEW_STATE) :-
    specialcast(NAME, YIELD, OLD_STATE, NEW_STATE, STEPS);
    STEPS = [],
    not(only_special(NAME)),
    (special_optional(NAME); not(specialcast(NAME, _, OLD_STATE, _, _))),
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
    carddata_key_value_default(DATA, protection, ADDITIONAL_PROTECTION, 0),
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
    % assume max plausible CMC is 4 for Sacrifice/Burnt Offering
    (NAME == 'Sacrifice'; NAME == 'Burnt Offering'),
    MAX is 3,
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

only_special(NAME) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(restricted, CARD, _).

special_optional(NAME) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(options, CARD, _).

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

remove_first(ITEM, [ITEM | T], T).
remove_first(ITEM, [H | T], [H | REMOVED]) :-
    dif(ITEM, H),
    remove_first(ITEM, T, REMOVED).

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

not_member(_, []).
not_member(ITEM, [H|T]) :-
    dif(ITEM, H),
    not_member(ITEM, T).

total([], 0).
total([H | T], SUM) :-
    total(T, PARTIAL),
    SUM is H + PARTIAL.

get_or_default(DICT, KEY, _, VAR) :-
    is_dict(DICT), get_dict(KEY, DICT, VAR).
get_or_default(DICT, KEY, DEFAULT, DEFAULT) :-
    is_dict(DICT), not(get_dict(KEY, DICT, _)).

combination(X, 0, [], X).
combination([H|T], N, [H|CHOICE], REMAINDER) :-
    N > 0,
    M is N - 1,
    combination(T, M, CHOICE, REMAINDER).
combination([H|T], N, CHOICE, [H|REMAINDER]) :-
    N > 0,
    combination(T, N, CHOICE, REMAINDER).

member_or_tutor(CARDNAME, HAND, LIBRARY) :-
    (member(CARDNAME, HAND);
    member(TUTOR, HAND), tutors_for(TUTOR, CARDNAME, LIBRARY), member(CARDNAME, LIBRARY)),
    !.

tutors_for(TUTOR_NAME, TARGET_NAME, DECK) :-
    card(TARGET_NAME, DATA),
    list_to_assoc(DATA, TARGET_ASSOC),
    tutors_for_(TUTOR_NAME, TARGET_NAME, TARGET_ASSOC, DECK).
tutors_for_('Summoner\'s Pact', TARGET_NAME, TARGET_ASSOC, DECK) :-
    member(TARGET_NAME, DECK),
    get_assoc(types, TARGET_ASSOC, TYPES),
    member(creature, TYPES),
    get_assoc(colors, TARGET_ASSOC, COLORS),
    member(g, COLORS).
tutors_for_('Once Upon a Time', TARGET_NAME, TARGET_ASSOC, DECK) :-
    in_first_n(TARGET_NAME, DECK, 5),
    get_assoc(types, TARGET_ASSOC, TYPES),
    (member(creature, TYPES); member(land, TYPES)).

in_first_n(H, [H|_], N) :-
    N > 0.
in_first_n(TARGET, [H|T], N) :-
    TARGET \= H,
    N > 1,
    M is N - 1,
    in_first_n(TARGET, T, M).
