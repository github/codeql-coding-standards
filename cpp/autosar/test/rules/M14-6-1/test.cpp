typedef int TYPE;
void g();
void g1();
int m;

template <typename T> class B {
public:
  typedef T TYPE;
  void g();
  int m;
};

template <typename T> class A : B<T> {
public:
  void m1() {
    m = 0;            // NON_COMPLIANT
    g();              // NON_COMPLIANT
    TYPE t = 0;       // NON_COMPLIANT[FALSE_NEGATIVE]
    void (*p)() = &g; // NON_COMPLIANT
  }
  void m2() {
    ::m = 0;                      // COMPLIANT
    ::g();                        // COMPLIANT
    ::TYPE t1 = 0;                // COMPLIANT
    B<T>::m = 0;                  // COMPLIANT
    this->m = 0;                  // COMPLIANT
    this->g();                    // COMPLIANT
    void (B<T>::*p)() = &B<T>::g; // COMPLIANT
    typename B<T>::TYPE t2 = 0;   // COMPLIANT
    g1();                         // COMPLIANT, identifier not found in B
  }
};

void f() {
  A<int> a;
  a.m1();
  a.m2();
}