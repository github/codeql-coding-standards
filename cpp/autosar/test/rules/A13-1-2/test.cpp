void operator"" x(long double);   // NON_COMPLIANT
void operator"" X(long double);   // NON_COMPLIANT
void operator"" _(long double);   // NON_COMPLIANT
void operator"" _1(long double);  // NON_COMPLIANT
void operator"" _x1(long double); // NON_COMPLIANT

void operator"" _x(long double);  // COMPLIANT
void operator"" _X(long double);  // COMPLIANT
void operator"" _XY(long double); // COMPLIANT