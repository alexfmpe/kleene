## 0.1

* Drop superclasses from `Kleene`.
* Rearrange classes. Introduce `CharKleene`, `FiniteKleene`.
* Add `ToLatin1` and ability to match on `ByteString`.
* Add `Derivate c (DFA c)` instance.
* Add `toDot` to output `DFA` to be rendered by *graphviz*.
* Add `fromRE :: RE c -> ERE c`
* Add `nullableProof :: RE c -> Maybe (RE c)` which returns non-nullable part
  of given regular expression.
* Support/require `lattices-2`: `RE` is now a `Lattice`, `M` isn't.
