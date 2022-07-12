// $Id: A11-3-1.cpp 325916 2018-07-13 12:26:22Z christof.meerwald $
class A
{
  public:
    A& operator+=(A const& oth);
    friend A const operator+(A const& lhs, A const& rhs); // Non-compliant
};
class B
{
  public:
    B& operator+=(B const& oth);
    friend bool operator ==(B const& lhs, B const& rhs) // Compliant by exception 
    {
      // Implementation
    } 
};

B const operator+(B const& lhs, B const& rhs) // Compliant 
{
  // Implementation
}