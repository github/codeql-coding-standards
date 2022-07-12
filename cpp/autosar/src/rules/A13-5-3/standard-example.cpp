// $Id: A13-5-3.cpp 305629 2018-01-29 13:29:25Z piotr.serwa $
#include <iostream>
class Complex
{
  public:
    Complex (double r, double i = 0.0) : re(r), im(i) {} 
    explicit operator double() const noexcept { return re; }
    double AsDouble() const noexcept { return re; }

  private: 
    double re; 
    double im;
};

int main(void)
{
  Complex c(2.0f);
  std::cout << (double) c << std::endl; //compliant with A13-5-2, non-compliant with A13-5-3
  std::cout << c.AsDouble() << std::endl; //compliant
  return 0;
}