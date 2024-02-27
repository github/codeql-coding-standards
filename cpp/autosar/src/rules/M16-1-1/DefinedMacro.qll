import cpp
import codingstandards.cpp.autosar

/**
 * A helper class describing macros wrapping the defined operator
 */
class MacroUsesDefined extends Macro {
  MacroUsesDefined() {
    // Uses `defined` directly
    exists(this.getBody().regexpFind("\\bdefined\\b", _, _))
    or
    // Uses a macro that uses `defined` (directly or indirectly)
    exists(MacroUsesDefined dm | exists(this.getBody().regexpFind(dm.getRegexForMatch(), _, _)))
  }

  /**
   * Gets a regex for matching uses of this macro.
   */
  string getRegexForMatch() {
    exists(string arguments |
      // If there are arguments
      if getHead() = getName() then arguments = "" else arguments = "\\s*\\("
    |
      // Use word boundary matching to find identifiers that match
      result = "\\b" + getName() + "\\b" + arguments
    )
  }
}
