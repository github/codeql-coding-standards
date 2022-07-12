//% $Id: A15-1-4.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <memory>
#include <stdexcept>
extern std::uint32_t F1();
void FVeryBad() noexcept(false) 
{
  std::logic_error* e = new std::logic_error("Logic Error 1");
  // ...
  std::uint32_t i = F1();

  if (i < 10)
  {
    throw(*e); // Non-compliant - fVeryBad() is not able to clean-up
               // allocated memory
  }

  // ...
  delete e;
}
void FBad() noexcept(false)
{
  std::int32_t* x = new std::int32_t(0);
  // ...
  std::uint32_t i = F1();

  if (i < 10)
  {
    throw std::logic_error("Logic Error 2"); // Non-compliant - exits from
                                             // fBad() without cleaning-up
                                             // allocated resources and
                                             // causes a memory leak
  }
  else if (i < 20)
  {
    throw std::runtime_error("Runtime Error 3"); // Non-compliant - exits
                                                 // from fBad() without
                                                 // cleaning-up allocated
                                                 // resources and causes a
                                                 // memory leak
  }

  // ...
  delete x; // Deallocates claimed resource only in the end of fBad() scope 
}
void FGood() noexcept(false)
{
  std::int32_t* y = new std::int32_t(0); 
  // ...
  std::uint32_t i = F1();

  if (i < 10)
  {
    delete y; // Deletes allocated resource before throwing an exception 
    throw std::logic_error("Logic Error 4"); // Compliant - deleting y
                                             // variable before exception 
                                             // leaves the fGood() scope
  }

  else if (i < 20)
  {
    delete y; // Deletes allocated resource before throwing an exception 
    throw std::runtime_error("Runtime Error 5"); // Compliant - deleting y
                                                 // exception leaves the
                                                 // fGood() scope
  }
 
  else if (i < 30)
  {
    delete y; // Deletes allocated resource before throwing an exception 
              // again, difficult to maintain
    throw std::invalid_argument("Invalid Argument 1"); // Compliant - deleting 
                                                       // y variable before
                                                       // exception leaves the 
                                                       // fGood() scope
  }

  // ...
  delete y; // Deallocates claimed resource also in the end of fGood() scope 
}
void FBest() noexcept(false)
{
  std::unique_ptr<std::int32_t> z = std::make_unique<std::int32_t>(0);
  // ...
  std::uint32_t i = F1();

  if (i < 10)
  {
    throw std::logic_error("Logic Error 6"); // Compliant - leaving the
                                             // fBest() scope causes
                                             // deallocation of all
                                             // automatic variables, unique_ptrs, too
  }
  else if (i < 20)
  {
    throw std::runtime_error("Runtime Error 3"); // Compliant - leaving the
                                                 // fBest() scope causes
                                                 // deallocation of all
                                                 // automatic variables, 
                                                 // unique_ptrs, too
  }

  else if (i < 30)
  {
    throw std::invalid_argument("Invalid Argument 2"); // Compliant - leaving the fBest() scope 
                                                       // causes deallocation of all automatic
                                                       // variables, unique_ptrs, too
  }

  // ...
  // z is deallocated automatically here, too
}
class CRaii // Simple class that follows RAII pattern
{
  public:
    CRaii(std::int32_t* pointer) noexcept : x(pointer) {}
    ~CRaii()
    {
      delete x;
      x = nullptr;
    }

  private:
    std::int32_t* x;
};
void FBest2() noexcept(false)
{
  CRaii a1(new std::int32_t(10));
  // ...
  std::uint32_t i = F1();

  if (i < 10)
  {
    throw std::logic_error("Logic Error 7"); // Compliant - leaving the
                                             // fBest2() scope causes a1
                                             // variable deallocation
                                             // automatically
  }
  else if (i < 20)
  {
    throw std::runtime_error("Runtime Error 4"); // Compliant - leaving the
                                                 // fBest2() scope causes
                                                 // a1 variable
                                                 // deallocation 
                                                 // automatically
  }
  else if (i < 30)
  {
    throw std::invalid_argument("Invalid Argument 3"); // Compliant - leaving the fBest2() scope 
                                                       // causes a1 variable deallocation
                                                       // automatically
  }

  // ...
  // a1 is deallocated automatically here, too 
}