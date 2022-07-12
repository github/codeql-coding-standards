if(x < 0)
{
  log_error(3);
  x = 0;
}
else if(y < 0)
{ 
    x = 3;
}
else // this else clause is required, even if the
{    // developer expects this will never be reached
  // No change in value of x
}