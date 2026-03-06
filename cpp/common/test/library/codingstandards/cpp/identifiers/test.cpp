#include <iostream>
#include <memory>
#include <utility>
#include <vector>

// Preprocessor identifiers
#define MACRO_CONSTANT 42
#define FUNCTION_MACRO(x) ((x)*2)
#define FUNCTION_MACRO_NOARGS() 0xFF
#define VARIADIC_MACRO(fmt, ...) printf(fmt, __VA_ARGS__)
#define VARIADIC_MACRO_CUSTOM(fmt, addl_args...) printf(fmt, addl_args)

// Global variables
int global_var = 10;
const int const_global = 20;
static int static_global = 30;
extern int extern_var;
thread_local int thread_local_var = 40;
int multiple_global_ids1, multiple_global_ids2;

// Function declarations and definitions
void simple_function();
int function_with_params(int param1, float param2);
auto auto_return_function() -> int;
inline int inline_function() { return 42; }
static int static_function() { return 42; }
extern "C" int c_function();

// Function with various parameter types
void complex_function(int normal_param, int &ref_param,
                      const int &const_ref_param, int *ptr_param,
                      int &&rvalue_ref_param, int array_param[],
                      int (*function_ptr)(int), void (*callback)());

void forward_declared_twice(int apm);
void forward_declared_twice(int apm);

void forward_declared_twice_differing(int apm);
void forward_declared_twice_differing(int bpm);

// Variadic functions
void variadic_function(int count, ...);
template <typename... Args> void variadic_template_function(Args... args);

// Namespace declarations
namespace outer_namespace {
int namespace_var = 100;

namespace inner_namespace {
int inner_var = 200;
}

namespace nested::deeply::nested {
int deep_var = 300;
}
} // namespace outer_namespace

// Namespace aliases
namespace alias_ns = outer_namespace;
namespace short_alias = outer_namespace::inner_namespace;

// Using declarations
using outer_namespace::namespace_var;
using std::cout;
using std::endl;

// Type aliases
using IntAlias = int;
using FunctionPtrAlias = int (*)(int);
template <typename T> using TemplateAlias = std::vector<T>;

// Traditional typedef
typedef int OldStyleInt;
typedef struct {
  int x, y;
} Point;
typedef int MultipleTypedefs, AnotherTypedef, *YetAnotherTypedef;

// Enumeration types
enum Color { RED, GREEN, BLUE };
enum class StrongColor : int { RED = 1, GREEN = 2, BLUE = 3 };
enum { ANONYMOUS_ENUM_VALUE = 99 };

// Forward declarations
class ForwardDeclaredClass;
struct ForwardDeclaredStruct;
union ForwardDeclaredUnion;

// Basic class with various member types
class BasicClass {
public:
  // Constructor and destructor identifiers
  BasicClass();
  BasicClass(int value);
  BasicClass(long declared_not_defined);
  BasicClass(const BasicClass &other);
  BasicClass(BasicClass &&other);
  ~BasicClass();

  // Assignment operators
  BasicClass &operator=(const BasicClass &other);
  BasicClass &operator=(BasicClass &&other);

  // Member variables
  int member_var;
  static int static_member;
  const int const_member;
  mutable int mutable_member;

  // Member functions
  void member_function();
  int const_member_function() const;
  virtual void virtual_function();
  virtual void pure_virtual_function() = 0;
  static void static_member_function();

  // Operator overloads
  BasicClass &operator+(const BasicClass &other) const;
  BasicClass &operator++();
  BasicClass &operator++(int);
  bool operator==(const BasicClass &other) const;
  int &operator[](int index);

  // Conversion operators
  operator int() const;
  explicit operator bool() const;

  // Friend declarations
  friend class FriendClass;
  friend void friend_function(const BasicClass &);
  friend void friend_function_no_impl(const BasicClass &);
  friend BasicClass &operator*(const BasicClass &, const BasicClass &);
  // operator with no implementation
  friend BasicClass &operator+(const BasicClass &, const BasicClass &);

  // Nested types
  class NestedClass {
  public:
    int nested_member;
    void nested_function();
  };

