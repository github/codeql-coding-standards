// File a.cpp
struct S1
{  
  int32_t i;
};
struct S2
{  
  int32_t i;
};
// File b.cpp
struct S1
{  
  int64_t i;
};           // Non-compliant – token sequence different
struct S2
{
  int32_t i;
  int32_t j;
};           // Non-compliant – token sequence different