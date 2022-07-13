//% $Id: A3-1-5.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <cstdint>
#include <iostream>

class A 
{
  public:
    //compliant with (2)
    template <typename T> 
    void Foo(T&& t)
    {
      std::cout << __PRETTY_FUNCTION__ << " defined inside with param: " << t << std::endl;
    }

    //non-compliant with (2)
    template <typename T> 
    void Bar(T&& t);

    //compliant with (1)
    std::uint32_t GetVal() const noexcept 
    {
      return val; 
    }

    //non-compliant with (1)
    std::uint32_t GetVal2() const noexcept;

  private:
    std::uint32_t val = 5;
};

template <typename T> 
void A::Bar(T&& t)
{
  std::cout << __PRETTY_FUNCTION__ << " defined outside with param: " << t << std::endl; 
}

std::uint32_t A::GetVal2() const noexcept 
{
  return val;
}

template <typename T>
class B
{
  public:
    B(const T& x) : t(x) {}

    //compliant with (3)
    void display() const noexcept
    {
      std::cout << t << std::endl;
    }

    //non-compliant with (3)
    void display2() const noexcept;

  private:
    T t;
};

template <typename T>
void B<T>::display2() const noexcept
{
  std::cout << t << std::endl;
}

int main(void)
{
  std::uint32_t tmp = 5;
  Aa;
  a.Foo(3.14f);
  a.Bar(5);

  std::cout << a.GetVal() << std::endl;
  B<std::int32_t> b(7);
  b.display();

  return 0;
}