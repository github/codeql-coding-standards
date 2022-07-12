//% $Id: A15-1-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
class A {
  // Implementation
};
void Fn(std::int16_t i) {
  A a1;
  A &a2 = a1;
  A *a3 = new A;

  if (i < 10) {
    throw a1; // Compliant - copyable object thrown
  } else if (i < 20) {
    throw A(); // Compliant - copyable object thrown
  }

  else if (i < 30) {
    throw a2; // Compliant - copyable object thrown
  }

  else if (i < 40) {
    throw &a1; // Non-compliant - pointer type thrown
  }

  else if (i < 50) {
    throw a3; // Non-compliant - pointer type thrown
  }

  else if (i < 60) {
    throw(*a3); // Compliant - memory leak occurs, violates other rules
  }

  else {
    throw new A; // Non-compliant - pointer type thrown
  }
}