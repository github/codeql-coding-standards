/**
 * @id c/misra/dead-code
 * @name RULE-2-2: There shall be no dead code
 * @description Dead code complicates the program and can indicate a possible mistake on the part of
 *              the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-2-2
 *       readability
 *       maintainability
 *       external/misra/c/2012/third-edition-first-revision
 *       coding-standards/baseline/style
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.alertreporting.HoldsForAllCopies
import codingstandards.cpp.deadcode.UselessAssignments

/**
 * Gets an explicit cast from `e` if one exists.
 */
Cast getExplicitCast(Expr e) {
  exists(Conversion c | c = e.getExplicitlyConverted() |
    result = c
    or
    result = c.(ParenthesisExpr).getExpr()
  )
}

class ExprStmtExpr extends Expr {
  ExprStmtExpr() { exists(ExprStmt es | es.getExpr() = this) }
}

/**
 * An "operation" as defined by MISRA C Rule 2.2 that is dead, i.e. it's removal has no effect on
 * the behaviour of the program.
 */
class DeadOperationInstance extends Expr {
  string description;

  DeadOperationInstance() {
    // Exclude cases nested within macro expansions, because the code may be "live" in other
    // expansions
    isNotWithinMacroExpansion(this) and
    exists(ExprStmtExpr e |
      if exists(getExplicitCast(e))
      then
        this = getExplicitCast(e) and
        // void conversions are permitted
        not getExplicitCast(e) instanceof VoidConversion and
        description = "Cast operation is unused"
      else (
        this = e and
        (
          if e instanceof Assignment
          then
            exists(SsaDefinition sd, LocalScopeVariable v |
              e = sd.getDefinition() and
              sd.getDefiningValue(v).isPure() and
              // The definition is useless
              isUselessSsaDefinition(sd, v) and
              description = "Assignment to " + v.getName() + " is unused and has no side effects"
            )
          else (
            e.isPure() and
            description = "Result of operation is unused and has no side effects"
          )
        )
      )
    )
  }

  string getDescription() { result = description }
}

class DeadOperation = HoldsForAllCopies<DeadOperationInstance, Expr>::LogicalResultElement;

from
  DeadOperation deadOperation, DeadOperationInstance instance, string message, Element explainer,
  string explainerDescription
where
  not isExcluded(instance, DeadCodePackage::deadCodeQuery()) and
  instance = deadOperation.getAnElementInstance() and
  if instance instanceof FunctionCall
  then
    message = instance.getDescription() + " from call to function $@" and
    explainer = instance.(FunctionCall).getTarget() and
    explainerDescription = explainer.(Function).getName()
  else (
    message = instance.getDescription() and
    // Ignore the explainer
    explainer = instance and
    explainerDescription = ""
  )
select deadOperation, message + ".", explainer, explainerDescription
