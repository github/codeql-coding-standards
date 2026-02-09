/**
 * @id cpp/cert/copy-operations-must-not-mutate-the-source-object
 * @name OOP58-CPP: Copy operations must not mutate the source object
 * @description Copy operations must not mutate the source object.  This will violate copy
 *              post-conditions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop58-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Operator
import codingstandards.cpp.Constructor

class UserCopyOperation extends MemberFunction {
  UserCopyOperation() { this instanceof UserCopyOperator or this instanceof UserCopyConstructor }
}

predicate hasDirectFieldAssignment(UserCopyOperation u) {
  exists(Parameter p, FieldAccess fa, Assignment a |
    fa.getQualifier*().(VariableAccess).getTarget() = p.getDefinition().getVariable() and
    p.getFunction() = u and
    fa = a.getLValue()
  )
}

predicate isMutatedByFunctionCall(UserCopyOperation u) {
  exists(FunctionCall fc |
    fc.getAnArgument() = u.getACallToThisFunction().getAnArgument() and
    fc.getEnclosingFunction() = u and
    not fc.getTarget() instanceof ConstMemberFunction
  )
}

from UserCopyOperation u
where
  not isExcluded(u, OperatorInvariantsPackage::copyOperationsMustNotMutateTheSourceObjectQuery()) and
  isMutatedByFunctionCall(u)
  or
  hasDirectFieldAssignment(u)
select u, "Copy constructor or copy assignment operator mutates the source object."
