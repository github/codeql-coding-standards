/**
 * Provides a library with a `problems` predicate for the following issue:
 * Within an enumerator list, the value of an implicitly-specified enumeration constant
 * shall be unique.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonUniqueEnumerationConstantSharedQuery extends Query { }

Query getQuery() { result instanceof NonUniqueEnumerationConstantSharedQuery }

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

query predicate problems(
  ImplicitlySpecifiedEnumConstant imp, string message, EnumConstant exp, string exp_string
) {
  not isExcluded(imp, getQuery()) and
  not isExcluded(exp, getQuery()) and
  not exp = imp and
  imp.getValue() = exp.getValue() and
  imp.getDeclaringEnum() = exp.getDeclaringEnum() and
  //can technically be the same declared enum across multiple headers but those are not relevant to this rule
  imp.getFile() = exp.getFile() and
  message = "Nonunique value of enum constant compared to $@" and
  exp_string = exp.getName()
}
