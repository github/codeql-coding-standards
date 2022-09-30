/**
 * @id cpp/autosar/non-virtual-public-or-protected-functions-redefined
 * @name A10-2-1: Non-virtual public or protected member functions shall not be redefined in derived classes
 * @description A non-virtual member function that is hidden defeats polymorphism and causes
 *              unnecessary errors and/or complex behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a10-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

Class getPublicOrPrivateDerivedClass(Class c) {
  result.hasPublicBaseClass(c)
  or
  result.hasProtectedBaseClass(c)
}

from MemberFunction f, Element e, string description, Class subclass
where
  not f.isVirtual() and
  (f.isPublic() or f.isProtected()) and
  not f instanceof Operator and
  (
    exists(MemberFunction shadowingFunction |
      getPublicOrPrivateDerivedClass+(f.getDeclaringType()) = subclass and
      f.getName() = pragma[only_bind_out](shadowingFunction.getName()) and
      e = shadowingFunction and
      description = "this member function" and
      subclass = shadowingFunction.getDeclaringType()
    )
    or
    exists(MemberVariable shadowingVariable |
      getPublicOrPrivateDerivedClass+(f.getDeclaringType()) = shadowingVariable.getDeclaringType() and
      f.getName() = shadowingVariable.getName() and
      e = shadowingVariable and
      description = "this member variable" and
      subclass = shadowingVariable.getDeclaringType()
    )
  )
select f, "Member function $@ is shadowed by $@ in derived class $@", f, f.getName(), e,
  description, subclass, subclass.getName()
