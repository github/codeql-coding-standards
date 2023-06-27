// A single line comment
class ClassA { // COMPLIANT
public:
  // A single line comment
  int a; // COMPLIANT
  // A single line comment
  static int b; // COMPLIANT
  // A single line comment
  void f(); // COMPLIANT
private:
  // A single line comment
  int c; // COMPLIANT
};
// A single line comment
void a();  // COMPLIANT
void a() { // COMPLIANT - according to our rules, a definition doesn't require
           // documentation if the non-definition declaration is documented
}

/*
 * A c-style comment.
 */
class ClassB { // COMPLIANT
public:
  /*
   * A c-style comment.
   */
  int a; // COMPLIANT
  /*
   * A c-style comment.
   */
  static int b; // COMPLIANT
  /*
   * A c-style comment.
   */
  void f(); // COMPLIANT
private:
  /*
   * A c-style comment.
   */
  int c; // COMPLIANT
};
/*
 * A c-style comment.
 */
void b();  // COMPLIANT
void b() { // COMPLIANT - according to our rules, a definition doesn't require
           // documentation if the non-definition declaration is documented
}

/// @brief A Doxygen comment.
class ClassC { // COMPLIANT
public:
  /// @brief A Doxygen comment.
  int a; // COMPLIANT
  /// @brief A Doxygen comment.
  static int b; // COMPLIANT
  /// @brief A Doxygen comment.
  ///
  /// @param i an integer.
  /// @throw std::runtime_error
  void f(int i); // COMPLIANT
private:
  /// @brief A Doxygen comment.
  int c; // COMPLIANT
};
/// A Doxygen comment.
void c(); // COMPLIANT

class ClassD { // NON_COMPLIANT
public:
  int a;        // NON_COMPLIANT
  static int b; // NON_COMPLIANT
  void f();     // NON_COMPLIANT
private:
  int c; // NON_COMPLIANT
};
void d();  // NON_COMPLIANT
void d() { // not flagged, as we will only flag the non-definition declaration
}
void e() { // NON_COMPLIANT - definition with no non-definition declaration, and
           // no documentation.
}

#include <string>
template <typename Message>
std::string
message_to_string_undocumented(Message message) noexcept { // NON_COMPLIANT
  return message.message();
}

/// @brief documents function message_to_string.
template <typename Message>
std::string message_to_string(Message message) noexcept { // COMPLIANT
  return message.message();
}
/// @brief documents user-defined type WarningMessage.
class WarningMessage {
public:
  /// @brief documents function message.
  std::string message() { // COMPLIANT
    return "Warning Message";
  }
};
/// @brief documents function template_function_test.
std::string template_function_test() { // COMPLIANT
  WarningMessage m;
  return message_to_string<WarningMessage>(m);
}

/// @brief function assigned_lambda_test.
int assigned_lambda_test() {
  auto l = [](int x, int y) { return x + y; }; // COMPLIANT: We exclude lambdas.
  return l(2, 3);
}

#include <algorithm>
#include <vector>
/// @brief function lambda_test.
void anon_lambda_test() {
  std::vector<int> data = {1, 2, 3};
  std::for_each(data.begin(), data.end(), [](int n) {}); // COMPLIANT
}

#include <condition_variable>
#include <memory>
#include <mutex>
#include <thread>

/// @brief type Test_462.
class Test_462 {
  /// @brief member variable _thread.
  std::unique_ptr<std::thread> _thread;
  /// @brief function run.
  void run() {}
  /// @brief function test1.
  void test1() {
    _thread = std::make_unique<std::thread>([this]() { run(); }); // COMPLIANT
  }
};

// lambda captures produce member variable in the closure type
// test that no documentation is required
#include <iostream>
/// @brief function TestCapture.
void testCapture() {
  std::string str{"Hello World"};
  [str]() { std::cout << str << '\n'; }();
}

class ClassE; // COMPLIANT - ignore forward declarations

// A single line comment
class ClassE {}; // COMPLIANT

template <typename T> class A2_7_3 final {
public:
  /// @brief This is the foo documentation
  const std::string kFoo{"foo"}; // COMPLIANT
  const std::string kBar{"bar"}; // NON_COMPLIANT
};
/// @brief This is the instantiateA2_7_3 documentation
void instantiateA2_7_3() { A2_7_3<int> instance; }