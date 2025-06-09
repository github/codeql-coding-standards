/**
 * @id cpp/cert/do-not-slice-derived-objects
 * @name OOP51-CPP: Do not slice derived objects
 * @description By-value assignment or copying an object of a derived type to a base type can result
 *              in derived member variables not being copied.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop51-cpp
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

class NonReferenceOrPointerBaseClassConversion extends BaseClassConversion {
  NonReferenceOrPointerBaseClassConversion() {
    not this.getUnconverted().getType() instanceof ReferenceType and
    not this.getUnconverted().getType() instanceof PointerType
  }
}

private Expr getConvertedConstructorCallExpression(ConstructorCall cc) {
  // the first argument's expression, if an implicit conversion from T to T& occurs
  result = cc.getArgument(0).getFullyConverted().(ReferenceToExpr).getExpr()
}

private Type getUnconvertedConstructorCallExpressionType(ConstructorCall cc) {
  if cc.getArgument(0) instanceof ConstructorCall
  then
    // when the first argument of the constructor call is another constructor call, then
    // the unconverted expression type is simply the 'Class' of the constructor being called
    result = cc.getArgument(0).(ConstructorCall).getTargetType()
  else
    // get the type of the non-conversion expression of the implicit conversion
    // of T to T& within the first argument of the constructor call
    result =
      cc.getArgument(0).getFullyConverted().(ReferenceToExpr).getExpr().getUnconverted().getType()
}

/**
 * A call to a constructor which assigns a derived object to an object of its base type
 * when the derived object defines member variables not defined by its base class
 */
class SlicingConstructorCall extends ConstructorCall {
  SlicingConstructorCall() {
    getConvertedConstructorCallExpression(this) instanceof NonReferenceOrPointerBaseClassConversion and
    this.getTargetType()
        .refersTo(any(Class base, Class derived |
            base = derived.getABaseClass+() and exists(derived.getAMemberVariable())
          |
            base
          ))
  }

  Type getConvertedExpressionType() {
    result = getConvertedConstructorCallExpression(this).getType()
  }

  Type getUnconvertedExpressionType() { result = getUnconvertedConstructorCallExpressionType(this) }
}

from SlicingConstructorCall scc
where not isExcluded(scc, InheritancePackage::doNotSliceDerivedObjectsQuery())
select scc, "Derived object sliced from type $@ to base $@.",
  scc.getUnconvertedExpressionType().stripType(),
  scc.getUnconvertedExpressionType().stripType().getName(),
  scc.getConvertedExpressionType().stripType(),
  scc.getConvertedExpressionType().stripType().getName()
