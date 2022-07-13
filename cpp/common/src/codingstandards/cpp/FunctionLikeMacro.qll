import cpp

/**
 * A `FunctionLikeMacro` that occurs in a `Macro` definition
 * with the form: macroname(parameters).
 *
 * Example:
 * ```
 * #define MACRO(X) X + 1
 * ...
 * ```
 */
class FunctionLikeMacro extends Macro {
  FunctionLikeMacro() { this.getHead().regexpMatch(".*\\(.*\\).*") }

  string getAParameter() {
    exists(string paramstr |
      paramstr = this.getHead().regexpReplaceAll(".*\\(", "").regexpReplaceAll("\\)", "") and
      result = paramstr.splitAt(",").trim() and
      result.length() > 0
    )
  }
}
