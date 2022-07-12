
class ExceptionB {};

class ExceptionA {
public:
  ExceptionA() { throw ExceptionB(); }
};

void test_throwing_throw() {
  throw ExceptionA(); // NON_COMPLIANT - constructor for ExceptionA can throw
                      //                 ExceptionB
}

void test_non_throwing_throw() {
  throw ExceptionB(); // COMPLIANT - ExceptionB() constructor cannot throw an
                      //             exception
}