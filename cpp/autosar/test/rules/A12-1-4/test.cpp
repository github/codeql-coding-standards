class ClassA {
public:
  ClassA() : m_i(0) {}      // COMPLIANT
  ClassA(int i) : m_i(i) {} // NON_COMPLIANT - not marked explicit
  explicit ClassA(unsigned int i) : m_i(i) {} // COMPLIANT
  ClassA(ClassA const &) = default;           // COMPLIANT
  ClassA(ClassA &&) = default;                // COMPLIANT
  ClassA(int i, int j) : m_i(i + j) {}        // COMPLIANT
private:
  int m_i;
};

template <typename T> class ClassB {
public:
  ClassB(T t) : m_t(t) {} // NON_COMPLIANT - not marked explicit
private:
  T m_t;
};

template <typename T> class ClassC {
public:
  ClassC(T t) : m_t(t) {} // COMPLIANT - not used for fundamental types
private:
  T m_t;
};

template <typename T> class ClassD {
public:
  explicit ClassD(T t) : m_t(t) {} // COMPLIANT
private:
  T m_t;
};

void test_templates() {
  ClassB<int> b(1); // triggers creation of non compliant constructor
  ClassA a;
  ClassC<ClassA> c(a); // triggers creation of non compliant constructor
  ClassD<int> d(1);    // triggers creation of compliant explicit constructor
}

class ClassE {
public:
  // Can be called with 1 argument of fundamental type
  ClassE(int i, int j = 0) : m_i(i), m_j(j) {} // NON_COMPLIANT
private:
  int m_i;
  int m_j;
};

class ClassF {
public:
  explicit ClassF(int i, int j = 0) : m_i(i), m_j(j) {} // COMPLIANT
private:
  int m_i;
  int m_j;
};