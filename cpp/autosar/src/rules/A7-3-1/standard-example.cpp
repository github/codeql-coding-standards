// $Id: A7-3-1.cpp 312801 2018-03-21 16:17:05Z michal.szczepankiewicz $
#include <cstdint>
class Base
{
  public:
    void P(uint32_t);

    virtual void V(uint32_t);
    virtual void V(double);
};

class NonCompliant : public Base
{
  public:
    //hides P(uint32_t) when calling from the
    //derived class
    void P(double);
    //hides V(uint32_t) when calling from the
    //derived class
    void V(double) override;
};

class Compliant : public Base
{
  public:
    //both P(uint32_t) and P(double) available
    //from the derived class
    using Base::P;
    void P(double);

    //both P(uint32_t) and P(double)
    using Base::V;
    void V(double) override;
};

void F1()
{
  NonCompliant d{};
  d.P(0U); // D::P (double) called
  Base& b{d};
  b.P(0U); // NonCompliant::P (uint32_t) called

  d.V(0U); // D::V (double) called
  b.V(0U); // NonCompliant::V (uint32_t) called
}

void F2()
{
  Compliant d{};
  d.P(0U); // Compliant::P (uint32_t) called
  Base& b{d};
  b.P(0U); // Compliant::P (uint32_t) called

  d.V(0U); // Compliant::V (uint32_t) called
  b.V(0U); // Compliant::V (uint32_t) called
}

namespace NS
{
  void F(uint16_t);
}

//includes only preceding declarations into
//the current scope
using NS::F;

namespace NS
{
  void F(uint32_t);
}

void B(uint32_t b)
{
  //non-compliant, only F(uint16_t) is available
  //in this scope
  F(b);
}