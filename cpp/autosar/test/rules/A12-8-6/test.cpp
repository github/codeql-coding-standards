// Base class with public move/copy is not compliant
class BaseClass1 {
public:
  BaseClass1(BaseClass1 const &) = default;            // NON_COMPLIANT
  BaseClass1(BaseClass1 &&) = default;                 // NON_COMPLIANT
  BaseClass1 &operator=(BaseClass1 const &) = default; // NON_COMPLIANT
  BaseClass1 &operator=(BaseClass1 &&) = default;      // NON_COMPLIANT
  int operator=(int i); // COMPLIANT - not an assignment operator
};
class DerivedClass1 // COMPLIANT - not a base class itself
    : public BaseClass1 {};

// Base class with compiler generated move/copy is not compliant, because they
// are public by default
class BaseClass2 {}; // NON_COMPLIANT - compiler generated move and assignment
                     // are in contravention
class DerivedClass2  // COMPLIANT - not a base class itself
    : public BaseClass2 {};

class BaseClass3 {
protected:
  BaseClass3(BaseClass3 const &) = default;            // COMPLIANT - protected
  BaseClass3(BaseClass3 &&) = default;                 // COMPLIANT - protected
  BaseClass3 &operator=(BaseClass3 const &) = default; // COMPLIANT - protected
  BaseClass3 &operator=(BaseClass3 &&) = default;      // COMPLIANT - protected
};
class DerivedClass3 // COMPLIANT - not a base class itself
    : public BaseClass3 {};

class BaseClass4 {
public:
  BaseClass4(BaseClass4 const &) = delete;            // COMPLIANT - deleted
  BaseClass4(BaseClass4 &&) = delete;                 // COMPLIANT - deleted
  BaseClass4 &operator=(BaseClass4 const &) = delete; // COMPLIANT - deleted
  BaseClass4 &operator=(BaseClass4 &&) = delete;      // COMPLIANT - deleted
};
class DerivedClass4
    : public BaseClass4 { // COMPLIANT - no compiler generated move/copy
};

class NonBaseClass1 { // Not a base class, so fine to be public
public:
  NonBaseClass1(NonBaseClass1 const &) = default;            // COMPLIANT
  NonBaseClass1(NonBaseClass1 &&) = default;                 // COMPLIANT
  NonBaseClass1 &operator=(NonBaseClass1 const &) = default; // COMPLIANT
  NonBaseClass1 &operator=(NonBaseClass1 &&) = default;      // COMPLIANT
};

class NonBaseClass2 {}; // COMPLIANT - move/copy is compiler
                        // generated, but this is not a base class

// A class where the definitions of the move/copy are external to the class body
class BaseClass5 {
public:
  BaseClass5(BaseClass5 const &);            // NON_COMPLIANT
  BaseClass5(BaseClass5 &&);                 // NON_COMPLIANT
  BaseClass5 &operator=(BaseClass5 const &); // NON_COMPLIANT
  BaseClass5 &operator=(BaseClass5 &&);      // NON_COMPLIANT
private:
  int x;
};
class DerivedClass5 // COMPLIANT - not a base class itself
    : public BaseClass5 {};

// We do not want to flag the definitions here - instead, we flag the
// declarations in the class body
BaseClass5::BaseClass5(BaseClass5 const &) {}
BaseClass5::BaseClass5(BaseClass5 &&) {}
BaseClass5 &BaseClass5::operator=(BaseClass5 const &other) { return *this; }
BaseClass5 &BaseClass5::operator=(BaseClass5 &&other) { return *this; }

// Abstract class assumed to be base class even without a derivation
class BaseClass6 {
public:
  BaseClass6(BaseClass6 const &) = default;            // NON_COMPLIANT
  BaseClass6(BaseClass6 &&) = default;                 // NON_COMPLIANT
  BaseClass6 &operator=(BaseClass6 const &) = default; // NON_COMPLIANT
  BaseClass6 &operator=(BaseClass6 &&) = default;      // NON_COMPLIANT
  virtual void test() = 0; // pure virtual function, making this abstract
};

template <class T1> class BaseClass7 {
public:
  BaseClass7() {}
  BaseClass7(BaseClass7 const &) = default;            // NON_COMPLIANT
  BaseClass7(BaseClass7 &&) = default;                 // NON_COMPLIANT
  BaseClass7 &operator=(BaseClass7 const &) = default; // NON_COMPLIANT
  BaseClass7 &operator=(BaseClass7 &&) = default;      // NON_COMPLIANT
  int operator=(int i); // COMPLIANT - not an assignment operator
};                      // COMPLIANT

template <class T>
class DerivedClass7 // COMPLIANT - not a base class itself
    : public BaseClass7<T> {
public:
  DerivedClass7() {}
};

class DerivedClass8 // COMPLIANT - not a base class itself
    : public BaseClass7<int> {
public:
  DerivedClass8() {}
};

class BaseClass8 {
public:
  BaseClass8() {}
  BaseClass8(BaseClass8 const &) = default;            // NON_COMPLIANT
  BaseClass8(BaseClass8 &&) = default;                 // NON_COMPLIANT
  BaseClass8 &operator=(BaseClass8 const &) = default; // NON_COMPLIANT
  BaseClass8 &operator=(BaseClass8 &&) = default;      // NON_COMPLIANT
};

template <class T>
class DerivedClass9 // COMPLIANT - not a base class itself
    : public BaseClass8 {
public:
  DerivedClass9() {}

private:
  T t;
};

template <class T> class BaseClass9 { // NON_COMPLIANT

public:
  BaseClass9() {}
};

template <class T>
class DerivedClass10 // COMPLIANT - not a base class itself
    : public BaseClass9<T> {
public:
  DerivedClass10() {}
};

void test() {
  BaseClass7<int> b;
  DerivedClass7<int> d;
  DerivedClass9<int> e;
  BaseClass9<int> f;
  DerivedClass10<int> g;
}