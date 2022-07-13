enum E1 { // COMPLIANT[FALSE_POSITIVE]; definition consists of the same tokens
          // as in test1.cpp
  M1,
  M2,
  M3
};

struct S1 { // COMPLIANT[FALSE_POSITIVE]; definition consists of the same tokens
            // as in test1.cpp
  int m1;
  char *m2;
};

inline void
f1(){}; // COMPLIANT; exemption listend in N3797 [basic.def.odr] point 6.

template <typename T>
class T1 { // COMPLIANT; exemption listed in N3797 [basic.def.odr] point 6.
};

template <typename T>
class T2 { // NON_COMPLIANT[FALSE_NEGATIVE]; differs from definition in
           // test1.cpp
public:
  T2() {}
  int f1(int i) { return i + 1; }
};

template <typename T> void f2(T p1){};

extern void f4();
inline void f3() { f4(); } // NON_COMPLIANT[FALSE_NEGATIVE]

struct S2 { // NON_COMPLIANT[FALSE_NEGATIVE]
  unsigned int f1;
};