import cpp
import codingstandards.cpp.StdNamespace
import Standard

from MemberVariable v
where
  not v.isCompilerGenerated() and
  not v.isFromTemplateInstantiation(_) and
  not v.getName().matches("\\_%") // exclude internal member variables starting with '_' or '__'
select getStandard(), v.getFile().getBaseName(), getVisibleNamespaceString(v.getNamespace()),
  v.getDeclaringType().getSimpleName(), v.getName(), v.getType().toString()
