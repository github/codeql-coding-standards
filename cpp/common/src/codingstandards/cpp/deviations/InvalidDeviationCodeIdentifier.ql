/**
 * @id cpp/coding-standards/invalid-deviation-code-identifiers
 * @name Invalid deviation code identifiers
 * @description Deviation code identifiers must be valid.
 * @kind problem
 * @problem.severity error
 */

import cpp
import CodeIdentifierDeviation

predicate deviationCodeIdentifierError(Element e, string message) {
  exists(DeviationEnd end |
    e = end and
    not isDeviationRangePaired(_, _, end) and
    message = "Deviation end block is unmatched."
  )
  or
  exists(DeviationBegin begin |
    e = begin and
    not isDeviationRangePaired(_, begin, _) and
    message = "Deviation start block is unmatched."
  )
  or
  exists(InvalidDeviationAttribute b |
    e = b and
    message =
      "Deviation attribute references unknown code identifier " + b.getAnUnknownCodeIdentifier() +
        "."
  )
  or
  exists(InvalidCommentDeviationMarker m |
    e = m and
    message =
      "Deviation marker does not match an expected format, or references an unknown code identifier."
  )
}

from Element e, string message
where deviationCodeIdentifierError(e, message)
select e, message
