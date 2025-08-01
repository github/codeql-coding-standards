/**
 * @id cpp/misra/undef-of-macro-not-defined-in-file
 * @name RULE-19-0-4: #undef should only be used for macros defined previously in the same file
 * @description Using #undef to undefine a macro that is not defined in the same file can lead to
 *              confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-19-0-4
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.util.CondensedList
import codingstandards.cpp.util.Pair

class DefOrUndef extends PreprocessorDirective {
  string name;

  DefOrUndef() {
    name = this.(PreprocessorUndef).getName() or
    name = this.(Macro).getName()
  }

  string getName() { result = name }
}

predicate relevantNameAndFile(string name, File file) {
  exists(DefOrUndef m |
    m.getName() = name and
    m.getFile() = file
  )
}

class StringFilePair = Pair<string, File>::Where<relevantNameAndFile/2>::Pair;

module DefUndefListConfig implements CondensedListSig {
  class Division = StringFilePair;

  class Item = DefOrUndef;

  int getSparseIndex(StringFilePair division, DefOrUndef directive) {
    directive.getName() = division.getFirst() and
    directive.getFile() = division.getSecond() and
    result = directive.getLocation().getStartLine()
  }
}

class ListEntry = Condense<DefUndefListConfig>::ListEntry;

from PreprocessorUndef undef, ListEntry defUndefListEntry
where
  not isExcluded(undef, PreprocessorPackage::undefOfMacroNotDefinedInFileQuery()) and
  // There exists a def or undef for a given name and file, and it is an #undef
  undef = defUndefListEntry.getItem() and
  // Exclude cases where the previous def or undef with the same name in the same file is a #define
  not exists(ListEntry prev |
    prev = defUndefListEntry.getPrev() and
    prev.getItem() instanceof Macro
  )
select undef, "Undef of name '" + undef.getName() + "' not defined in the same file."
