#include <map>
#include <utility>
#include <vector>

int g0 = 0; // COMPLIANT -- not automatic storage duration

bool f0(int x);

void f1() {
  int l0 = 0;        // NON_COMPLIANT
  static int l1 = 0; // COMPLIANT -- not automatic storage duration
}

void f2() {
  int l0 = 0; // COMPLIANT -- used as function parameter
  f0(l0);
}

void f3() {
  int l0 = 0; // COMPLIANT
  if (l0) {
  }

  int l1 = 0; // COMPLIANT
  while (l1) {
  }

  int l2 = 0; // COMPLIANT
  for (; l2;) {
  }

  int l3 = 0; // COMPLIANT
  switch (l3) {}

  int l4 = 0; // COMPLIANT
  do {
  } while (l4);

  int l5 = 0; // COMPLIANT
  l5 ? f0(0) : f0(1);

  bool l6; // COMPLIANT
  l6 &&f0(0);

  bool l7; // COMPLIANT
  l7 || f0(0);

  auto l8 = f0; // COMPLIANT
  l8(0);

  int l9 = 0;   // COMPLIANT
  int l10 = l9; // COMPLIANT
  f0(l10);

  int l11 = 0; // COMPLIANT
  int l12 = 0; // COMPLIANT
  l11 += l12;  // COMPLIANT
  f0(l11);

  int l13 = 0;
  l13 = l13 + 1; // NON_COMPLIANT -- read but not observed

  int l14 = 0;
  l14 = l14 + 1; // COMPLIANT -- read and observed
  f0(l14);
}

void f4() {
  int l0 = 0; // COMPLIANT
  f0(l0 + 1);
  int l1 = 0; // COMPLIANT
  f0(l1 - 1);
  int l2 = 0;  // COMPLIANT
  f0(l2 * 2);  // COMPLIANT
  int l3 = 0;  // COMPLIANT
  f0(l3 / 2);  // COMPLIANT
  int l4 = 0;  // COMPLIANT
  f0(l4 % 2);  // COMPLIANT
  int l5 = 0;  // COMPLIANT
  f0(l5 & 2);  // COMPLIANT
  int l6 = 0;  // COMPLIANT
  f0(l6 | 2);  // COMPLIANT
  int l7 = 0;  // COMPLIANT
  f0(l7 ^ 2);  // COMPLIANT
  int l8 = 0;  // COMPLIANT
  f0(l8 << 1); // COMPLIANT
  int l9 = 0;  // COMPLIANT
  f0(l9 >> 1); // COMPLIANT
  int l10 = 0; // COMPLIANT
  f0(-l10);    // COMPLIANT
  int l11 = 0; // COMPLIANT
  f0(~l11);    // COMPLIANT
  int l12 = 0; // COMPLIANT
  f0(!l12);    // COMPLIANT
  int l13 = 0; // COMPLIANT
  f0(+l13);    // COMPLIANT

  int l14 = 0;       // COMPLIANT
  int l15[] = {l14}; // COMPLIANT
  int l16 = 10;      // COMPLIANT
  f0(l15[l16]);

  // Copy the above test, but with tainted values instead of direct uses
  int l17 = 0;            // COMPLIANT
  int l18[] = {l17 + 1};  // COMPLIANT
  int l19 = 0;            // COMPLIANT
  f0((l18 + 1)[l19 + 1]); // COMPLIANT
}

void f5() {
  int l0 = 0; // COMPLIANT
  f0(++l0);   // COMPLIANT -- modified value immediately observed
  int l1 = 0; // COMPLIANT
  f0(--l1);   // COMPLIANT -- modified value immediately observed
  int l2 = 0; // COMPLIANT
  f0(l2--);   // NON_COMPLIANT -- modified value not observed
  int l3 = 0; // COMPLIANT
  f0(l3++);   // NON_COMPLIANT -- modified value not observed

  int l4 = 0; // COMPLIANT
  f0(l4++);   // COMPLIANT -- modified value observed later
  f0(l4);
}

