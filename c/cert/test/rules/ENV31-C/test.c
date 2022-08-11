#include <stdio.h>
#include <stdlib.h>

// UNIX
extern char **environ;

// WINDOWS
extern char **_environ;
int _putenv_s(const char *varname, const char *value_string);

int main(int argc, const char *argv[], const char *envp[]) {

  if (argc) {
    // UNIX
    if (setenv("MY_NEW_VAR", "new_value", 1) != 0) {
      /* Handle error */
    }
    if (environ != NULL) { // COMPLIANT
      for (size_t i = 0; environ[i] != NULL; ++i) {
        puts(environ[i]);
      }
    }
    if (envp != NULL) {                          // NON_COMPLIANT
      for (size_t i = 0; envp[i] != NULL; ++i) { // NON_COMPLIANT
        puts(envp[i]);                           // NON_COMPLIANT
      }
    }
  } else {
    // WINDOWS
    if (_putenv_s("MY_NEW_VAR", "new_value") != 0) {
      /* Handle error */
    }
    if (_environ != NULL) { // COMPLIANT
      for (size_t i = 0; _environ[i] != NULL; ++i) {
        puts(_environ[i]);
      }
    }
    if (envp != NULL) {                          // NON_COMPLIANT
      for (size_t i = 0; envp[i] != NULL; ++i) { // NON_COMPLIANT
        puts(envp[i]);                           // NON_COMPLIANT
      }
    }
  }
  return 0;
}
