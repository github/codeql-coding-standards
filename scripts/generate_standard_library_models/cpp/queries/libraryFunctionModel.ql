import cpp
import codingstandards.cpp.Linkage
import codingstandards.cpp.StdNamespace
import Standard

from Function f, string declaringType, string linkage
where
  not exists(f.getAFile().getRelativePath()) and
  not f.isCompilerGenerated() and
  // exclude user defined operators
  not f instanceof Operator and
  not f.isFromTemplateInstantiation(_) and
  not f instanceof Constructor and
  not f instanceof Destructor and
  // exclude internal functions starting with '_' or '__'
  not f.getName().matches("\\_%") and
  // exclude user defined literals
  not f.getName().matches("operator \"%") and
  // Restrict to declarations in `std` namespace as the global namespace in a real database
  // includes many functions outside the C/C++ standard library.
  declInVisibleStdNamespace(f) and
  // In practice there aren't any internal linkage functions specified by the C++ standard
  (if hasExternalLinkage(f) then linkage = "external" else linkage = "internal") and
  if f instanceof MemberFunction
  then f.getDeclaringType().getSimpleName() = declaringType and not f.(MemberFunction).isPrivate()
  else declaringType = ""
select getStandard(), getAClosestStandardLibraryHeader(f.getFile()).getBaseName(),
  getVisibleNamespaceString(f.getNamespace()), declaringType, f.getName(), f.getType().toString(),
  f.getParameterString(), linkage
