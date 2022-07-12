class ExceptionA {};

class ClassB {
public:
  ClassB() { throw ExceptionA(); }
};

void test_catch_block_candidates() {
  try {
    ClassB b;
    throw ExceptionA();
    try {
      ClassB b2;
      throw ExceptionA();
    } catch (ExceptionA &a) {
    } catch (...) {
      ClassB b2;
      throw ExceptionA();
    }
  } catch (ExceptionA &a) {
  } catch (...) {
  }
}