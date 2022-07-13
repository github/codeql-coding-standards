// $Id: A18-1-4.cpp 313638 2018-03-26 15:34:51Z jan.babst $
#include <memory>
class A {};
void F1() {
  // Create a dynamically allocated array of 10 objects of type A.
  auto up1 = std::make_unique<A[]>(10); // Compliant

  std::unique_ptr<A> up2{up1.release()}; // Non-compliant
}
void F2() {
  auto up1 = std::make_unique<A[]>(10); // Compliant

  std::unique_ptr<A> up2;
  up2.reset(up1.release()); // Non-compliant
}
void F3() {
  auto up = std::make_unique<A[]>(10); // Compliant

  std::shared_ptr<A> sp{up.release()}; // Non-compliant
}
void F4() {
  auto up = std::make_unique<A[]>(10); // Compliant

  std::shared_ptr<A> sp;
  sp.reset(up.release()); // Non-compliant
}
void F5() {
  auto up = std::make_unique<A[]>(10); // Compliant

  // sp will obtain its deleter from up, so the array will be correctly
  // deallocated. However, this is no longer allowed in C++17.
  std::shared_ptr<A> sp{std::move(up)}; // Non-compliant
  sp.reset(new A{});                    // leads to undefined behavior
}
void F6() {
  auto up = std::make_unique<A[]>(10); // Compliant

  // Well behaving, but error-prone
  std::shared_ptr<A> sp{up.release(),
                        std::default_delete<A[]>{}}; // Non-compliant
  sp.reset(new A{}); // leads to undefined behavior
}