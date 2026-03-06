/**
 * @id cpp/misra/implicit-declaration-of-copy-constructor-audit
 * @name RULE-4-1-2: Implicit declaration of copy constructors is a deprecated language feature should not be used
 * @description Deprecated language features such as implicit declarations of copy constructors are
 *              only supported for backwards compatibility; these are considered bad practice, or
 *              have been superseded by better alternatives.
 * @kind problem
 * @precision low
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       external/misra/audit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.ImplicitSpecialMemberFunctions

from Class c, string specialMemberName
where
  not isExcluded(c, Toolchain3Package::implicitDeclarationOfCopyConstructorAuditQuery()) and
  (
    c instanceof MayHaveDeprecatedCopyConstructor and
    not c instanceof MustHaveDeprecatedCopyConstructor and
    specialMemberName = "copy constructor"
    or
    c instanceof MayHaveDeprecatedCopyAssignmentOperator and
    not c instanceof MustHaveDeprecatedCopyAssignmentOperator and
    specialMemberName = "copy assignment operator"
  )
select c, "Class '" + c.getName() + "' may have a deprecated implicit " + specialMemberName + "."
