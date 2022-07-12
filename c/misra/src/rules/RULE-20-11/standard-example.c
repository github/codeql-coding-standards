#define A(x) #x       /* Compliant */
#define B(x, y) x##y  /* Compliant */
#define C(x, y) #x##y /* Non-compliant */