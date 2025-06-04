/**
 * Helper predicates related to C11/C17 constraints on simple assignment between two types.
 *
 * Currently only a subset of the constraints are implemented, specifically those
 * related to pointer types.
 */

import codingstandards.cpp.types.LvalueConversion
import codingstandards.cpp.types.Compatible

module SimpleAssignment<interestedInEquality/2 checksAssignment> {
  /**
   * Whether a pair of qualified or unqualified pointer types satisfy the simple assignment
   * constraints from 6.5.16.1.
   *
   * There are additional constraints not implemented here involving one or more arithmetic types.
   */
  predicate satisfiesSimplePointerAssignment(Type left, Type right) {
    checksAssignment(left, right) and
    simplePointerAssignmentImpl(getLvalueConverted(left), right)
  }

  private predicate satisfiedWhenTypesCompatible(Type left, Type right, Type checkA, Type checkB) {
    interestedInTypes(left, right) and
    exists(Type leftBase, Type rightBase |
      // The left operand has atomic, qualified, or unqualified pointer type:
      leftBase = left.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      rightBase = right.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      (
        // and both operands are pointers to qualified or unqualified versions of compatible types:
        checkA = leftBase.stripTopLevelSpecifiers() and
        checkB = rightBase.stripTopLevelSpecifiers()
      ) and
      // and the type pointed to by the left has all the qualifiers of the type pointed to by the
      // right:
      forall(Specifier s | s = rightBase.getASpecifier() | s = leftBase.getASpecifier())
    )
  }

  predicate interestedInTypes(Type left, Type right) {
    exists(Type unconverted |
      left = getLvalueConverted(unconverted) and
      checksAssignment(unconverted, right)
    )
  }

  predicate checksCompatibility(Type left, Type right) {
    // Check if the types are compatible
    exists(Type assignA, Type assignB |
      checksAssignment(assignA, assignB) and
      satisfiedWhenTypesCompatible(assignA, assignB, left, right)
    )
  }

  /**
   * Implementation of 6.5.16.1 for a pair of pointer types, that assumes lvalue conversion has been
   * performed on the left operand.
   */
  bindingset[left, right]
  private predicate simplePointerAssignmentImpl(Type left, Type right) {
    exists(Type checkA, Type checkB |
      satisfiedWhenTypesCompatible(left, right, checkA, checkB) and
      TypeEquivalence<TypesCompatibleConfig, checksCompatibility/2>::equalTypes(checkA, checkB)
    )
    or
    exists(Type leftBase, Type rightBase |
      // The left operand has atomic, qualified, or unqualified pointer type:
      leftBase = left.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      rightBase = right.stripTopLevelSpecifiers().(PointerType).getBaseType() and
      // or one operand is a pointer to a qualified or unqualified version of void
      [leftBase, rightBase].stripTopLevelSpecifiers() instanceof VoidType and
      // and the type pointed to by the left has all the qualifiers of the type pointed to by the
      // right:
      forall(Specifier s | s = rightBase.getASpecifier() | s = leftBase.getASpecifier())
    )
  }
}
