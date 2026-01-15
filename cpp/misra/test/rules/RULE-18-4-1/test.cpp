#include <cstdlib>
#include <exception>

class CompliantClass {
public:
  CompliantClass() noexcept {} // COMPLIANT: constructor is noexcept
  ~CompliantClass() {}         // COMPLIANT: destructor defaults to noexcept

  // COMPLIANT: copy constructor is noexcept
  CompliantClass(const CompliantClass &) noexcept {}

  // COMPLIANT: move constructor is noexcept
  CompliantClass(CompliantClass &&) noexcept {}

  // COMPLIANT: copy assignment operator is noexcept
  CompliantClass &operator=(const CompliantClass &) noexcept { return *this; }

  // COMPLIANT: move assignment operator is noexcept
  CompliantClass &operator=(CompliantClass &&) noexcept { return *this; }

  // COMPLIANT: swap function is noexcept
  friend void swap(CompliantClass &a, CompliantClass &b) noexcept;

  void f() {} // COMPLIANT: Not a special function.
};

class NonCompliantClass {
public:
  // COMPLIANT: constructor doesn't need to be noexcept
  NonCompliantClass() {}

  // COMPLIANT: copy constructor doesn't need to be noexcept. It seems the rule
  // is satisfied if the move constructor is noexcept. If the move constructor
  // is noexcept, the standard containers will safely use it instead of the copy
  // constructor.
  NonCompliantClass(const NonCompliantClass &) {} // COMPLIANT

  ~NonCompliantClass() noexcept(false) {} // NON-COMPLIANT

  NonCompliantClass(NonCompliantClass &&) {} // NON-COMPLIANT

  // COMPLIANT: copy assignment doesn't need to be noexcept. It seems the rule
  // is satisfied if the move assignment operator is noexcept. If the move
  // constructor is noexcept, the standard containers will safely use it instead
  // of the copy assignment operator.
  NonCompliantClass &operator=(const NonCompliantClass &) { return *this; }

  // NON-COMPLIANT
  NonCompliantClass &operator=(NonCompliantClass &&) { return *this; }

  friend void swap(NonCompliantClass &a, NonCompliantClass &b) {
  } // NON-COMPLIANT
};

class DeleteDestructorOk {
  DeleteDestructorOk() = delete; // COMPLIANT
};

class ConstructorNotNoexcept {
public:
  // COMPLIANT: at definition, but checked at use site.
  ConstructorNotNoexcept() {}
};

CompliantClass g1; // COMPLIANT: static initialization with noexcept
ConstructorNotNoexcept
    g2; // NON-COMPLIANT: static initialization without noexcept
thread_local CompliantClass
    g3; // COMPLIANT: thread-local initialization with noexcept
thread_local ConstructorNotNoexcept
    g4; // NON-COMPLIANT: thread-local initialization without noexcept
CompliantClass *g5 = new CompliantClass(); // COMPLIANT: initializing dynamic
                                           // allocation with noexcept
ConstructorNotNoexcept *g6 =
    new ConstructorNotNoexcept(); // NON-COMPLIANT: initializing dynamic
                                  // allocation without noexcept

// Invalid cpp: cannot use constexpr with out noexcept constructor.
// constexpr CompliantClass g7;
// constexpr ConstructorNotNoexcept g8;

void f1() {
  CompliantClass l1;         // COMPLIANT: local initialization with noexcept
  ConstructorNotNoexcept l2; // COMPLIANT: local initialization without noexcept
  static CompliantClass l3;  // COMPLIANT: static initialization with noexcept
  static ConstructorNotNoexcept
      l4; // NON-COMPLIANT: static initialization without noexcept
  thread_local CompliantClass
      l5; // COMPLIANT: thread-local initialization with noexcept
  thread_local ConstructorNotNoexcept
      l6; // NON-COMPLIANT: thread-local initialization without noexcept
  new CompliantClass();         // COMPLIANT: dynamic allocation with noexcept
  new ConstructorNotNoexcept(); // COMPLIANT: not initializing allocation
                                // without noexcept
}

int calledInInitializer() { return 0; }
int calledInInitializerNoexcept() noexcept { return 0; }

int g9 = calledInInitializer();          // NON-COMPLIANT
int g10 = calledInInitializerNoexcept(); // COMPLIANT

typedef int func_t(int);
void take_int_cpp(func_t f);
extern "C" {
void take_int_c(func_t f);
}

int some_func_t(int) { return 0; }
int some_func_t_noexcept(int) noexcept { return 0; }

void f2() {
  take_int_cpp(some_func_t); // COMPLIANT: passing function pointer to cpp
  take_int_cpp(some_func_t_noexcept); // COMPLIANT: passing noexcept function
                                      // pointer to cpp
  take_int_c(some_func_t); // NON-COMPLIANT: passing function pointer to c
                           // without noexcept
  take_int_c(some_func_t_noexcept); // COMPLIANT: passing function pointer to c
                                    // with noexcept
  take_int_cpp([](int) {
    return 0;
  }); // COMPLIANT: passing noexcept function pointer to cpp
  take_int_c([](int) {
    return 0;
  }); // NON-COMPLIANT: passing function pointer to c without noexcept
  take_int_c([](int) noexcept {
    return 0;
  }); // COMPLIANT: passing function pointer to c with noexcept
}

void exit_handler() {}
void exit_handler_noexcept() noexcept {}

void f3() {
  std::atexit(exit_handler); // NON-COMPLIANT: passing function pointer to
                             // atexit without noexcept
  std::atexit(exit_handler_noexcept); // COMPLIANT: passing function pointer to
                                      // atexit with noexcept
  std::at_quick_exit(exit_handler);   // NON-COMPLIANT: passing function pointer
                                      // to at_quick_exit without noexcept
  std::at_quick_exit(
      exit_handler_noexcept);       // COMPLIANT: passing function pointer to
                                    // at_quick_exit with noexcept
  std::set_terminate(exit_handler); // NON-COMPLIANT: passing function pointer
                                    // to set_terminate without noexcept
  std::set_terminate(
      exit_handler_noexcept); // COMPLIANT: passing function pointer to
                              // set_terminate with noexcept
}