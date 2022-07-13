struct S
{
  signed int a : 1; // Non-compliant
  signed int   : 1; // Compliant
  signed int   : 0; // Compliant
  signed int b : 2; // Compliant
  signed int   : 2; // Compliant
};