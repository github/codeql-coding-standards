void f2(int *v1) { return; }

int *g_v1 = nullptr;

class C1 {
private:
  int *v1; // COMPLIANT

public:
  C1() { v1 = new int(0); }
  ~C1() { delete v1; }
};

class C2 {
private:
  int *v1; // NON_COMPLIANT

public:
  C2() { v1 = new int(0); }
  ~C2() { delete v1; }

  int *get_ptr() { return v1; }
};

int *f1(int *v1) {      // COMPLIANT
  int *v2 = new int(0); // COMPLIANT
  int *v3 = new int(0); // NON_COMPLIANT
  int *v4 = v1;         // COMPLIANT
  int *v5 = new int(0); // NON_COMPLIANT
  f2(v3);
  f2(v4);
  g_v1 = v5;
  *v2 = 0;
  return v3;
}