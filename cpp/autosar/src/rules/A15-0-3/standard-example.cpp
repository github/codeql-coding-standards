//% $Id: A15-0-3.cpp 271687 2017-03-23 08:57:35Z piotr.tanski $
#include <cstdint> 
#include <stdexcept> 
#include <vector> 
class A
{
  public:
    explicit A(std::int32_t value) noexcept(false) : x(value) 
    {
      if (x == 0)
      {
        throw std::invalid_argument("Constructor: Invalid Argument"); 
      }
    }

  private:
    std::int32_t x;
};
int main(int, char**)
{
  constexpr std::int32_t limit = 10;
  std::vector<A> vec1; // Constructor and assignment operator of A class
                       // throw exceptions

  try
  {
    for (std::int32_t i = 1; i < limit; ++i) 
    {
      vec1.push_back(A(i)); // Constructor of A class will not throw for 
                            // value from 1 to 10
    }

    vec1.emplace(vec1.begin(), 0); // Non-compliant - constructor A(0) throws in an
                                   // emplace() method of std::vector. This leads to
                                   // unexpected result of emplace() method. Throwing an 
                                   // exception inside an object constructor in emplace()
                                   // leads to duplication of one of vector’s elements.
                                   // Vector invariants are valid and the object is destructible.
  }
  catch (std::invalid_argument& e)
  {
    // Handle an exception
  }

  std::vector<A> vec2; 
  vec2.reserve(limit);
  try
  {
    for (std::int32_t i = limit - 1; i >= 0; --i) 
    {
      vec2.push_back(A(i)); // Compliant - constructor of A(0) throws for
                            // i = 0, but in this case strong exception
                            // safety is guaranteed. While push_back()
                            // offers strong exception safety guarantee, 
                            // push_back can only succeed to add a new 
                            // element or fails and does not change the 
                            // container
    }
  }
  catch (std::invalid_argument& e) 
  {
    // Handle an exception
  }

  return 0;
}