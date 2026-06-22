% To implement:
% cast Jack-o'-Lantern from hand, then sacrifice, then exile (3 generic -> 1 of any)
% Land Grant
% make Manamorphose draw a card (doesn't it already?)
% Wish for mana?
% Cast creatures just for Dread Return (have we done that yet?)
% Casting the land/spells (e.g. Turntimber Symbiosis)
% Finale of Devastation
% Once Upon a Time
% LED + Shallow Grave / Corpse Dance
% Neoform / Eldritch Evolution for Griselbrand, Atraxa, etc.
% Selective Memory / Doomsday
%
% for artifacts:
% Irencrag Feat
% Planar Nexus for colored mana
% Mox Diamond
% Transmute Artifact
% Kappa Cannoneer
% Tezzeret, Cruel Captain (untap Monolith, maybe tutor for storm/colored mana?)
% Kozilek's Command (X=0, for storm)
% activating Candelabra of Tawnos
% Eldrazi Temple

nb_setval(reveal_draws, false).

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
    gy     - 1,
    options - true
]).
card('Lotus Petal_unused', [
    base   - 'Lotus Petal',
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0,
    restricted - true
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
    gy     - 0,
    roles  - [pregame]
]).

card('Dark Ritual', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 2,
    colors - [b],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    priority - 10
]).
card('Cabal Ritual', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 3,
    best   - [0, 0, 5, 0, 0, 0, 0],
    colors - [b],
    types  - [instant],
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
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Pyretic Ritual', [
    cost   - [0, 0, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 3, 0, 0, 0],
    net    - 1,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Desperate Ritual', [
    cost   - [0, 0, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 3, 0, 0, 0],
    net    - 1,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Seething Song', [
    cost   - [0, 0, 0, 1, 0, 0, 2],
    yield  - [0, 0, 0, 5, 0, 0, 0],
    net    - 2,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Irencrag Feat', [
    cost   - [0, 0, 0, 3, 0, 0, 1],
    yield  - [0, 0, 0, 7, 0, 0, 0],
    net    - 3,
    colors - [r],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
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
    base   - 'Tinder Wall',
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
    types  - [instant],
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
    types  - [instant],
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
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    best   - [0, 0, 4, 4, 0, 0, 0],
    restricted - true
]).

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

