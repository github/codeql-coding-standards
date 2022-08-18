# STR31-C: Guarantee that storage for strings has sufficient space for character data and the null terminator

This query implements the CERT-C rule STR31-C:

> Guarantee that storage for strings has sufficient space for character data and the null terminator


## Description

Copying data to a buffer that is not large enough to hold that data results in a buffer overflow. Buffer overflows occur frequently when manipulating strings \[[Seacord 2013b](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Seacord2013)\]. To prevent such errors, either limit copies through truncation or, preferably, ensure that the destination is of sufficient size to hold the character data to be copied and the null-termination character. (See [STR03-C. Do not inadvertently truncate a string](https://wiki.sei.cmu.edu/confluence/display/c/STR03-C.+Do+not+inadvertently+truncate+a+string).)

When strings live on the heap, this rule is a specific instance of [MEM35-C. Allocate sufficient memory for an object](https://wiki.sei.cmu.edu/confluence/display/c/MEM35-C.+Allocate+sufficient+memory+for+an+object). Because strings are represented as arrays of characters, this rule is related to both [ARR30-C. Do not form or use out-of-bounds pointers or array subscripts](https://wiki.sei.cmu.edu/confluence/display/c/ARR30-C.+Do+not+form+or+use+out-of-bounds+pointers+or+array+subscripts) and [ARR38-C. Guarantee that library functions do not form invalid pointers](https://wiki.sei.cmu.edu/confluence/display/c/ARR38-C.+Guarantee+that+library+functions+do+not+form+invalid+pointers).

## Noncompliant Code Example (Off-by-One Error)

This noncompliant code example demonstrates an *off-by-one* error \[[Dowd 2006](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Dowd06)\]. The loop copies data from `src` to `dest`. However, because the loop does not account for the null-termination character, it may be incorrectly written 1 byte past the end of `dest`.

```cpp
#include <stddef.h>
 
void copy(size_t n, char src[n], char dest[n]) {
   size_t i;
 
   for (i = 0; src[i] && (i < n); ++i) {
     dest[i] = src[i];
   }
   dest[i] = '\0';
}

```

## Compliant Solution (Off-by-One Error)

In this compliant solution, the loop termination condition is modified to account for the null-termination character that is appended to `dest`:

```cpp
#include <stddef.h>
 
void copy(size_t n, char src[n], char dest[n]) {
   size_t i;
 
   for (i = 0; src[i] && (i < n - 1); ++i) {
     dest[i] = src[i];
   }
   dest[i] = '\0';
}

```

## Noncompliant Code Example (gets())

The `gets()` function, which was deprecated in the C99 Technical Corrigendum 3 and removed from C11, is inherently unsafe and should never be used because it provides no way to control how much data is read into a buffer from `stdin`. This noncompliant code example assumes that `gets()` will not read more than `BUFFER_SIZE - 1` characters from `stdin`. This is an invalid assumption, and the resulting operation can result in a buffer overflow.

The `gets()` function reads characters from the `stdin` into a destination array until end-of-file is encountered or a newline character is read. Any newline character is discarded, and a null character is written immediately after the last character read into the array.

```cpp
#include <stdio.h>
 
#define BUFFER_SIZE 1024

void func(void) {
  char buf[BUFFER_SIZE];
  if (gets(buf) == NULL) {
    /* Handle error */
  }
}
```
See also [MSC24-C. Do not use deprecated or obsolescent functions](https://wiki.sei.cmu.edu/confluence/display/c/MSC24-C.+Do+not+use+deprecated+or+obsolescent+functions).

## Compliant Solution (fgets())

The `fgets()` function reads, at most, one less than the specified number of characters from a stream into an array. This solution is compliant because the number of characters copied from `stdin` to `buf` cannot exceed the allocated memory:

```cpp
#include <stdio.h>
#include <string.h>
 
enum { BUFFERSIZE = 32 };
 
void func(void) {
  char buf[BUFFERSIZE];
  int ch;

  if (fgets(buf, sizeof(buf), stdin)) {
    /* fgets() succeeded; scan for newline character */
    char *p = strchr(buf, '\n');
    if (p) {
      *p = '\0';
    } else {
      /* Newline not found; flush stdin to end of line */
      while ((ch = getchar()) != '\n' && ch != EOF)
        ;
      if (ch == EOF && !feof(stdin) && !ferror(stdin)) {
          /* Character resembles EOF; handle error */ 
      }
    }
  } else {
    /* fgets() failed; handle error */
  }
}
```
The `fgets()` function is not a strict replacement for the `gets()` function because `fgets()` retains the newline character (if read) and may also return a partial line. It is possible to use `fgets()` to safely process input lines too long to store in the destination array, but this is not recommended for performance reasons. Consider using one of the following compliant solutions when replacing `gets()`.

## Compliant Solution (gets_s())

The `gets_s()` function reads, at most, one less than the number of characters specified from the stream pointed to by `stdin` into an array.

The C Standard, Annex K \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO%2FIEC9899-2011)\], states

> No additional characters are read after a new-line character (which is discarded) or after end-of-file. The discarded new-line character does not count towards number of characters read. A null character is written immediately after the last character read into the array.


If end-of-file is encountered and no characters have been read into the destination array, or if a read error occurs during the operation, then the first character in the destination array is set to the null character and the other elements of the array take unspecified values:

```cpp
#define __STDC_WANT_LIB_EXT1__ 1
#include <stdio.h>
 
enum { BUFFERSIZE = 32 };
 
void func(void) {
  char buf[BUFFERSIZE];

  if (gets_s(buf, sizeof(buf)) == NULL) {
    /* Handle error */
  }
}
```

## Compliant Solution (getline(), POSIX)

The `getline()` function is similar to the `fgets()` function but can dynamically allocate memory for the input buffer. If passed a null pointer, `getline()` dynamically allocates a buffer of sufficient size to hold the input. If passed a pointer to dynamically allocated storage that is too small to hold the contents of the string, the `getline()` function resizes the buffer, using `realloc()`, rather than truncating the input. If successful, the `getline()` function returns the number of characters read, which can be used to determine if the input has any null characters before the newline. The `getline()` function works only with dynamically allocated buffers. Allocated memory must be explicitly deallocated by the caller to avoid memory leaks. (See [MEM31-C. Free dynamically allocated memory when no longer needed](https://wiki.sei.cmu.edu/confluence/display/c/MEM31-C.+Free+dynamically+allocated+memory+when+no+longer+needed).)

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
void func(void) {
  int ch;
  size_t buffer_size = 32;
  char *buffer = malloc(buffer_size);
 
  if (!buffer) {
    /* Handle error */
    return;
  }

  if ((ssize_t size = getline(&buffer, &buffer_size, stdin))
        == -1) {
    /* Handle error */
  } else {
    char *p = strchr(buffer, '\n');
    if (p) {
      *p = '\0';
    } else {
      /* Newline not found; flush stdin to end of line */
      while ((ch = getchar()) != '\n' && ch != EOF)
	    ;
	  if (ch == EOF && !feof(stdin) && !ferror(stdin)) {
         /* Character resembles EOF; handle error */
      }
    }
  }
  free (buffer);
}
```
Note that the `getline()` function uses an [in-band error indicator](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-in-banderrorindicator), in violation of [ERR02-C. Avoid in-band error indicators](https://wiki.sei.cmu.edu/confluence/display/c/ERR02-C.+Avoid+in-band+error+indicators).

## Noncompliant Code Example (getchar())

Reading one character at a time provides more flexibility in controlling behavior, though with additional performance overhead. This noncompliant code example uses the `getchar()` function to read one character at a time from `stdin` instead of reading the entire line at once. The `stdin` stream is read until end-of-file is encountered or a newline character is read. Any newline character is discarded, and a null character is written immediately after the last character read into the array. Similar to the noncompliant code example that invokes `gets()`, there are no guarantees that this code will not result in a buffer overflow.

```cpp
#include <stdio.h>
 
enum { BUFFERSIZE = 32 };
 
void func(void) {
  char buf[BUFFERSIZE];
  char *p;
  int ch;
  p = buf;
  while ((ch = getchar()) != '\n' && ch != EOF) {
    *p++ = (char)ch;
  }
  *p++ = 0;
  if (ch == EOF) {
      /* Handle EOF or error */
  }
}
```
After the loop ends, if `ch == EOF`, the loop has read through to the end of the stream without encountering a newline character, or a read error occurred before the loop encountered a newline character. To conform to [FIO34-C. Distinguish between characters read from a file and EOF or WEOF](https://wiki.sei.cmu.edu/confluence/display/c/FIO34-C.+Distinguish+between+characters+read+from+a+file+and+EOF+or+WEOF), the error-handling code must verify that an end-of-file or error has occurred by calling `feof()` or `ferror()`.

## Compliant Solution (getchar())

In this compliant solution, characters are no longer copied to `buf` once `index == BUFFERSIZE - 1`, leaving room to null-terminate the string. The loop continues to read characters until the end of the line, the end of the file, or an error is encountered. When `chars_read > index`, the input string has been truncated.

```cpp
#include <stdio.h>
 
enum { BUFFERSIZE = 32 };
 
void func(void) {
  char buf[BUFFERSIZE];
  int ch;
  size_t index = 0;
  size_t chars_read = 0;
 
  while ((ch = getchar()) != '\n' && ch != EOF) {
    if (index < sizeof(buf) - 1) {
      buf[index++] = (char)ch;
    }
    chars_read++;
  }
  buf[index] = '\0';  /* Terminate string */
  if (ch == EOF) {
    /* Handle EOF or error */
  }
  if (chars_read > index) {
    /* Handle truncation */
  }
}

```

## Noncompliant Code Example (fscanf())

In this noncompliant example, the call to `fscanf()` can result in a write outside the character array `buf`:

```cpp
#include <stdio.h>
 
enum { BUF_LENGTH = 1024 };
 
void get_data(void) {
  char buf[BUF_LENGTH];
  if (1 != fscanf(stdin, "%s", buf)) {
    /* Handle error */
  }

  /* Rest of function */
}

```

## Compliant Solution (fscanf())

In this compliant solution, the call to `fscanf()` is constrained not to overflow `buf`:

```cpp
#include <stdio.h>
 
enum { BUF_LENGTH = 1024 };
 
void get_data(void) {
  char buf[BUF_LENGTH];
  if (1 != fscanf(stdin, "%1023s", buf)) {
    /* Handle error */
  }

  /* Rest of function */
}

```

## Noncompliant Code Example (argv)

In a [hosted environment](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-hostedenvironment), arguments read from the command line are stored in process memory. The function `main()`, called at program startup, is typically declared as follows when the program accepts command-line arguments:

```cpp
int main(int argc, char *argv[]) { /* ... */ }

```
Command-line arguments are passed to `main()` as pointers to strings in the array members `argv[0]` through `argv[argc - 1]`. If the value of `argc` is greater than 0, the string pointed to by `argv[0]` is, by convention, the program name. If the value of `argc` is greater than 1, the strings referenced by `argv[1]` through `argv[argc - 1]` are the program arguments.

[Vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) can occur when inadequate space is allocated to copy a command-line argument or other program input. In this noncompliant code example, an attacker can manipulate the contents of `argv[0]` to cause a buffer overflow:

```cpp
#include <string.h>
 
int main(int argc, char *argv[]) {
  /* Ensure argv[0] is not null */
  const char *const name = (argc && argv[0]) ? argv[0] : "";
  char prog_name[128];
  strcpy(prog_name, name);
 
  return 0;
}

```

## Compliant Solution (argv)

The `strlen()` function can be used to determine the length of the strings referenced by `argv[0]` through `argv[argc - 1]` so that adequate memory can be dynamically allocated.

```cpp
#include <stdlib.h>
#include <string.h>
 
int main(int argc, char *argv[]) {
  /* Ensure argv[0] is not null */
  const char *const name = (argc && argv[0]) ? argv[0] : "";
  char *prog_name = (char *)malloc(strlen(name) + 1);
  if (prog_name != NULL) {
    strcpy(prog_name, name);
  } else {
    /* Handle error */
  }
  free(prog_name);
  return 0;
}

```
Remember to add a byte to the destination string size to accommodate the null-termination character.

## Compliant Solution (argv)

The `strcpy_s()` function provides additional safeguards, including accepting the size of the destination buffer as an additional argument. (See [STR07-C. Use the bounds-checking interfaces for string manipulation](https://wiki.sei.cmu.edu/confluence/display/c/STR07-C.+Use+the+bounds-checking+interfaces+for+string+manipulation).)

```cpp
#define __STDC_WANT_LIB_EXT1__ 1
#include <stdlib.h>
#include <string.h>
 
int main(int argc, char *argv[]) {
  /* Ensure argv[0] is not null */
  const char *const name = (argc && argv[0]) ? argv[0] : "";
  char *prog_name;
  size_t prog_size;

  prog_size = strlen(name) + 1;
  prog_name = (char *)malloc(prog_size);

  if (prog_name != NULL) {
    if (strcpy_s(prog_name, prog_size, name)) {
      /* Handle  error */
    }
  } else {
    /* Handle error */
  }
  /* ... */
  free(prog_name);
  return 0;
}

```
The `strcpy_s()` function can be used to copy data to or from dynamically allocated memory or a statically allocated array. If insufficient space is available, `strcpy_s()` returns an error.

## Compliant Solution (argv)

If an argument will not be modified or concatenated, there is no reason to make a copy of the string. Not copying a string is the best way to prevent a buffer overflow and is also the most efficient solution. Care must be taken to avoid assuming that `argv[0]` is non-null.

```cpp
int main(int argc, char *argv[]) {
  /* Ensure argv[0] is not null */
  const char * const prog_name = (argc && argv[0]) ? argv[0] : "";
  /* ... */
  return 0;
}

```

## Noncompliant Code Example (getenv())

According to the C Standard, 7.22.4.6 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\]

> The `getenv` function searches an environment list, provided by the host environment, for a string that matches the string pointed to by `name`. The set of environment names and the method for altering the environment list are implementation defined.


Environment variables can be arbitrarily large, and copying them into fixed-length arrays without first determining the size and allocating adequate storage can result in a buffer overflow.

```cpp
#include <stdlib.h>
#include <string.h>
 
void func(void) {
  char buff[256];
  char *editor = getenv("EDITOR");
  if (editor == NULL) {
    /* EDITOR environment variable not set */
  } else {
    strcpy(buff, editor);
  }
}

```

## Compliant Solution (getenv())

Environmental variables are loaded into process memory when the program is loaded. As a result, the length of these strings can be determined by calling the `strlen()` function, and the resulting length can be used to allocate adequate dynamic memory:

```cpp
#include <stdlib.h>
#include <string.h>
 
void func(void) {
  char *buff;
  char *editor = getenv("EDITOR");
  if (editor == NULL) {
    /* EDITOR environment variable not set */
  } else {
    size_t len = strlen(editor) + 1;
    buff = (char *)malloc(len);
    if (buff == NULL) {
      /* Handle error */
    }  
    memcpy(buff, editor, len);
    free(buff);
  }
}

```

## Noncompliant Code Example (sprintf())

In this noncompliant code example, `name` refers to an external string; it could have originated from user input, the file system, or the network. The program constructs a file name from the string in preparation for opening the file.

```cpp
#include <stdio.h>
 
void func(const char *name) {
  char filename[128];
  sprintf(filename, "%s.txt", name);
}
```
Because the `sprintf()` function makes no guarantees regarding the length of the generated string, a sufficiently long string in `name` could generate a buffer overflow.

## Compliant Solution (sprintf())

The buffer overflow in the preceding noncompliant example can be prevented by adding a precision to the `%s` conversion specification. If the precision is specified, no more than that many bytes are written. The precision `123` in this compliant solution ensures that `filename` can contain the first 123 characters of `name`, the `.txt` extension, and the null terminator.

```cpp
#include <stdio.h>
 
void func(const char *name) {
  char filename[128];
  sprintf(filename, "%.123s.txt", name);
}

```
You can also use `*` to indicate that the precision should be provided as a variadic argument:

```cpp
#include <stdio.h>
 
void func(const char *name) {
  char filename[128];
  sprintf(filename, "%.*s.txt", sizeof(filename) - 5, name);
}
```

## Compliant Solution (snprintf())

A more general solution is to use the `snprintf()` function:

```cpp
#include <stdio.h>
 
void func(const char *name) {
  char filename[128];
  snprintf(filename, sizeof(filename), "%s.txt", name);
}

```

## Risk Assessment

Copying string data to a buffer that is too small to hold that data results in a buffer overflow. Attackers can exploit this condition to execute arbitrary code with the permissions of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> STR31-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

Array access out of bounds, Buffer overflow from incorrect string format specifier, Destination buffer overflow in string manipulation, Invalid use of standard library string routine, Missing null in string array, Pointer access out of bounds, Tainted NULL or non-null-terminated string, Use of dangerous standard function

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported Astrée reports all buffer overflows resulting from copying data to a buffer that is not large enough to hold that data. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-STR31</strong> </td> <td> Detects calls to unsafe string function that may cause buffer overflow Detects potential buffer overruns, including those caused by unsafe usage of <code>fscanf()</code> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.TO</strong> <strong>MISC.MEM.NTERM</strong> <strong>BADFUNC.BO.\*</strong> </td> <td> Buffer overrun Type overrun No space for null terminator A collection of warning classes that report uses of library functions prone to internal buffer overflows </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of the rule. However, it is unable to handle cases involving <code>strcpy_s()</code> or manual string copies such as the one in the first example </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>STRING_OVERFLOW</strong> <strong>BUFFER_SIZE</strong> <strong>OVERRUN</strong> <strong>STRING_SIZE</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Fortify SCA </a> </td> <td> 5.0 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C2840, C2841, C2842, C2843, C2845, C2846, C2847, C2848, C2930, C2931, C2932, C2933, C2935, C2936, C2937, C2938</strong> <strong>C++0145, C++2840, C++2841, C++2842, C++2843, C++2845, C++2846, C++2847, C++2848, C++2930, C++2931, C++2932, C++2933, C++2935, C++2936, C++2937, C++2938</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>SV.FMT_STR.BAD_SCAN_FORMAT</strong> <strong>SV.UNBOUND_STRING_INPUT.FUNC</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>489 S, 109 D, 66 X, 70 X, 71 X</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-STR31-a</strong> <strong>CERT_C-STR31-b</strong> <strong>CERT_C-STR31-c</strong> <strong>CERT_C-STR31-d</strong> <strong>CERT_C-STR31-e</strong> </td> <td> Avoid accessing arrays out of bounds Avoid overflow when writing to a buffer Prevent buffer overflows from tainted data Avoid buffer write overflow from tainted data Avoid using unsafe string functions which may cause buffer overflows </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>421, 498</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule STR31-C </a> </td> <td> Checks for: Use of dangerous standard functionse of dangerous standard function, missing null in string arrayissing null in string array, buffer overflow from incorrect string format specifieruffer overflow from incorrect string format specifier, destination buffer overflow in string manipulationestination buffer overflow in string manipulation, tainted null or non-null-terminated stringainted null or non-null-terminated string. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5009, 5038, 2840, 2841, 2842, 2843, 2845, 2846, 2847, 2848, 2930, 2931, 2932, 2933, 2935, 2936, 2937, 2938</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>0145, 2840, 2841, 2842, 2843, 2845, 2846, 2847, 2848, 2930, 2931, 2932, 2933, 2935, 2936, 2937, 2938, 5006, 5038</strong> </td> <td> </td> </tr> <tr> <td> <a> PVS-Studio </a> </td> <td> 7.20 </td> <td> <strong>V518<a></a></strong> , <strong>V645<a></a></strong> , <strong>V727<a></a></strong> , <strong><a>V755</a></strong> </td> <td> </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>mem_access</strong> </td> <td> Exhaustively verified (see <a> one compliant and one non-compliant example </a> ). </td> </tr> </tbody> </table>


## Related Vulnerabilities

[CVE-2009-1252](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-1252) results from a violation of this rule. The Network Time Protocol daemon (NTPd), before versions 4.2.4p7 and 4.2.5p74, contained calls to `sprintf` that allow an attacker to execute arbitrary code by overflowing a character array \[[xorl 2009](http://xorl.wordpress.com/2009/06/10/freebsd-sa-0911-ntpd-remote-stack-based-buffer-overflows/)\].

[CVE-2009-0587](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-0587) results from a violation of this rule. Before version 2.24.5, Evolution Data Server performed unchecked arithmetic operations on the length of a user-input string and used the value to allocate space for a new buffer. An attacker could thereby execute arbitrary code by inputting a long string, resulting in incorrect allocation and buffer overflow \[[xorl 2009](http://xorl.wordpress.com/2009/06/10/cve-2009-0587-evolution-data-server-base64-integer-overflows/)\].

[CVE-2021-3156](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-3156) results from a violation of this rule in versions of Sudo before 1.9.5p2. Due to inconsistencies on whether backslashes are escaped, vulnerable versions of Sudo enabled a user to create a heap-based buffer overflow and exploit it to execute arbitrary code. [\[BC\]](https://www.bleepingcomputer.com/news/security/new-linux-sudo-flaw-lets-local-users-gain-root-privileges/).

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ARR32-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR03-C. Do not inadvertently truncate a string </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> STR07-C. Use the bounds-checking interfaces for remediation of existing string manipulation code </a> <a> MSC24-C. Do not use deprecated or obsolescent functions </a> <a> MEM00-C. Allocate and free memory in the same module, at the same level of abstraction </a> <a> FIO34-C. Distinguish between characters read from a file and EOF or WEOF </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> String Termination \[CJM\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Buffer Boundary Violation (Buffer Overflow) \[HCB\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Unchecked Array Copying \[XYW\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Using a tainted value to write to an object using a formatted input or output function \[taintformatio\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Tainted strings are passed to a string copying function \[taintstrcpy\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-119 </a> , Improper Restriction of Operations within the Bounds of a Memory Buffer </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-120 </a> , Buffer Copy without Checking Size of Input ("Classic Buffer Overflow") </td> <td> 2017-05-15: CERT: Exact </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-123 </a> , Write-what-where Condition </td> <td> 2017-06-12: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-125 </a> , Out-of-bounds Read </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-676 </a> , Off-by-one Error </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-122 and STR31-C**

STR31-C = Union( CWE-122, list) where list =

* Buffer overflows on strings in the stack or data segment
**CWE-125 and STR31-C**

Independent( ARR30-C, ARR38-C, EXP39-C, INT30-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

Intersection( STR31-C, CWE-125) =

* Directly reading beyond the end of a string
STR31-C – CWE-125 =
* Directly writing beyond the end of a string
CWE-125 – STR31-C =
* Reading beyond a non-string array
* Reading beyond a string using library functions
**CWE-676 and STR31-C**
* Independent( ENV33-C, CON33-C, STR31-C, EXP33-C, MSC30-C, ERR34-C)
* STR31-C implies that several C string copy functions, like strcpy() are dangerous.
Intersection( CWE-676, STR31-C) =
* Buffer Overflow resulting from invocation of the following dangerous functions:
* gets(), fscanf(), strcpy(), sprintf()
STR31-C – CWE-676 =
* Buffer overflow that does not involve the dangerous functions listed above.
CWE-676 - STR31-C =
* Invocation of other dangerous functions
**CWE-121 and STR31-C**

STR31-C = Union( CWE-121, list) where list =

* Buffer overflows on strings in the heap or data segment
**CWE-123 and STR31-C**

Independent(ARR30-C, ARR38-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

Intersection( CWE-123, STR31-C) =

* Buffer overflow that overwrites a (unrelated) pointer with untrusted data
STR31-C – CWE-123 =
* Buffer overflow that does not overwrite a (unrelated) pointer
CWE-123 – STR31-C =
* Arbitrary writes that do not involve buffer overflows
**CWE-119 and STR31-C**

Independent( ARR30-C, ARR38-C, ARR32-C, INT30-C, INT31-C, EXP39-C, EXP33-C, FIO37-C)

STR31-C = Subset( Union( ARR30-C, ARR38-C))

STR32-C = Subset( ARR38-C)

CWE-119 = Union( STR31-C, list) where list =

* Out-of-bounds reads or writes that are not created by string copy operations
**CWE-193 and STR31-C**

Intersection( CWE-193, STR31-C) = Ø

CWE-193 involves an integer computation error (typically off-by-one), which is often a precursor to (slight) buffer overflow. However the two errors occur in different operations and are thus unrelated.

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Dowd 2006 </a> \] </td> <td> Chapter 7, "Program Building Blocks" ("Loop Constructs," pp. 327–336) </td> </tr> <tr> <td> \[ <a> Drepper 2006 </a> \] </td> <td> Section 2.1.1, "Respecting Memory Bounds" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> K.3.5.4.1, "The <code>gets_s</code> Function" </td> </tr> <tr> <td> \[ <a> Lai 2006 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> NIST 2006 </a> \] </td> <td> SAMATE Reference Dataset Test Case ID 000-000-088 </td> </tr> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 2, "Strings" </td> </tr> <tr> <td> \[ <a> xorl 2009 </a> \] </td> <td> <a> FreeBSD-SA-09:11: NTPd Remote Stack Based Buffer Overflows </a> </td> </tr> <tr> <td> \[BC\] </td> <td> <a> New Linux SUDO flaw lets local users gain root privileges </a> </td> </tr> </tbody> </table>


## Implementation notes

The enforcement of this rule does not try to approximate the effects of loops and as such may not find cases where a loop operation on a string fails to null terminate a string (or causes an overflow).

## References

* CERT-C: [STR31-C: Guarantee that storage for strings has sufficient space for character data and the null terminator](https://wiki.sei.cmu.edu/confluence/display/c)
