/**
 * @id c/misra/non-boolean-iteration-condition
 * @name RULE-14-4: The condition of an iteration statement shall have type bool
 * @description Non boolean conditions can be confusing for developers.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-14-4
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

/** A macro within the source location of this project. */
class UserProvidedMacro extends Macro {
  UserProvidedMacro() { exists(this.getFile().getRelativePath()) }
}

/** A macro defined within a library used by this project. */
class LibraryMacro extends Macro {
  LibraryMacro() { not this instanceof UserProvidedMacro }
}

from Expr condition, Loop l, Type essentialType
where
  not isExcluded(condition, Statements4Package::nonBooleanIterationConditionQuery()) and
  // Exclude loops generated from library macros
  not l = any(LibraryMacro lm).getAnInvocation().getAGeneratedElement() and
  condition = l.getCondition() and
  essentialType = getEssentialType(condition) and
  not getEssentialTypeCategory(essentialType) = EssentiallyBooleanType()
select condition, "Iteration condition has non boolean type " + essentialType + "."
