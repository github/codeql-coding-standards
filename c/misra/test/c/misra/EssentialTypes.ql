import codingstandards.c.misra.EssentialTypes

from Expr e
select e, getEssentialType(e) as et, getEssentialTypeBeforeConversions(e),
  getEssentialTypeCategory(et)
