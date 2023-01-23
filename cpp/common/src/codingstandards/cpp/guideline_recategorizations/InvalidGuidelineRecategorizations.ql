/**
 * @id cpp/coding-standards/invalid-guideline-recategorizations
 * @name Invalid guideline recategorizations
 * @description Guideline recategorizations marked as invalid will not be applied.
 */

import cpp
import GuidelineRecategorizations

from GuidelineRecategorization gr
select gr,
  gr.getFile().getRelativePath() + ": '" + gr.getAnInvalidReason() + "' for rule " + gr.getRuleId() +
    "."
