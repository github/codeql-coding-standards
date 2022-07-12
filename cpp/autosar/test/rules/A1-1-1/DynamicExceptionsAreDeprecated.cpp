void test_des_1() throw(int);        // NON_COMPLIANT
void test_des_2() throw(int, float); // NON_COMPLIANT
void test_des_3() throw();           // NON_COMPLIANT

class Foo {
public:
  Foo(int) throw();                // NON_COMPLIANT
  Foo(bool) throw(int);            // NON_COMPLIANT
  Foo(int, bool) throw(int, bool); // NON_COMPLIANT
  Foo();                           // COMPLIANT

  Foo(const Foo &);    // copy constructor
  Foo &operator=(Foo); // copy-assignment operator
};

void test_no_des_2(); // COMPLIANT