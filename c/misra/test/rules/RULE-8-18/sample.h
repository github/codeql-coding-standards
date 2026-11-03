// Only uninitialized file-scope objects without extern are tentative.
extern int external_declaration; // COMPLIANT
int initialized_in_header = 0;   // COMPLIANT
int header_tentative;            // NON_COMPLIANT
static int static_object;        // NON_COMPLIANT
const int const_object;          // NON_COMPLIANT

// An initializer applies only to its own declarator.
int initialized = 1, uninitialized; // NON_COMPLIANT: uninitialized

// Later definitions do not excuse earlier tentative declarations.
int initialized_elsewhere;  // NON_COMPLIANT: initialized in test.c
int same_header_object;     // NON_COMPLIANT
int same_header_object = 1; // COMPLIANT

// Extern declarations around a tentative declaration remain compliant.
extern int redeclared_object; // COMPLIANT
int redeclared_object;        // NON_COMPLIANT
extern int redeclared_object; // COMPLIANT

// Macro-generated declarations follow their expansion file.
#define DECLARE_OBJECT(name) int name
DECLARE_OBJECT(macro_header_object); // NON_COMPLIANT