import cpp
import codingstandards.cpp.StdNamespace
import Standard

from MemberVariable v
where
  not v.isCompilerGenerated() and
  not v.isFromTemplateInstantiation(_) and
  // exclude internal member variables starting with '_' or '__' and
  not v.getName().matches("\\_%") and
  // Restrict to declarations in `std` namespace as the global namespace in a real database
  // includes many member variables outside the C/C++ standard library.
  declInVisibleStdNamespace(v)
select getStandard(), getAClosestStandardLibraryHeader(v.getFile()).getBaseName(),
  getVisibleNamespaceString(v.getNamespace()), v.getDeclaringType().getSimpleName(), v.getName(),
  v.getType().toString()
