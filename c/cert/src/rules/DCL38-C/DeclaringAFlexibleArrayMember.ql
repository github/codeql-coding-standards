/**
 * @id c/cert/declaring-a-flexible-array-member
 * @name DCL38-C: Use the correct syntax when declaring a flexible array member
 * @description Structures with flexible array members can be declared in ways that will lead to
 *              undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl38-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * A member with the type array that is last in a struct
 * includes any sized array (either specified or not)
 */
class FlexibleArrayMember extends MemberVariable {
  Struct s;

  FlexibleArrayMember() {
    this.getType() instanceof ArrayType and
    this.getDeclaringType() = s and
    not exists(int i, int j |
      s.getAMember(i) = this and
      exists(s.getAMember(j)) and
      j > i
    )
  }
}

from VariableDeclarationEntry m, ArrayType a
where
  not isExcluded(m, Declarations2Package::declaringAFlexibleArrayMemberQuery()) and
  m.getType() = a and
  m.getVariable() instanceof FlexibleArrayMember and
  a.getArraySize() = 1
select m, "Incorrect syntax used for declaring this flexible array member."
