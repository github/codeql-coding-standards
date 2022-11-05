/**
 * @id cpp/coding-standards/list-guideline-recategorizations
 * @kind table
 * @name List all guideline recategorizations observed in a database
 * @description Lists all the guideline recategorizations that were indexed in the database.
 */

import cpp
import GuidelineRecategorizations

from GuidelineRecategorization gr
select gr.getRuleId(), gr.getQuery().getCategory(), gr.getCategory()
