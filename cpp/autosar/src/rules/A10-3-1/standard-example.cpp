// $Id: A10-3-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A
{
  public:
    virtual ~A() {} // Compliant
    virtual void F() noexcept = 0; // Compliant
    virtual void G() noexcept final = 0; // Non-compliant - virtual final pure
                                         // function is redundant
    virtual void
    H() noexcept final // Non-compliant - function is virtual and final
    {
    }
    virtual void K() noexcept // Compliant
    {
    }
    virtual void J() noexcept {}
    virtual void M() noexcept // Compliant
    {
    }
    virtual void Z() noexcept // Compliant
    {
    }
    virtual A& operator+=(A const& rhs) noexcept // Compliant
    {
    // ...
    return *this;
    }
    };
class B : public A
{
  public:
    ~B() override {} // Compliant
    virtual void F() noexcept override // Non-compliant - function is specified
                                       // with virtual and override
    {
    }
    void K() noexcept override
    final // Non-compliant - function is specified with override and final
    {
    }
    virtual void M() noexcept // Compliant - violates A10-3-2
    {
    }
    void Z() noexcept override // Compliant
    {
    }
    void J() noexcept // Non-compliant - virtual function but not marked as
                      // overrider
    {
    }
    A& operator+=(A const& rhs) noexcept override // Compliant - to override
                                                  // the operator correctly,
                                                  // its signature needs to be
                                                  // the same as in the base
                                                  // class
    {
    // ...
    return *this;
    }
};