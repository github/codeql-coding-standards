// $Id: A18-9-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
#include <string> 
#include <utility> 
class A
{
  public:
    explicit A(std::string&& s)
                         : str(std::move(s))
    {
    }

  private: 
    std::string str; 
};
class B
{
};
void Fn1(const B& lval) 
{
  // Compliant - forwarding rvalue reference
}
void Fn1(B&& rval)
{
}
template <typename T>
void Fn2(T&& param)
{
  Fn1(std::forward<T>(param)); // Compliant - forwarding forwarding reference 
}
template <typename T>
void Fn3(T&& param)
{
  Fn1(std::move(param)); // Non-compliant - forwarding forwarding reference
                                         // via std::move
}
void Fn4() noexcept
{
  B b1;
  B& b2 = b1;
  Fn2(b2);            // fn1(const B&) is called
  Fn2(std::move(b1)); // fn1(B&&) is called
  Fn3(b2);            // fn1(B&&) is called 
  Fn3(std::move(b1)); // fn1(B&&) is called
}