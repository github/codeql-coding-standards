#include <stdio.h>

FILE *pf1;
FILE *pf2;
FILE f3;

pf2 = pf1; /* Compliant */
f3 = *pf2; /* Non-compliant */
