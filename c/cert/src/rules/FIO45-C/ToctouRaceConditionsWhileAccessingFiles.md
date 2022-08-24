# FIO45-C: Avoid TOCTOU race conditions while accessing files

This query implements the CERT-C rule FIO45-C:

> Avoid TOCTOU race conditions while accessing files


## Description

A [TOCTOU](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-TOCTOU) (time-of-check, time-of-use) race condition is possible when two or more concurrent processes are operating on a shared file system \[[Seacord 2013b](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Seacord2013)\]. Typically, the first access is a check to verify some attribute of the file, followed by a call to use the file. An attacker can alter the file between the two accesses, or replace the file with a symbolic or hard link to a different file. These TOCTOU conditions can be exploited when a program performs two or more file operations on the same file name or path name.

A program that performs two or more file operations on a single file name or path name creates a race window between the two file operations. This race window comes from the assumption that the file name or path name refers to the same resource both times. If an attacker can modify the file, remove it, or replace it with a different file, then this assumption will not hold.

## Noncompliant Code Example

If an existing file is opened for writing with the `w` mode argument, the file's previous contents (if any) are destroyed. This noncompliant code example tries to prevent an existing file from being overwritten by first opening it for reading before opening it for writing. An attacker can exploit the race window between the two calls to `fopen()` to overwrite an existing file.

```cpp
#include <stdio.h>

void open_some_file(const char *file) {
  FILE *f = fopen(file, "r");
  if (NULL != f) {
    /* File exists, handle error */
  } else {
    if (fclose(f) == EOF) {
      /* Handle error */
    }
    f = fopen(file, "w");
    if (NULL == f) {
      /* Handle error */
    }
 
    /* Write to file */
    if (fclose(f) == EOF) {
      /* Handle error */
    }
  }
}

```

## Compliant Solution

This compliant solution invokes `fopen()` at a single location and uses the `x` mode of `fopen()`, which was added in C11. This mode causes `fopen()` to fail if the file exists. This check and subsequent open is performed without creating a race window. The `x` mode provides exclusive access to the file only if the host environment provides this support.

```cpp
#include <stdio.h>

void open_some_file(const char *file) {
  FILE *f = fopen(file, "wx");
  if (NULL == f) {
    /* Handle error */
  }
  /* Write to file */
  if (fclose(f) == EOF) {
    /* Handle error */
  }
}
```

## Compliant Solution (POSIX)

This compliant solution uses the `O_CREAT` and `O_EXCL` flags of POSIX's `open()` function. These flags cause `open()` to fail if the file exists.

```cpp
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

void open_some_file(const char *file) {
  int fd = open(file, O_CREAT | O_EXCL | O_WRONLY);
  if (-1 != fd) {
    FILE *f = fdopen(fd, "w");
    if (NULL != f) {
      /* Write to file */

      if (fclose(f) == EOF) {
        /* Handle error */
      }
    } else {
      if (close(fd) == -1) {
        /* Handle error */
      }
    }
  }
}
```

## Exceptions

**FIO45-C-EX2:** Accessing a file name or path name multiple times is permitted if the file referenced resides in a secure directory. (For more information, see [FIO15-C. Ensure that file operations are performed in a secure directory](https://wiki.sei.cmu.edu/confluence/display/c/FIO15-C.+Ensure+that+file+operations+are+performed+in+a+secure+directory).)

**FIO45-C-EX3:** Accessing a file name or path name multiple times is permitted if the program can verify that every operation operates on the same file.

This POSIX code example verifies that each subsequent file access operates on the same file. In POSIX, every file can be uniquely identified by using its device and i-node attributes. This code example checks that a file name refers to a regular file (and not a directory, symbolic link, or other special file) by invoking `lstat()`. This call also retrieves its device and i-node. The file is subsequently opened. Finally, the program verifies that the file that was opened is the same one (matching device and i-nodes) as the file that was confirmed as a regular file.

An attacker can still exploit this code if they have the ability to delete the benign file and create the malicious file within the race window between lstat() and open(). It is possible that the OS kernel will reuse the same device and i-node for both files. This can be mitigated by making sure that the attacker lacks the permissions to delete the benign file.

```cpp
#include <sys/stat.h>
#include <fcntl.h>

int open_regular_file(char *filename, int flags) {
  struct stat lstat_info;
  struct stat fstat_info;
  int f;
 
  if (lstat(filename, &lstat_info) == -1) {
    /* File does not exist, handle error */
  }
 
  if (!S_ISREG(lstat_info.st_mode)) {
    /* File is not a regular file, handle error */
  }
 
  if ((f = open(filename, flags)) == -1) {
    /* File has disappeared, handle error */
  }
 
  if (fstat(f, &fstat_info) == -1) {
    /* Handle error */
  }
 
  if (lstat_info.st_ino != fstat_info.st_ino  ||
      lstat_info.st_dev != fstat_info.st_dev) {
    /* Open file is not the expected regular file, handle error */
  }
 
  /* f is the expected regular open file */
  return f;
}
```

## Risk Assessment

[TOCTOU](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-TOCTOU) race conditions can result in [unexpected behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior), including privilege escalation.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> FIO45-C </td> <td> High </td> <td> Probable </td> <td> High </td> <td> <strong>P6</strong> </td> <td> <strong>L2</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>IO.RACE</strong> </td> <td> File system race condition </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>TOCTOU</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4851, C4852, C4853</strong> <strong>C++4851, C++4852, C++4853</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>SV.TOCTOU.FILE_ACCESS</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>75 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-FIO45-a</strong> </td> <td> Avoid race conditions while accessing files </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule FIO45-C </a> </td> <td> Checks for file access between time of check and use (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+FIO45-C).

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Seacord 2013b </a> \] </td> <td> Chapter 7, "Files" </td> </tr> </tbody> </table>


## Implementation notes

The query is limited to the specific class of TOCTOU race conditions that derives from the incorrectuse of `fopen` to check the existence of a file.

## References

* CERT-C: [FIO45-C: Avoid TOCTOU race conditions while accessing files](https://wiki.sei.cmu.edu/confluence/display/c)
