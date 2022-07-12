/**
 * @id cpp/autosar/object-assigned-to-an-overlapping-object
 * @name M0-2-1: An object shall not be assigned to an overlapping object
 * @description An object shall not be assigned to an overlapping object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m0-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

//Assignment between different active members of same union instance
import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

VariableAccess getAQualifier(VariableAccess va) { result = va.getQualifier+() }

int getAccessByteOffset(FieldAccess fa) {
  not fa.getQualifier() instanceof FieldAccess and result = fa.getTarget().getByteOffset()
  or
  result = fa.getTarget().getByteOffset() + getAccessByteOffset(fa.getQualifier())
}

predicate overlaps(FieldAccess fa1, FieldAccess fa2) {
  exists(int startfa1, int endfa1, int startfa2, int endfa2 |
    startfa1 = getAccessByteOffset(fa1) and
    endfa1 = startfa1 + fa1.getTarget().getType().getSize() - 1 and
    startfa2 = getAccessByteOffset(fa2) and
    endfa2 = startfa2 + fa2.getTarget().getType().getSize() - 1
  |
    startfa1 = startfa2 and endfa1 = endfa2
    or
    startfa1 > startfa2 and endfa1 < endfa2
    or
    startfa1 < startfa2 and endfa1 < endfa2 and endfa1 > startfa2
    or
    startfa1 > startfa2 and endfa1 > endfa2 and startfa1 < endfa2
  )
}

from AssignExpr assignExpr, Expr lhs, Expr rhs, ValueFieldAccess valuelhs, ValueFieldAccess valuerhs
where
  not isExcluded(assignExpr, RepresentationPackage::objectAssignedToAnOverlappingObjectQuery()) and
  lhs.getType() instanceof Union and
  rhs.getType() instanceof Union and
  lhs = getAQualifier(assignExpr.getLValue()) and
  rhs = getAQualifier(assignExpr.getRValue()) and
  globalValueNumber(lhs) = globalValueNumber(rhs) and
  valuerhs = assignExpr.getRValue() and
  valuelhs = assignExpr.getLValue() and // a.b.c == ((a.b).c)
  overlaps(valuelhs, valuerhs)
select assignExpr, "An object $@ assigned to overlapping object $@.", valuelhs,
  valuelhs.getTarget().getName(), valuerhs, valuerhs.getTarget().getName()
