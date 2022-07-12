// $Id: A10-3-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A
{
  public:
    virtual ~A() {}
    virtual void F() noexcept = 0;
    virtual void G() noexcept {}
    virtual void Z() noexcept {}
    virtual A& operator+=(A const& oth) = 0;
};
class B : public A
{
  public:
    ~B() override {} // Compliant
    void F() noexcept // Non-compliant
    {
    }
    virtual void G() noexcept // Non-compliant
    {
    }
    void Z() noexcept override // Compliant
    {
    }
    B& operator+=(A const& oth) override // Compliant
    {
      return *this;
    }
};
class C : public A
{
  public:
    ~C() {} // Non-compliant
    void F() noexcept override // Compliant
    {
    }
    void G() noexcept override // Compliant
    {
    }
    void Z() noexcept override // Compliant
    {
    }
    C& operator+=(A const& oth) // Non-compliant
    {
      return *this;
    }
};