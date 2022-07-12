// File1
void CreateRectangle(uint32_t Height, uint32_t Width);
// File2
// Non-compliant
void CreateRectangle(uint32_t Width, uint32_t Height);
void fn1(int32_t a);
void fn2(int32_t);
void fn1(int32_t b) // Non-compliant 
{
}
void fn2(int32_t b) // Compliant 
{
}