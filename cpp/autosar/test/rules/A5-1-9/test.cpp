struct S1 {
  int m1;
  int m2;
};

extern int f1(char *);
extern void f2(int);

void test_compliant() {
  int l1 = 0;

  [l1]() { return l1 + 1; }; // COMPLIANT

  [](int i) { return i + 2; };   // COMPLIANT
  [](short i) { return i + 2; }; // COMPLIANT

  [](int i) { return i + f1("foo"); }; // COMPLIANT
  [](int i) { return i + f1("bar"); }; // COMPLIANT

  [](S1 *p) { p->m1++; }; // COMPLIANT
  [](S1 *p) { p->m2++; }; // COMPLIANT

  [](S1 *p) { // COMPLIANT
    p->m1++;
    return p;
  };
  [](S1 *q) { // COMPLIANT
    q->m1++;
    return q;
  };

  // Non-commutative operations with swapped arguments.
  [](int i, int j) { return i / j; }; // COMPLIANT
  [](int i, int j) { return j / i; }; // COMPLIANT

  [](int i) { // COMPLIANT
    if (i % 3 == 0) {
      for (int j = 0; j < i; j++) {
        f2(j);
      }
    }
  };

  [](int i) { // COMPLIANT
    if (i % 3 == 0) {
      for (int j = 0; j <= i; j++) {
        f2(j);
      }
    }
  };
}

void test_noncompliant() {
  [](int i) { return i + 1; }; // NON_COMPLIANT
  [](int i) { return i + 1; }; // NON_COMPLIANT

  [](int i) { return i + f1("baz"); }; // NON_COMPLIANT
  [](int i) { return i + f1("baz"); }; // NON_COMPLIANT

  [](S1 *r) { // NON_COMPLIANT
    r->m1++;
    return r;
  };
  [](S1 *r) { // NON_COMPLIANT
    r->m1++;
    return r;
  };

  [](int i) { // NON_COMPLIANT
    if (i % 2 == 0) {
      for (int j = 0; j < i; j++) {
        f2(j);
      }
    }
  };

  [](int i) { // NON_COMPLIANT
    if (i % 2 == 0) {
      for (int j = 0; j < i; j++) {
        f2(j);
      }
    }
  };
}

#include <string>
class Test_issue468 {
public:
  template <typename... As> static void LogInfo(const As &...rest) {
    [](const std::string &s) -> void { LogInfo(s); }; // COMPLIANT
  }
  template <typename... As> static void LogWarn(const As &...rest) {
    [](const std::string &s) -> void { LogWarn(s); }; // COMPLIANT
  }
  template <typename... As> static void LogError(const As &...rest) {
    [](const std::string &s) -> void { LogError(s); }; // NON_COMPLIANT
  }
  template <typename... As> static void LogFatal(const As &...rest) {
    [](const std::string &s) -> void { LogError(s); }; // NON_COMPLIANT
  }
  void instantiate() {
    LogInfo("Info");
    LogWarn("Warn");
    LogError("Error");
    LogFatal("Fatal");
  }
};