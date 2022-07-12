// $Id: A12-8-5.cpp 271773 2017-03-23 13:16:53Z piotr.tanski $
#include <cstdint>
#include <stdexcept>
struct A
{   
  std::int32_t number; 
  std::int32_t* ptr;
  // Implementation
};
class B 
{
  public: 
    // ...
    B& operator=(B const& oth) // Non-compliant 
    {
      i = oth.i; 
      delete aPtr;
      try
      {
        aPtr = new A(*oth.aPtr); // If this is the self-copy case, then 
                                 // the oth.a_ptr is already deleted
      }
      catch (std::bad_alloc&) 
      {
        aPtr = nullptr; 
      }
      return *this; 
    }
  
  private:
    std::int16_t i = 0; 
    A* aPtr = nullptr;
};
class C 
{
  public:
    C& operator=(C const& oth) // Compliant
    {
      if (this != &oth) 
      {
        A* tmpPtr = new A(*oth.aPtr);
        i = oth.i;
        delete aPtr; 
        aPtr = tmpPtr;
      }
      return *this; 
    }
    C& operator=(C&& oth) // Compliant 
    {
      if (this != &oth) 
      {
        A* tmpPtr = new A{std::move(*oth.aPtr)};
        i = oth.i; 
        delete aPtr;
        aPtr = tmpPtr;
      }
      return *this;
    }
  
  private:
    std::int16_t i = 0; 
    A* aPtr = nullptr;
};