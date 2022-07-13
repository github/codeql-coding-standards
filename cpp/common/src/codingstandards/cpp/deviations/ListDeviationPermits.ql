/**
 * @id cpp/coding-standards/list-deviation-permits
 * @kind table
 * @name List all deviation permits observed in a database
 * @description Lists all the deviation permits that were indexed in the database.
 */

import cpp
import Deviations

from DeviationPermit dp, string automatedScope
where
  if dp.hasCodeIdentifier()
  then
    automatedScope =
      "Identified by the use of the code-identifier: " + dp.getCodeIdentifier() +
        " and associated deviation records"
  else automatedScope = "Application depends on the associated deviation records"
select dp.getPermitId(), dp.getRuleId(), dp.getQueryId(), automatedScope, dp.getScope(),
  dp.getJustification(), dp.getBackground(), dp.getRequirements()