void f6() {
  int l0 = 0;      // NON_COMPLIANT -- overwritten before being read
  f0(l0 = 1);      // COMPLIANT -- value observed
  int l1 = 0;      // COMPLIANT
  f0(l1 = l1);     // COMPLIANT -- value observed
  int l2 = 0;      // COMPLIANT
  f0(l2 = l2 + 1); // COMPLIANT -- value observed
  int l3 = 0;      // COMPLIANT
  f0(l3 += 1);     // COMPLIANT -- value observed
}

void f7(int x = 0) { // COMPLIANT -- default parameter value
}

void f8() {
  std::pair<int, int> p = {1, 2};
  auto [l0, l1] = p; // NON_COMPLIANT -- 'l1' is unused
  f0(l0);

  std::vector<int> v;
  for (auto l2 : v) { // COMPLIANT -- 'l2' is used
    f0(l2);
  }

  for (auto l3 : v) { // NON_COMPLIANT -- 'l3' is unused
  }

  std::map<int, int> m;
  for (auto [a, b] : m) { // COMPLIANT
    // Technically 'a' is unused, but this is a convenient cost free pattern
    f0(b);
  }
}

void f9() {
  int l0 = 0;    // COMPLIANT -- observed via address-of
  int *l1 = &l0; // COMPLIANT -- observed via deref
  f0(*l1);

  int *l2 = new int(0); // COMPLIANT -- dynamic storage duration
  delete l2;            // COMPLIANT

  int *l3 = new int(0); // NON_COMPLIANT -- unused
}

int f10() {
  int l0 = 0; // COMPLIANT -- observed via return
  int l1 = 1; // NON_COMPLIANT -- unused
  return l0;
}

int f11() {
  int l0 = 0; // COMPLIANT -- observed via throw
  int l1 = 1; // NON_COMPLIANT -- unused
  throw l0;
}

class Trivial {
public:
  int a;
  int b;
  void member();
};

class NonTrivial {
public:
  ~NonTrivial() {}
  int a;
  void member();
};

void use(Trivial t);

void f12() {
  Trivial t0 = Trivial();       // NON_COMPLIANT -- unused
  NonTrivial t1 = NonTrivial(); // COMPLIANT -- non-trivial type
}

void f13() {
  Trivial t0;
  t0.a = 0; // COMPLIANT -- write to a is observed through t0
  use(t0);

  Trivial t1 = Trivial(); // COMPLIANT -- used via member() call
  t1.member();

  Trivial *t2 = new Trivial();
  t2->a = 0; // COMPLIANT -- write to a is observed through t2
  use(*t2);

  Trivial *t3 = new Trivial(); // COMPLIANT -- used via member() call
  t3->member();

  Trivial t4 = Trivial();      // NON_COMPLIANT -- unused
  Trivial *t5 = new Trivial(); // NON_COMPLIANT -- unused

  Trivial t6;
  t6.a = 0; // NON_COMPLIANT -- write to a is not observed

  Trivial *t7 = new Trivial(); // COMPLIANT
  t7->a = 0; // write to a triggers observation of *t7 through deref assignment.

  Trivial t8 = Trivial();
  f0(t8.a); // COMPLIANT -- observation of subobject 'a' counts as observing the
            // whole t8 object

  Trivial *t9 = new Trivial();
  f0(t9->a); // COMPLIANT -- observation of subobject 'a' counts as observing
             // the whole *t9 object

  Trivial t10 = Trivial(); // NON_COMPLIANT
  t10.a;                   // reading a does not count as observing t10

  Trivial *t11 = new Trivial(); // NON_COMPLIANT
  t11->a;                       // reading a does not count as observing *t11

  Trivial t12[] = {Trivial(), Trivial()}; // NON_COMPLIANT -- unused
  NonTrivial t13[] = {NonTrivial(),
                      NonTrivial()}; // COMPLIANT -- non-trivial type
}

void f14() {
  // Test that dereferencing can observe the pointer base, but only when
  // assigned to.
  //
  // Note that the cases involve assignment to dereferenced pointers could be
  // fully modeled to count as an assignment to the pointee object, but we don't
  // currently do that advanced of an analysis.
  int l0[] = {0, 1, 2}; // COMPLIANT

  int *l1 = l0; // NON_COMPLIANT -- dereference occurs but is not observed
  *l1;

  int *l2 = l0; // COMPLIANT
  *l2 = 0;      // dereference observed via assignment to pointee.

  int *l3 = l0; // COMPLIANT
  *(l3 + 1) = 0;

  int *l4 = l0; // COMPLIANT
  *l4++ = 0;    // NON_COMPLIANT -- increment not observed

  int *l5 = l0; // COMPLIANT
  *++l5 = 0;

  int *l6 = l0; // COMPLIANT
  *l6 += 1;
}

