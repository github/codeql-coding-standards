#define GOODMACRO // COMPLIANT
#undef GOODMACRO  // COMPLIANT

namespace notGlobalNamespace {

#define BADMACRO // NON_COMPLIANT
#undef BADMACRO  // NON_COMPLIANT

} // namespace notGlobalNamespace

namespace secondNotGlobalNamespace {
#define SECONDBADMACRO // NON_COMPLIANT
}
#undef SECONDBADMACRO // COMPLIANT

#define THIRDBADMACRO // COMPLIANT
namespace thirdNotGlobalNamespace {
#undef THIRDBADMACRO // NON_COMPLIANT
}