  struct NestedStruct {
    int struct_member;
  };

  union NestedUnion {
    int int_member;
    float float_member;
  };

  enum NestedEnum { NESTED_VALUE };

private:
  int private_member;

protected:
  int protected_member;
};

// Struct with various features
struct ComplexStruct {
  int x, y, z;

  // Constructor in struct
  ComplexStruct(int a, int b, int c) : x(a), y(b), z(c) {}

  // Operator overload in struct
  ComplexStruct operator+(const ComplexStruct &other) const {
    return ComplexStruct(x + other.x, y + other.y, z + other.z);
  }
};

// Union types
union SimpleUnion {
  int int_value;
  float float_value;
  char char_array[4];
};

// Anonymous union
static union {
  int anonymous_int;
  float anonymous_float;
};

// Anonymous struct
struct {
  int anonymous_struct_member;
} anonymous_struct_instance;

// Template declarations
template <typename T> class TemplateClass {
public:
  T template_member;

  TemplateClass(T value) : template_member(value) {}

  // Note: the identifier "param2" is missing from the database, and cannot be
  // matched as an identifier. The later implementation of this function gets a
  // duplicate "param" identifier.
  template <typename U> void template_member_function(U param2);
  // Mirrors the above case, but there is no corresponding function definition.
  // In this case, the identifier "param" is in the database and correctly
  // matched.
  template <typename U> void template_member_function_unused(U param);

  // Nested template
  template <typename V> class NestedTemplate { V nested_template_member; };
};

// Template function
template <typename T, typename U> T template_function(T first, U second) {
  return first;
}

// Template specialization
template <> class TemplateClass<int> {
public:
  int specialized_member;
  TemplateClass(int value) : specialized_member(value) {}
};

// Partial template specialization
template <typename T> class TemplateClass<T *> {
public:
  T *pointer_member;
  TemplateClass(T *ptr) : pointer_member(ptr) {}
};

// Template with non-type parameters
template <int N, typename T> class FixedArray {
  T array[N];

public:
  // This and other constexprs in templates seem to have redundant variables
  // declared. These should currently be harmless to users of this library at
  // the moment, but that is not necessarily the case in the future.
  static constexpr int size = N;
};

// Template with template parameters
template <template <typename> class Container, typename T>
class TemplateTemplateClass {
  Container<T> container;
};

// Variable templates (C++14)
template <typename T> constexpr T variable_template = T{};

// Alias templates
template <typename T> using VectorAlias = std::vector<T>;

// Inheritance
class BaseClass {
public:
  virtual ~BaseClass() = default;
  virtual void base_virtual_function() = 0;
};

class DerivedClass : public BaseClass {
public:
  void base_virtual_function() override;
  void derived_function();
};

// Multiple inheritance
class MultipleInheritance : public BaseClass, public ComplexStruct {
public:
  void base_virtual_function() override;
};

// Virtual inheritance
class VirtualBase {
public:
  int virtual_base_member;
};

class VirtualDerived1 : public virtual VirtualBase {
public:
  int derived1_member;
};

class VirtualDerived2 : public virtual VirtualBase {
public:
  int derived2_member;
};

class Diamond : public VirtualDerived1, public VirtualDerived2 {
public:
  int diamond_member;
};

// User-defined literals
constexpr long long operator""_km(unsigned long long value) {
  return value * 1000;
}

constexpr long double operator""_celsius(long double temp) {
  return temp + 273.15;
}

// Raw string literal operator
std::string operator""_raw(const char *str, size_t len) {
  return std::string(str, len);
}

// Function objects and lambdas
class FunctionObject {
public:
  int operator()(int x) const { return x * 2; }
};

// Exception classes
class CustomException : public std::exception {
public:
  const char *what() const noexcept override { return "Custom exception"; }
};