void f15() {
  Trivial t0;
  t0.a = 0; // COMPLIANT -- not overwritten by assignment to b
  t0.b = 1; // COMPLIANT -- used via containing object t0.
  use(t0);

  t0.a = 0; // NON_COMPLIANT -- overwritten before being read
  t0.a = 1; // COMPLIANT -- used via containing object t0.
  use(t0);

  t0.a = 0; // NON_COMPLIANT -- overwritten before being read
  t0 = Trivial();
  use(t0);

  struct {
    Trivial t;
    int x;
  } t1;
  t1.t.a = 0; // COMPLIANT -- not overwritten
  t1.x = 1; // COMPLIANT -- observing t1.t counts as observing t1.x by rule text
  use(t1.t); // use t1.t containing subobject t1.t.a

  struct {
    Trivial t;
    int x;
  } t2;
  t2.t.a = 0; // NON_COMPLIANT -- overwritten before being read
  t2.t = Trivial();
  use(t2.t);
}

template <typename T> void useVec(std::vector<T> &v);

void f16() {
  std::vector<int> v0 = {0, 1, 2}; // COMPLIANT
  useVec(v0);

  std::vector<int> v1 = {0, 1, 2}; // NON_COMPLIANT -- unused

  std::vector<int> v2;
  v2[0] = 0; // COMPLIANT -- write to element is observed via useVec
  useVec(v2);

  std::vector<int> v3; // NON_COMPLIANT -- unobserved
  v3[0] = 0;           // NON_COMPLIANT -- unused

  std::vector<int> v4;
  v4[0] = 0; // COMPLIANT
  v4[1] = 0; // COMPLIANT
  useVec(v4);

  std::vector<int> v5;
  v5[0] = 0; // NON_COMPLIANT
  v5[0] = 0; // COMPLIANT
  useVec(v5);

  std::vector<int> v6 = {0, 1, 2}; // COMPLIANT
  f0(v6[0]);

  std::vector<int> v7;
  v7[0] = 1; // COMPLIANT
  f0(v7[0]);

  std::vector<int> v8;
  v8[0] =
      1; // COMPLIANT -- observing v8[1] counts as observing the whole v8 object
  f0(v8[1]);

  std::vector<NonTrivial> v9 = {NonTrivial(),
                                NonTrivial()}; // COMPLIANT -- non-trivial type

  std::vector<Trivial> v10 = {Trivial(), Trivial()}; // NON_COMPLIANT -- unused

  std::vector<Trivial> v11 = {Trivial(), Trivial()}; // COMPLIANT
  useVec(v11);
}

void f17(int p0, int p1) {
  p0 = 0; // COMPLIANT
  f0(p0);

  p1 = 0; // NON_COMPLIANT
}

void f18(Trivial t0, Trivial t1, NonTrivial t2) {
  t0.a = 0; // COMPLIANT
  use(t0);

  t1.a = 0; // NON_COMPLIANT

  t2.a = 0; // COMPLIANT -- non-trivial type
}

void f19(std::vector<Trivial> v0, std::vector<Trivial> v1,
         std::vector<NonTrivial> v2) {
  v0[0] = Trivial(); // COMPLIANT
  useVec(v0);

  v1[0] = Trivial(); // NON_COMPLIANT

  v2[0] = NonTrivial(); // COMPLIANT -- non-trivial type
}

void f20(int *p0, int *p1, Trivial *p2, NonTrivial *p3,
         std::vector<Trivial> *p4) {
  *p0 = 0;            // COMPLIANT -- not an assignment to a local object
  *p2 = Trivial();    // COMPLIANT
  *p3 = NonTrivial(); // COMPLIANT
  *p4 = std::vector<Trivial>(); // COMPLIANT

  p0 = nullptr; // COMPLIANT
  f0(*p0);

  p1 = nullptr; // NON_COMPLIANT -- the pointer is a local object
  p2 = nullptr; // NON_COMPLIANT
  p3 = nullptr; // NON_COMPLIANT
  p4 = nullptr; // NON_COMPLIANT -- a pointer to a non-trivial type is itself a
                // local trivial object
}

