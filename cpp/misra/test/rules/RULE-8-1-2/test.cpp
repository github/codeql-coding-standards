#include <type_traits>

/**
 * Declare relevant parts of std utilities here, so that the resulting path
 * problem nodes and edges are all local paths and don't refer to the actual
 * standard library implementation.
 *
 * This approach reduces the burden of managing compiler compatibility results
 * (since the exact names and source locations etc will vary between compilers
 * and versions), and also fixes local vs CI/CD compatibility where absolute
 * paths differ.
 *
 * However, note that does not fix all issues. Users still will have these
 * absolute paths appear in their own results, which results in unviewable
 * locations inside GitHub code scanning. However, the fix to this would likely
 * require defining our own data modeling for where lambdas are stored in the
 * standard library, which is not work we have yet performed. In the meantime,
 * including these unviewable locations will hopefully still help users track
 * the storage locations of their lambdas.
 */
namespace std {
template <class T> constexpr T &&forward(remove_reference_t<T> &t) noexcept {
  return static_cast<T &&>(t);
}
template <class T> constexpr T &&forward(remove_reference_t<T> &&t) noexcept {
  return static_cast<T &&>(t);
}
template <class> class function;
template <class R, class... Args> class function<R(Args...)> {
public:
  function();
  template <class F> function(F &&f) { auto fptr = new F(std::forward<F>(f)); }
  template <class F> function &operator=(F &&);
};
} // namespace std

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

void m1() {
  int l1, l2, l3;

  // Not transient (always compliant)
  [=]() { return l1; }();          // COMPLIANT
  [&]() { return l1; }();          // COMPLIANT
  [l1]() { return l1; }();         // COMPLIANT
  [&, l1]() { return l1; }();      // COMPLIANT
  [&, l1]() { return l1 + l2; }(); // COMPLIANT

  // Transient by immediate move (must not implicitly capture local variables)
  auto la1 = []() { return 1; };            // COMPLIANT
  auto la2 = [=]() { return 1; };           // COMPLIANT
  auto la3 = [=]() { return l1; };          // NON_COMPLIANT
  auto la4 = [&]() { return l1; };          // NON_COMPLIANT
  auto la5 = [l1]() { return l1; };         // COMPLIANT
  auto la6 = [&, l1]() { return l1; };      // COMPLIANT
  auto la7 = [&, l1]() { return l1 + l2; }; // NON_COMPLIANT

  // Compliant, transient lambdas.
  function_transient([]() { return 1; });            // COMPLIANT
  function_transient([=]() { return 1; });           // COMPLIANT
  function_transient([=]() { return l1; });          // COMPLIANT
  function_transient([&]() { return l1; });          // COMPLIANT
  function_transient([l1]() { return l1; });         // COMPLIANT
  function_transient([&, l1]() { return l1; });      // COMPLIANT
  function_transient([&, l1]() { return l1 + l2; }); // COMPLIANT

  // Non-compliant with implicit local variable capture, non-transient lambdas.
  function_not_transient([]() { return 1; });            // COMPLIANT
  function_not_transient([=]() { return 1; });           // COMPLIANT
  function_not_transient([=]() { return l1; });          // NON_COMPLIANT
  function_not_transient([&]() { return l1; });          // NON_COMPLIANT
  function_not_transient([l1]() { return l1; });         // COMPLIANT
  function_not_transient([&, l1]() { return l1; });      // COMPLIANT
  function_not_transient([&, l1]() { return l1 + l2; }); // NON_COMPLIANT

  // Not valid cpp, as lambda expressions aren't rvalues:
  // f(&([](int i) { return i; }));
  // Not valid cpp, as each lambda expression has a unique implicit type:
  // decltype([](int i) { return i; }) &f = [](int i) { return i; };

  // No implicit capture of local variables, always compliant.
  []() { return 1; }();                            // COMPLIANT
  [=]() { return 1; }();                           // COMPLIANT
  [&]() { return 1; }();                           // COMPLIANT
  [l1]() { return l1; }();                         // COMPLIANT
  function_not_transient([]() { return 1; }());    // COMPLIANT
  function_not_transient([=]() { return 1; }());   // COMPLIANT
  function_not_transient([&]() { return 1; }());   // COMPLIANT
  function_not_transient([l1]() { return l1; }()); // COMPLIANT

  // Dead lambdas should be considered transient:
  []() { return 1; };       // COMPLIANT
  [=]() { return 1; };      // COMPLIANT
  [=]() { return l1; };     // COMPLIANT
  [&]() { return l1; };     // COMPLIANT
  [l1]() { return l1; };    // COMPLIANT
  [&, l1]() { return l1; }; // COMPLIANT

  // Casting to std::function is a copy, so it is non-transient:
  static_cast<std::function<int()>>([]() { return 1; });       // COMPLIANT
  static_cast<std::function<int()>>([=]() { return 1; });      // COMPLIANT
  static_cast<std::function<int()>>([=]() { return l1; });     // NON_COMPLIANT
  static_cast<std::function<int()>>([&]() { return l1; });     // NON_COMPLIANT
  static_cast<std::function<int()>>([l1]() { return l1; });    // COMPLIANT
  static_cast<std::function<int()>>([&, l1]() { return l1; }); // COMPLIANT
  (std::function<int()>)([]() { return 1; });                  // COMPLIANT
  (std::function<int()>)([=]() { return 1; });                 // COMPLIANT
  (std::function<int()>)([=]() { return l1; });                // NON_COMPLIANT
  (std::function<int()>)([&]() { return l1; });                // NON_COMPLIANT
  (std::function<int()>)([l1]() { return l1; });               // COMPLIANT
  (std::function<int()>)([&, l1]() { return l1; });            // COMPLIANT
  static_cast<int (*)()>([]() { return 1; });                  // COMPLIANT

  // Not valid cpp:
  // reinterpret_cast<std::function<int()>>([]() { return 1; });
  // dynamic_cast<std::function<int()>>([]() { return 1; });
  // static_cast<int (*)()>([=]() { return 1; });
  // static_cast<int (*)()>([&]() { return 1; });
}

