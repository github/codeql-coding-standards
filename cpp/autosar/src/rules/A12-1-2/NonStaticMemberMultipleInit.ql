/**
 * @id cpp/autosar/non-static-member-multiple-init
 * @name A12-1-2: Both non-static data member initialization and a non-static member initializer in a constructor shall not be used in the same type
 * @description Using both non-static data member initialization and non static member initializers
 *              can cause confusion over which values are used.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-1-2
 *       correctness
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from MemberVariable mv, ConstructorFieldInit cfi
where
  not isExcluded(mv, InitializationPackage::nonStaticMemberMultipleInitQuery()) and
  exists(mv.getInitializer()) and
  cfi.getTarget() = mv and
  not cfi.isCompilerGenerated()
select mv,
  "Member variable " + mv.getName() +
    " is initialized using NSDMI, but is also explicitly initialized in this $@.", cfi,
  "constructor"
