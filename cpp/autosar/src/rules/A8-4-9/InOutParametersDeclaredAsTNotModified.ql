/**
 * @id cpp/autosar/in-out-parameters-declared-as-t-not-modified
 * @name A8-4-9: 'in-out' parameters declared as T & shall be modified
 * @description Parameters declared as `T &` are intended to be modified (or else they would be
 *              specified to be read-only) and not modifiying them indicate a possible mistake on
 *              the part of the programmer.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-4-9
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionParameter
import codingstandards.cpp.ConstHelpers
import codingstandards.cpp.Operator

/**
 * Non-const T& `Parameter`s to `Function`s
 */
class NonConstReferenceParameterCandidate extends FunctionParameter {
  NonConstReferenceParameterCandidate() { this instanceof NonConstReferenceParameter }
}

from NonConstReferenceParameterCandidate p, string condition
where
  not isExcluded(p, ConstPackage::inOutParametersDeclaredAsTNotModifiedQuery()) and
  not exists(Call call |
    call.getEnclosingFunction() = p.getFunction() and
    exists(int idx |
      call.getArgument(idx) = p.getAnAccess() and
      not call.getTarget().getParameter(idx).getType().(DerivedType).getBaseType*().isConst() and
      call.getTarget().getParameter(idx).getType() instanceof ReferenceType
    )
  ) and
  (
    //read and not written
    exists(p.getAnAccess()) and
    not exists(VariableEffect ve | ve.getTarget() = p) and
    // Exclusion that we cannot track with `VariableEffect`.
    not exists(ConstructorCall call, Parameter parameter, int index |
      DataFlow::localExprFlow(p.getAnAccess(), call.getArgument(index)) and
      call.getTarget().getParameter(index) = parameter and
      not parameter.isConst()
    ) and
    // Call to nonconst operator of param's type is present
    not exists(Call call |
      call.getTarget() instanceof Operator and
      call.getEnclosingFunction() = p.getFunction() and
      call.getTarget().getDeclaringType() = p.getUnspecifiedType().(ReferenceType).getBaseType() and
      not call.getTarget().hasSpecifier("const")
    ) and
    //also not having a nonconst member accessed through the param
    notUsedAsQualifierForNonConst(p) and
    not exists(ClassAggregateLiteral l, Field f |
      DataFlow::localExprFlow(p.getAnAccess(), l.getFieldExpr(f)) and
      not f.isConst()
    ) and
    // Exclude parameters that are used to initialize member fields.
    not exists(ConstructorFieldInit cfi | cfi.getExpr() = p.getAnAccess()) and
    condition = "written to"
    or
    //written and not read
    forex(VariableAccess va | va.getTarget() = p |
      exists(VariableEffect ve |
        ve.getAnAccess() = va and
        // exclude assign operations, because the arguable also read the variable
        not ve instanceof AnyAssignOperation and
        not ve instanceof CrementOperation
      )
    ) and
    condition = "read from"
    or
    //not accessed (ie not written and not read)
    not exists(p.getAnAccess()) and
    condition = "used"
  )
select p, "In-out parameter " + p.getName() + " that is not " + condition + "."