static int g1;

void f1() {
  int l1, l2;

  // No local variables captured, always compliant
  auto la1 = []() { return 1; };   // COMPLIANT
  auto la2 = [=]() { return 1; };  // COMPLIANT
  auto la3 = [&]() { return 1; };  // COMPLIANT
  auto la4 = []() { return g1; };  // COMPLIANT - global variable
  auto la5 = [=]() { return g1; }; // COMPLIANT - global variable
  auto la6 = [&]() { return g1; }; // COMPLIANT - global variable

  // Implicit capture of local variables
  auto la7 = [=]() { return l1; }; // NON_COMPLIANT
  auto la8 = [&]() { return l1; }; // NON_COMPLIANT
}

void f2() {
  int x, y;

  auto lb1 = (1, [&]() { return 1; });  // COMPLIANT
  auto lb2 = (1, [&]() { return x; });  // NON_COMPLIANT
  auto lb3 = true ? [&]() { return 1; } // COMPLIANT
                  : throw "error";
  auto lb4 = true ? [&]() { return x; } // NON_COMPLIANT
                  : throw "error";
  auto lb5 = true ? throw "error" : [&]() { return 1; }; // COMPLIANT
  auto lb6 = true ? throw "error" : [&]() { return x; }; // NON_COMPLIANT
}

template <typename Func> void function_outside_translation_unit(Func f);

void f3() {
  int l1, l2;

  // Passing the lambda to a function outside the translation unit is considered
  // non-transient, as the lambda may be stored and used later.
  function_outside_translation_unit([=]() { return l1; });     // NON_COMPLIANT
  function_outside_translation_unit([&]() { return l1; });     // NON_COMPLIANT
  function_outside_translation_unit([l1]() { return l1; });    // COMPLIANT
  function_outside_translation_unit([&, l1]() { return l1; }); // COMPLIANT
  function_outside_translation_unit(
      [&, l1]() { return l1 + l2; }); // NON_COMPLIANT
}

class C1 {
public:
  template <typename Func> C1(Func &&f) { new Func(std::forward<Func>(f)); }
};

class C2 : public C1 {
public:
  template <typename Func> C2(Func &&f) : C1(std::forward<Func>(f)) {}
};

class C3 {
public:
  template <typename Func> C3(Func &&f);
};

void f4() {
  int l1, l2;
  // Using a lambda in a constructor, which is transient.
  C1 c1([]() { return 1; });            // COMPLIANT
  C1 c2([=]() { return 1; });           // COMPLIANT
  C1 c3([=]() { return l1; });          // NON_COMPLIANT
  C1 c4([&]() { return l1; });          // NON_COMPLIANT
  C1 c5([l1]() { return l1; });         // COMPLIANT
  C1 c6([&, l1]() { return l1; });      // COMPLIANT
  C1 c7([&, l1]() { return l1 + l2; }); // NON_COMPLIANT
  C2 c8([]() { return 1; });            // COMPLIANT
  C2 c9([=]() { return 1; });           // COMPLIANT
  C2 c10([=]() { return l1; });         // NON_COMPLIANT
  C3 c11([]() { return 1; });           // COMPLIANT
  C3 c12([=]() { return 1; });          // COMPLIANT
  C3 c13([=]() { return l1; });         // NON_COMPLIANT
}
