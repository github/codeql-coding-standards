/**
 * @id cpp/misra/unscoped-enumerations-should-not-be-declared
 * @name RULE-10-2-2: Unscoped enumerations should not be declared
 * @description An unscoped enumeration should not be used outside of a class/struct scope; use
 *              'enum class' instead to prevent name clashes and implicit conversions to integral
 *              types.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-2-2
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

class MemberUnscopedEnum extends Enum {
  MemberUnscopedEnum() {
    not this instanceof ScopedEnum and
    exists(Class klass | klass = this.getEnclosingElement())
  }
}

from Enum enum
where
  not isExcluded(enum, Banned2Package::unscopedEnumerationsShouldNotBeDeclaredQuery()) and
  not (enum instanceof ScopedEnum or enum instanceof MemberUnscopedEnum)
select enum, "This enumeration is an unscoped enum not enclosed in a class or a struct."
