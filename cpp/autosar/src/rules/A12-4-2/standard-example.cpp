// $Id: A12-4-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A // Non-compliant - class A should not be used as a base class because
        // its destructor is not virtual, but it is
        // not declared final
{
  public:
    A() = default;
    A(A const&) = default;
    A(A&&) = default;
    A& operator=(A const&) = default;
    A& operator=(A&&) = default;
    ~A() = default; // Public non-virtual destructor
};
class B final // Compliant - class B can not be used as a base class, because
              // it is declared final, and it should not be derived
              // because its destructor is not virtual
{
  public:
    B() = default;
    B(B const&) = default;
    B(B&&) = default;
    B& operator=(B const&) = default;
    B& operator=(B&&) = default;
    ~B() = default; // Public non-virtual destructor
};
class C // Compliant - class C is not final, and its destructor is virtual. It
        // can be used as a base class
{
  public:
    C() = default;
    C(C const&) = default;
    C(C&&) = default;
    C& operator=(C const&) = default;
    C& operator=(C&&) = default;
    virtual ~C() = default; // Public virtual destructor
};
class AA : public A
{
};
// class BA : public B // Compilation error - can not derive from final base
// class B
//{
//};
class CA : public C
{
};
void Fn() noexcept
{
    AA obj1;
    CA obj2;
    A& ref1 = obj1;
    C& ref2 = obj2;
    ref1.~A(); // Calls A::~A() only
    ref2.~C(); // Calls both CA::~CA() and C::~C()
}