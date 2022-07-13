//% $Id: A15-0-2.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cstdint> 
#include <cstring> 
class C1
{
  public:
    C1(const C1& rhs) 
    {
      CopyBad(rhs);  // Non-compliant - if an exception is thrown, an object
                     // will be left in an indeterminate state
      CopyGood(rhs); // Compliant - full object will be properly copied or
                     // none of its properties will be changed
    }
    ~C1() { delete[] e; }
    void CopyBad(const C1& rhs) 
      {
      if (this != &rhs)
      {
        delete[] e; 
        e = nullptr; // e changed before the block where an exception can
                     // be thrown
        s = rhs.s;   // s changed before the block where an exception can be 
                     // thrown

        if (s > 0)
        {
          e = new std::int32_t[s]; // If an exception will be thrown 
                                   // here, the
                                   // object will be left in an indeterminate 
                                   // state
          std::memcpy(e, rhs.e, s * sizeof(std::int32_t));
        }
      }
    }
    void CopyGood(const C1& rhs) 
    {
      std::int32_t* eTmp = nullptr;
      if (rhs.s > 0)
      {
        eTmp = new std::int32_t[rhs.s]; // If an exception will be thrown
                                        // here, the
                                        // object will be left unchanged
        std::memcpy(eTmp, rhs.e, rhs.s * sizeof(std::int32_t));
      }

      delete[] e; 
      e = eTmp; 
      s = rhs.s; 
    }

  private:
    std::int32_t* e;
    std::size_t s;
};
class A
{
  public:
    A() = default;
};
class C2
{
  public:
    C2() : a1(new A), a2(new A) // Non-compliant - if a2 memory allocation
                                // fails, a1 will never be deallocated 
    {
    }

  private:
    A* a1;
    A* a2;
};
class C3
{
  public:
    C3() : a1(nullptr), a2(nullptr) // Compliant
    {
      try
      {
        a1 =new A;
        a2 = new A; // If memory allocation for a2 fails, catch-block will 
                    // deallocate a1
      }
      catch (...) 
      {
        delete a1; 
        a1 = nullptr; 
        delete a2; 
        a2 = nullptr; 
        throw;
      }
    }

  private: 
    A* a1;
    A* a2; 
};