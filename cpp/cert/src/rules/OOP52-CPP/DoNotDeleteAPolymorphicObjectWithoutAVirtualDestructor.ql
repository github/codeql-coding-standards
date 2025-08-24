/**
 * @id cpp/cert/do-not-delete-a-polymorphic-object-without-a-virtual-destructor
 * @name OOP52-CPP: Do not delete a polymorphic object without a virtual destructor
 * @description Deleting a polymorphic object without a virtual destructor through a pointer to its
 *              base type causes undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/oop52-cpp
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

// A polymorphic class that does not have a virtual destructor and is not 'final'
class PolymorphicClassWithoutVirtualDestructor extends PolymorphicClass {
  PolymorphicClassWithoutVirtualDestructor() {
    not this.isFinal() and
    not exists(Destructor d | d.getDeclaringType().refersTo(this) and d.isVirtual())
  }

  Expr getNonCompliantUsage() {
    // A cast, implicit or explicit, from a derived class to T
    exists(BaseClassConversion c | c.getBaseClass().refersTo(this) and result = c)
    or
    // Usage of pointer to type T in a method in class of type T in a delete operator
    // Example: 'delete this'
    exists(DeleteExpr de |
      not de.isCompilerGenerated() and
      de.getExpr().getType().refersTo(this) and
      de.getEnclosingFunction().getDeclaringType().refersTo(this) and
      result = de
    )
  }
}

from Expr expr, PolymorphicClassWithoutVirtualDestructor c
where
  not isExcluded(expr,
    InheritancePackage::doNotDeleteAPolymorphicObjectWithoutAVirtualDestructorQuery()) and
  expr = c.getNonCompliantUsage()
select expr, "Pointer to polymorphic object of type $@ calls non-virtual destructor if destructed.",
  c, c.getName()
