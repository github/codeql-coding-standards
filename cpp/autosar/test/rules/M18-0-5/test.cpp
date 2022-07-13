#include <string>

void test_unbounded_str_funs() {
  char str1[] = "Sample string";
  char str2[40];
  char str3[40];

  int len = std::strlen(str1);

  std::strcpy(str2, str1);

  std::strncpy(str3, str2, 5);

  std::strcat(str2, "cat");

  std::strncat(str3, str2, 5);

  std::strcmp(str1, str2);
  std::strcoll(str1, str2);

  std::strxfrm(str1, str2, 5);

  char *pch = std::strchr(str1, 's');

  int i = std::strcspn(str1, str2);

  char *sub = std::strstr(str2, str1);

  char *toks = std::strtok(str1, "s");
}