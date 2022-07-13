#include <cstdint>
#include <functional> 
#include <string>
#include <unordered_map>
class A 
{ 
  public:
    A(uint32_t x, uint32_t y) noexcept : x(x), y(y) {}
    uint32_t GetX() const noexcept { return x; }
    uint32_t GetY() const noexcept { return y; }

    friend bool operator == (const A &lhs, const A &rhs) noexcept 
    { return lhs.x == rhs.x && lhs.y == rhs.y; }
    private: 
      uint32_t x; 
      uint32_t y; 
};

class B
{
  public:
    B(uint32_t x, uint32_t y) noexcept : x(x), y(y) {} 
    uint32_t GetX() const noexcept { return x; }
    uint32_t GetY() const noexcept { return y; }

    friend bool operator == (const B &lhs, const B &rhs) noexcept 
    { return lhs.x == rhs.x && lhs.y == rhs.y; }
  private: 
    uint32_t x; uint32_t y; };

namespace std 
{
  // Compliant 
  template <> struct hash<A> {
    std::size_t operator()(const A& a) const noexcept
    {
      auto h1 = std::hash<decltype(a.GetX())>{}(a.GetX()); 
      std::size_t seed { h1 + 0x9e3779b9 };
      auto h2 = std::hash<decltype(a.GetY())>{}(a.GetY()); 
      seed ^= h2 + 0x9e3779b9 + (seed << 6) + (seed >> 2); 
      return seed;
    }
  };

  // Non-compliant: string concatenation can potentially throw
  template <>
  struct hash<B>
  {
    std::size_t operator()(const B& b) const
    {
      std::string s{std::to_string(b.GetX()) + ',' + std::to_string(b.GetY())}; 
      return std::hash<std::string>{}(s);
    }
  };
}

int main()
{
  std::unordered_map<A, bool> m1 { { A{5, 7}, true } };

  if (m1.count(A{4, 3}) != 0)
  {
    // ....
  }

  std::unordered_map<B, bool> m2 { { B{5, 7}, true } };
 
  // Lookup can potentially throw if hash function throws
  if (m2.count(B{4, 3}) != 0)
  {
    // ....
  }
}