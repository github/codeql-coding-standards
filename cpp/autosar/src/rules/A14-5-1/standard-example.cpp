// $Id: A14-5-1.cpp 309903 2018-03-02 12:54:18Z christof.meerwald $
#include <cstdint>
#include <type_traits>

class A
{
  public:
    // Compliant: template constructor does not participate in overload 
    // resolution for copy/move operations
    template<typename T,
             std::enable_if_t<! std::is_same<std::remove_cv_t<T>, A>::value> * = nullptr>

    A(const T &value) 
    : m_value { value } 
    {}

  private:
    std::int32_t m_value;
};

void Foo(A const &a)
{
  A myA { a }; // will use the implicit copy ctor, not the template converting ctor
 
  A a2 { 2 }; // will use the template converting ctor 
}

class B
{
  public:
    B(const B &) = default;
    B(B &&) = default;

    // Compliant: forwarding constructor does not participate in overload
    //            resolution for copy/move operations 
    template<typename T, 
             std::enable_if_t<! std::is_same<std::remove_cv_t<std:: remove_reference_t<T>>, 
                              B>::value> * = nullptr>

    B(T &&value); 
};

void Bar(B b) 
{
  B myB { b }; // will use the copy ctor, not the forwarding ctor 
}

class C
{
  public:
    C(const C &) = default;
    C(C &&) = default;
 
    // Non-Compliant: unconstrained template constructor template<typename T>
    C(T &);
};

void Bar(C c)
{
  C myC { c }; // will use template ctor instead of copy ctor 
}