void f20(int &p0, int &p1, Trivial &p2, std::vector<Trivial> &p3) {
  p0 = 0;                      // COMPLIANT
  p2 = Trivial();              // COMPLIANT
  p3 = std::vector<Trivial>(); // COMPLIANT
}

void f21() {
  int l0[] = {0, 1, 2}; // COMPLIANT
  f0(l0[0]);            // Observes entire object

  int l1[] = {0, 1, 2}; // NON_COMPLIANT -- unused

  Trivial l2[] = {Trivial(), Trivial()}; // COMPLIANT
  use(l2[0]);                            // Observes entire object

  Trivial l3[] = {Trivial(), Trivial()}; // NON_COMPLIANT -- unused

  NonTrivial l4[] = {NonTrivial(),
                     NonTrivial()}; // COMPLIANT -- non-trivial type

  int l5[10];
  l5[0] = 0; // COMPLIANT
  l5[1] = 0; // COMPLIANT
  f0(l5[0]); // Observes entire object

  int l6[10];
  l6[0] = 0; // NON_COMPLIANT
  l6[0] = 0; // COMPLIANT
  f0(l6[0]); // Observes entire object

  int l6_1[10];
  l6_1[0] = 0;       // NON_COMPLIANT
  l6_1[1] = l6_1[2]; // COMPLIANT
  l6_1[0] = 0;       // COMPLIANT
  f0(l6_1[0]);       // Observes entire object

  int l7[10];
  l7[0] = 0;  // COMPLIANT
  l7[0] += 1; // COMPLIANT
  f0(l7[0]);  // Observes entire object

  int l8[10];
  l8[0] = 0;         // COMPLIANT
  l8[0] = l8[0] + 1; // COMPLIANT
  f0(l8[0]);         // Observes entire object

  int l9[10];
  l9[0] = 0;         // NON_COMPLIANT -- not observed
  l9[1] = 0;         // NON_COMPLIANT -- not observed
  l9[1] = l9[1] + 1; // NON_COMPLIANT -- not observed

  int l10[10];
  l10[0] = 0; // COMPLIANT
  l10[0]++;   // COMPLIANT
  f0(l10[0]); // Observes entire object

  int l11[10];
  l11[0] = 0; // NON_COMPLIANT -- not observed
  l11[0]++;   // NON_COMPLIANT -- not observed
}

void f21(size_t p0, size_t p1) {
  int l0[10];
  l0[p0] = 0; // COMPLIANT
  l0[p1] = 0; // COMPLIANT
  f0(l0[0]);  // Observes entire object

  int l1[10];
  l1[0] = 0;  // COMPLIANT
  l1[p0] = 0; // COMPLIANT
  f0(l1[0]);  // Observes entire object
}

