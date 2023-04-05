#include <stdint.h>
#include <stdio.h>

void sample(int32_t nums[4], const char string[], int32_t x) {
  for (int i = 0;
       i < sizeof(nums) / // NON_COMPLIANT: `sizeof` directly invoked on `nums`
               sizeof(int32_t);
       i++) {
    printf("%d\n", nums[i]);
  }

  for (int i = 0;
       i < sizeof(string) / // NON_COMPLIANT: directly invoked on `string`
               sizeof(char);
       i++) {
    printf("%c", string[i]);
  }

  printf("%lu\n", sizeof(x)); // COMPLIANT: `x` not a array type parameter

  char local_string[5] = "abcd";
  printf(
      "%lu\n",
      sizeof(
          local_string)); // COMPLIANT: `local_string` not a function parameter
}