#include <memory>
#include <string>

namespace std {}

// TODO test [[gsl::Owner]]

void f(int x);

void test_pointer_aliasing() {
  int *p = nullptr;
  {
    int x = 0;
    p = &x;
    *p = 1; // COMPLIANT
  }
  *p = 2; // NON_COMPLIANT
}

class ClassA {
public:
  int i = 0;
};

std::unique_ptr<ClassA> getUniquePtr() {
  std::unique_ptr<ClassA> up(new ClassA());
  return up;
}

void test_unique_ptr() {
  const ClassA &a = *getUniquePtr();
  a.i; // NON_COMPLIANT - the temporary object holding the unique_ptr returned
       // from getUniquePtr is out of scope, so rA is a reference to invalid
       // memory

  auto retVal = getUniquePtr();
  const ClassA &a2 = *retVal;
  a2.i; // COMPLIANT - lifetime of underlying Class is bound to retVal in this
        // case
}

void test_owner_reset() {
  std::unique_ptr<ClassA> up(new ClassA());
  ClassA &a = *up;
  a.i; // COMPLIANT - a is still valid
  up.reset(new ClassA());
  a.i; // NON_COMPLIANT - a is a reference to the old ClassA
}

void test_iterator() {
  std::string s = "A string";
  for (std::string::iterator it = s.begin(); it != s.end(); ++it) {
    *it; // NON_COMPLIANT
    s = "a new string";
  }
}

void use(const char *c) { *c; }
std::string get_temp_string();

void test_temp_string() {
  const char *contents = get_temp_string().c_str();
  use(contents); // NON_COMPLIANT - reference to temp
}