#include <functional>

template <typename Func> void function_transient(Func f) {
  // transient, does not store.
  f();
}

template <typename Func> void function_not_transient(Func f) {
  // Non transient, stores the lambda.
  auto l = f; // NON_COMPLIANT
}

template <typename Func> void calls_function_transient(Func f) {
  // Calls a function that takes a transient lambda.
  function_transient(f);
}

template <typename Func> void calls_function_not_transient(Func f) {
  // Calls a function that takes a non transient lambda.
  function_not_transient(f); // NON_COMPLIANT
}

class C1 {
  int f1;

  void m1() {
    // Not transient (always compliant)
    [=]() { return f1; }();                 // COMPLIANT
    [&]() { return f1; }();                 // COMPLIANT
    [this]() { return f1; }();              // COMPLIANT
    [self = *this]() { return self.f1; }(); // COMPLIANT
    [&, self = *this]() { return f1; }();   // COMPLIANT

    // Transient by immediate move (must not implicitly capture this)
    auto l1 = []() { return 1; };                   // COMPLIANT
    auto l2 = [=]() { return 1; };                  // COMPLIANT
    auto l3 = [=]() { return f1; };                 // NON_COMPLIANT
    auto l4 = [&]() { return f1; };                 // NON_COMPLIANT
    auto l5 = [this]() { return f1; };              // COMPLIANT
    auto l6 = [self = *this]() { return self.f1; }; // COMPLIANT
    auto l7 = [&, self = *this]() { return f1; };   // NON_COMPLIANT

    // Compliant, transient lambdas.
    function_transient([]() { return 1; });                   // COMPLIANT
    function_transient([=]() { return 1; });                  // COMPLIANT
    function_transient([=]() { return f1; });                 // COMPLIANT
    function_transient([&]() { return f1; });                 // COMPLIANT
    function_transient([this]() { return f1; });              // COMPLIANT
    function_transient([self = *this]() { return self.f1; }); // COMPLIANT
    function_transient([&, self = *this]() { return f1; });   // COMPLIANT

    // Non-compliant with implicit this capture, non-transient lambdas.
    function_not_transient([]() { return 1; });      // COMPLIANT
    function_not_transient([=]() { return 1; });     // COMPLIANT
    function_not_transient([=]() { return f1; });    // NON_COMPLIANT
    function_not_transient([&]() { return f1; });    // NON_COMPLIANT
    function_not_transient([this]() { return f1; }); // COMPLIANT
    function_not_transient([self = *this]() { return self.f1; }); // COMPLIANT
    function_not_transient([&, self = *this]() { return f1; }); // NON_COMPLIANT

    // Not valid cpp, as lambda expressions aren't rvalues:
    // f(&([](int i) { return i; }));
    // Not valid cpp, as each lambda expression has a unique implicit type:
    // decltype([](int i) { return i; }) &f = [](int i) { return i; };

    // No implicit capture of this, always compliant.
    []() { return 1; }();                                     // COMPLIANT
    [=]() { return 1; }();                                    // COMPLIANT
    [&]() { return 1; }();                                    // COMPLIANT
    [this]() { return 1; }();                                 // COMPLIANT
    [self = *this]() { return 1; }();                         // COMPLIANT
    function_not_transient([]() { return 1; }());             // COMPLIANT
    function_not_transient([=]() { return 1; }());            // COMPLIANT
    function_not_transient([&]() { return 1; }());            // COMPLIANT
    function_not_transient([this]() { return 1; }());         // COMPLIANT
    function_not_transient([self = *this]() { return 1; }()); // COMPLIANT

    // Dead lambdas should be considered transient:
    []() { return 1; };                   // COMPLIANT
    [=]() { return 1; };                  // COMPLIANT
    [=]() { return f1; };                 // COMPLIANT
    [&]() { return f1; };                 // COMPLIANT
    [this]() { return f1; };              // COMPLIANT
    [self = *this]() { return self.f1; }; // COMPLIANT
    [&, self = *this]() { return f1; };   // COMPLIANT

    // Casting to std::function is a copy, so it is non-transient:
    static_cast<std::function<int()>>([]() { return 1; });      // COMPLIANT
    static_cast<std::function<int()>>([]() { return 1; });      // COMPLIANT
    static_cast<std::function<int()>>([=]() { return f1; });    // NON_COMPLIANT
    static_cast<std::function<int()>>([&]() { return f1; });    // NON_COMPLIANT
    static_cast<std::function<int()>>([this]() { return f1; }); // COMPLIANT
    static_cast<std::function<int()>>(
        [self = *this]() { return self.f1; });       // COMPLIANT
    (std::function<int()>)([]() { return 1; });      // COMPLIANT
    (std::function<int()>)([=]() { return 1; });     // COMPLIANT
    (std::function<int()>)([=]() { return f1; });    // NON_COMPLIANT
    (std::function<int()>)([&]() { return f1; });    // NON_COMPLIANT
    (std::function<int()>)([this]() { return f1; }); // COMPLIANT
    (std::function<int()>)([self = *this]() { return self.f1; }); // COMPLIANT
    static_cast<int (*)()>([]() { return 1; });                   // COMPLIANT

    // Not valid cpp:
    // reinterpret_cast<std::function<int()>>([]() { return 1; });
    // dynamic_cast<std::function<int()>>([]() { return 1; });
    // static_cast<int (*)()>([=]() { return 1; });
    // static_cast<int (*)()>([&]() { return 1; });
    // static_cast<int (*)()>([this]() { return 1; });
    // static_cast<int (*)()>([self = *this]() { return 1; });
  }

