static int g = 0;
extern int g; // NON_COMPLIANT

static int g1;
static int g1 = 0; // COMPLIANT

int g2;
int g2 = 0; // COMPLIANT