void f22(size_t p0, size_t p1) {
  std::vector<int> v0(10);
  v0[p0] = 0; // COMPLIANT
  v0[p1] = 0; // COMPLIANT
  useVec(v0);

  std::vector<int> v1(10);
  v1[p0] = 0;  // COMPLIANT
  v1[p0] += 1; // COMPLIANT
  useVec(v1);

  // This case can be caught without too much difficulty using global value
  // numbering, but this has not been done yet, and may be slow.
  //
  // Many cases below are similar false negatives, just in more complicated
  // circumstances.
  std::vector<int> v2(10);
  v2[p0] = 0; // NON_COMPLIANT[False negative]
  v2[p0] = 1; // COMPLIANT
  useVec(v2);

  /* Test index aliasing */
  std::vector<int> v3(10);
  v3[0] = 0;      // COMPLIANT -- may be read in next line when p0 == 1
  v3[1] = v3[p0]; // COMPLIANT
  v3[0] = 2;      // COMPLIANT
  useVec(v3);

  std::vector<int> v4(10);
  v4[p0] = 0;     // COMPLIANT -- may be read in next line when p0 == p1
  v4[0] = v4[p1]; // COMPLIANT
  v4[p0] = 2;     // COMPLIANT
  useVec(v4);

  std::vector<int> v5(10);
  v5[p0] = 0;    // COMPLIANT -- may be read in next line when p0 == 0
  v5[1] = v5[0]; // COMPLIANT
  v5[p0] = 2;    // COMPLIANT
  useVec(v5);

  /* Set it so that p0 and p1 cannot alias */
  if (p0 < 10 && p1 > 10) {
    std::vector<int> v6(10);
    v6[0] = 0;      // COMPLIANT -- can be read in next line when p0 == 0
    v6[1] = v6[p0]; // COMPLIANT
    v6[0] = 2;      // COMPLIANT
    useVec(v6);

    std::vector<int> v7(10);
    v7[0] = 0;      // NON_COMPLIANT -- p1 cannot be equal to 0
    v7[1] = v7[p1]; // COMPLIANT
    v7[0] = 2;      // COMPLIANT
    useVec(v7);

    std::vector<int> v8(10);
    v8[p0] = 0; // NON_COMPLIANT[False negative] -- cannot be read in next line
    v8[0] = v8[p1]; // COMPLIANT
    v8[p0] = 2;     // COMPLIANT
    useVec(v8);

    std::vector<int> v9(10);
    v9[p0] = 0; // NON_COMPLIANT[False negative] -- cannot be read in next line
    // p0 cannot be 11
    v9[0] = v9[11]; // COMPLIANT
    v9[p0] = 2;     // COMPLIANT
    useVec(v9);

    std::vector<int> v10(10);
    v10[p0] = 0; // COMPLIANT -- can be read in next line
    // p0 can be equal to 0
    v10[1] = v10[0]; // COMPLIANT
    v10[p0] = 2;     // COMPLIANT
    useVec(v10);

    std::vector<int> v11(10);
    v11[p1] = 0; // COMPLIANT -- can be read in next line
    // p1 may be equal to be 11
    v11[0] = v11[11]; // COMPLIANT
    v11[p1] = 2;      // COMPLIANT
    useVec(v11);

    std::vector<int> v12(10);
    v12[p1] = 0; // NON_COMPLIANT[False negative] -- cannot be read in next line
    // p1 cannot be equal to 0
    v12[1] = v12[0]; // COMPLIANT
    v12[p1] = 2;     // COMPLIANT
    useVec(v12);
  }
}

void f23() {
  int *l0 = nullptr; // NON_COMPLIANT

  int *l1 = nullptr; // NON_COMPLIANT
  l1[0];             // read but not observed

  int *l2 = nullptr; // COMPLIANT
  l2[0] = 0;         // write observed via assignment
}

void f24() {
  int l0 = 0; // COMPLIANT
  std::vector<int> l1(10);
  l1[l0 + 1] = 0; // COMPLIANT
  useVec(l1);

  int l2 = 0;     // COMPLIANT
  int *l3;        // COMPLIANT
  l3[l2 * 2] = 0; // COMPLIANT
  f0(l3[0]);

  int l4 = 0; // COMPLIANT
  int l5[10];
  l5[l4 % 10] = 0; // COMPLIANT
  f0(l5[0]);

  int l6 = 0;       // COMPLIANT
  Trivial *l7;      // COMPLIANT
  l7[l6 & 3].a = 0; // COMPLIANT
  use(l7[0]);

  int l8 = 0; // COMPLIANT
  std::vector<Trivial> l9(10);
  l9[l8 | 1].a = 0; // COMPLIANT
  useVec(l9);

  int l10 = 0; // COMPLIANT
  int l11[10];
  l11[l10]++; // COMPLIANT
  f0(l11[0]);

  int l12 = 0; // COMPLIANT
  int l13[10];
  l13[l12 + 1]++; // COMPLIANT
  f0(l13[0]);
}

