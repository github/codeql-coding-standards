// $Id: A9-3-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint>
#include <memory>
#include <utility>
class A
{
  public:
    explicit A(std::int32_t number) : x(number) {}
    // Implementation
    std::int32_t&
    GetX() noexcept // Non-compliant - x is a resource owned by the A class 
    {
      return x; 
    }

  private: 
    std::int32_t x;
};
void Fn1() noexcept 
{
  A a{10};
  std::int32_t& number = a.GetX();
  number = 15; // External modification of private class data
}
class B 
{
  public:
    explicit B(std::shared_ptr<std::int32_t> ptr) : sharedptr(std::move(ptr)) {} 
    // Implementation
    std::shared_ptr<std::int32_t> GetSharedPtr() const
    noexcept // Compliant - sharedptr is a variable being shared between 
             // instances
    {
      return sharedptr;
    }
  private:
    std::shared_ptr<std::int32_t> sharedptr;
};
void Fn2() noexcept 
{
  std::shared_ptr<std::int32_t> ptr = std::make_shared<std::int32_t>(10); 
  B b1{ptr};
  B b2{ptr};
  *ptr = 50; // External modification of ptr which shared between b1 and b2
             // instances
  auto shared = b1.GetSharedPtr();
  *shared = 100; // External modification of ptr which shared between b1 and
                 // b2 instances
}
class C {
  public:
    explicit C(std::int32_t number)
               : ownedptr{std::make_unique<std::int32_t>(number)}
    {
    }
    // Implementation
    const std::unique_ptr<std::int32_t>& GetOwnedPtr() const
          noexcept // Non-compliant - only unique_ptr is const, the object that 
                   // it is pointing to is modifiable
    {
      return ownedptr;
    }
    const std::int32_t& GetData() const noexcept // Compliant 
    {
      return *ownedptr; 
    }
  private:
    std::unique_ptr<std::int32_t> ownedptr;
};
void Fn3() noexcept 
{
  C c{10};
  const std::int32_t& data = c.GetData();
  // data = 20; // Can not modify data, it is a const reference
  const std::unique_ptr<std::int32_t>& ptr = c.GetOwnedPtr(); 
  *ptr = 20; // Internal data of class C modified
}