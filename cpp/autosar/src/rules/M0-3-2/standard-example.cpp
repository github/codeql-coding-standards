extern void fn3(int32_t i, bool & flag);
int32_t fn1(int32_t i)
{
  int32_t result  = 0;
  bool success = false;
  fn3(i, success);
  return result;
}
int32_t fn2(int32_t i)
{
  int32_t result  = 0;
  bool success = false;
  fn3(i, success);
  if(!success)
  { 
    throw 42;
  }
  return result; 
}