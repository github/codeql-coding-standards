#include <functional>
#include <string>

class A {
public:
  A(int x, int y) noexcept : x(x), y(y) {}

  int GetX() const noexcept { return x; }
  int GetY() const noexcept { return y; }

  friend bool operator==(const A &lhs, const A &rhs) noexcept {
    return lhs.x == rhs.x && lhs.y == rhs.y;
  }

private:
  int x;
  int y;
};

class B {
public:
  B(int x, int y) noexcept : x(x), y(y) {}

  int GetX() const noexcept { return x; }
  int GetY() const noexcept { return y; }

  friend bool operator==(const B &lhs, const B &rhs) noexcept {
    return lhs.x == rhs.x && lhs.y == rhs.y;
  }

private:
  int x;
  int y;
};

namespace std {
// COMPLIANT
template <> struct hash<A> {
  std::size_t operator()(const A &a) const noexcept {
    auto h1 = std::hash<decltype(a.GetX())>{}(a.GetX());
    std::size_t seed{h1 + 0x9e3779b9};
    auto h2 = std::hash<decltype(a.GetY())>{}(a.GetY());
    seed ^= h2 + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    return seed;
  }
};

// NON_COMPLIANT
template <> struct hash<B> {
  std::size_t operator()(const B &b) const {
    std::string s{std::to_string(b.GetX()) + "," + std::to_string(b.GetY())};
    return std::hash<std::string>{}(s);
  }
};
} // namespace std
