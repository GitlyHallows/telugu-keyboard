# Correction Process

Every user-confirmed correction must be recorded in `data/correction_ledger.tsv`.
The goal is to avoid turning `common_chat.tsv` into an unexamined pile of one-off rows.

## Categories

- `exact-common-word`: add a curated lexical mapping when the correction is word-specific or unsafe to generalize.
- `generalized-suffix-pattern`: add or reuse a bounded pattern when the same suffix behavior is likely to apply to a small family of stems.
- `candidate-ranking-feature`: adjust ranking when generated candidates are valid but ordered poorly.
- `local-user-learning-case`: rely on explicit user selection learning, stored locally, when the preference is personal rather than a shared default.

## Generalization Rule

For each correction, decide whether it produced:

- `exact-only`
- `pattern-implemented`
- `ranking-implemented`
- `local-runtime`

If the correction is broad enough to generalize but not safe enough to implement yet, keep it exact and explain the risk in the ledger notes.

## Language Notes

- Telugu consonants have an inherent `/a/`; vowel signs or halant change that value, so Roman vowel handling must avoid meaningless independent-vowel splits.
- Geminate consonants are a normal part of Telugu syllable structure and orthography, so candidates like `చ్చి`, `న్న`, and `క్క` need explicit ranking support.
- Dative pronouns such as `నాకు`, `నీకు`, `మీకు`, and `మాకు` are common building blocks. The emphatic particle `e` attaches after the emphasized word, so common Roman forms like `naake` should produce `నాకే`.
- Local learning should be strong but not reckless: one explicit selection is provisional and may beat rules, while repeated explicit selections are required to beat high-confidence curated common-chat mappings.

Runtime behavior must remain offline-only. External transliteration tools may be used privately by maintainers for comparison, but no runtime provider may call a network service and generated comparison dumps must not be committed.
