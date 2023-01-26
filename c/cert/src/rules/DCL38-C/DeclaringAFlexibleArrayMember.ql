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
import codingstandards.c.Variable

from VariableDeclarationEntry m, ArrayType a
where
  not isExcluded(m, Declarations2Package::declaringAFlexibleArrayMemberQuery()) and
  m.getType() = a and
  m.getVariable() instanceof FlexibleArrayMemberCandidate and
  a.getArraySize() = 1
select m, "Incorrect syntax used for declaring this flexible array member."
