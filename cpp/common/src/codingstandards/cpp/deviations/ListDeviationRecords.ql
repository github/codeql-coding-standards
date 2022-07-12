/**
 * @id cpp/coding-standards/list-deviation-records
 * @kind table
 * @name List all deviation records observed in a database
 * @description Lists all the deviation records that were indexed in the database.
 */

import cpp
import Deviations

from DeviationRecord dr, Query q, string automatedScope
where
  dr.getQuery() = q and
  if exists(dr.getADeviationPath())
  then
    automatedScope = "Applies to the following file paths: " + concat(dr.getADeviationPath(), ",")
  else automatedScope = "Identified by the use of the code-identifier: " + dr.getCodeIdentifier()
select q.getRuleId(), q.getQueryId(), automatedScope, dr.getScope(), dr.getJustification(),
  dr.getBackground(), dr.getRequirements()
