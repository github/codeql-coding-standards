void foobar(void)
{
  int8_t * p1;
  {
    int8_t local_auto;
    p1 = &local_auto; // Non-compliant
  }
}