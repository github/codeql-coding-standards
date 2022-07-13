#include <stdexcept>

class ClassA {
public:
  ~ClassA() { throw std::exception(); }
};

ClassA classA; // NON_COMPLIANT - exception thrown during destruction