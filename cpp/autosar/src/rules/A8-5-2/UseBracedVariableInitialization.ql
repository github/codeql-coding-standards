/**
 * @id cpp/autosar/use-braced-variable-initialization
 * @name A8-5-2: Braced-initialization {}, without equals sign, shall be used for variable initialization
 * @description Braced initialization is less confusing than alternative approaches initialization.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/a8-5-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/*
 * This is a tricky query to write, because we don't store syntactic information about the
 * form of initialization used - the database only represents the semantic information about the
 * initialization.
 *
 * To work around this in the short term, we use a heuristic which assumes that the source code is
 * well formatted, and therefore that `{}` initialization of a variable can be distinguished from
 * `=` initialization of a variable by locations. For example, consider
 * ```
 * int a1{1};
 * int a2 = {1};
 * ```
 * In a1, the initializer starts one column after the last column of the variable name (at the
 * location of `1`), but the `=` initializer starts two columns after the last column of the
 * variable name (at the location of the ` ` after the equals sign).
 *
 * In practice, this seems to work surprisingly well - most projects use some auto-formatting
 *
 * Unfortunately, I can find no heuristic to differentiate between:
 * ```
 * int a1{1};
 * int a2(1);
 * ```
 * So we cannot currently flag bracket `()` initialization.
 */

/**
 * Holds if `v` is an assignment initializer
 */
predicate hasAssignmentInitializer(Variable v, Initializer i, Expr e) {
  v.getInitializer() = i and
  e = v.getInitializer().getExpr() and
  // Find cases where the variable initializer starts three columns after the last column of the
  // variable name. Three columns equates to add ` =` to the end of the variable name. For example:
  // ```
  // int a1 = 1;
  //      ^  ^
  //      6  9   - column number
  // ```
  exists(string filepath, int startline, int startcolumn, int endline, int endcolumn |
    v.getLocation().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
    v.getInitializer().getLocation().hasLocationInfo(filepath, startline, endcolumn + 3, endline, _)
  )
}

from Variable v
where
  not isExcluded(v, InitializationPackage::useBracedVariableInitializationQuery()) and
  not v.declaredUsingAutoType() and
  hasAssignmentInitializer(v, _, _)
select v, "Variable " + v.getName() + " does not appear to use braced-initialization."
