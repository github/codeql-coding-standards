/**
 * @id c/misra/atomic-aggregate-object-directly-accessed
 * @name RULE-12-6: Structure and union members of atomic objects shall not be directly accessed
 * @description Accessing a member of an atomic structure or union results in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-6
 *       external/misra/c/2012/amendment4
 *       correctness
 *       concurrency
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Expr expr, Field field
where
  not isExcluded(expr, Concurrency6Package::atomicAggregateObjectDirectlyAccessedQuery()) and
  not expr.isUnevaluated() and
  (
    exists(FieldAccess fa |
      expr = fa and
      fa.getQualifier().getType().hasSpecifier("atomic") and
      field = fa.getTarget()
    )
    or
    exists(PointerFieldAccess fa |
      expr = fa and
      fa.getQualifier()
          .getType()
          .stripTopLevelSpecifiers()
          .(PointerType)
          .getBaseType()
          .hasSpecifier("atomic") and
      field = fa.getTarget()
    )
  )
select expr, "Invalid access to member '$@' on atomic struct or union.", field, field.getName()
