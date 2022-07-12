// $Id: A7-1-9.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>

enum class DIRECTION { UP, DOWN } dir; // non-compliant

class Foo {
public:
  enum class ONE { AA, BB }; // compliant

  static constexpr enum class TWO { CC, DD } sVar = TWO::CC; // non-compliant
  static constexpr ONE sVar2 = ONE::AA;                      // compliant
};

struct Bar {
  std::uint32_t a;
} barObj; // non-compliant

struct Bar2 {
  std::uint32_t a;
} bar2Obj, *bar2Ptr; // non-compliant, also with A7-1-7

struct Foo2 {
  std::uint32_t f;
};

Foo2 foo2Obj; // compliant