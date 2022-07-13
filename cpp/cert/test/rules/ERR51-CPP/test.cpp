class ExceptionA {};
class ExceptionB {};
class ExceptionC {};

void throwA() { throw ExceptionA(); }

void throwB() {
  throw ExceptionB(); // COMPLIANT - dead code, never thrown
}

class ClassD {
public:
  ClassD() { throw ExceptionC(); }
};

int main() { // NON_COMPLIANT - throws ExceptionA
  throwA();  // Throws ExceptionA

  try {
    throwA(); // Throws ExceptionA, but is caught
  } catch (...) {
  }

  try {
    throwA(); // Throws ExceptionA
  } catch (ExceptionB &b) {
    // IGNORE
  }

  try {
    ClassD classD; // COMPLIANT - initializer exceptions should also
                   // be caught
  } catch (...) {
  }
}