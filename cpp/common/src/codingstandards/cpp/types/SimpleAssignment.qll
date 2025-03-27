/**
 * Helper predicates related to C11/C17 constraints on simple assignment between two types.
 *
 * Currently only a subset of the constraints are implemented, specifically those
 * related to pointer types.
 */

import codingstandards.cpp.types.LvalueConversion
import codingstandards.cpp.types.Compatible

module SimpleAssignment<TypeSubset T> {
  final private class FinalType = Type;

  private class RelevantType extends FinalType {
    RelevantType() { exists(T t | typeGraph*(t, this) or typeGraph(getLvalueConverted(t), this)) }

    string toString() { result = "relevant type" }
  }

  /**
   * Whether a pair of qualified or unqualified pointer types satisfy the simple assignment
   * constraints from 6.5.16.1.
   *
   * There are additional constraints not implemented here involving one or more arithmetic types.
   */
  predicate satisfiesSimplePointerAssignment(RelevantType left, RelevantType right) {
    simplePointerAssignmentImpl(getLvalueConverted(left), right)
  }

  /**
   * Implementation of 6.5.16.1 for a pair of pointer types, that assumes lvalue conversion has been
   * performed on the left operand.
   */
  private predicate simplePointerAssignmentImpl(RelevantType left, RelevantType right) {
    exists(RelevantType leftBase, RelevantType rightBase |
      // The left operand has atomic, qualified, or unqualified pointer type:
      leftBase = left.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      rightBase = right.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      (
        // and both operands are pointers to qualified or unqualified versions of compatible types:
        TypeEquivalence<TypesCompatibleConfig, RelevantType>::equalTypes(leftBase
              .stripTopLevelSpecifiers(), rightBase.stripTopLevelSpecifiers())
        or
        // or one operand is a pointer to a qualified or unqualified version of void
        [leftBase, rightBase].stripTopLevelSpecifiers() instanceof VoidType
      ) and
      // and the type pointed to by the left has all the qualifiers of the type pointed to by the
      // right:
      forall(Specifier s | s = rightBase.getASpecifier() | s = leftBase.getASpecifier())
    )
  }
}
