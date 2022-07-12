struct S {
  signed int x : 1; // NON-COMPLIANT
  signed int y : 5; // COMPLIANT
  signed int z : 7; // COMPLIANT
  signed int : 0;   // COMPLIANT
  signed int : 1;   // COMPLIANT
  signed int : 2;   // COMPLIANT
};