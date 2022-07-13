

class ClassA {
public:
  ClassA(int x) : m1_x(x), m2_x(x) {}

private:
  int m1_x{1}; // NON_COMPLIANT
               // uses both nsdmi and member init
  int m2_x;    // COMPLIANT - only uses member init
  int m3_x{1}; // COMPLIANT - only uses NSDMI
};