// Function with various control flow and local declarations
void complex_function_body() {
  // Local variables
  int local_var = 10;
  const int const_local = 20;
  static int static_local = 30;

  // Arrays
  int array[10];
  int dynamic_array[] = {1, 2, 3, 4, 5};

  // Pointers and references
  int *ptr = &local_var;
  int &ref = local_var;

  // Auto declarations
  auto auto_var = 42;
  auto auto_ptr = std::make_unique<int>(42);

  // Structured bindings (C++17)
  auto pair = std::make_pair(1, 2.0f);
  auto [first, second] = pair;

  // Range-based for loop (implicit iterator declarations)
  int range_array[] = {1, 2, 3, 4, 5};
  for (int element : range_array) {
    // element is implicitly declared
  }

  for (auto &ref_element : range_array) {
    // ref_element is implicitly declared
  }

  // Traditional for loop
  for (int i = 0; i < 10; ++i) {
    // i is declared in for loop
  }

  // While loop
  int counter = 0;
  while (counter < 5) {
    ++counter;
  }

  // Do-while loop
  do {
    --counter;
  } while (counter > 0);

  // Switch statement with labels
  switch (local_var) {
  case 1:
    // No identifier introduced
    break;
  case 2: {
    int case_local = 42;
    break;
  }
  default:
    break;
  }

  // Goto labels
  goto label1;

label1:
  // Label identifier

  // Try-catch blocks
  try {
    throw CustomException();
  } catch (const CustomException &e) {
    // e is declared in catch block
  } catch (const std::exception &generic_e) {
    // generic_e is declared
  } catch (...) {
    // No identifier
  }

  // Lambda expressions
  auto simple_lambda = []() { return 42; };

  auto lambda_with_capture = [local_var](int param) -> int {
    return local_var + param;
  };

  auto lambda_with_various_captures = [&, local_var](int x) mutable {
    return local_var + x;
  };

  // Generic lambda (C++14)
  auto generic_lambda = [](auto x, auto y) { return x + y; };

  // Lambda with template parameter (C++20)
  auto template_lambda = []<typename T>(T value) { return value * 2; };

  // If statement with initializer (C++17)
  if (auto result = simple_lambda(); result > 0) {
    // result is declared in if statement
  }

  // Switch with initializer (C++17)
  switch (auto val = local_var * 2; val) {
  case 20:
    break;
  default:
    break;
  }

  // Conditional operator with declarations
  int condition = 1;
  int result = condition ? local_var : static_local;

  // Compound literals (C99 style, limited support in C++)
  int *compound_literal = (int[]){1, 2, 3, 4, 5};

  // Nested scope
  {
    int nested_scope_var = 100;
    { int deeply_nested_var = 200; }
  }
}

// Template instantiations (explicit)
// These should not introduce new identifiers.
template class TemplateClass<double>;
template int template_function<int, float>(int, float);
template const double variable_template<double>;

// Explicit template instantiation declarations
extern template class TemplateClass<float>;
extern template float template_function<float, double>(float, double);

// Template member function definitions
// Note: this template parameter `T` does not get added to the database, so we
// cannot support the inclusion of 'T' in the identifiers.
template <typename T>
// Note: Unlike above, the template parameter `U` does get added to the database
// and is supported.
template <typename U>
// See the forward declaration comment above: the forward declared parameter
// name "param2" is not included in the database. Instead, two
// `VariableDeclarationEntry`s with name "param" exist at this location. Thus,
// we get two identifiers for "param" here which is not correct but that is the
// best we can do for now.
void TemplateClass<T>::template_member_function(U param) {
  // Implementation
}

// Static member definitions
int BasicClass::static_member = 42;

// Non-template member function definitions
void BasicClass::member_function() {
  // Implementation
}

// Constructor definitions with member initializer lists
BasicClass::BasicClass() : member_var(0), const_member(10), mutable_member(20) {
  // Constructor body
}

BasicClass::BasicClass(int value)
    : member_var(value), const_member(value), mutable_member(value) {
  // Constructor body
}

// Destructor definition
BasicClass::~BasicClass() {
  // Destructor body
}

// Operator overload definitions
BasicClass &BasicClass::operator+(const BasicClass &other) const {
  throw "stub";
}

// Friend function definition
void friend_function(const BasicClass &obj) {
  // Can access private members
}

// Nested class member definitions
void BasicClass::NestedClass::nested_function() {
  // Implementation
}