card('Basalt Monolith', [
    cost   - [0, 0, 0, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 3, 0],
    net    - 1,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

card('Throne of Eldraine', [
    cost   - [0, 0, 0, 0, 0, 0, 5],
    yield  - [0, 0, 0, 0, 0, 0, 4],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).

card('Voltaic Key', [
    activate - 'Voltaic Key_tapped',
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    best   - [0, 0, 0, 0, 0, 0, 4],
    net    - 2,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Manifold Key', [
    activate - 'Manifold Key_tapped',
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    best   - [0, 0, 0, 0, 0, 0, 4],
    net    - 2,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Voltaic Key_tapped', [
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    best   - [0, 0, 0, 0, 0, 0, 4],
    net    - 3,
    colors - [],
    types  - [artifact],
    spell  - 0,
    board  - 1,
    gy     - 0,
    restricted - true
]).
card('Manifold Key_tapped', [
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    best   - [0, 0, 0, 0, 0, 0, 4],
    net    - 3,
    colors - [],
    types  - [artifact],
    spell  - 0,
    board  - 1,
    gy     - 0,
    restricted - true
]).

card('Pentad Prism', DATA) :-
    (
        %YIELD = [0, 0, 0, 0, 0, 0, 5];
        %YIELD = [0, 0, 0, 0, 0, 0, 4];
        %        YIELD = [0, 0, 0, 0, 0, 0, 3];
        YIELD = [0, 0, 0, 0, 0, 0, 2];
        YIELD = [0, 0, 0, 0, 0, 0, 1];
        YIELD = [0, 0, 0, 0, 0, 0, 0]
    ),
    DATA = [
        cost   - [0, 0, 0, 0, 0, 0, 2],
        yield  - YIELD,
        best   - [0, 0, 0, 0, 0, 0, 2],
        net    - 0,
        colors - [],
        types  - [artifact],
        spell  - 1,
        board  - 1,
        gy     - 0,
        restricted - true
    ].

card('Manamorphose', [
    cost   - [0, 0, 0, 0, 0, 0, 1, 1],
    yield  - [0, 0, 0, 0, 0, 0, 2],
    net    - 0,
    colors - [r,g],
    types  - [instant],
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
    base   - 'Wild Cantor',
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
card('Crop Rotation', [
    cost   - [0, 0, 0, 0, 1, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 0,
    colors - [g],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 1,
    restricted - true
]).
card('Gold Rush', [
    cost   - [0, 0, 0, 0, 1, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 0,
    colors - [g],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 2
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
    net    - 0,
    colors - [g],
    types  - [instant],
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
    types  - [instant],
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
card('Entomb', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 1,
    roles  - [entomb]
]).
card('Buried Alive', [
    cost   - [0, 0, 1, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 3,
    roles  - [entomb]
]).
card('Unmarked Grave', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 2,
    roles  - [entomb]
]).

% Draw
card('Valakut Awakening', [
    cost   - [0, 0, 0, 1, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 3
]).
card('Fateful Showdown', [
    cost   - [0, 0, 0, 2, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 4
]).

card('Reanimate', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 1,
    roles  - [animate]
]).
card('Animate Dead', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [enchantment],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 2,
    roles  - [animate]
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

% Generic land pattern
card(NAME, [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - YIELD,
    net    - NET,
    colors - [],
    types  - [land|EXTRA_TYPES],
    spell  - 0,
    board  - 1,
    gy     - 0,
    priority - PRIORITY
]) :- land(NAME, YIELD, EXTRA_TYPES, PRIORITY), sum_list(YIELD, NET).

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
    roles  - [combo],
    cost   - [0, 0, 1, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - 1,
    board  - 0,
    gy     - 0
]).
card('Balustrade Spy', [
    roles  - [combo],
    cost   - [0, 0, 1, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Destroy the Evidence', [
    roles  - [combo],
    cost   - [0, 0, 1, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - -1,
    board  - 0,
    gy     - 1
]).
card('Cephalid Illusionist', [
    roles  - [combo],
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Shuko', [
    roles  - [combo, enkor],
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
    roles  - [combo],
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
card('Elemental Eruption', [
    roles  - [combo],
    cost   - [0, 0, 0, 2, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 0
     ]).
card('Stormscale Scion', [
    roles  - [combo],
    cost   - [0, 0, 0, 2, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    protection - 0
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
    roles  - [combo],
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Tendrils of Agony', [
    cost   - [0, 0, 2, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Brain Freeze', [
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('The One Ring', [
    roles  - [combo, engine],
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Mystic Forge', [
    roles  - [combo, engine],
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Karn, the Great Creator', [
    roles  - [combo, engine],
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [planeswalker],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Paradox Engine', [
    roles  - [engine],
    cost   - [0, 0, 0, 0, 0, 0, 5],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Glaring Fleshraker', [
    roles  - [engine],
    cost   - [0, 0, 0, 0, 0, 1, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('The Fantasticar', [
    roles  - [combo],
    cost   - [0, 0, 0, 0, 0, 0, 3],
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
card('Poxwalkers', [
    cost   - [0, 0, 1, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
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
card('Necrodominance', [
    roles  - [combo],
    cost   - [0, 0, 3, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [enchantment],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('Borne Upon a Wind', [
    cost   - [0, 1, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).
card('Necrologia', [
    roles  - [combo],
    cost   - [0, 0, 2, 0, 0, 0, 3],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
]).

% Protection spells
card('Pact of Negation', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 0,
    board  - 0,
    gy     - 0,
    roles  - [counterspell],
    protection - 1
]).
card('Force of Will', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1,
    roles  - [counterspell],
    restricted - true
]).
card('Misdirection', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 0,
    board  - 0,
    gy     - 0,
    protection - 1,
    roles  - [counterspell],
    restricted - true
]).
card('Unmask', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1,
    restricted - true,
    roles - [self_discard]
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
    roles  - [pregame],
    protection - 1
]).
card('Leyline of Lifeforce', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [g],
    types  - [enchantment],
    spell  - 0,
    board  - 1,
    gy     - 0,
    roles  - [pregame],
    protection - 1
]).
card('Leyline of Sanctity', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [enchantment],
    spell  - 0,
    board  - 1,
    gy     - 0,
    roles  - [pregame],
    protection - 0
]).
card('Leyline of the Void', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [enchantment],
    spell  - 0,
    board  - 1,
    gy     - 0,
    roles  - [pregame],
    protection - 0
]).
card('Leyline of Anticipation', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [enchantment],
    spell  - 0,
    board  - 1,
    gy     - 0,
    roles  - [pregame],
    protection - 0
]).
card('Thoughtseize', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    cmc    - 1,
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1,
    roles - [self_discard]
]).
card('Duress', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    cmc    - 1,
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
card('Into the Flood Maw', [
    cost   - [0, 1, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
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
card('Jack-o\'-Lantern', [
    activate_gy - 'exile Jack-o\'-Lantern',
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0
]).
card('exile Jack-o\'-Lantern', [
    cost   - [0, 0, 0, 0, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 1],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 0,
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

% Template for a castable permanent whose text doesn't matter
card(NAME, [
    cost   - COST,
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - TYPES,
    spell  - 1,
    board  - 1,
    gy     - 0
]) :- permanent_card(NAME, COST, TYPES).

% Tokens
card('Drone Token', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact, creature],
    spell  - -1,
    board  - 1,
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

card('Lion\'s Eye Diamond_unused', [
    base   - 'Lion\'s Eye Diamond',
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    best   - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact],
    spell  - 1,
    board  - 1,
    gy     - 0,
    restricted - true
]).

% (Effectively) modal cards whose properties change in different modes
card(CARDNAME, DATA) :- card(CARDNAME, DATA, base).

card('Lion\'s Eye Diamond', [
        cost   - [0, 0, 0, 0, 0, 0, 0],
        best   - [0, 0, 0, 0, 0, 0, 3],
        net    - 3,
        colors - [],
        types  - [artifact],
        spell  - 1,
        board  - 0,
        gy     - 1,
        options - true,
        restricted - true
], base).
card('Lion\'s Eye Diamond', [yield - [0, 0, 0, 0, 0, 0, 0]], default).
card('Lion\'s Eye Diamond', [yield - [3, 0, 0, 0, 0, 0, 0]], w).
card('Lion\'s Eye Diamond', [yield - [0, 3, 0, 0, 0, 0, 0]], u).
card('Lion\'s Eye Diamond', [yield - [0, 0, 3, 0, 0, 0, 0]], b).
card('Lion\'s Eye Diamond', [yield - [0, 0, 0, 3, 0, 0, 0]], r).
card('Lion\'s Eye Diamond', [yield - [0, 0, 0, 0, 3, 0, 0]], g).

card('Lively Dirge', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 1,
    roles  - [entomb, animate]
], base).
card('Lively Dirge', [
    cost   - [0, 0, 1, 0, 0, 0, 2],
    cmc    - 3,
    roles  - [entomb]
], entomb).
card('Lively Dirge', [
    cost   - [0, 0, 1, 0, 0, 0, 3],
    cmc    - 4,
    roles  - [animate]
], animate).
card('Lively Dirge', [
    cost   - [0, 0, 1, 0, 0, 0, 4],
    cmc    - 5,
    roles  - [entomb, animate]
], win).

card('Electrodominance', [
    roles  - [],
    cost   - [0, 0, 0, 2, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [r],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
], base).
card('Electrodominance', [
    cost   - [0, 0, 0, 2, 0, 0, C]
], C) :- number(C).

card('Pinnacle Emissary', [
    roles  - [],
    cost   - [0, 1, 0, 1, 0, 0, 1],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [ur],
    types  - [artifact, creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 3
], base).
card('Pinnacle Emissary', [], default).
card('Pinnacle Emissary', [
    cost   - [0, 1, 0, 0, 0, 0, 0]
], warp_u).
card('Pinnacle Emissary', [
    cost   - [0, 0, 0, 1, 0, 0, 0]
], warp_r).

card('Cabal Therapy', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    protection - 1,
    roles - [self_discard]
], base).
card('Cabal Therapy', [], default).
card('Cabal Therapy', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    gy     - 0,
    restricted - true
], flashback).

card('Lingering Souls', [
    cost   - [1, 0, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [w],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1
], base).
card('Lingering Souls', [], default).
card('Lingering Souls', [
    gy     - 0,
    cost   - [0, 0, 1, 0, 0, 0, 1]
], flashback).

card('Echo of Eons', [
    cost   - [0, 2, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1
], base).
card('Echo of Eons', [], default).
card('Echo of Eons', [
    gy     - 0,
    cost   - [0, 1, 0, 0, 0, 0, 2]
], flashback).

card('Frogmite', [
    cost   - [0, 0, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [],
    types  - [artifact, creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 4,
    restricted - true
], base).
card('Thoughtcast', [
    cost   - [0, 1, 0, 0, 0, 0, 4],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    cmc    - 5,
    restricted - true
], base).
card('Emry, Lurker of the Loch', [
    cost   - [0, 1, 0, 0, 0, 0, 2],
    yield  - [0, 0, 0, 0, 0, 0, 0],
    net    - 0,
    colors - [u],
    types  - [creature],
    spell  - 1,
    board  - 1,
    gy     - 0,
    cmc    - 3,
    restricted - true
], base).

% Generates distinct modes for all possible Affinity discounts
card(Name, [
    cost   - [W, U, B, R, G, A, DiscountedGeneric],
    restricted - true
    ], [affinity, Type, N]) :-
    affinity(Name, Type, Discounts),
    card(Name, Data, base),
    list_to_assoc(Data, Assoc),
    get_assoc(cost, Assoc, [W, U, B, R, G, A, BaseGeneric]),
    member(N, Discounts),
    N =< BaseGeneric,
    N >= 0,
    DiscountedGeneric is BaseGeneric - N.

affinity('Frogmite', artifact, [0, 1, 2, 3, 4]).
affinity('Thoughtcast', artifact, [0, 1, 2, 3, 4]).
affinity('Emry, Lurker of the Loch', artifact, [0, 1, 2]).

card_key_value_default(CARDNAME, KEY, VALUE, DEFAULT) :-
    findall(DATA, card(CARDNAME, DATA), DATA_LIST),
    maplist(get_or_default_carddata(KEY, DEFAULT), DATA_LIST, VALUE_LIST),
    list_to_set(VALUE_LIST, VALUE_SET),
    member(VALUE, VALUE_SET).
    %    card(CARDNAME, DATA),
%    carddata_key_value_default(DATA, KEY, VALUE, DEFAULT).
get_or_default_carddata(KEY, _, [KEY - VALUE | _], VALUE).
get_or_default_carddata(KEY, DEFAULT, [HKEY - _ | T], VALUE) :-
    dif(HKEY, KEY),
    get_or_default_carddata(KEY, DEFAULT, T, VALUE).
get_or_default_carddata(_, DEFAULT, [], DEFAULT).

card_priority(CARDNAME, PRIORITY) :-
    card_key_value_default(CARDNAME, priority, PRIORITY, 100).
card_storm(CARDNAME, STORM) :-
    card_key_value_default(CARDNAME, spell, STORM, 0).

% Mark which cards need to be cast at the start or end of the sequence
castfirst('Chancellor of the Annex').
castfirst('Chancellor of the Tangle').
castfirst('Leyline of Lifeforce').
castfirst('Leyline of Sanctity').
castfirst('Leyline of the Void').
castfirst('Leyline of Anticipation').
castlast('Pact of Negation').
castlast('Force of Will').
castlast('Misdirection').

% Other restrictions
spellsonly('Throne of Eldraine').
contains_spellsonly([H | T]) :-
    spellsonly(H), !;
    contains_spellsonly(T).

% Concrete instantiations of the land/spell pattern
landspell('Witch Enchanter', w, [1, 0, 0, 0, 0, 0, 0]).
landspell('Razorgrass Ambush', w, [1, 0, 0, 0, 0, 0, 0]).
landspell('Emeria\'s Call', w, [1, 0, 0, 0, 0, 0, 0]).
landspell('Sink into Stupor', u, [0, 1, 0, 0, 0, 0, 0]).
landspell('Hydroelectric Specimen', u, [0, 1, 0, 0, 0, 0, 0]).
landspell('Sea Gate Restoration', u, [0, 1, 0, 0, 0, 0, 0]).
landspell('Boggart Trawler', b, [0, 0, 1, 0, 0, 0, 0]).
landspell('Fell the Profane', b, [0, 0, 1, 0, 0, 0, 0]).
landspell('Agadeem\'s Awakening', b, [0, 0, 1, 0, 0, 0, 0]).
landspell('Sundering Eruption', r, [0, 0, 0, 1, 0, 0, 0]).
landspell('Pinnacle Monk', r, [0, 0, 0, 1, 0, 0, 0]).
landspell('Shatterskull Smashing', r, [0, 0, 0, 1, 0, 0, 0]).
landspell('Disciple of Freyalise', g, [0, 0, 0, 0, 1, 0, 0]).
landspell('Bridgeworks Battle', g, [0, 0, 0, 0, 1, 0, 0]).
landspell('Turntimber Symbiosis', g, [0, 0, 0, 0, 1, 0, 0]).

% Concrete instantiations of the land pattern
land(NAME, YIELD, EXTRA_TYPES, 100) :- land(NAME, YIELD, EXTRA_TYPES).

land('Emergence Zone', [0, 0, 0, 0, 0, 1, 0], [], 2).
land('Emergence Zone_untapped', [0, 0, 0, 0, 0, 0, 0], []).

land('Gemstone Mine', [0, 0, 0, 0, 0, 0, 1], []).
land('Undiscovered Paradise', [0, 0, 0, 0, 0, 0, 1], []).
land('Mana Confluence', [0, 0, 0, 0, 0, 0, 1], []).
land('City of Brass', [0, 0, 0, 0, 0, 0, 1], []).

land('Ancient Tomb', [0, 0, 0, 0, 0, 2, 0], []).
land('City of Traitors', [0, 0, 0, 0, 0, 2, 0], []).
land('Crystal Vein', [0, 0, 0, 0, 0, 2, 0], []).
land('Urza\'s Saga', [0, 0, 0, 0, 0, 1, 0], [enchantment]).
land('Wastes', [0, 0, 0, 0, 0, 1, 0], []).

land('Planar Nexus', [0, 0, 0, 0, 0, 1, 0], []).
land('Urza\'s Tower', [0, 0, 0, 0, 0, 1, 0], []).
land('Urza\'s Workshop', [0, 0, 0, 0, 0, 1, 0], []).

land('Plains', [1, 0, 0, 0, 0, 0, 0], []).
land('Island', [0, 1, 0, 0, 0, 0, 0], []).
land('Swamp', [0, 0, 1, 0, 0, 0, 0], []).
land('Mountain', [0, 0, 0, 1, 0, 0, 0], []).
land('Forest', [0, 0, 0, 0, 1, 0, 0], []).

land('Ancient Den', [1, 0, 0, 0, 0, 0, 0], [artifact]).
land('Seat of the Synod', [0, 1, 0, 0, 0, 0, 0], [artifact]).
land('Vault of Whispers', [0, 0, 1, 0, 0, 0, 0], [artifact]).
land('Great Furnace', [0, 0, 0, 1, 0, 0, 0], [artifact]).
land('Tree of Tales', [0, 0, 0, 0, 1, 0, 0], [artifact]).
land('Darksteel Citadel', [0, 0, 0, 0, 0, 1, 0], [artifact]).

% Concrete instantiations of the free permanent pattern
free_permanent('Shield Sphere', [artifact, creature], []).
free_permanent('Phyrexian Walker', [artifact, creature], []).
free_permanent('Ornithopter', [artifact, creature], []).
free_permanent('Memnite', [artifact, creature], []).
free_permanent('Mishra\'s Bauble', [artifact], []).
free_permanent('Urza\'s Bauble', [artifact], []).

% Concrete instantiations of the generic permanent pattern
permanent_card('Ghost Vacuum', [0, 0, 0, 0, 0, 0, 1], [artifact]).
permanent_card('Candelabra of Tawnos', [0, 0, 0, 0, 0, 0, 1], [artifact]). % TODO: should be implemented explicitly
permanent_card('Disruptor Flute', [0, 0, 0, 0, 0, 0, 2], [artifact]).
permanent_card('Pithing Needle', [0, 0, 0, 0, 0, 0, 1], [artifact]).
permanent_card('Mishra\'s Research Desk', [0, 0, 0, 0, 0, 0, 1], [artifact]).
permanent_card('Soul-Guide Lantern', [0, 0, 0, 0, 0, 0, 1], [artifact]).

% Special rules for casting / making mana

specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, _, _, EXTRA_STEPS) :-
    NAME == 'Chrome Mox', cmox(YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS);
    NAME == 'Crop Rotation', crop_rotation(YIELD, OLD_STATE, NEW_STATE, EXTRA_STEPS).
specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, _, _, []) :-
    NAME == 'Cabal Ritual', cabal(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Mox Opal', opal(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Rite of Flame', rite(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Chancellor of the Tangle', chancellor(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Manamorphose', cantrip('Manamorphose', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Street Wraith', cantrip('Street Wraith', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Borne Upon a Wind', cantrip('Borne Upon a Wind', YIELD, OLD_STATE, NEW_STATE);
%    NAME == 'Gitaxian Probe', cantrip('Gitaxian Probe', YIELD, OLD_STATE, NEW_STATE). (banned)
    NAME == 'Chancellor of the Annex', chancellor_annex(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Wild Cantor', alternate_version('Wild Cantor_unused', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Tinder Wall', alternate_version('Tinder Wall_unused', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Lotus Petal', alternate_version('Lotus Petal_unused', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Lion\'s Eye Diamond', alternate_version('Lion\'s Eye Diamond_unused', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Emergence Zone', alternate_version('Emergence Zone_untapped', YIELD, OLD_STATE, NEW_STATE);
    NAME == 'Once Upon a Time', once_upon_a_time(YIELD, OLD_STATE, NEW_STATE);
    NAME == 'exile Jack-o\'-Lantern', activate_jackolantern(YIELD, OLD_STATE, NEW_STATE).
specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, _, EXTRA_STEPS) :-
    NAME == 'Culling the Weak', culling(YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, EXTRA_STEPS);
    NAME == 'Sacrifice', sacrifice(YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, EXTRA_STEPS);
    NAME == 'Burnt Offering', burnt_offering(YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, EXTRA_STEPS).
specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, _, EXTRA_STEPS) :-
    (NAME = 'Voltaic Key_tapped'; NAME = 'Manifold Key_tapped'),
    activate_key(NAME, YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, EXTRA_STEPS).
specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, _, SPENT_MANA, []) :-
    NAME == 'Pentad Prism', pentad(YIELD, SPENT_MANA, OLD_STATE, NEW_STATE).
specialcast(NAME, default, YIELD, OLD_STATE, NEW_STATE, _, _, [STEP]) :-
    NAME == 'Summoner\'s Pact', spact(YIELD, TARGET, OLD_STATE, NEW_STATE),
    atom_concat('find ', TARGET, STEP);
    (
        NAME == 'Unmask', pitch('Unmask', b, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Grief', pitch('Grief', b, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Endurance', pitch('Endurance', g, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Force of Will', pitch('Force of Will', u, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Misdirection', pitch('Misdirection', u, YIELD, OLD_STATE, NEW_STATE, PITCH);
        NAME == 'Vine Dryad', pitch('Vine Dryad', g, YIELD, OLD_STATE, NEW_STATE, PITCH)
    ), atom_concat('pitch ', PITCH, STEP).
specialcast(NAME, MODE, YIELD, OLD_STATE, NEW_STATE, _, _, []) :-
    NAME == 'Lion\'s Eye Diamond', led(MODE, YIELD, OLD_STATE, NEW_STATE).
specialcast(NAME, [affinity, Type, N], YIELD, OLD_STATE, NEW_STATE, _, _, [AffinityCount]) :-
    affinity(NAME, Type, Ns),
    state_board(OLD_STATE, Battlefield),
    zone_type_count(Battlefield, Type, N),
    member(N, Ns),
    normalcast(NAME, [affinity, Type, N], YIELD, OLD_STATE, NEW_STATE),
    atomic_list_concat([N, ' ', type, '(s)'], AffinityCount).
specialcast('Cabal Therapy', flashback, YIELD, OLD_STATE, NEW_STATE, PRIOR_STEPS, _, EXTRA_STEPS) :-
    sacrifice_creature(_, OLD_STATE, SAC_STATE, PRIOR_STEPS, EXTRA_STEPS),
    normalcast('Cabal Therapy', flashback, YIELD, SAC_STATE, CAST_STATE),
    % This might happen after casting the wincon, in which case we can't count it as protection
    (   any_has_role(PRIOR_STEPS, combo),
        state_protection(CAST_STATE, P_PLUS_ONE),
        P_CORRECT is P_PLUS_ONE - 1,
        update_protection(CAST_STATE, P_CORRECT, NEW_STATE),
        !
    ;   NEW_STATE = CAST_STATE
    ).

led(MODE,
    YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [[], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    normalcast('Lion\'s Eye Diamond', MODE, YIELD,
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
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION],
    [IMPRINT_STEP]) :-
    normalcast('Chrome Mox', _,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]),
        %(
        % Imprint a card:
        remove_first(IMPRINT, NEXT_HAND, END_HAND),
        chrome_yield(IMPRINT, YIELD),
        atom_concat('imprint ', IMPRINT, IMPRINT_STEP).
        % or don't:
        %YIELD = [0, 0, 0, 0, 0, 0, 0],
        %IMPRINT_STEP = 'no imprint'
        %).
chrome_color([H|T], YIELD) :-
    chrome_color(H, YIELD);
    chrome_color(T, YIELD).
chrome_color(w, [1, 0, 0, 0, 0, 0, 0]).
chrome_color(u, [0, 1, 0, 0, 0, 0, 0]).
chrome_color(b, [0, 0, 1, 0, 0, 0, 0]).
chrome_color(r, [0, 0, 0, 1, 0, 0, 0]).
chrome_color(g, [0, 0, 0, 0, 1, 0, 0]).
chrome_yield(IMPRINT_NAME, YIELD) :-
    card(IMPRINT_NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(colors, CARD, COLORS),
    chrome_color(COLORS, YIELD).

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

%cantor_unused(YIELD,
%    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
%    normalcast('Wild Cantor_unused', YIELD,
%        [['Wild Cantor_unused'|START_HAND], START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).
%tinder_unused(YIELD,
%    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
%    normalcast('Tinder Wall_unused', YIELD,
%        [['Tinder Wall_unused'|START_HAND], START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
%        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).

alternate_version(ALT_NAME, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    %card_property(ALT_NAME, alt, base, BASE_NAME),
    %remove_first(BASE_NAME, START_HAND, HAND2),
    normalcast(ALT_NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]).

culling(YIELD, START_STATE, END_STATE, HISTORY, STEPS) :-
    sacrifice_creature_instant(_, START_STATE, NEXT_STATE, HISTORY, STEPS),
    normalcast('Culling the Weak', YIELD, NEXT_STATE, END_STATE).
sacrifice([0, 0, CMC, 0, 0, 0, 0], START_STATE, END_STATE, HISTORY, STEPS) :-
    sacrifice_creature_instant(CREATURE, START_STATE, NEXT_STATE, HISTORY, STEPS),
    cmc(CREATURE, CMC),
    normalcast('Sacrifice', _, NEXT_STATE, END_STATE).
burnt_offering([0, 0, B, R, 0, 0, 0], START_STATE, END_STATE, HISTORY, STEPS) :-
    sacrifice_creature_instant(CREATURE, START_STATE, NEXT_STATE, HISTORY, SACRIFICE_STEPS),
    cmc(CREATURE, CMC),
    normalcast('Burnt Offering', _, NEXT_STATE, END_STATE),
    between(0, CMC, B),
    R is CMC - B,
    concat_n(b, B, BS),
    concat_n(r, R, RS),
    atom_concat(BS, RS, DISTRIBUTION),
    append(SACRIFICE_STEPS, [DISTRIBUTION], STEPS).

crop_rotation(YIELD, START_STATE, END_STATE, [SAC_STEP, FIND_STEP]) :-
    normalcast('Crop Rotation', _, START_STATE, CAST_STATE),
    sacrifice_land(_, CAST_STATE, SAC_STATE, SAC_STEP),
    land(TARGET, NORMAL_YIELD, _, _),
    remove_from_deck(TARGET, SAC_STATE, FIND_STATE),
    atom_concat('find ', TARGET, FIND_STEP),
    (
        add_to_board(TARGET, FIND_STATE, END_STATE),
        YIELD = NORMAL_YIELD;
        atom_concat(TARGET, '_untapped', UNTAPPED_VERSION),
        add_to_board(UNTAPPED_VERSION, FIND_STATE, END_STATE),
        YIELD = [0, 0, 0, 0, 0, 0, 0]
    ).

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
    _,
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
    HISTORY,
    STEPS) :-
    (CARD_NAME = 'Grief' ; CARD_NAME = 'Endurance'),
    remove_first(CARD_NAME, START_HAND, NEXT_HAND),
    specialcast(CARD_NAME, _, _, [NEXT_HAND, BOARD, MANA, GY, STORM, DECK, PROTECTION], END_STATE, HISTORY, _, CAST_STEPS),
    atom_concat('sacrifice ', CARD_NAME, SACRIFICE_STEP),
    append(CAST_STEPS, [SACRIFICE_STEP], STEPS).
sacrifice_creature_instant(CARDNAME, START_STATE, END_STATE, HISTORY, STEPS) :-
    sacrifice_creature(CARDNAME, START_STATE, END_STATE, HISTORY, STEPS).

sacrifice_bargain(CARDNAME,
    [HAND, START_BOARD, MANA, START_GY, STORM, DECK, PROTECTION],
    [HAND, END_BOARD, MANA, [CARDNAME|START_GY], STORM, DECK, END_PROTECTION],
    [SACRIFICE_STEP]) :-
    remove_first(CARDNAME, START_BOARD, END_BOARD),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    (member(token, TYPES); member(artifact, TYPES); member(enchantment, TYPES)),
    (
        get_assoc(protection, CARD, LOSE_PROTECTION),
        END_PROTECTION is PROTECTION - LOSE_PROTECTION,
        !;
        END_PROTECTION is PROTECTION
    ),
    atom_concat('sacrifice ', CARDNAME, SACRIFICE_STEP).

sacrifice_land(CARDNAME, START_STATE, END_STATE, SACRIFICE_STEP) :-
    board_to_grave(CARDNAME, START_STATE, END_STATE),
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    member(land, TYPES),
    atom_concat('sacrifice ', CARDNAME, SACRIFICE_STEP).

spact(YIELD,
    CARDNAME,
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
    [["(unknown draw)" | END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    (nb_current(reveal_draws, false); not(nb_current(reveal_draws, true))),
    normalcast(NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, [ _ | END_DECK], PROTECTION]).
cantrip(NAME, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
    [[DRAW | END_HAND], END_BOARD, END_MANA, END_GY, END_STORM, END_DECK, PROTECTION]) :-
    nb_current(reveal_draws, true),
    normalcast(NAME, YIELD,
        [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, PROTECTION],
        [END_HAND, END_BOARD, END_MANA, END_GY, END_STORM, [ DRAW | END_DECK], PROTECTION]).

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

activate_key(ACTIVATED_KEY, YIELD, [H, START_BOARD, M, G, S, D, P], [H, END_BOARD, M, G, S, D, P], HISTORY, [STEP]) :-
    atom_concat(KEY, "_tapped", ACTIVATED_KEY),
    remove_first(KEY, START_BOARD, BOARD2),
    member(TARGET, BOARD2),
    (   TARGET = 'Grim Monolith', YIELD = [0, 0, 0, 0, 0, 3, 0]
    ;   TARGET = 'Mox Opal', metalcraft(H, START_BOARD), YIELD = [0, 0, 0, 0, 0, 0, 1]
    ;   TARGET = 'Chrome Mox',
        member(IMPRINT_STEP, HISTORY),
        atom_concat('imprint ', IMPRINT_NAME, IMPRINT_STEP),
        chrome_yield(IMPRINT_NAME, YIELD)
    ),
    atom_concat("untap ", TARGET, STEP),
    append(BOARD2, [ACTIVATED_KEY], END_BOARD).

activate_jackolantern([0, 0, 0, 0, 0, 0, 1], [H, B, M, G1, S, D, P], [H, B, M, G2, S, D, P]) :-
    remove_first('Jack-o\'-Lantern', G1, G2).

pentad([0, 0, 0, 0, 0, 0, NUM_COUNTERS], SPENT_MANA, START_STATE, END_STATE) :-
    sunburst(SPENT_MANA, NUM_COUNTERS),
    normalcast('Pentad Prism', [0, 0, 0, 0, 0, 0, NUM_COUNTERS], START_STATE, END_STATE).
min(A, B, A) :- B >= A.
min(A, B, B) :- A > B.
sunburst([W, U, B, R, G, _, X | _ ], N) :-
    min(W, 1, NW),
    min(U, 1, NU),
    min(B, 1, NB),
    min(R, 1, NR),
    min(G, 1, NG),
    total([NW, NU, NB, NR, NG, X], TOTAL),
    min(TOTAL, 5, N).

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
    ['Beseech the Mirror' | STEPS],
    SACRIFICE) :-
    normalcast('Beseech the Mirror', _, START_STATE, CAST_STATE),
    sacrifice_bargain(SACRIFICE, CAST_STATE, [NEXT_HAND, END_BOARD, END_MANA, END_GY, END_STORM, NEXT_DECK, PROTECTION], STEPS),
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
    not_member(TYPE, TYPES),
    !.
isnottype(CARDNAME, _) :-
    not(card(CARDNAME, _)).
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
    N >= 1,
    istype(CARDNAME, TYPE),
    M is N-1,
    type_threshold(M, TYPE, T), !;
    type_threshold(N, TYPE, T), !.
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
    istype(H, TYPE),
    zone_type_count(T, TYPE, N),
    COUNT is N+1,
    !.
zone_type_count([H|T], TYPE, COUNT) :-
    isnottype(H, TYPE),
    zone_type_count(T, TYPE, COUNT).

zone_type_cards([], _, []).
zone_type_cards([H | T_ZONE], TYPE, [H | T_TYPE]) :-
    istype(H, TYPE),
    zone_type_cards(T_ZONE, TYPE, T_TYPE).
zone_type_cards([H | T_ZONE], TYPE, T_TYPE) :-
    isnottype(H, TYPE),
    zone_type_cards(T_ZONE, TYPE, T_TYPE).

% General rules for casting

cast(NAME, YIELD, STEPS, OLD_STATE, NEW_STATE, PRIOR_STEPS, SPENT_MANA) :-
    cast(NAME, default, YIELD, STEPS, OLD_STATE, NEW_STATE, PRIOR_STEPS, SPENT_MANA).

cast(NAME, MODE, YIELD, STEPS, OLD_STATE, NEW_STATE, PRIOR_STEPS, SPENT_MANA) :-
    cast_triggers(NAME, OLD_STATE, INTERMEDIATE_STATE, TRIGGERS),
    (
        specialcast(NAME, MODE, YIELD, INTERMEDIATE_STATE, NEW_STATE, PRIOR_STEPS, SPENT_MANA, INTERMEDIATE_STEPS)
    ;
        not(requires_special(NAME, MODE, INTERMEDIATE_STATE)),
        normalcast(NAME, MODE, YIELD, INTERMEDIATE_STATE, NEW_STATE),
        INTERMEDIATE_STEPS = []
    ),
    append(INTERMEDIATE_STEPS, TRIGGERS, STEPS).

requires_special(Name, Mode, _) :-
    card_property(Name, Mode, restricted, true),
    !.
requires_special(Name, Mode, State) :-
    specialcast(Name, Mode, _, State, _, _, _, _), !,
    not(card_property(Name, Mode, options, true)).

normalcast(NAME, YIELD, START_STATE, END_STATE) :-
    normalcast(NAME, default, YIELD, START_STATE, END_STATE).
normalcast(NAME, MODE, YIELD,
    [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION],
    [START_HAND, END_BOARD, START_MANA, END_GY, END_STORM, START_DECK, END_PROTECTION]) :-
    card_property(NAME, MODE, spell, SPELLS),
    SPELLS >= 0,
    card_property(NAME, MODE, yield, YIELD),
    card_property(NAME, MODE, gy, GY),
    card_property(NAME, MODE, board, BOARD),
    END_STORM is START_STORM + SPELLS,
    yard(NAME, [START_HAND, START_BOARD, START_MANA, START_GY, START_STORM, START_DECK, START_PROTECTION], END_GY, GY),
    board(NAME, START_BOARD, END_BOARD, BOARD),
    type_max(1, land, END_BOARD),
    card_property_default(NAME, MODE, protection, 0, ADDITIONAL_PROTECTION),
    END_PROTECTION is START_PROTECTION + ADDITIONAL_PROTECTION.

has_trigger(TRIGGER_CONDITION, NAME) :-
    card_key_value_default(NAME, triggers, TRIGGERS, []),
    member(TRIGGER_CONDITION, TRIGGERS).

cast_triggers(CARDNAME, OLD_STATE, NEW_STATE, STEPS) :-
    OLD_STATE = [_, START_BOARD, _, _, _, _, _],
    card(CARDNAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(types, CARD, TYPES),
    % trigger Pinnacle Emissary if appropriate
    (   member(artifact, TYPES),
        include(=('Pinnacle Emissary'), START_BOARD, EMISSARIES),
        length(EMISSARIES, N),
        N > 0,
        n_copies(N, 'Drone Token', DRONES),
        n_copies(N, 'Pinnacle Emissary trigger', STEPS),
        append(START_BOARD, DRONES, NEW_BOARD),
        update_board(OLD_STATE, NEW_BOARD, PINNACLE_STATE),
        !
    ;   PINNACLE_STATE = OLD_STATE,
        STEPS = []
    ),
    NEW_STATE = PINNACLE_STATE.

yard(_, START_STATE, END_GY, 0) :-
    state_gy(START_STATE, END_GY).
yard(_, START_STATE, END_GY, 1) :-
    exile_grave(START_STATE),
    state_gy(START_STATE, END_GY).
yard(NAME, START_STATE, END_GY, 1) :-
    not(exile_grave(START_STATE)),
    state_gy(START_STATE, START_GY),
    append(START_GY, [NAME], END_GY).

board(_, START_BOARD, START_BOARD, 0).
board(NAME, START_BOARD, END_BOARD, 1) :-
    append(START_BOARD, [NAME], END_BOARD).
threshold(GRAVEYARD) :-
    length(GRAVEYARD, N),
    N >= 7.

exile_grave(STATE) :-
    state_board(STATE, BOARD),
    member('Necrodominance', BOARD).

maxnet(NAME, MAX) :-
    card(NAME, DATA),
    list_to_assoc(DATA, CARD),
    get_assoc(net, CARD, MAX), !;
    MAX = 0.

maxnet(NAME, HAND, BOARD, GY, LIBRARY, MAX) :-
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
    % for Summoner's Pact, check for specific green creatures in library
    NAME == 'Summoner\'s Pact',
    (member('Elvish Spirit Guide', LIBRARY); member('Tinder Wall', LIBRARY)),
    MAX is 1,
    !;
    % for Voltaic/Manifold Key, use the best artifact between hand and board
    (   member(NAME, ['Voltaic Key', 'Manifold Key']), KEY_COST = 2 % still in hand
    ;   member(NAME, ['Voltaic Key_tapped', 'Manifold Key_tapped']), KEY_COST = 1 % already on board
    ),
    append(HAND, BOARD, HAND_AND_BOARD),
    zone_type_cards(HAND_AND_BOARD, artifact, ARTIFACTS),
    subtract(ARTIFACTS, ['Voltaic Key', 'Manifold Key', 'Voltaic Key_tapped', 'Manifold Key_tapped'], MINUS_KEYS),
    maplist(max_yield, MINUS_KEYS, ARTIFACT_YIELDS),
    maplist(sum_list, ARTIFACT_YIELDS, CONVERTED),
    max_list([KEY_COST | CONVERTED], MAX_YIELD),
    MAX is MAX_YIELD - KEY_COST,
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
    get_assoc(options, CARD, true).

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

remove_first_opt(_, [], [], []).
remove_first_opt(ITEM, [ITEM | T], T, [ITEM]).
remove_first_opt(ITEM, [H | T], [H | T_REMOVED], REMOVED) :-
    dif(ITEM, H),
    remove_first_opt(ITEM, T, T_REMOVED, REMOVED).

remove_first_type(TYPE, [CARDNAME | T], T, CARDNAME) :-
    istype(CARDNAME, TYPE).
remove_first_type(TYPE, [H | T], [H | REMOVED], CARDNAME) :-
    not(istype(H, TYPE)),
    remove_first_type(TYPE, T, REMOVED, CARDNAME).

take(ITEM, [ITEM | T], T).
take(ITEM, [H | T], [H | TAKEN]) :-
    take(ITEM, T, TAKEN).

take_all(LIST, [], [], LIST).
take_all([], _, [], []).
take_all([H|T], SET, [H|TAKEN], REMAINDER) :-
    member(H, SET),
    take_all(T, SET, TAKEN, REMAINDER).
take_all([H|T], SET, TAKEN, [H|REMAINDER]) :-
    not(member(H, SET)),
    take_all(T, SET, TAKEN, REMAINDER).

remove_n(_, 0, LIST, LIST, []) :- !.
remove_n(ITEM, N, LIST, REMAINDER, [ITEM|REMOVED]) :-
    N > 0,
    remove(ITEM, LIST, PARTIAL),
    N2 is N - 1,
    remove_n(ITEM, N2, PARTIAL, REMAINDER, REMOVED).

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

all_member_or_tutor([], _, _).
all_member_or_tutor([H|T], HAND, DECK) :-
    member_or_tutor(H, HAND, DECK),
    all_member_or_tutor(T, HAND, DECK).

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

has_role(CARDNAME, ROLE) :-
    (
        card_property(CARDNAME, _, roles, ROLES),
        member(ROLE, ROLES),
        !
    ;   sub_string(CARDNAME, LENGTH_BEFORE, 2, LENGTH_AFTER, '->'),
        !,
        sub_atom(CARDNAME, 0, LENGTH_BEFORE, _, CARD1),
        sub_atom(CARDNAME, _, LENGTH_AFTER, 0, CARD2),
        (has_role(CARD1, ROLE), !; has_role(CARD2, ROLE))
    ).

all_have_role([], _).
all_have_role([H|T], ROLE) :-
    has_role(H, ROLE),
    all_have_role(T, ROLE).

any_has_role([H|_], ROLE) :-
    has_role(H, ROLE),
    !.
any_has_role([_|T], ROLE) :-
    any_has_role(T, ROLE),
    !.

card_property(CARDNAME, MODE, PROPERTY, VALUE) :-
    % if the card isn't modal, get the default value
    card(CARDNAME, DATA),
    not(card(CARDNAME, _, _)),
    list_to_assoc(DATA, ASSOC),
    get_assoc(PROPERTY, ASSOC, VALUE);
    % if it is modal, use the right mode
    card(CARDNAME, DATA, MODE),
    list_to_assoc(DATA, ASSOC),
    (
        get_assoc(PROPERTY, ASSOC, VALUE);
        % but if this mode doesn't specify the property, use the base mode
        not(get_assoc(PROPERTY, ASSOC, _)),
        card(CARDNAME, BASE_DATA, base),
        list_to_assoc(BASE_DATA, BASE_ASSOC),
        get_assoc(PROPERTY, BASE_ASSOC, VALUE)
    ).

card_property_default(CARDNAME, MODE, PROPERTY, _, VALUE) :-
    card_property(CARDNAME, MODE, PROPERTY, VALUE).
card_property_default(CARDNAME, MODE, PROPERTY, DEFAULT, DEFAULT) :-
    not(card_property(CARDNAME, MODE, PROPERTY, _)).

in_first_n(H, [H|_], N) :-
    N > 0.
in_first_n(TARGET, [H|T], N) :-
    TARGET \= H,
    N > 1,
    M is N - 1,
    in_first_n(TARGET, T, M).

n_copies(0, _, []).
n_copies(N, ITEM, [ITEM|T]) :-
    N > 0,
    N2 is N - 1,
    n_copies(N2, ITEM, T),
    !.

activates(UNUSED_NAME, ACTIVATED_NAME) :-
    card(UNUSED_NAME, UNUSED_DATA),
    list_to_assoc(UNUSED_DATA, UNUSED_CARD),
    get_assoc(activate, UNUSED_CARD, ACTIVATED_NAME).

activates_gy(UNUSED_NAME, ACTIVATED_NAME) :-
    card(UNUSED_NAME, UNUSED_DATA),
    list_to_assoc(UNUSED_DATA, UNUSED_CARD),
    get_assoc(activate_gy, UNUSED_CARD, ACTIVATED_NAME).

possible_activations([], []).
possible_activations([H|T], ACTIVATED_T) :-
    not(activates(H, _)),
    possible_activations(T, ACTIVATED_T).
possible_activations([H|T], [ACTIVATED_H | ACTIVATED_T]) :-
    activates(H, ACTIVATED_H),
    possible_activations(T, ACTIVATED_T).

possible_activations_gy([], []).
possible_activations_gy([H|T], ACTIVATED_T) :-
    not(activates_gy(H, _)),
    possible_activations_gy(T, ACTIVATED_T).
possible_activations_gy([H|T], [ACTIVATED_H | ACTIVATED_T]) :-
    activates_gy(H, ACTIVATED_H),
    possible_activations_gy(T, ACTIVATED_T).
