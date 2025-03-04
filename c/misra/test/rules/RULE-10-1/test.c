#include "math.h"
#include "stdbool.h"

void testInappropriateOperands() {
  _Bool b = true;
  char c = 'c';
  enum E1 { A, B, C } e1 = A;
  signed int s = 100;
  unsigned int u = 1;
  float f = 1.0;
  float _Complex cf = 1.0 + 1.0i;

  int a[20];

  a[b];  // NON_COMPLIANT
  a[c];  // NON_COMPLIANT
  a[e1]; // COMPLIANT
  a[s];  // COMPLIANT
  a[u];  // COMPLIANT
  // a[f];  // NON_COMPILABLE
  // a[cf]; // NON_COMPILABLE

  +b;  // NON_COMPLIANT
  +c;  // NON_COMPLIANT
  +e1; // NON_COMPLIANT
  +s;  // COMPLIANT
  +u;  // COMPLIANT
  +f;  // COMPLIANT
  +cf; // COMPLIANT

  -b;  // NON_COMPLIANT
  -c;  // NON_COMPLIANT
  -e1; // NON_COMPLIANT
  -s;  // COMPLIANT
  -u;  // NON_COMPLIANT
  -f;  // COMPLIANT
  -cf; // COMPLIANT

  1 + b;  // NON_COMPLIANT
  1 + c;  // COMPLIANT
  1 + e1; // NON_COMPLIANT
  1 + s;  // COMPLIANT
  1 + u;  // COMPLIANT
  1 + f;  // COMPLIANT
  1 + cf; // COMPLIANT

  1 - b;  // NON_COMPLIANT
  1 - c;  // COMPLIANT
  1 - e1; // NON_COMPLIANT
  1 - s;  // COMPLIANT
  1 - u;  // COMPLIANT
  1 - f;  // COMPLIANT
  1 - cf; // COMPLIANT

  b + 1;  // NON_COMPLIANT
  c + 1;  // COMPLIANT
  e1 + 1; // NON_COMPLIANT
  s + 1;  // COMPLIANT
  u + 1;  // COMPLIANT
  f + 1;  // COMPLIANT
  cf + 1; // COMPLIANT

  b - 1;  // NON_COMPLIANT
  c - 1;  // COMPLIANT
  e1 - 1; // NON_COMPLIANT
  s - 1;  // COMPLIANT
  u - 1;  // COMPLIANT
  f - 1;  // COMPLIANT
  cf - 1; // COMPLIANT

  b++;  // NON_COMPLIANT
  c++;  // COMPLIANT
  e1++; // NON_COMPLIANT
  s++;  // COMPLIANT
  u++;  // COMPLIANT
  f++;  // COMPLIANT
  cf++; // NON_COMPLIANT

  b--;  // NON_COMPLIANT
  c--;  // COMPLIANT
  e1--; // NON_COMPLIANT
  s--;  // COMPLIANT
  u--;  // COMPLIANT
  f--;  // COMPLIANT
  cf--; // NON_COMPLIANT

  ++b;  // NON_COMPLIANT
  ++c;  // COMPLIANT
  ++e1; // NON_COMPLIANT
  ++s;  // COMPLIANT
  ++u;  // COMPLIANT
  ++f;  // COMPLIANT
  ++cf; // NON_COMPLIANT

  --b;  // NON_COMPLIANT
  --c;  // COMPLIANT
  --e1; // NON_COMPLIANT
  --s;  // COMPLIANT
  --u;  // COMPLIANT
  --f;  // COMPLIANT
  --cf; // NON_COMPLIANT

  1 * b;  // NON_COMPLIANT
  1 * c;  // NON_COMPLIANT
  1 * e1; // NON_COMPLIANT
  1 * s;  // COMPLIANT
  1 * u;  // COMPLIANT
  1 * f;  // COMPLIANT
  1 * cf; // COMPLIANT

  1 / b;  // NON_COMPLIANT
  1 / c;  // NON_COMPLIANT
  1 / e1; // NON_COMPLIANT
  1 / s;  // COMPLIANT
  1 / u;  // COMPLIANT
  1 / f;  // COMPLIANT
  1 / cf; // COMPLIANT

  b * 1;  // NON_COMPLIANT
  c * 1;  // NON_COMPLIANT
  e1 * 1; // NON_COMPLIANT
  s * 1;  // COMPLIANT
  u * 1;  // COMPLIANT
  f * 1;  // COMPLIANT
  cf * 1; // COMPLIANT

  b / 1;  // NON_COMPLIANT
  c / 1;  // NON_COMPLIANT
  e1 / 1; // NON_COMPLIANT
  s / 1;  // COMPLIANT
  u / 1;  // COMPLIANT
  f / 1;  // COMPLIANT
  cf / 1; // COMPLIANT

  b % 1;  // NON_COMPLIANT
  c % 1;  // NON_COMPLIANT
  e1 % 1; // NON_COMPLIANT
  s % 1;  // COMPLIANT
  u % 1;  // COMPLIANT
  // f % 1;  // NON_COMPILABLE
  // cf % 1;  // NON_COMPILABLE

  1 % b;  // NON_COMPLIANT
  1 % c;  // NON_COMPLIANT
  1 % e1; // NON_COMPLIANT
  1 % s;  // COMPLIANT
  1 % u;  // COMPLIANT
  // 1 % f;  // NON_COMPILABLE
  // 1 % cf;  // NON_COMPILABLE

  1 < b;  // NON_COMPLIANT
  1 < c;  // COMPLIANT
  1 < e1; // COMPLIANT
  1 < s;  // COMPLIANT
  1 < u;  // COMPLIANT
  1 < f;  // COMPLIANT
  // 1 < cf;  // NON_COMPILABLE

  1 > b;  // NON_COMPLIANT
  1 > c;  // COMPLIANT
  1 > e1; // COMPLIANT
  1 > s;  // COMPLIANT
  1 > u;  // COMPLIANT
  1 > f;  // COMPLIANT
  // 1 > cf;  // NON_COMPILABLE

  1 <= b;  // NON_COMPLIANT
  1 <= c;  // COMPLIANT
  1 <= e1; // COMPLIANT
  1 <= s;  // COMPLIANT
  1 <= u;  // COMPLIANT
  1 <= f;  // COMPLIANT
  // 1 <= cf;  // NON_COMPILABLE

  1 >= b;  // NON_COMPLIANT
  1 >= c;  // COMPLIANT
  1 >= e1; // COMPLIANT
  1 >= s;  // COMPLIANT
  1 >= u;  // COMPLIANT
  1 >= f;  // COMPLIANT
  // 1 >= cf;  // NON_COMPILABLE

  b < 1;  // NON_COMPLIANT
  c < 1;  // COMPLIANT
  e1 < 1; // COMPLIANT
  s < 1;  // COMPLIANT
  u < 1;  // COMPLIANT
  f < 1;  // COMPLIANT
  // cf < 1;  // NON_COMPILABLE

  b > 1;  // NON_COMPLIANT
  c > 1;  // COMPLIANT
  e1 > 1; // COMPLIANT
  s > 1;  // COMPLIANT
  u > 1;  // COMPLIANT
  f > 1;  // COMPLIANT
  // cf > 1;  // NON_COMPILABLE

  b <= 1;  // NON_COMPLIANT
  c <= 1;  // COMPLIANT
  e1 <= 1; // COMPLIANT
  s <= 1;  // COMPLIANT
  u <= 1;  // COMPLIANT
  f <= 1;  // COMPLIANT
  // cf <= 1;  // NON_COMPILABLE

  b >= 1;  // NON_COMPLIANT
  c >= 1;  // COMPLIANT
  e1 >= 1; // COMPLIANT
  s >= 1;  // COMPLIANT
  u >= 1;  // COMPLIANT
  f >= 1;  // COMPLIANT
  // cf >= 1;  // NON_COMPILABLE

  b == 1;          // COMPLIANT
  c == 1;          // COMPLIANT
  e1 == 1;         // COMPLIANT
  s == 1;          // COMPLIANT
  u == 1;          // COMPLIANT
  f == 1;          // NON_COMPLIANT
  cf == 1;         // NON_COMPLIANT
  f == 0;          // COMPLIANT
  f == INFINITY;   // COMPLIANT
  f == -INFINITY;  // COMPLIANT
  cf == 0;         // COMPLIANT
  cf == INFINITY;  // COMPLIANT
  cf == -INFINITY; // COMPLIANT

  b != 1;          // COMPLIANT
  c != 1;          // COMPLIANT
  e1 != 1;         // COMPLIANT
  s != 1;          // COMPLIANT
  u != 1;          // COMPLIANT
  f != 1;          // NON_COMPLIANT
  cf != 1;         // NON_COMPLIANT
  f != 0;          // COMPLIANT
  f != INFINITY;   // COMPLIANT
  f != -INFINITY;  // COMPLIANT
  cf != 0;         // COMPLIANT
  cf != INFINITY;  // COMPLIANT
  cf != -INFINITY; // COMPLIANT

  1 == b;          // COMPLIANT
  1 == c;          // COMPLIANT
  1 == e1;         // COMPLIANT
  1 == s;          // COMPLIANT
  1 == u;          // COMPLIANT
  1 == f;          // NON_COMPLIANT
  1 == cf;         // NON_COMPLIANT
  0 == f;          // COMPLIANT
  INFINITY == f;   // COMPLIANT
  -INFINITY == f;  // COMPLIANT
  0 == cf;         // COMPLIANT
  INFINITY == cf;  // COMPLIANT
  -INFINITY == cf; // COMPLIANT

  1 != b;          // COMPLIANT
  1 != c;          // COMPLIANT
  1 != e1;         // COMPLIANT
  1 != s;          // COMPLIANT
  1 != u;          // COMPLIANT
  1 != f;          // NON_COMPLIANT
  1 != cf;         // NON_COMPLIANT
  0 != f;          // COMPLIANT
  INFINITY != f;   // COMPLIANT
  -INFINITY != f;  // COMPLIANT
  0 != cf;         // COMPLIANT
  INFINITY != cf;  // COMPLIANT
  -INFINITY != cf; // COMPLIANT

  !b;  // COMPLIANT
  !c;  // NON_COMPLIANT
  !e1; // NON_COMPLIANT
  !s;  // NON_COMPLIANT
  !u;  // NON_COMPLIANT
  !f;  // NON_COMPLIANT
  !cf; // NON_COMPLIANT

  b && true;  // COMPLIANT
  c && true;  // NON_COMPLIANT
  e1 && true; // NON_COMPLIANT
  s && true;  // NON_COMPLIANT
  u && true;  // NON_COMPLIANT
  f && true;  // NON_COMPLIANT
  cf && true; // NON_COMPLIANT

  b || false;  // COMPLIANT
  c || false;  // NON_COMPLIANT
  e1 || false; // NON_COMPLIANT
  s || false;  // NON_COMPLIANT
  u || false;  // NON_COMPLIANT
  f || false;  // NON_COMPLIANT
  cf || false; // NON_COMPLIANT

  true && b;  // COMPLIANT
  true && c;  // NON_COMPLIANT
  true && e1; // NON_COMPLIANT
  true && s;  // NON_COMPLIANT
  true && u;  // NON_COMPLIANT
  true && f;  // NON_COMPLIANT
  true && cf; // NON_COMPLIANT

  false || b;  // COMPLIANT
  false || c;  // NON_COMPLIANT
  false || e1; // NON_COMPLIANT
  false || s;  // NON_COMPLIANT
  false || u;  // NON_COMPLIANT
  false || f;  // NON_COMPLIANT
  false || cf; // NON_COMPLIANT

  b << u;  // NON_COMPLIANT
  c << u;  // NON_COMPLIANT
  e1 << u; // NON_COMPLIANT
  s << u;  // NON_COMPLIANT
  u << u;  // COMPLIANT
  // f << u;  // NON_COMPILABLE
  // cf << u;  // NON_COMPILABLE

  b >> u;  // NON_COMPLIANT
  c >> u;  // NON_COMPLIANT
  e1 >> u; // NON_COMPLIANT
  s >> u;  // NON_COMPLIANT
  u >> u;  // COMPLIANT
  // f >> u;  // NON_COMPILABLE
  // cf >> u;  // NON_COMPILABLE

  u << b;  // NON_COMPLIANT
  u << c;  // NON_COMPLIANT
  u << e1; // NON_COMPLIANT
  u << s;  // NON_COMPLIANT
  u << u;  // COMPLIANT
  // u << f;  // NON_COMPILABLE
  // u << cf;  // NON_COMPILABLE

  u >> b;  // NON_COMPLIANT
  u >> c;  // NON_COMPLIANT
  u >> e1; // NON_COMPLIANT
  u >> s;  // NON_COMPLIANT
  u >> u;  // COMPLIANT
  // u >> f;  // NON_COMPILABLE
  // u >> cf;  // NON_COMPILABLE

  b &u;  // NON_COMPLIANT
  c &u;  // NON_COMPLIANT
  e1 &u; // NON_COMPLIANT
  s &u;  // NON_COMPLIANT
  u &u;  // COMPLIANT
  // f &u;  // NON_COMPILABLE
  // cf &u;  // NON_COMPILABLE

  b | u;  // NON_COMPLIANT
  c | u;  // NON_COMPLIANT
  e1 | u; // NON_COMPLIANT
  s | u;  // NON_COMPLIANT
  u | u;  // COMPLIANT
  // f | u;  // NON_COMPILABLE
  // cf | u;  // NON_COMPILABLE

  b ^ u;  // NON_COMPLIANT
  c ^ u;  // NON_COMPLIANT
  e1 ^ u; // NON_COMPLIANT
  s ^ u;  // NON_COMPLIANT
  u ^ u;  // COMPLIANT
  // f ^ u;  // NON_COMPILABLE
  // cf ^ u;  // NON_COMPILABLE

  u &b;  // NON_COMPLIANT
  u &c;  // NON_COMPLIANT
  u &e1; // NON_COMPLIANT
  u &s;  // NON_COMPLIANT
  u &u;  // COMPLIANT
  // u &f;  // NON_COMPILABLE
  // u &cf;  // NON_COMPILABLE

  u | b;  // NON_COMPLIANT
  u | c;  // NON_COMPLIANT
  u | e1; // NON_COMPLIANT
  u | s;  // NON_COMPLIANT
  u | u;  // COMPLIANT
  // u | f;  // NON_COMPILABLE
  // u | cf;  // NON_COMPILABLE

  u ^ b;  // NON_COMPLIANT
  u ^ c;  // NON_COMPLIANT
  u ^ e1; // NON_COMPLIANT
  u ^ s;  // NON_COMPLIANT
  u ^ u;  // COMPLIANT
  // u ^ f;  // NON_COMPILABLE
  // u ^ cf;  // NON_COMPILABLE

  ~b;  // NON_COMPLIANT
  ~c;  // NON_COMPLIANT
  ~e1; // NON_COMPLIANT
  ~s;  // NON_COMPLIANT
  ~u;  // COMPLIANT
  //~f;  // NON_COMPILABLE
  ~cf; // NON_COMPLIANT

  b ? 1 : 2;  // COMPLIANT
  c ? 1 : 2;  // NON_COMPLIANT
  e1 ? 1 : 2; // NON_COMPLIANT
  s ? 1 : 2;  // NON_COMPLIANT
  u ? 1 : 2;  // NON_COMPLIANT
  f ? 1 : 2;  // NON_COMPLIANT
  cf ? 1 : 2; // NON_COMPLIANT

  b ? b : b;   // COMPLIANT
  b ? c : c;   // COMPLIANT
  b ? e1 : e1; // COMPLIANT
  b ? s : s;   // COMPLIANT
  b ? u : u;   // COMPLIANT
  b ? f : f;   // COMPLIANT
  b ? cf : cf; // COMPLIANT

  b += 1;  // NON_COMPLIANT
  c += 1;  // COMPLIANT
  e1 += 1; // NON_COMPLIANT
  s += 1;  // COMPLIANT
  u += 1;  // COMPLIANT
  f += 1;  // COMPLIANT
  cf += 1; // COMPLIANT

  b -= 1;  // NON_COMPLIANT
  c -= 1;  // COMPLIANT
  e1 -= 1; // NON_COMPLIANT
  s -= 1;  // COMPLIANT
  u -= 1;  // COMPLIANT
  f -= 1;  // COMPLIANT
  cf -= 1; // COMPLIANT

  u += b;  // NON_COMPLIANT
  u += c;  // COMPLIANT
  u += e1; // NON_COMPLIANT
  u += s;  // COMPLIANT
  u += u;  // COMPLIANT
  u += f;  // COMPLIANT
  u += cf; // COMPLIANT

  u -= b;  // NON_COMPLIANT
  u -= c;  // COMPLIANT
  u -= e1; // NON_COMPLIANT
  u -= s;  // COMPLIANT
  u -= u;  // COMPLIANT
  u -= f;  // COMPLIANT
  u -= cf; // COMPLIANT

  b *= 1;  // NON_COMPLIANT
  c *= 1;  // NON_COMPLIANT
  e1 *= 1; // NON_COMPLIANT
  s *= 1;  // COMPLIANT
  u *= 1;  // COMPLIANT
  f *= 1;  // COMPLIANT
  cf *= 1; // COMPLIANT

  b /= 1;  // NON_COMPLIANT
  c /= 1;  // NON_COMPLIANT
  e1 /= 1; // NON_COMPLIANT
  s /= 1;  // COMPLIANT
  u /= 1;  // COMPLIANT
  f /= 1;  // COMPLIANT
  cf /= 1; // COMPLIANT

  u *= b;  // NON_COMPLIANT
  u *= c;  // NON_COMPLIANT
  u *= e1; // NON_COMPLIANT
  u *= s;  // COMPLIANT
  u *= u;  // COMPLIANT
  u *= f;  // COMPLIANT
  u *= cf; // COMPLIANT

  u /= b;  // NON_COMPLIANT
  u /= c;  // NON_COMPLIANT
  u /= e1; // NON_COMPLIANT
  u /= s;  // COMPLIANT
  u /= u;  // COMPLIANT
  u /= f;  // COMPLIANT
  u /= cf; // COMPLIANT

  b %= 1;  // NON_COMPLIANT
  c %= 1;  // NON_COMPLIANT
  e1 %= 1; // NON_COMPLIANT
  s %= 1;  // COMPLIANT
  u %= 1;  // COMPLIANT
  // f %= 1;  // NON_COMPILABLE
  // cf %= 1;  // NON_COMPILABLE

  u %= b;  // NON_COMPLIANT
  u %= c;  // NON_COMPLIANT
  u %= e1; // NON_COMPLIANT
  u %= s;  // COMPLIANT
  u %= u;  // COMPLIANT
  // u %= f;  // NON_COMPILABLE
  // u %= cf;  // NON_COMPILABLE

  b <<= u;  // NON_COMPLIANT
  c <<= u;  // NON_COMPLIANT
  e1 <<= u; // NON_COMPLIANT
  s <<= u;  // NON_COMPLIANT
  u <<= u;  // COMPLIANT
  // f <<= u;  // NON_COMPILABLE
  // cf <<= u;  // NON_COMPILABLE

  b >>= u;  // NON_COMPLIANT
  c >>= u;  // NON_COMPLIANT
  e1 >>= u; // NON_COMPLIANT
  s >>= u;  // NON_COMPLIANT
  u >>= u;  // COMPLIANT
  // f >>= u;  // NON_COMPILABLE
  // cf >>= u;  // NON_COMPILABLE

  u <<= b;  // NON_COMPLIANT
  u <<= c;  // NON_COMPLIANT
  u <<= e1; // NON_COMPLIANT
  u <<= s;  // NON_COMPLIANT
  u <<= u;  // COMPLIANT
  // u <<= f;  // NON_COMPILABLE
  // u <<= cf;  // NON_COMPILABLE

  u >>= b;  // NON_COMPLIANT
  u >>= c;  // NON_COMPLIANT
  u >>= e1; // NON_COMPLIANT
  u >>= s;  // NON_COMPLIANT
  u >>= u;  // COMPLIANT
  // u >>= f;  // NON_COMPILABLE
  // u >>= cf;  // NON_COMPILABLE

  b &= u;  // NON_COMPLIANT
  c &= u;  // NON_COMPLIANT
  e1 &= u; // NON_COMPLIANT
  s &= u;  // NON_COMPLIANT
  u &= u;  // COMPLIANT
  // f &= u;  // NON_COMPILABLE
  // cf &= u;  // NON_COMPILABLE

  b ^= u;  // NON_COMPLIANT
  c ^= u;  // NON_COMPLIANT
  e1 ^= u; // NON_COMPLIANT
  s ^= u;  // NON_COMPLIANT
  u ^= u;  // COMPLIANT
  // f ^= u;  // NON_COMPILABLE
  // cf ^= u;  // NON_COMPILABLE

  b |= u;  // NON_COMPLIANT
  c |= u;  // NON_COMPLIANT
  e1 |= u; // NON_COMPLIANT
  s |= u;  // NON_COMPLIANT
  u |= u;  // COMPLIANT
  // f |= u;  // NON_COMPILABLE
  // cf |= u;  // NON_COMPILABLE

  u &= b;  // NON_COMPLIANT
  u &= c;  // NON_COMPLIANT
  u &= e1; // NON_COMPLIANT
  u &= s;  // NON_COMPLIANT
  u &= u;  // COMPLIANT
  // u &= f;  // NON_COMPILABLE
  // u &= cf;  // NON_COMPILABLE

  u ^= b;  // NON_COMPLIANT
  u ^= c;  // NON_COMPLIANT
  u ^= e1; // NON_COMPLIANT
  u ^= s;  // NON_COMPLIANT
  u ^= u;  // COMPLIANT
  // u ^= f;  // NON_COMPILABLE
  // u ^= cf;  // NON_COMPILABLE

  u |= b;  // NON_COMPLIANT
  u |= c;  // NON_COMPLIANT
  u |= e1; // NON_COMPLIANT
  u |= s;  // NON_COMPLIANT
  u |= u;  // COMPLIANT
  // u |= f;  // NON_COMPILABLE
  // u |= cf;  // NON_COMPILABLE
}

void pointerType() {
  _Bool b = true;
  int *p;

  !b;     // COMPLIANT
  !p;     // NON_COMPLIANT
  b &&b;  // COMPLIANT
  p &&b;  // NON_COMPLIANT
  b &&p;  // NON_COMPLIANT
  b || b; // COMPLIANT
  p || b; // NON_COMPLIANT
  b || p; // NON_COMPLIANT
  p += 1; // COMPLIANT
  p -= 1; // COMPLIANT
}
