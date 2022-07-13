// $Id: A13-5-4.cpp 328319 2018-08-03 14:08:42Z christof.meerwald $
#include <cstdint>

// non-compliant 
class A
  public:
    explicit A(std::uint32_t d) : d(d) {}
    friend bool operator==(A const & lhs, A const & rhs) noexcept 
    {
      return lhs.d == rhs.d; 
    }
    friend bool operator!=(A const & lhs, A const & rhs) noexcept 
    {
      return lhs.d != rhs.d; 
    }
  private:
    std::uint32_t d;
};

// compliant
class B
{
  public:
    explicit B(std::uint32_t d) : d(d) {}
  
    friend bool operator==(B const & lhs, B const & rhs) noexcept
    {
        return lhs.d ==rhs.d;
    }
    friend bool operator!=(B const & lhs, B const & rhs) noexcept
    {
        return !(lhs == rhs)
    }

  private:  
    std::uint32_t d;
};
