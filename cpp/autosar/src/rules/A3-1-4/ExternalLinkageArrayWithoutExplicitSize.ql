/**
 * @id cpp/autosar/external-linkage-array-without-explicit-size
 * @name A3-1-4: When an array with external linkage is declared, its size shall be stated explicitly
 * @description A developer can more safely access the elements of an array if the size of the array
 *              can be explicitly determined.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-4
 *       correctness
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class ArrayDeclarationEntry extends VariableDeclarationEntry {
  ArrayDeclarationEntry() { this.getUnspecifiedType() instanceof ArrayType }

  predicate hasExplicitSize() {
    exists(ArrayType at | at = this.getUnspecifiedType() | at.hasArraySize())
  }
}

from ArrayDeclarationEntry ade
where
  // We only consider extern specified arrays because we can't determine the size of an incomplete object
  // which makes it difficult to access its element in a safe way.
  ade.hasSpecifier("extern") and
  not isExcluded(ade, ScopePackage::externalLinkageArrayWithoutExplicitSizeQuery()) and
  not ade.hasExplicitSize()
select ade,
  "The declared array '" + ade.getName() +
    "' with external linkage doesn't specify the size explicitly."
