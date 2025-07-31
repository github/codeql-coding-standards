private import codeql.util.DenseRank

/**
 * Describes how to construct a condensed list from sparse but orderable data, and how that data
 * should be connected, with one such list per specified division.
 */
signature module CondensedListSig {
  /**
   * The division specifies which items are connected into lists, with one list per division.
   *
   * For instance, if connecting variables defined in a file, the division will be the file.
   */
  class Division;

  /**
   * The class of the items to be condensed into lists.
   *
   * For instance, when connecting variables defined in a file, the items are the variables.
   */
  class Item {
    string toString();
  }

  /**
   * The index specifies the order of the items in the condensed list, and may be sparse (have
   * gaps).
   *
   * For instance, if connecting variables defined in a file, the index will be the line number of
   * the variable in the file.
   *
   * The sparse index (which may have gaps) is used to determine the ordering of the items in the
   * condensed list. Once the condensed list is created, the items in the list will automatically be
   * assigned a dense index (which has no gaps).
   *
   * There must be no duplicate indices for the same division for correctness.
   */
  int getSparseIndex(Division d, Item l);
}

/**
 * A module to take orderable data (which may not be continuous) and condense it into one or more
 * dense lists, with one such list per specified division.
 *
 * To instantiate this module, you need to provide a `CondensedListSig` module that
 * specifies the spare index and division of the items to be connected.
 *
 * For instance, to create a condensed list of variables defined in every file, you can
 * create a `CondensedListSig` module that specifies the file as the division and
 * the line number as the sparse index.
 *
 * ```ql
 *   module ConfigFileListConfig {
 *     class Division = File;
 *     class Item = Variable;
 *     int getSparseIndex(File file, Variable var) {
 *       file = var.getLocation().getFile() and
 *       var.getLocation().getStartLine()
 *     }
 *   }
 *
 *   import Condense<ConfigFileListConfig>
 *
 *   from Condense::ListEntry l
 *   select l, l.getItem(), l.getDenseIndex(), l.getNext(), l.getPrev(),
 * ```
 */
module Condense<CondensedListSig Config> {
  newtype TList =
    THead(Config::Item l, Config::Division t) { denseRank(t, l) = 1 } or
    TCons(ListEntry prev, Config::Item l) {
      prev.getDenseIndex() = denseRank(prev.getDivision(), l) - 1
    }

  private module DenseRankConfig implements DenseRankInputSig2 {
    class Ranked = Config::Item;

    class C = Config::Division;

    predicate getRank = Config::getSparseIndex/2;
  }

  private import DenseRank2<DenseRankConfig>

  class ListEntry extends TList {
    Config::Division getDivision() {
      this = THead(_, result)
      or
      exists(ListEntry prev | this = TCons(prev, _) and result = prev.getDivision())
    }

    string toString() { result = getItem().toString() + " [index " + getDenseIndex() + "]" }

    Config::Item getItem() {
      this = THead(result, _)
      or
      this = TCons(_, result)
    }

    int getDenseIndex() { result = denseRank(getDivision(), getItem()) }

    ListEntry getPrev() { this = TCons(result, _) }

    ListEntry getNext() { result.getPrev() = this }
  }
}
