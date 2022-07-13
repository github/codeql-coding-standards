/**
 * @id cpp/autosar/move-constructor-uses-copy-semantics
 * @name A12-8-4: Move constructor shall not initialize its class members and base classes using copy semantics
 * @description Using copying semantics in move constructors can have a performance penalty, and is
 *              contrary to developer expectations.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a12-8-4
 *       maintainability
 *       performance
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TrivialType

/**
 * A literal with no values.
 */
class UnknownLiteral extends Literal {
  UnknownLiteral() { not exists(getValue()) }
}

from MoveConstructor c, Field f, Expr e
where
  not isExcluded(f, InitializationPackage::moveConstructorUsesCopySemanticsQuery()) and
  not isExcluded(e, InitializationPackage::moveConstructorUsesCopySemanticsQuery()) and
  f.getAnAssignedValue() = e and
  e.getEnclosingFunction() = c and
  // No need to move initialize scalar types
  not isScalarType(f.getType()) and
  not (
    // It is correctly move initialized if it calls the appropriate move constructor
    e.getFullyConverted().(ConstructorCall).getTarget() instanceof MoveConstructor
    or
    // ... or it's an rvalue reference, and the type of the field has a trivial
    // move constructor (which was omitted from the database)
    e.getType() instanceof RValueReferenceType and
    hasTrivialMoveConstructor(f.getType())
  ) and
  // Compiler generated or default move constructors should be valid (and are not under the remit of the user)
  not c.isCompilerGenerated() and
  not c.isDefaulted() and
  // Ignore uninstantiated templates, as they may not have a complete semantic representation
  not c.isFromUninstantiatedTemplate(_) and
  // `UnknownLiteral`s typically appear in compiler generated functions, and represent unknowns,
  // so are unfair to flag
  not e instanceof UnknownLiteral
select e,
  "Move constructor for " + c.getDeclaringType().getSimpleName() + " initializes " + f.getName() +
    " with copy semantics."
