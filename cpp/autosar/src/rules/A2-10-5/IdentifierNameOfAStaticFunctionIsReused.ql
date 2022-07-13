/**
 * @id cpp/autosar/identifier-name-of-a-static-function-is-reused
 * @name A2-10-5: Reuse of identifier that identifies an internally linked function
 * @description An identifier name of a function with internal linkage not be reused anywhere in the
 *              source code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-10-5
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

class StaticFunction extends TopLevelFunction {
  StaticFunction() {
    this.isStatic() and
    not (
      this instanceof TemplateFunction or
      this instanceof FunctionTemplateSpecialization or
      exists(TemplateFunction f | this = f.getAnInstantiation())
    )
  }
}

from StaticFunction f1, StaticFunction f2
where
  not isExcluded(f1, NamingPackage::identifierNameOfAStaticFunctionIsReusedQuery()) and
  not isExcluded(f2, NamingPackage::identifierNameOfAStaticFunctionIsReusedQuery()) and
  not f1 = f2 and
  f1.getName() = f2.getName()
select f1, "Identifier name of static function $@ reuses identifier name of static function $@", f1,
  f1.getName(), f2, f2.getName()
