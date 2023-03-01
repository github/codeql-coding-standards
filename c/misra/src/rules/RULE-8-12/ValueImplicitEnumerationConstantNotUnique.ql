/**
 * @id c/misra/value-implicit-enumeration-constant-not-unique
 * @name RULE-8-12: Within an enumerator list, the value of an implicitly-specified enumeration constant shall be unique
 * @description Using an implicitly specified enumeration constant that is not unique (with respect
 *              to an explicitly specified constant) can lead to unexpected program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-12
 *       correctness
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/**
 * An `EnumConstant` that has an implicitly specified value:
 * `enum e { explicit = 1, implicit }`
 */
class ImplicitlySpecifiedEnumConstant extends EnumConstant {
  ImplicitlySpecifiedEnumConstant() {
    //implicitly specified have an initializer with location: `file://:0:0:0:0`
    not this.getInitializer().getLocation().getFile() = this.getFile()
  }
}

from EnumConstant exp, ImplicitlySpecifiedEnumConstant imp
where
  not isExcluded(exp, Declarations7Package::valueImplicitEnumerationConstantNotUniqueQuery()) and
  not isExcluded(imp, Declarations7Package::valueImplicitEnumerationConstantNotUniqueQuery()) and
  not exp = imp and
  imp.getValue() = exp.getValue() and
  imp.getDeclaringEnum() = exp.getDeclaringEnum() and
  //can technically be the same declared enum across multiple headers but those are not relevant to this rule
  imp.getFile() = exp.getFile()
select imp, "Nonunique value of enum constant compared to $@", exp, exp.getName()
