#include <csignal>
void my_handler(int32_t);
void f1()
{ 
  signal(1, my_handler); // Non-compliant
}