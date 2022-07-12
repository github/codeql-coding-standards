/**
 * @id cpp/autosar/avoid-duplication-in-constructors
 * @name A12-1-5: Common class initialization for non-constant members shall be done by a delegating constructor
 * @description Repeating initialization steps in multiple places is error prone and hard to
 *              maintain.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-1-5
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import InitializerHashCons as InitializerHashCons

/*
 * This query works by finding pairs of field assignments to the same field in different
 * constructors, where the assigned value is structurally equivalent.
 *
 * The CodeQL standard library provides the `semmle.code.cpp.valuenumbering.HashCons` library for
 * structural equivalence, which provides a `hashCons` predicate which produces a unique value for
 * each equivalent structure. For example, in:
 * ```
 * int x = i + 8;
 * int y = i + 8;
 * ```
 * The two `i + 8` expressions would report the same `hasCons` value.
 *
 * Unfortunately, it is not suitable for our use case, because we want to compare across different
 * constructors, and, critically, consider parameters to be equivalent. For example, in:
 * ```
 * class ClassA {
 * public:
 *   ClassA(int i1) m_i1(i1 + 8), m_i2(0) {}
 *   ClassA(int i1, int i2) m_i1(i1 + 8), m_i2(i2) {}
 * private:
 *   int m_i1;
 * };
 * ```
 * The two initializers of m_i1 do not have the same `hashCons` value, because the parameters are
 * different.
 *
 * We work around this by taking a copy of the standard library which is specialized to our use
 * case. In particular it is modified to consider any parameter access to be equivalent. This then
 * ensures the two initializers above have equivalent `hashCons` values.
 */

predicate isNonTrivialUserFieldAssignmentInConstructor(
  Class clazz, Constructor constructor, int constructorIndex, Field assignedField,
  Expr assignedValue
) {
  constructor = clazz.getAMember(constructorIndex) and
  assignedValue = assignedField.getAnAssignedValue() and
  assignedValue.getEnclosingFunction() = constructor and
  // Not constant
  not exists(assignedValue.getValue()) and
  // Non trivial
  not assignedValue.(VariableAccess).getTarget() instanceof Parameter and
  // Not compiler generated
  not assignedValue.isCompilerGenerated() and
  not constructor.isCompilerGenerated() and
  not exists(ConstructorInit init |
    init = constructor.getAnInitializer() and
    init.isCompilerGenerated() and
    init.getAChild*() = assignedValue
  )
}

from
  Field f, Class declaringClass, Constructor c1, Expr e1, Constructor c2, Expr e2, int index1,
  int index2
where
  // Exclude any cases where either the field or initializer expressions are marked as suppressed
  // for this rule
  not isExcluded(f, InitializationPackage::avoidDuplicationInConstructorsQuery()) and
  not isExcluded(e1, InitializationPackage::avoidDuplicationInConstructorsQuery()) and
  not isExcluded(e2, InitializationPackage::avoidDuplicationInConstructorsQuery()) and
  isNonTrivialUserFieldAssignmentInConstructor(declaringClass, c1, index1, f, e1) and
  isNonTrivialUserFieldAssignmentInConstructor(declaringClass, c2, index2, f, e2) and
  // c2 occurs after c1
  // This reduces duplication of results, and ensures that we don't report results from different
  // instantiations of the same template constructor
  index1 < index2 and
  // Field initializer expressions are structurally equal according to our specialized version of
  // `hashCons`
  InitializerHashCons::hashCons(e1) = InitializerHashCons::hashCons(e2)
select e1, "Assignment is a duplicate of $@ assignment.", e2, "this"
