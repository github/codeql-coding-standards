#include <stdio.h>
void fn(void) {
  FILE *fp = fopen("tmp", "r");
  (void)fprintf(fp, "What happens now?"); /* Non-compliant */
  (void)fclose(fp);
}