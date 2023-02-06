#include <stdlib.h>
#include <string.h>

struct node {
  struct node *next;
};

void test_freed_loop_var(struct node *list1, struct node *list2) {
  struct node *tmp;

  for (struct node *p = list1; p != NULL; p = p->next) { // NON_COMPLIANT
    free(p);
  }

  for (struct node *p = list2; p != NULL; p = tmp) { // COMPLIANT
    tmp = p->next;
    free(p);
  }
}

void test_freed_arg(char *input) {
  char *buf = (char *)malloc(strlen(input) + 1);
  strcpy(buf, input); // COMPLIANT
  free(buf);
  strcpy(buf, input); // NON_COMPLIANT
}

void test_freed_access_no_deref(char *input) {
  char *buf = (char *)malloc(strlen(input) + 1);
  strcpy(buf, input); // COMPLIANT
  free(buf);
  char *tmp = buf;  // NON_COMPLIANT
  tmp = buf + 1;    // NON_COMPLIANT
  char *tmp2 = buf; // NON_COMPLIANT
  buf = NULL;       // COMPLIANT
  (char *)buf;      // COMPLIANT
  tmp2 = buf + 1;   // COMPLIANT
}