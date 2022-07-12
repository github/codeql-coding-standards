/**
 * @id cpp/autosar/member-function-static-if-possible
 * @name M9-3-3: A member function shall be made static where possible
 * @description Using `static` specifiers for member functions where possible prevents unintentional
 *              data modification (and therefore unintentional program behaviour).
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m9-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * `MemberFunction`s that are not static
 * and not already const
 * and not `Constructor`s as static constructors are
 * not a thing in cpp
 */
class NonStaticMemberFunction extends MemberFunction {
  NonStaticMemberFunction() {
    not this.isStatic() and
    not this.hasSpecifier("const") and
    //leave compiler generateds and operators and constructors alone
    not this.isCompilerGenerated() and
    not this instanceof Constructor and
    not this instanceof Destructor and
    not this instanceof Operator and
    this.hasDefinition()
  }
}

from NonStaticMemberFunction nonstatic
where
  not isExcluded(nonstatic, ConstPackage::memberFunctionStaticIfPossibleQuery()) and
  not exists(ThisExpr t | t.getEnclosingFunction() = nonstatic) and
  not nonstatic.isVirtual()
select nonstatic, "Member function can be declared as static."
