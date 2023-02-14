/**
 * @id c/misra/operands-of-an-inappropriate-essential-type
 * @name RULE-10-1: Operands shall not be of an inappropriate essential type
 * @description Using an inappropriate essential type operand may lead to confusing or unexpected
 *              behavior when the operand is converted.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-1
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

/**
 * Holds if the operator `operator` has an operand `child` that is of an inappropriate essential type
 * according to MISRA C 2012 Rule 10.1.
 */
predicate isInappropriateEssentialType(
  Expr operator, Expr child, EssentialTypeCategory etc, int rationaleId
) {
  etc = getEssentialTypeCategory(getEssentialType(child)) and
  (
    child = operator.(ArrayExpr).getArrayOffset() and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 1
    )
    or
    child = operator.(UnaryPlusExpr).getOperand() and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 5
    )
    or
    child = operator.(UnaryMinusExpr).getOperand() and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 5
      or
      etc = EssentiallyUnsignedType() and
      rationaleId = 8
    )
    or
    // The table only talks about + and -, but below it clarifies ++ and -- are also considered to
    // be equivalent.
    child =
      [
        operator.(AddExpr).getAnOperand(), operator.(SubExpr).getAnOperand(),
        operator.(IncrementOperation).getAnOperand(), operator.(DecrementOperation).getAnOperand(),
        operator.(AssignAddExpr).getAnOperand(), operator.(AssignSubExpr).getAnOperand()
      ] and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyEnumType() and
      rationaleId = 5
    )
    or
    child =
      [
        operator.(DivExpr).getAnOperand(), operator.(MulExpr).getAnOperand(),
        operator.(AssignDivExpr).getAnOperand(), operator.(AssignMulExpr).getAnOperand()
      ] and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 5
    )
    or
    child = [operator.(RemExpr).getAnOperand(), operator.(AssignRemExpr).getAnOperand()] and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 5
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 1
    )
    or
    child = operator.(RelationalOperation).getAnOperand() and
    etc = EssentiallyBooleanType() and
    rationaleId = 3
    or
    child = [operator.(NotExpr).getAnOperand(), operator.(BinaryLogicalOperation).getAnOperand()] and
    rationaleId = 2 and
    (
      etc = EssentiallyCharacterType()
      or
      etc = EssentiallyEnumType()
      or
      etc = EssentiallySignedType()
      or
      etc = EssentiallyUnsignedType()
      or
      etc = EssentiallyFloatingType()
    )
    or
    child =
      [
        operator.(LShiftExpr).getLeftOperand(), operator.(RShiftExpr).getLeftOperand(),
        operator.(AssignLShiftExpr).getLValue(), operator.(AssignRShiftExpr).getLValue()
      ] and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 6 // 5 also applies, but 6 is sufficient explanation
      or
      etc = EssentiallySignedType() and
      rationaleId = 6
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 1
    )
    or
    child =
      [
        operator.(LShiftExpr).getRightOperand(), operator.(RShiftExpr).getRightOperand(),
        operator.(AssignLShiftExpr).getRValue(), operator.(AssignRShiftExpr).getRValue()
      ] and
    // Integer constant non negative essentially signed types are allowed by exception
    not (child.getValue().toInt() >= 0 and etc = EssentiallySignedType()) and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 7
      or
      etc = EssentiallySignedType() and
      rationaleId = 7
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 1
    )
    or
    child =
      [
        operator.(BinaryBitwiseOperation).getAnOperand(),
        operator.(AssignBitwiseOperation).getAnOperand()
      ] and
    not operator instanceof LShiftExpr and
    not operator instanceof RShiftExpr and
    not operator instanceof AssignLShiftExpr and
    not operator instanceof AssignRShiftExpr and
    (
      etc = EssentiallyBooleanType() and
      rationaleId = 3
      or
      etc = EssentiallyCharacterType() and
      rationaleId = 4
      or
      etc = EssentiallyEnumType() and
      rationaleId = 6
      or
      etc = EssentiallySignedType() and
      rationaleId = 6
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 1
    )
    or
    child = operator.(ConditionalExpr).getCondition() and
    (
      etc = EssentiallyCharacterType() and
      rationaleId = 2
      or
      etc = EssentiallyEnumType() and
      rationaleId = 2
      or
      etc = EssentiallySignedType() and
      rationaleId = 2
      or
      etc = EssentiallyUnsignedType() and
      rationaleId = 2
      or
      etc = EssentiallyFloatingType() and
      rationaleId = 2
    )
  )
}

string getRationaleMessage(int rationaleId, EssentialTypeCategory etc) {
  rationaleId = 1 and
  result = "Constraint violation from using an operand of essentially Floating type."
  or
  rationaleId = 2 and result = "Operand of " + etc + " type interpreted as a Boolean value."
  or
  rationaleId = 3 and result = "Operand of essentially Boolean type interpreted as a numeric value."
  or
  rationaleId = 4 and
  result = "Operand of essentially Charater type interpreted as a numeric value."
  or
  rationaleId = 5 and
  result =
    "Operand of essentially Enum type used in arithmetic operation, but has an implementation defined integer type."
  or
  rationaleId = 6 and
  result = "Bitwise operator applied to operand of " + etc + " and not essentially unsigned."
  or
  rationaleId = 7 and
  result = "Right hand operatand of shift operator is " + etc + " and not not essentially unsigned."
  or
  rationaleId = 8 and
  result =
    "Operand of essentially Unsigned type will be converted to a signed type with the signedness dependent on the implemented size of int."
}

from Expr operator, Expr child, int rationaleId, EssentialTypeCategory etc
where
  not isExcluded(operator, EssentialTypesPackage::operandsOfAnInappropriateEssentialTypeQuery()) and
  isInappropriateEssentialType(operator, child, etc, rationaleId)
select operator, getRationaleMessage(rationaleId, etc)
