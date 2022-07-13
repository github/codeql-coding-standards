//% $Id: A15-4-3.cpp 317753 2018-04-27 07:44:02Z jan.babst $
// f1.hpp
void Fn() noexcept;

// f1.cpp
// #include <f1.hpp>
void Fn() noexcept // Compliant
{
  // Implementation
}

// f2.cpp
// #include <f1.hpp>
void Fn() noexcept(false) // Non-compliant - different exception specifier
{
  // Implementation
}

class A {
public:
  void F() noexcept;
  void G() noexcept(false);
  virtual void V1() noexcept = 0;
  virtual void V2() noexcept(false) = 0;
};
void A::F() noexcept // Compliant
// void A::F() noexcept(false) // Non-compliant - different exception specifier
// than in declaration
{
  // Implementation
}
void A::G() noexcept(false) // Compliant
// void A::G() noexcept // Non-compliant - different exception specifier than
// in declaration
{
  // Implementation
}
class B : public A {
public:
  void V1() noexcept override // Compliant
  // void V1() noexcept(false) override // Non-compliant - less restrictive
  // exception specifier in derived method, non-compilable
  {
    // Implementation
  }
  void V2() noexcept override // Compliant - stricter noexcept specification
  {
    // Implementation
  }
};