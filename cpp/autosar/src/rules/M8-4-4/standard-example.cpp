extern void f(void);
if (0 == f) // Non-compliant
{
  // ...
}
void (*p)(void) = f; // Non-compliant
if (0 == &f)         // Compliant
{
  (f)(); // Compliant as function is called
}
void (*p)(void) = &f; // Compliant