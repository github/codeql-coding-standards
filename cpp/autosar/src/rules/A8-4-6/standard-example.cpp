// $Id: A8-4-6.cpp 305588 2018-01-29 11:07:35Z michal.szczepankiewicz $ 2
#include <string>
#include <vector>
class A
{
  public:
    explicit A(std::vector<std::string> &&v);
};

class B 
{
  public:
    explicit B(const std::vector<std::string> &v);
};

template<typename T, typename ... Args> 
T make(Args && ... args)
{
  return T{std::forward<Args>(args) ...}; // Compliant, forwarding args 
}

int main() {
  make<A>(std::vector<std::string>{ });
  std::vector<std::string> v;
  make<B>(v); 
}