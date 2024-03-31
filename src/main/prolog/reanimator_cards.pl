animate_spell('Reanimate').
animate_spell('Exhume').
animate_spell('Animate Dead').
animate_spell('Dance of the Dead').

animate_target('Griselbrand').
animate_target('Chancellor of the Annex').
animate_target('Archon of Cruelty').
animate_target('Atraxa, Grand Unifier').

discard_outlet('Faithless Looting').
discard_outlet('Careful Study').
discard_outlet('Unmask').
discard_outlet('Thoughtseize').

entomb_spell('Entomb').
entomb_spell('Buried Alive').
entomb_spell('Unmarked Grave').
entomb_spell('Intuition').

card('Entomb', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    colors - [b],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Buried Alive', [
    cost   - [0, 0, 1, 0, 0, 2, 0],
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Unmarked Grave', [
    cost   - [0, 0, 1, 0, 0, 1, 0],
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Intuition', [
    cost   - [0, 1, 0, 0, 0, 2, 0],
    colors - [u],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).

card('Reanimate', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Exhume', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    colors - [b],
    types  - [sorcery],
    spell  - 1,
    board  - 0,
    gy     - 1,
    restricted - true
]).
card('Animate Dead', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    colors - [b],
    types  - [enchantment],
    spell  - 1,
    board  - 1,
    gy     - 0,
    restricted - true
]).
card('Dance of the Dead', [
    cost   - [0, 0, 1, 0, 0, 0, 1],
    colors - [b],
    types  - [enchantment],
    spell  - 1,
    board  - 1,
    gy     - 0,
    restricted - true
]).
card('Griselbrand', [
    cost   - [0, 0, 3, 0, 0, 0, 4],
    colors - [b],
    types  - [creature],
    spell  - 0,
    board  - 1,
    gy     - 0,
    restricted - true
]).
card('Atraxa, Grand Unifier', [
    cost   - [1, 1, 1, 0, 1, 0, 3],
    colors - [wubg],
    types  - [creature],
    spell  - 0,
    board  - 1,
    gy     - 0,
    restricted - true
]).
card('Archon of Cruelty', [
    cost   - [0, 0, 2, 0, 0, 0, 6],
    colors - [b],
    types  - [creature],
    spell  - 0,
    board  - 1,
    gy     - 0,
    restricted - true
]).

card('Swamp', [
    cost   - [0, 0, 0, 0, 0, 0, 0],
    yield  - [0, 0, 1, 0, 0, 0, 0],
    net    - 1,
    colors - [],
    types  - [land],
    spell  - 0,
    board  - 1,
    gy     - 0
]).
card('Dark Ritual', [
    cost   - [0, 0, 1, 0, 0, 0, 0],
    yield  - [0, 0, 3, 0, 0, 0, 0],
    net    - 2,
    colors - [b],
    types  - [instant],
    spell  - 1,
    board  - 0,
    gy     - 1
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
