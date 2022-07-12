// $Id: A6-2-2.cpp 326655 2018-07-20 14:58:55Z christof.meerwald $

#include <cstdint> 
#include <fstream> 
#include <mutex>

class A
{
  public:
    void SetValue1(std::int32_t value) 
    {
      std::lock_guard<std::mutex> {m_mtx}; // Non-compliant: temporary object 
      // Assignment to m_value is not protected by lock
      m_value = value;
    }
    void SetValue2(std::int32_t value) 
    {
      std::lock_guard<std::mutex> guard{m_mtx}; // Compliant: local variable m_value = value; 
    }
  
  private:
    mutable std::mutex m_mtx; std::int32_t m_value;
};

void Print(std::string const & fname, std::string const & s) 
{
  // Compliant: Not only constructing a temporary object
  std::ofstream{fname}.write(s.c_str(), s.length()); 
}