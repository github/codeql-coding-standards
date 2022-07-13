if(test1);     // Non-compliant - accidental single null statement
{
  x = 1;
}
if(test1)
{
  x = 1;       // Compliant - a single statement must be in braces
}
else if(test2) // Compliant - no need for braces between else and if
{
   x = 0;      // Compliant – a single statement must be in braces
}
else           // Non-compliant
  x = 3;       // This was (incorrectly) not enclosed in braces
  y = 2;       // This line was added later but, despite the
               // appearance (from the indent) it is actually not
               // part of the else, and is executed unconditionally