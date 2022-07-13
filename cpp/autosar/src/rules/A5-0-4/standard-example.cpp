// $Id: A5-0-4.cpp 309849 2018-03-02 09:36:31Z christof.meerwald $
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdlib>
#include <memory>
#include <vector>

class Base {
public:
  virtual ~Base() noexcept = 0;
  virtual void Do() = 0;
};

class Derived1 final : public Base {
public:
  void Do() final {
    // ...
  }

private:
  std::int32_t m_value{0};
};

class Derived2 final : public Base {
public:
  void Do() final {
    // ...
  }

private:
  std::string m_value{};
};

void Foo(Base *start, size_t len) {
  // Non-Compliant: pointer arithmetic on non-final pointer type
  for (Base *iter = start; iter != start + len; ++iter) {
    iter->Do();
  }
}

void Foo(const std::vector<std::unique_ptr<Base>> &v) {
  // Compliant: uses std::unique_ptr for polymorphic objects
  std::for_each(v.begin(), v.end(),
                [](const std::unique_ptr<Base> &ptr) { ptr->Do(); });
}

void DoOpt(Base *obj) {
  if (obj != nullptr) {
    obj->Do();
  }
}

void Bar() {
  std::array<Derived1, 2> arr1;
  Base *base1{arr1.data()};
  Foo(base1, arr1.size());

  DoOpt(&arr1[1]);  // Compliant: pointer arithmetic on final class
  DoOpt(&base1[1]); // Non-Compliant: pointer arithmetic on base class

  std::array<Derived2, 2> arr2;
  Base *base2{arr2.data()};
  Foo(base2, arr2.size());

  DoOpt(arr2.data() + 1); // Compliant: pointer arithmetic on final class
  DoOpt(base2 + 1);       // Non-Compliant: pointer arithmetic on base class

  std::vector<std::unique_ptr<Base>> v;
  v.push_back(std::make_unique<Derived1>());
  v.push_back(std::make_unique<Derived2>());
  Foo(v);
}