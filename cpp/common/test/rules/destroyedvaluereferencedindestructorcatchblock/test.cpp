class Base {
public:
  int fieldB;
};

class ClassA : Base {
  int fieldA;

public:
  ClassA(int a) try : fieldA(a) { throw "error"; } catch (...) {
    if (fieldA < 10) { // NON_COMPLIANT
      fieldA = 0;      // NON_COMPLIANT
    }
    this->fieldB = 10; // NON_COMPLIANT
    fieldB = 10;       // NON_COMPLIANT
    Base::fieldB = 10; // NON_COMPLIANT

    try {
      throw "OtherException";
    } catch (...) {
      if (fieldA > 100) { // NON_COMPLIANT
        fieldA = 100;     // NON_COMPLIANT
      }
    }
  };

  ClassA(int a, int b) try : fieldA(a) { throw "error"; } catch (...) {
    if (a < 10) { // COMPLIANT
      throw "NewException";
    }
  }
};