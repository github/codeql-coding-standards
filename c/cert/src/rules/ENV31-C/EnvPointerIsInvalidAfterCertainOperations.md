# ENV31-C: Do not rely on an env pointer following an operation that may invalidate it

This query implements the CERT-C rule ENV31-C:

> Do not rely on an environment pointer following an operation that may invalidate it


## Description

Some implementations provide a nonportable environment pointer that is valid when `main()` is called but may be invalidated by operations that modify the environment.

The C Standard, J.5.1 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], states

> In a hosted environment, the main function receives a third argument, `char *envp[]`, that points to a null-terminated array of pointers to `char`, each of which points to a string that provides information about the environment for this execution of the program.


Consequently, under a [hosted environment](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions) supporting this common extension, it is possible to access the environment through a modified form of `main()`:

```cpp
main(int argc, char *argv[], char *envp[]){ /* ... */ }

```
However, modifying the environment by any means may cause the environment memory to be reallocated, with the result that `envp` now references an incorrect location. For example, when compiled with GCC 4.8.1 and run on a 32-bit Intel GNU/Linux machine, the following code,

```cpp
#include <stdio.h>
#include <stdlib.h>
 
extern char **environ;

int main(int argc, const char *argv[], const char *envp[]) {
  printf("environ:  %p\n", environ);
  printf("envp:     %p\n", envp);
  setenv("MY_NEW_VAR", "new_value", 1);
  puts("--Added MY_NEW_VAR--");
  printf("environ:  %p\n", environ);
  printf("envp:     %p\n", envp);
  return 0;
}

```
yields

```cpp
% ./envp-environ
environ: 0xbf8656ec
envp:    0xbf8656ec
--Added MY_NEW_VAR--
environ: 0x804a008
envp:    0xbf8656ec

```
It is evident from these results that the environment has been relocated as a result of the call to `setenv()`. The external variable `environ` is updated to refer to the current environment; the `envp` parameter is not.

An environment pointer may also become invalidated by subsequent calls to `getenv().` (See [ENV34-C. Do not store pointers returned by certain functions](https://wiki.sei.cmu.edu/confluence/display/c/ENV34-C.+Do+not+store+pointers+returned+by+certain+functions) for more information.)

## Noncompliant Code Example (POSIX)

After a call to the POSIX `setenv()` function or to another function that modifies the environment, the `envp` pointer may no longer reference the current environment. The *Portable Operating System Interface (POSIX<sup>®</sup>), Base Specifications, Issue 7* \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\], states

> Unanticipated results may occur if `setenv()` changes the external variable `environ`. In particular, if the optional `envp` argument to `main()` is present, it is not changed, and thus may point to an obsolete copy of the environment (as may any other copy of `environ`).


This noncompliant code example accesses the `envp` pointer after calling `setenv()`:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
int main(int argc, const char *argv[], const char *envp[]) {
  if (setenv("MY_NEW_VAR", "new_value", 1) != 0) {
    /* Handle error */
  }
  if (envp != NULL) {
    for (size_t i = 0; envp[i] != NULL; ++i) {
      puts(envp[i]);
    }
  }
  return 0;
}

```
Because `envp` may no longer point to the current environment, this program has unanticipated behavior.

## Compliant Solution (POSIX)

Use `environ` in place of `envp` when defined:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
extern char **environ;

int main(void) {
  if (setenv("MY_NEW_VAR", "new_value", 1) != 0) {
    /* Handle error */
  }
  if (environ != NULL) {
    for (size_t i = 0; environ[i] != NULL; ++i) {
      puts(environ[i]);
    }
  }
  return 0;
}

```

## Noncompliant Code Example (Windows)

After a call to the Windows [_putenv_s()](http://msdn.microsoft.com/en-us/library/eyw7eyfw.aspx) function or to another function that modifies the environment, the `envp` pointer may no longer reference the environment.

According to the Visual C++ reference \[[MSDN](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-MSDN)\]

> The environment block passed to `main` and `wmain` is a "frozen" copy of the current environment. If you subsequently change the environment via a call to `_putenv` or `_wputenv`, the current environment (as returned by `getenv` / `_wgetenv` and the `_environ` / `_wenviron` variable) will change, but the block pointed to by `envp` will not change.


This noncompliant code example accesses the `envp` pointer after calling `_putenv_s()`:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
int main(int argc, const char *argv[], const char *envp[]) {
  if (_putenv_s("MY_NEW_VAR", "new_value") != 0) {
    /* Handle error */
  }
  if (envp != NULL) {
    for (size_t i = 0; envp[i] != NULL; ++i) {
      puts(envp[i]);
    }
  }
  return 0;
}

```
Because `envp` no longer points to the current environment, this program has unanticipated behavior.

## Compliant Solution (Windows)

This compliant solution uses the [_environ](http://msdn.microsoft.com/en-us/library/stxk41x1.aspx) variable in place of `envp`:

```cpp
#include <stdio.h>
#include <stdlib.h>
 
_CRTIMP extern char **_environ;

int main(int argc, const char *argv[]) {
  if (_putenv_s("MY_NEW_VAR", "new_value") != 0) {
    /* Handle error */
  }
  if (_environ != NULL) {
    for (size_t i = 0; _environ[i] != NULL; ++i) {
      puts(_environ[i]);
    }
  }
return 0;
}

```

## Compliant Solution

This compliant solution can reduce remediation time when a large amount of noncompliant `envp` code exists. It replaces

```cpp
int main(int argc, char *argv[], char *envp[]) {
  /* ... */
}

```
with

```cpp
#if defined (_POSIX_) || defined (__USE_POSIX)
  extern char **environ;
  #define envp environ
#elif defined(_WIN32)
  _CRTIMP extern char **_environ;
  #define envp _environ
#endif

int main(int argc, char *argv[]) {
  /* ... */
}

```
This compliant solution may need to be extended to support other implementations that support forms of the external variable `environ`.

## Risk Assessment

Using the `envp` environment pointer after the environment has been modified can result in [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ENV31-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4991, C4992, C4993</strong> <strong>C++4991, C++4992, C++4993</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> 118 S </td> <td> Fully Implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ENV31-a</strong> </td> <td> Do not rely on an environment pointer following an operation that may invalidate it </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule ENV31-C </a> </td> <td> Checks for environment pointer invalidated by previous operation (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4991, 4992, 4993</strong> </td> <td> </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>4991, 4992, 4993</strong> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+MEM00-CPP).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> VOID ENV31-CPP. Do not rely on an environment pointer following an operation that may invalidate it </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>setenv</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> J.5.1, "Environment Arguments" </td> </tr> <tr> <td> \[ <a> MSDN </a> \] </td> <td> <code><a>_environ</a></code> , <code><a>_wenviron</a></code> , <code></code> <a> getenv , _wgetenv </a> , <a> _putenv_s </a> , <a> _wputenv_s </a> </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [ENV31-C: Do not rely on an environment pointer following an operation that may invalidate it](https://wiki.sei.cmu.edu/confluence/display/c)
