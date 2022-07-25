#define CONCATMACRO(X, Y) (X #Y)  // COMPLIANT
#define CONCATMACROTWO(X, Y) X #Y // COMPLIANT

#define STRINGIZEMACRO(X) #X // COMPLIANT

#define OBJECTMACRO (1024) // COMPLIANT

#define BADMACRO(X) X          // NON_COMPLIANT
#define BADNEGATIVEMACRO(X) -X // NON_COMPLIANT
// clang-format off
#define GOODNEGATIVEMACROLOOSEPARENTH(X) -( X ) // COMPLIANT
// clang-format on
#define GOODNEGATIVEMACROTIGHTPARENTH(X) -(X) // COMPLIANT

#define BADCOMPLICATENDNEGATIVEMACRO(X) (X < 0 ? X : -X)        // NON_COMPLIANT
#define GOODCOMPLICATENDNEGATIVEMACRO(X) ((X) < 0 ? (X) : -(X)) // COMPLIANT

#define BADMACROMANYPARAMS(X, Y, Z)                                            \
  (X + Y + Z < 0 ? X + Y + Z : -(X + Y + Z)) // NON_COMPLIANT
#define BADMACROMANYPARAMSNOTALLPARENTH(X, Y, Z)                               \
  (X) + Y + Z < 0 ? (X) + (Y) + (Z) : -(X) + Y + Z)) // NON_COMPLIANT
#define GOODMACROMANYPARAMS(X, Y, Z)                                           \
  ((X) + (Y) + (Z) < 0 ? (X) + (Y) + (Z) : -((X) + (Y) + (Z))) // COMPLIANT

#define BADMACROEMPTY() X // COMPLIANT

#define BADMACROVARIADICGOOD(X, ...) (X) // COMPLIANT

#define BADMACROVARIADICBAD(X, ...) X // NON_COMPLIANT

#define MACROFUNCTIONNAMEWITHPARAMSUBSTR(x)                                    \
  function_with_x_name((x) + 1) // COMPLIANT

#define MACROFUNCTIONNAMEWITHPARAMSUBSTRBAD(x)                                 \
  function_with_x_name(x + 1) // NON_COMPLIANT