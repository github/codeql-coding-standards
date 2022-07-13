#include <initializer_list>

class ClassA {
public:
  ClassA(int i, int j); // COMPLIANT
};

class ClassB {
public:
  ClassB(int i, int j); // NON_COMPLIANT
  ClassB(std::initializer_list<int> list);
};

class ClassC {
public:
  ClassC(const ClassC &c); // COMPLIANT
  ClassC(ClassC &&c);      // COMPLIANT
  ClassC(std::initializer_list<int> list);
};

class ClassD {
public:
  ClassD(std::initializer_list<int> const &list, int p1 = 1, int p2 = 2);
  ClassD(int i, int j); // NON_COMPLIANT
};