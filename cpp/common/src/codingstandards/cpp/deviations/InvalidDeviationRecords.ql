/**
 * @id cpp/coding-standards/invalid-deviations
 * @name Invalid deviations
 * @description Deviation records marked as invalid will not be applied.
 */

import cpp
import Deviations

from DeviationRecord dr
select dr, dr.getFile().getRelativePath() + ": " + dr.getAnInvalidRecordReason()
