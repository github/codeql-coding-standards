#ifdef INITIALIZE_CONDITIONAL
int conditional_after = 1; // COMPLIANT
#else
int conditional_after;      // NON_COMPLIANT
#endif

#ifndef INITIALIZE_CONDITIONAL
int conditional_before; // NON_COMPLIANT
#else
int conditional_before = 1; // COMPLIANT
#endif

#ifdef INITIALIZE_CONDITIONAL
#define CONDITIONAL_OBJECT(name) int name = 1
#define OPTIONAL_INITIALIZER = 1
#define DECLARE_OR_DEFINE(name, value) int name = value
#else
#define CONDITIONAL_OBJECT(name) int name
#define OPTIONAL_INITIALIZER
#define DECLARE_OR_DEFINE(name, value) extern int name
#endif

CONDITIONAL_OBJECT(conditional_macro_object);        // NON_COMPLIANT
int conditional_optional_init OPTIONAL_INITIALIZER;  // NON_COMPLIANT
DECLARE_OR_DEFINE(conditional_extern_or_defined, 1); // COMPLIANT

#ifdef INITIALIZE_CONDITIONAL
CONDITIONAL_OBJECT(conditional_macro_when_initialized); // COMPLIANT
#endif
