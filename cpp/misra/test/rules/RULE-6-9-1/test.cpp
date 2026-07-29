typedef int INT;
using Index = int;

INT i;
extern int i; // NON_COMPLIANT

INT j;
extern INT j; // COMPLIANT

void g(int i);
void g(Index const i); // NON_COMPLIANT

void h(Index i);
void h(Index const i); // COMPLIANT
void h(int *i);        // COMPLIANT