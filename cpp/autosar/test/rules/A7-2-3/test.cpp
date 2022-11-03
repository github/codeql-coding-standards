enum C // NON_COMPLIANT
{
  c1
};
enum class A // COMPLIANT - Violates a different rule (A7-2-2)
{
  a1
};
enum struct A1 // COMPLIANT - Violates a different rule (A7-2-2)
{
  a12
};
enum class B : int // COMPLIANT
{
  b1
};
enum struct B1 : int // COMPLIANT
{
  b12
};
enum D : int // NON_COMPLIANT
{
  d1
};