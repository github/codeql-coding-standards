// $Id: A12-8-6.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <memory>
#include <utility>
#include <vector>
class A // Abstract base class
{
  public:
    A() = default;
    A(A const&) = default;            // Non-compliant
    A(A&&) = default;                 // Non-compliant 
    virtual ~A() = 0;
    A& operator=(A const&) = default; // Non-compliant
    A& operator=(A&&) = default;      // Non-compliant
};
class B : public A
{
};
class C // Abstract base class 
{
  public:
    C() = default; 
    virtual ~C() = 0;
    
  protected:
    C(C const&) = default;            // Compliant
    C(C&&) = default;                 // Compliant
    C& operator=(C const&) = default; // Compliant
    C& operator=(C&&) = default;      // Compliant
};
class D : public C
{
};
class E // Abstract base class 
{
  public:
    E() = default;
    virtual ~E() = 0;
    E(E const&) = delete;            // Compliant
    E(E&&) = delete;                 // Compliant
    E& operator=(E const&) = delete; // Compliant
    E& operator=(E&&) = delete;      // Compliant
};
class F : public E
{
};
class G // Non-abstract base class 
{
  public:
    G() = default;
    virtual ~G() = default;
    G(G const&) = default;            // Non-compliant
    G(G&&) = default;                 // Non-compliant
    G& operator=(G const&) = default; // Non-compliant
    G& operator=(G&&) = default;      // Non-compliant
};
class H : public G
{
};
void Fn1() noexcept 
{
  B obj1;
  B obj2;
  A* ptr1 = &obj1;
  A* ptr2 = &obj2;
  *ptr1 = *ptr2; // Partial assignment only 
  *ptr1 = std::move(*ptr2); // Partial move only
  D obj3;
  D obj4;
  C* ptr3 = &obj3; 
  C* ptr4 = &obj4;
  //*ptr3 = *ptr4; // Compilation error - copy assignment operator of class C
  // is protected
  //*ptr3 = std::move(*ptr4); // Compilation error - move assignment operator 
  // of class C is protected
  F obj5;
  F obj6;
  E* ptr5 = &obj5;
  E* ptr6 = &obj6;
  //*ptr5 = *ptr6; // Compilation error - use of deleted copy assignment
  // operator
  //*ptr5 = std::move(*ptr6); // Compilation error - use of deleted move 
  // assignment operator
  H obj7;
  H obj8;
  G* ptr7 = &obj7;
  G* ptr8 = &obj8;
  *ptr7 = *ptr8;// Partial assignment only
  *ptr7 = std::move(*ptr8); // Partial move only
}
class I // Non-abstract base class 
{
  public:
    I() = default; 
    ~I() = default;

  protected:
    I(I const&) = default;            // Compliant
    I(I&&) = default;                 // Compliant
    I& operator=(I const&) = default; // Compliant 
    I& operator=(I&&) = default;      // Compliant
};
class J : public I 
{
  public:
    J() = default;
    ~J() = default;
    J(J const&) = default;
    J(J&&) = default;
    J& operator=(J const&) = default; 
    J& operator=(J&&) = default;
};
void Fn2() noexcept 
{
  std::vector<I> v1;
  // v1.push_back(J{}); // Compilation-error on calling a deleted move 
  // constructor of I class, slicing does not occur
  // v1.push_back(I{}); // Compilation-error on calling a deleted move 
  // constructor of I class

  std::vector<J> v2;
  v2.push_back(J{}); // No compilation error

  std::vector<std::unique_ptr<I>> v3;
  v3.push_back(std::unique_ptr<I>{});  // No compilation error
  v3.push_back(std::make_unique<I>()); // No compilation error 
  v3.push_back(std::make_unique<J>()); // No compilation error 
  v3.emplace_back();                   // No compilation error
}