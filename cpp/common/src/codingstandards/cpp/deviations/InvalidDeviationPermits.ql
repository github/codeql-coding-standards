/**
 * @id cpp/coding-standards/invalid-deviation-permits
 * @name Invalid deviation permits
 * @description Deviation permits marked as invalid will not be applied.
 * @kind problem
 */

import cpp
import Deviations

from DeviationPermit dp
select dp, dp.getFile().getRelativePath() + ": " + dp.getAnInvalidPermitReason()
