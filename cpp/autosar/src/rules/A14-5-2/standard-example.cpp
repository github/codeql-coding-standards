// $Id: A14-5-2.cpp 323444 2018-06-22 14:38:18Z christof.meerwald $
#include <cstdint>
template<typename T> 
class A
{
  public:
    enum State // Non-Compliant: member doesn’t depend on template parameter 
    {
      State1,
      State2
    };

    State GetState();
};

class B_Base
{
  public:
    enum State // Compliant: not a member of a class template 
    {
      State1, 
      State2 
    };
};

template<typename T> 
class B : B_Base
{
  public:
    State GetState(); 
};