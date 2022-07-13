#include <new>
#include <stdlib.h>

class ClassA { // Not a trivial class, has a non-trivial constructor
public:
  ClassA(int x);
};

struct TrivialClass {
  int x;
  int y;
};

void test_no_constructor_no_destructor() {

  ClassA *a1 = (ClassA *)malloc(sizeof(ClassA));              // NON_COMPLIANT
  ClassA *a2 = static_cast<ClassA *>(malloc(sizeof(ClassA))); // NON_COMPLIANT
  ClassA *a3 = (ClassA *)::operator new(sizeof(ClassA));      // NON_COMPLIANT
  ClassA *a4 =
      static_cast<ClassA *>(::operator new(sizeof(ClassA))); // NON_COMPLIANT

  free(a1); // NON_COMPLIANT
  free(a2); // NON_COMPLIANT
  // These are direct calls to the `operator delete` function, which do not call
  // the destructor, and therefore are non-compliant
  ::operator delete(a3); // NON_COMPLIANT
  ::operator delete(a4); // NON_COMPLIANT
}

void test_constructor_no_destructor() {
  void *goodAlloc = ::operator new(sizeof(ClassA));
  ClassA *a5 = new (goodAlloc) ClassA{1}; // COMPLIANT
  ClassA *a6 = new ClassA{1};             // COMPLIANT
  TrivialClass *t1 = static_cast<TrivialClass *>(
      ::operator new(sizeof(TrivialClass))); // COMPLIANT

  ::operator delete(goodAlloc); // NON_COMPLIANT[FALSE_NEGATIVE] - no destructor
                                // called for the memory used
  ::operator delete(a6);        // COMPLIANT
  ::operator delete(t1);        // COMPLIANT - trivial class with no need for a
                                // destructor
}

void test_no_constructor_but_has_destructor() {
  ClassA *a1 = (ClassA *)malloc(sizeof(ClassA));              // NON_COMPLIANT
  ClassA *a2 = static_cast<ClassA *>(malloc(sizeof(ClassA))); // NON_COMPLIANT
  ClassA *a3 = (ClassA *)::operator new(sizeof(ClassA));      // NON_COMPLIANT
  ClassA *a4 =
      static_cast<ClassA *>(::operator new(sizeof(ClassA))); // NON_COMPLIANT
  ClassA *a5 =
      static_cast<ClassA *>(::operator new(sizeof(ClassA))); // NON_COMPLIANT

  a1->~ClassA();
  a2->~ClassA();
  a3->~ClassA();
  a4->~ClassA();
  free(a1);              // COMPLIANT - destructor called explicitly
  free(a2);              // COMPLIANT - destructor called explicitly
  ::operator delete(a3); // COMPLIANT - destructor called explicitly
  ::operator delete(a4); // COMPLIANT - destructor called explicitly
  delete a5;             // COMPLIANT - delete calls destructor
}

void test_realloc() {
  void *goodAlloc = ::operator new(sizeof(ClassA));
  ClassA *a1 = new (goodAlloc) ClassA{1};                        // COMPLIANT
  ClassA *a2 = (ClassA *)realloc(goodAlloc, sizeof(ClassA) * 2); // COMPLIANT
}