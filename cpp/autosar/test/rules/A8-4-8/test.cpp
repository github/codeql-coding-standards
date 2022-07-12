#include <string>
void f(int &i) { // COMPLIANT
  int &j = i;
}
void f1(std::string &str) { // NON_COMPLIANT
  str = "replacement";
}
void f2(std::string &str) { // COMPLIANT
  str += "suffix";
}

void f3(int &i) { // COMPLIANT
  f(i);
}

void f4(int &i) { // NON_COMPLIANT
  int x = 10;
  i = x;
}

void f5(int &i) { // NON_COMPLIANT
  f4(i);
}

class A {
public:
  int m;
};
void f6(A &a) { // NON_COMPLIANT
  a.m = 0;
  int l = a.m;
}
void f7(A &a) { // NON_COMPLIANT
  a = A();
}

void f8(int i) { // COMPLIANT
  i += 1;
}
