// $Id: A12-7-1.cpp 271715 2017-03-23 10:13:51Z piotr.tanski $
#include <cstdint>
#include <utility>
class A
{
  public:
    A() : x(0), y(0) {} // Compliant
    A(std::int32_t first, std::int32_t second) : x(first), y(second) {} // Compliant

    // anyway, such 
    // a constructor 
    // cannot be
    // defaulted.
    A(const A& oth)
             : x(oth.x),
               y(oth.y) // Non-compliant - equivalent to the implicitly
                        // defined copy constructor
    {
    }
    A(A&& oth)
             : x(std::move(oth.x)), 
               y(std::move(
                    oth.y)) // Non-compliant - equivalent to the implicitly 
                            // defined move constructor
    {
    } 
    ~A() // Non-compliant - equivalent to the implicitly defined destructor
    {
    }

  private: 
    std::int32_t x; 
    std::int32_t y;
};
class B 
{
  public:
    B() {} // Non-compliant - x and y are not initialized
           // should be replaced with: B() : x{0}, y{0} {}
    B(std::int32_t first, std::int32_t second) : x(first), y(second) {} // Compliant
    
    B(const B&) =
        default; // Compliant - equivalent to the copy constructor of class A
    B(B&&) =
        default; // Compliant - equivalent to the move constructor of class A
    ~B() = default; // Compliant - equivalent to the destructor of class A

  private: 
    std::int32_t x; 
    std::int32_t y;
};
class C 
{
  public:
    C() = default;         // Compliant
    C(const C&) = default; // Compliant
    C(C&&) = default;      // Compliant
};
class D
{
  public:
    D() : ptr(nullptr) {}  // Compliant - this is not equivalent to what the 
                           // implicitly defined default constructor would do
    D(C* p) : ptr(p) {}    // Compliant
    D(const D&) = default; // Shallow copy will be performed, user-defined copy
                           // constructor is needed to perform deep copy on ptr variable
    D(D&&) = default;      // ptr variable will be moved, so ptr will still point to
                           // the same object
    ~D() = default;        // ptr will not be deleted, the user-defined destructor is
                           // needed to delete allocated memory

  private: 
    C* ptr;
};
class E // Compliant - special member functions definitions are not needed as
        // class E uses only implicit definitions
{ 
};