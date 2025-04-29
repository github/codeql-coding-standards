bindingset[this]
signature class ItemSig {
  bindingset[this]
  string toString();
}

module Pair<ItemSig A, ItemSig B> {
  signature predicate pred(A a, B b);

  module Where<pred/2 ctor> {
    private newtype TAll = TSome(A a, B b) { ctor(a, b) }

    class Pair extends TAll {
      A getFirst() { this = TSome(result, _) }

      B getSecond() { this = TSome(_, result) }

      string toString() { result = getFirst().toString() + ", " + getSecond().toString() }
    }
  }
}
