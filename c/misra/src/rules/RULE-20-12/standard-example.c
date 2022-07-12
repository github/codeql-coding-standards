#define AA 0xffff
#define BB(x) (x) + wow##x /* Non-compliant */
void f(void) {
  int32_t wowAA = 0;
  /* Expands as wowAA = ( 0xffff ) + wowAA; */
  wowAA = BB(AA);
}