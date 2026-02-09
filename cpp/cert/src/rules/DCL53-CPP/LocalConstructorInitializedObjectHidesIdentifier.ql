/**
 * @id cpp/cert/local-constructor-initialized-object-hides-identifier
 * @name DCL53-CPP: Do not declare local identifiers that shadow an in scope identifier
 * @description An object declaration that declares an identifier that shadows an existing
 *              identifier relies on ambiguous syntax when initialized by a constructor and could
 *              lead to unintended behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl53-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Scope

from UserVariable v, UserVariable hidden
where
  not isExcluded(v, ScopePackage::localConstructorInitializedObjectHidesIdentifierQuery()) and
  v.getInitializer().getExpr() instanceof ConstructorCall and
  hidesStrict(hidden, v)
select v, "The declaration declares variable " + v.getName() + " that hides $@", hidden,
  hidden.getName()
