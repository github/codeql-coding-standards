/**
 * @id c/cert/do-not-modify-constant-objects
 * @name EXP40-C: Do not modify constant objects
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp40-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, Contracts6Package::doNotModifyConstantObjectsQuery()) and
select
