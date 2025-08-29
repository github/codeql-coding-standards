import cpp
import Standard

from UserType t
where
  // exclude internal objects that start with a '_' or a '__'
  not t.getName().matches("\\_%") and
  // Restrict to declarations in `std` namespace as the global namespace in a real database
  // includes types outside the C/C++ standard library.
  declInVisibleStdNamespace(t) and
  // Do not report types from template instantiations - instead report the uninstantiated template
  not t.isFromTemplateInstantiation(_) and
  // Exclude all template specializations, except those where (due to an extractor bug?) the
  // primary template is missing
  (
    t instanceof ClassTemplateSpecialization
    implies
    not exists(t.(ClassTemplateSpecialization).getPrimaryTemplate())
  ) and
  // Remove unnamed types, because they do not have a reserved name
  not t.isAnonymous()
select getStandard(), getAClosestStandardLibraryHeader(t.getFile()).getBaseName(),
  getVisibleNamespaceString(t.getNamespace()), t.getSimpleName()