// Global operator overload
BasicClass &operator*(const BasicClass &lhs, const BasicClass &rhs) {
  throw "stub";
}

// Function with function-try-block
BasicClass::BasicClass(const BasicClass &other) try
    : member_var(other.member_var), const_member(other.const_member),
      mutable_member(other.mutable_member) {
  // Constructor body
} catch (...) {
  // Exception handling
}

// Concepts (C++20)
#if __cpp_concepts
template <typename T>
concept Addable = requires(T a, T b) {
  a + b;
};

template <Addable T> T add(T a, T b) { return a + b; }
#endif

// Coroutines (C++20)
#if __cpp_coroutines
#include <coroutine>

struct SimpleCoroutine {
  struct promise_type {
    SimpleCoroutine get_return_object() {
      return SimpleCoroutine{
          std::coroutine_handle<promise_type>::from_promise(*this)};
    }
    std::suspend_never initial_suspend() { return {}; }
    std::suspend_never final_suspend() noexcept { return {}; }
    void return_void() {}
    void unhandled_exception() {}
  };

  std::coroutine_handle<promise_type> handle;
};

SimpleCoroutine coroutine_function() { co_return; }
#endif

// Module declarations (C++20)
#if __cpp_modules
export module test_module;
export int exported_function();
#endif

// Designated initializers (C++20)
struct Point3D {
  int x, y, z;
};

void designated_initializer_example() { Point3D p = {.x = 1, .y = 2, .z = 3}; }

// Attribute declarations
[[nodiscard]] int attribute_function();
[[deprecated("Use new_function instead")]] void old_function();
[[maybe_unused]] int unused_variable = 42;
// Note: Currently missing `custom_namespace` in the matched identifiers.
[[custom_namespace::custom_attr]] int custom_attr_var = 42;

// Attributes on classes
// Note: for some reason missing the `nodiscard` attribute in the matched
// identifiers.
[[nodiscard]] class [[deprecated("Use NewClass instead")]] OldClass{};

// Attributes on statements
void attribute_on_statement() {
  int x = 0;
  // not a variable declaration, but an attribute on a statement "x++"
  [[my_attr]] x++;

  // attribute on lambda
  // Note: for some reason missing the `my_attr` attribute in the matched
  // identifiers.
  auto lambda = []() [[my_attr]] {
    // Implementation
  };
}

// Inline namespaces
inline namespace versioning {
namespace v1 {
void api_function_v1();
}

namespace v2 {
void api_function_v2();
}
} // namespace versioning

// Anonymous namespaces
namespace {
int anonymous_namespace_var = 123;
void anonymous_namespace_function() {}
} // namespace

// Extern template declarations
extern template class std::vector<int>;

// Thread-local storage
thread_local int thread_local_counter = 0;

// Constexpr and consteval functions
constexpr int constexpr_function(int x) { return x * x; }

#if __cpp_consteval
consteval int consteval_function(int x) { return x + 1; }
#endif

// Variable declarations with various storage classes
extern const int extern_const;
static constexpr int static_constexpr = 42;
inline constexpr int inline_constexpr = 100;

// Structured binding declarations
void structured_binding_examples() {
  std::pair<int, float> pair_value = {42, 3.14f};
  auto [int_part, float_part] = pair_value;

  int array[3] = {1, 2, 3};
  auto [a, b, c] = array;

  struct LocalStruct {
    int x;
    float y;
  };
  LocalStruct local_struct{10, 20.0f};
  auto [struct_x, struct_y] = local_struct;
}

// Function pointer declarations
int (*global_function_ptr)(int) = nullptr;
void (*void_function_ptr)() = nullptr;

// Member function pointers
int (BasicClass::*member_function_ptr)() const = nullptr;
int BasicClass::*member_variable_ptr = nullptr;

// Reference declarations
int &reference_to_global = global_var;
const int &const_reference_to_global = const_global;

// Bit fields
struct BitFieldStruct {
  unsigned int flag1 : 1;
  unsigned int flag2 : 1;
  unsigned int value : 30;
};

// Flexible array member (C99 feature, limited C++ support)
struct FlexibleArray {
  int count;
  int data[]; // Flexible array member
};