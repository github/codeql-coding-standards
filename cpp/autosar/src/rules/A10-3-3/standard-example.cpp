// $Id: A10-3-3.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
class A
{
  public:
    virtual ~A() = default;
    virtual void F() noexcept = 0;
    virtual void G() noexcept {}
    };
    class B final : public A
    {
    public:
    void F() noexcept final // Compliant
    {
    }
    void G() noexcept override // Non-compliant
    {
    }
    virtual void H() noexcept = 0; // Non-compliant
    virtual void Z() noexcept // Non-compliant
    {
    }
};