  static int f2;
  static void m2() {
    // No 'this' pointer to capture, since its a static method.
    auto l1 = []() { return 1; };   // COMPLIANT
    auto l2 = [=]() { return 1; };  // COMPLIANT
    auto l3 = [&]() { return 1; };  // COMPLIANT
    auto l4 = []() { return f2; };  // COMPLIANT
    auto l5 = [=]() { return f2; }; // COMPLIANT
    auto l6 = [&]() { return f2; }; // COMPLIANT
  }
};

void f1() {
  // No 'this' pointer to capture, since its not a class method.
  auto l1 = []() { return 1; };  // COMPLIANT
  auto l2 = [=]() { return 1; }; // COMPLIANT
  auto l3 = [&]() { return 1; }; // COMPLIANT
}

class C2 {
  int f1;
  void m2() {
    auto l1 = (1, [&]() { return 1; });  // COMPLIANT
    auto l2 = (1, [&]() { return f1; }); // NON_COMPLIANT
    auto l3 = true ? [&]() { return 1; } // COMPLIANT
                   : throw "error";
    auto l4 = true ? [&]() { return f1; } // NON_COMPLIANT
                   : throw "error";
    auto l5 = true ? throw "error" : [&]() { return 1; };  // COMPLIANT
    auto l6 = true ? throw "error" : [&]() { return f1; }; // NON_COMPLIANT
  }
};

template <typename Func> void function_outside_translation_unit(Func f);

class C3 {
  int f1, f2;

  void m3() {
    // Passing the lambda to a function outside the translation unit is
    // considered non-transient, as the lambda may be stored and used later.
    function_outside_translation_unit([=]() { return f1; });    // NON_COMPLIANT
    function_outside_translation_unit([&]() { return f1; });    // NON_COMPLIANT
    function_outside_translation_unit([this]() { return f1; }); // COMPLIANT
    function_outside_translation_unit(
        [self = *this]() { return self.f1; }); // COMPLIANT
  }
};

class CopyAssignFunctorClass {
public:
  template <class Func> void operator=(Func &&f) {
    new Func(std::forward<Func>(f));
  }
};

class C4 {
  int f1;

  void m4() {
    CopyAssignFunctorClass functor;
    // Not transient, but no implicit this:
    functor = [&]() { return 1; }; // COMPLIANT
    // Non transient (copies assigned value), implicit this
    functor = [&]() { return f1; }; // NON_COMPLIANT
  }
};