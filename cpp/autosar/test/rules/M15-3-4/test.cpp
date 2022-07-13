
class ExceptionA {};
class ExceptionB {};

void throwA() {
  throw ExceptionA(); // NON_COMPLIANT
}

void throwB() {
  throw ExceptionB(); // COMPLIANT - dead code
}

int main() { throwA(); }