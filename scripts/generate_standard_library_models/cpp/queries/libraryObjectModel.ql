import cpp
import codingstandards.cpp.StdNamespace
import codingstandards.cpp.Linkage
import Standard

from GlobalOrNamespaceVariable v, string linkage
where
  // exclude internal objects that start with a '_' or a '__'
  not v.getName().matches("\\_%") and
  // Restrict to declarations in `std` namespace as the global namespace in a real database
  // includes many objects outside the C/C++ standard library.
  declInVisibleStdNamespace(v) and
  if hasExternalLinkage(v) then linkage = "external" else linkage = "internal"
select getStandard(), getAClosestStandardLibraryHeader(v.getFile()).getBaseName(), "std",
  v.getName(), v.getType().toString(), linkage
