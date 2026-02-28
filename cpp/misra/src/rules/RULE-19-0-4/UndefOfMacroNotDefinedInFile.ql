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
import qtil.Qtil

class DefOrUndef extends PreprocessorDirective {
  DefOrUndef() { this instanceof PreprocessorUndef or this instanceof Macro }

  string getName() {
    result = this.(PreprocessorUndef).getName() or
    result = this.(Macro).getName()
  }
}

predicate relevantNameAndFile(string name, File file) {
  exists(DefOrUndef m |
    m.getName() = name and
    m.getFile() = file
  )
}

class StringFilePair = Qtil::Pair<string, File, relevantNameAndFile/2>::Pair;

/**
 * Defs and undefs ordered by location, grouped by name and file.
 */
class OrderedDefOrUndef extends Qtil::Ordered<DefOrUndef>::GroupBy<StringFilePair>::Type {
  override int getOrder() { result = getLocation().getStartLine() }

  override StringFilePair getGroup() {
    result.getFirst() = getName() and result.getSecond() = getFile()
  }
}

from OrderedDefOrUndef defOrUndef
where
  not isExcluded(defOrUndef, PreprocessorPackage::undefOfMacroNotDefinedInFileQuery()) and
  // There exists an #undef for a given name and file
  defOrUndef instanceof PreprocessorUndef and
  // A previous def or undef of this name must exist in this file, and it must be a #define
  not defOrUndef.getPrevious() instanceof Macro
select defOrUndef, "Undef of name '" + defOrUndef.getName() + "' not defined in the same file."
