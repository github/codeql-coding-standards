enum class A // COMPLIANT
{
  a1
};

enum class A1 // COMPLIANT
{
  a1 = 0,
  a2 = 1,
  a3 = 2
};

enum class A2 // NON_COMPLIANT
{
  a1,
  a2 = 0,
  a3
};

enum class A3 // COMPLIANT
{
  a1 = 0,
  a2,
  a3
};

enum class B : int // COMPLIANT
{
  b1
};

enum class B1 : int // COMPLIANT
{
  b1,
  b2,
  b3
};

enum class B2 : int // COMPLIANT
{
  b1 = 0,
  b2,
  b3
};

int f() {
  enum class B3 : int // NON_COMPLIANT
  {
    b1,
    b2 = 0,
    b3 = 0
  };

  return 0;
}

enum C // COMPLIANT
{
  c1,
  c2
};

enum D // NON_COMPLIANT
{
  d1,
  d2 = 0
};

enum E : int // COMPLIANT
{
  e1,
  e2
};

enum E1 : int // NON_COMPLIANT
{
  e11,
  e22 = 0
};