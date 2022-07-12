#define START 0x8000
#define END   0xFFFF
#define LEN   0x8000
#if ((START + LEN) > END)
#error Buffer Overrun // OK as START and LEN are unsigned long
#endif
#if (((END - START) - LEN) < 0)
  #error Buffer Overrun
  // Not OK: subtraction result wraps around to 0xFFFFFFFF
#endif
// contrast the above START + LEN with the following
void fn()
{
  if((START + LEN) > END)
  {
    error ( "Buffer overrun" );
    // Not OK: START + LEN wraps around to 0x0000 due to unsigned int
    // arithmetic
  } 
}