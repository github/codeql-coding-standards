/**
 * @id cpp/autosar/iterator-implicitly-converted-to-const-iterator
 * @name A23-0-1: An iterator shall not be implicitly converted to const_iterator
 * @description Assigning directly to a `const_iterator` can remove implicit conversions.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a23-0-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Iterators

/*
 *  Due to inconsistent typedefs across STL containers the way this is parsed
 *  is slightly different from container to container.
 *
 *  For example, take the first 10 initializers in `test.cpp`. In this case:
 *
 *   | var | Variable.getAnAssignedValue()
 *   --------------------------------
 *   i1	  | call to cbegin
 *   i2	  | call to __normal_iterator
 *   i3	  | call to cbegin
 *   i4	  | call to begin
 *   i5	  | call to cbegin
 *   i6	  | call to begin
 *   i7	  | call to cbegin
 *   i8	  | call to _Rb_tree_const_iterator
 *   i9	  | call to cbegin
 *   i10	| call to _Rb_tree_const_iterator
 *
 *   Writing the check for `begin/end` above allows the same logic to be used for
 *   all container cases.
 */

from ConstIteratorVariable v, STLContainer c, Expr e
where
  not isExcluded(v) and
  not isExcluded(e) and
  e = v.getAnAssignedValue() and
  e.getAChild*() = /* see note at top of query */ c.getANonConstIteratorFunctionCall()
select e, "Non-const version of container call immediately converted to a `const_iterator`."
