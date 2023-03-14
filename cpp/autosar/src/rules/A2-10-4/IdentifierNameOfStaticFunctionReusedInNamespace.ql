/**
 * @id cpp/autosar/identifier-name-of-static-function-reused-in-namespace
 * @name A2-10-4: Reuse of identifier name of a static function within a namespace
 * @description The identifier name of a static function shall not be reused within a namespace.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a2-10-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class CandidateFunction extends Function {
  CandidateFunction() {
    hasDefinition() and
    isStatic() and
    not isMember() and
    not (
      this instanceof TemplateFunction or
      this instanceof FunctionTemplateSpecialization or
      exists(TemplateFunction tf | this = tf.getAnInstantiation())
    )
  }
}

from CandidateFunction f1, CandidateFunction f2
where
  not isExcluded(f1, NamingPackage::identifierNameOfStaticFunctionReusedInNamespaceQuery()) and
  not isExcluded(f2, NamingPackage::identifierNameOfStaticFunctionReusedInNamespaceQuery()) and
  not f1 = f2 and
  f1.getQualifiedName() = f2.getQualifiedName()
select f2, "Static function $@ reuses identifier of $@", f2, f2.getName(), f1, f1.getName()
