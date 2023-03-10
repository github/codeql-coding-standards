import codingstandards.c.misra.EssentialTypes

from Expr e, Type et
where et = getEssentialType(e)
select e, et.getName(), getEssentialTypeBeforeConversions(e).getName(), getEssentialTypeCategory(et)
