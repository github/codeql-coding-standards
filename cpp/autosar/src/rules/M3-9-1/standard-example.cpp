typedef int32_t INT;
INT i;
extern int32_t i; // Non-compliant
INT j;
extern INT j; // Compliant

// The following lines break Rule 3–9–2
extern void f(signed int);
void f(int); // Non-compliant
extern void g(const int);
void g(int); // Non-compliant
