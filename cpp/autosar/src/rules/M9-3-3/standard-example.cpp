class A
{
  public:
    int16_t f1()
    {
      return m_i;
    }

    int16_t f2()
    { 
      return m_s;
    }
    
    int16_t f3()
    {
      return ++m_i;
    } 
  private:
    int16_t m_i;
    static int16_t m_s;
};