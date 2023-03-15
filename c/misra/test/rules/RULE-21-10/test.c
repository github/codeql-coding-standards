#include <time.h>
#include <wchar.h>
void f1() {
  time_t current_time;
  char *c_time_string;
  current_time = time(NULL); // NON_COMPLIANT
  if (current_time == ((time_t)-1)) {
  }
  c_time_string = ctime(&current_time); // NON_COMPLIANT
}
void f2() {

  time_t l1;
  struct tm *l2;
  wchar_t buffer[80];

  time(&l1);                                      // NON_COMPLIANT
  l2 = localtime(&l1);                            // NON_COMPLIANT
  wcsftime(buffer, 80, L"Now it's %I:%M%p.", l2); // NON_COMPLIANT
}
