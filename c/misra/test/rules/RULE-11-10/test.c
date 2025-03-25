// _Atomic void g1;  // doesn't compile
_Atomic int g2;   // COMPLIANT
_Atomic void *g3; // NON_COMPLIANT
// _Atomic void g4[]; // doesn't compile
void *_Atomic g5; // COMPLIANT

struct {
  _Atomic int m1; // COMPLIANT
  // _Atomic void m2; // doesn't compile
  _Atomic void *m3; // NON_COMPLIANT
  void *_Atomic m4; // COMPLIANT
} s1;

void f(_Atomic int p1,  // COMPLIANT
       _Atomic void *p2 // NON_COMPLIANT
       // _Atomic void p3[] // doesn't compile, even though it perhaps should as
       // it is adjusted to void*.
) {}

typedef _Atomic void *f2(void);     // NON_COMPLIANT
typedef _Atomic void *(*f3)(void);  // NON_COMPLIANT
typedef void f4(_Atomic void *);    // NON_COMPLIANT
typedef void (*f5)(_Atomic void *); // NON_COMPLIANT

void f6() {
  (void *)0;         // COMPLIANT
  (_Atomic void *)0; // NON_COMPLIANT
}