void f25() {
  // True positive case
  int l0 = 0; // COMPLIANT
  int *l1 = &l0;
  l0 = 1; // COMPLIANT -- observed via pointer
  f0(*l1);

  // False positive case
  int l2 = 0;    // COMPLIANT
  int *l3 = &l2; // COMPLIANT
  f0(*l3);
  l2 = 1; // NON_COMPLIANT[False negative] -- not observed

  // True positive case
  // Handles case where l4 is written twice without read
  int l4 = 0;    // COMPLIANT
  int *l5 = &l4; // COMPLIANT
  l4 = 1;        // COMPLIANT
  f0(*l5);
  l4 = 2; // COMPLIANT
  f0(l4); // observe l4

  // False positive case
  // Handles case where l6 is written twice without read
  int l6 = 0;    // COMPLIANT
  int *l7 = &l6; // COMPLIANT
  f0(*l7);
  l6 = 1; // NON_COMPLIANT[False negative]
  l6 = 2; // COMPLIANT
  f0(l6); // observe l6

  // Test reference variables
  int l8 = 0;   // COMPLIANT
  int &l9 = l8; // COMPLIANT
  l8 = 1;       // COMPLIANT
  f0(l9);

  int l10 = 0;    // COMPLIANT
  int &l11 = l10; // COMPLIANT
  f0(l11);
  l10 = 1; // NON_COMPLIANT[False negative]
}

void f26() {
  /**
   * The following tests show the limitations of our STL container modeling.
   *
   * These FNs are preferred over FPs.
   */
  std::vector<int> v0 = {0, 1, 2}; // COMPLIANT[False negative]
  v0.size(); // finding size is currently treated as observes whole object

  std::vector<int> v1 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v1.begin(); // obtaining iterator is currently treated as observing whole
              // object

  std::vector<int> v2 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v2.end(); // obtaining iterator is currently treated as observing whole object

  std::vector<int> v3 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v3.empty(); // checking emptiness is currently treated as observing whole
              // object

  // std::vector<int> v4 = {0, 1, 2}; // COMPLIANT[False negative]
  // v4.capacity(); // checking capacity is currently treated as observing whole
  // object

  /**
   * Testing calls to methods that modify the container.
   *
   * These could be treated as a possible assignment to any index of that
   * container. Therefore, never treated as an overwrite, but must be observed.
   *
   * This is not currently modeled, so all are FNs.
   */
  std::vector<int> v5 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  // We don't model that this must modify indexes 0 through 2.
  v5.clear(); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v6 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v6.clear();                      // COMPLIANT -- observed
  useVec(v6);

  std::vector<int> v7 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v7.push_back(3); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v8 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v8.resize(10); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v9 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v9.pop_back(); // NON_COMPLIANT[False negative] -- not observed

  // std::vector<int> v10 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  // v10.assign(5, 0); // NON_COMPLIANT[False negative] -- not observed

  // std::vector<int> v11 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  // std::vector<int> v12 = {3, 4, 5}; // NON_COMPLIANT[False negative]
  // v11.swap(v12); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v13 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v13.emplace(v13.begin(), 3); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v14 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v14.emplace_back(3); // NON_COMPLIANT[False negative] -- not observed

  std::vector<int> v15 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  v15.insert(v15.begin(), 3); // NON_COMPLIANT[False negative] -- not observed

  // std::vector<int> v16 = {0, 1, 2}; // NON_COMPLIANT[False negative]
  // v16.erase(v16.begin()); // NON_COMPLIANT[False negative] -- not observed
}

void f27() {
  // Lambdas have been excluded for now for simplicity.
  int l0 = 0;                           // COMPLIANT
  auto l1 = [&l0]() { return l0 + 1; }; // COMPLIANT
  f0(l1());

  // All of f27 is excluded from analysis.
  int l2 = 0; // NON_COMPLIANT[False negative]

  []() {
    // Some lambda bodies had strange results, so lambda bodies are excluded.
    int l3 = 0; // NON_COMPLIANT[False negative]
  };
}

void f28() {
  // Try catch blocks are excluded from analysis for simplicity.
  int l0, l1;
  try {
    l0 = 0; // NON_COMPLIANT[False negative]
    l1 = 0; // COMPLIANT
  } catch (...) {
    f0(l1);
  }

  // All of f28 is excluded from analysis.
  int l2 = 0; // COMPLIANT
}

int f29() {
  struct {
    int arr[10];
  } x;

  int l0 = 0; // COMPLIANT
  f0(x.arr[l0]);
}