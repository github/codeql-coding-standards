#include <cstdint>

// Helper types
enum UnscopedEnum { A, B, C };
enum SmallEnum : uint8_t { S1, S2 };

uint8_t operator+(SmallEnum e) { return static_cast<uint8_t>(e); }

void test_unary_plus() {
  // === NON-COMPLIANT: integral promotion ===
  uint8_t u8 = 1;
  auto a = +u8; // NON_COMPLIANT: promotes to int

  int8_t i8 = 1;
  auto b = +i8; // NON_COMPLIANT: promotes to int

  uint16_t u16 = 1;
  auto c = +u16; // NON_COMPLIANT: promotes to int

  char ch = 'x';
  auto d = +ch; // NON_COMPLIANT: promotes to int

  bool bl = true;
  auto e = +bl; // NON_COMPLIANT: promotes to int

  auto f = +UnscopedEnum::A; // NON_COMPLIANT: promotes to int

  // === NON_COMPLIANT: function/lambda decay ===
  void (*fp)() = +[]() {};   // NON_COMPLIANT: lambda decays to pointer
  auto g = +test_unary_plus; // NON_COMPLIANT: function decays to pointer

  // === NON_COMPLIANT: literals and expressions ===
  auto h = +1;    // NON_COMPLIANT: unary + on literal
  auto i = +'a';  // NON_COMPLIANT: promotes char to int
  auto j = +true; // NON_COMPLIANT: promotes bool to int

  int x;
  x = +1; // NON_COMPLIANT: unary +, not +=

  // === NON_COMPLIANT: larger types (still built-in +) ===
  int i32 = 1;
  auto k = +i32; // NON_COMPLIANT: built-in unary +

  long l = 1;
  auto m = +l; // NON_COMPLIANT: built-in unary +

  double dbl = 1.0;
  auto n = +dbl; // NON_COMPLIANT: built-in unary +

  // === COMPLIANT: user-defined operator+ ===
  auto o = +SmallEnum::S1;           // COMPLIANT: calls user-defined operator+
  auto p = operator+(SmallEnum::S2); // COMPLIANT: explicit call

  // === COMPLIANT: not unary + ===
  auto q = 1 + 2;   // COMPLIANT: binary +
  auto r = u8 + u8; // COMPLIANT: binary +

  int y = 0;
  y += 1; // COMPLIANT: compound assignment
}

// === NON_COMPLIANT: in other contexts ===
template <typename T> T promote(T val) {
  return +val; // NON_COMPLIANT (when T is built-in type)
}

void test_template() {
  promote(uint8_t{1}); // Instantiates NON_COMPLIANT case
  promote(1);          // Instantiates NON_COMPLIANT case
}

// === NON_COMPLIANT: array decay ===
void test_array() {
  int arr[5];
  auto ptr = +arr; // NON_COMPLIANT: array decays to pointer
}
