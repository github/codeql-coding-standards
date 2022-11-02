# ENV33-C: Do not call 'system'

This query implements the CERT-C rule ENV33-C:

> Do not call system()


## Description

The C Standard `system()` function executes a specified command by invoking an [implementation-defined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) command processor, such as a UNIX shell or `CMD.EXE` in Microsoft Windows. The POSIX [popen()](http://pubs.opengroup.org/onlinepubs/9699919799/) and Windows `[_popen()](https://msdn.microsoft.com/en-us/library/96ayss4b(v=vs.140).aspx)` functions also invoke a command processor but create a pipe between the calling program and the executed command, returning a pointer to a stream that can be used to either read from or write to the pipe \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\].

Use of the system() function can result in exploitable [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability), in the worst case allowing execution of arbitrary system commands. Situations in which calls to system() have high risk include the following:

* When passing an unsanitized or improperly sanitized command string originating from a tainted source
* If a command is specified without a path name and the command processor path name resolution mechanism is accessible to an attacker
* If a relative path to an executable is specified and control over the current working directory is accessible to an attacker
* If the specified executable program can be spoofed by an attacker
Do not invoke a command processor via `system()` or equivalent functions to execute a command.

## Noncompliant Code Example

In this noncompliant code example, the `system()` function is used to execute `any_cmd` in the host environment.

```cpp
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

enum { BUFFERSIZE = 512 };

void func(const char *input) {
  char cmdbuf[BUFFERSIZE];
  int len_wanted = snprintf(cmdbuf, BUFFERSIZE,
                            "any_cmd '%s'", input);
  if (len_wanted >= BUFFERSIZE) {
    /* Handle error */
  } else if (len_wanted < 0) {
    /* Handle error */
  } else if (system(cmdbuf) == -1) {
    /* Handle error */
  }
}

```
If this code is compiled and run with elevated privileges on a Linux system, for example, an attacker can create an account by entering the following string:

```cpp
happy'; useradd 'attacker

```
The shell would interpret this string as two separate commands:

```cpp
any_cmd 'happy';
useradd 'attacker'

```
and create a new user account that the attacker can use to access the compromised system.

This noncompliant code example also violates [STR02-C. Sanitize data passed to complex subsystems](https://wiki.sei.cmu.edu/confluence/display/c/STR02-C.+Sanitize+data+passed+to+complex+subsystems).

## Compliant Solution (POSIX)

In this compliant solution, the call to `system()` is replaced with a call to `execve()`. The `exec` family of functions does not use a full shell interpreter, so it is not vulnerable to command-injection attacks, such as the one illustrated in the noncompliant code example.

The `execlp()`, `execvp()`, and (nonstandard) `execvP()` functions duplicate the actions of the shell in searching for an executable file if the specified file name does not contain a forward slash character (`/`). As a result, they should be used without a forward slash character (`/`) only if the `PATH` environment variable is set to a safe value, as described in [ENV03-C. Sanitize the environment when invoking external programs](https://wiki.sei.cmu.edu/confluence/display/c/ENV03-C.+Sanitize+the+environment+when+invoking+external+programs).

The `execl()`, `execle()`, `execv()`, and `execve()` functions do not perform path name substitution.

Additionally, precautions should be taken to ensure the external executable cannot be modified by an untrusted user, for example, by ensuring the executable is not writable by the user.

```cpp
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
 
void func(char *input) {
  pid_t pid;
  int status;
  pid_t ret;
  char *const args[3] = {"any_exe", input, NULL};
  char **env;
  extern char **environ;

  /* ... Sanitize arguments ... */

  pid = fork();
  if (pid == -1) {
    /* Handle error */
  } else if (pid != 0) {
    while ((ret = waitpid(pid, &status, 0)) == -1) {
      if (errno != EINTR) {
        /* Handle error */
        break;
      }
    }
    if ((ret == 0) ||
        !(WIFEXITED(status) && !WEXITSTATUS(status))) {
      /* Report unexpected child status */
    }
  } else {
    /* ... Initialize env as a sanitized copy of environ ... */
    if (execve("/usr/bin/any_cmd", args, env) == -1) {
      /* Handle error */
      _Exit(127);
    }
  }
}

```
This compliant solution is significantly different from the preceding noncompliant code example. First, `input` is incorporated into the `args` array and passed as an argument to `execve()`, eliminating concerns about buffer overflow or string truncation while forming the command string. Second, this compliant solution forks a new process before executing `"/usr/bin/any_cmd"` in the child process. Although this method is more complicated than calling `system()`, the added security is worth the additional effort.

The exit status of 127 is the value set by the shell when a command is not found, and POSIX recommends that applications should do the same. XCU, Section 2.8.2, of *Standard for Information Technology—Portable Operating System Interface (POSIX®), Base Specifications, Issue 7* \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\], says

> If a command is not found, the exit status shall be 127. If the command name is found, but it is not an executable utility, the exit status shall be 126. Applications that invoke utilities without using the shell should use these exit status values to report similar errors.


## Compliant Solution (Windows)

This compliant solution uses the Microsoft Windows [CreateProcess()](http://msdn.microsoft.com/en-us/library/windows/desktop/ms682425(v=vs.85).aspx) API:

```cpp
#include <Windows.h>

void func(TCHAR *input) {
  STARTUPINFO si = { 0 };
  PROCESS_INFORMATION pi;
  si.cb = sizeof(si);
  if (!CreateProcess(TEXT("any_cmd.exe"), input, NULL, NULL, FALSE,
                     0, 0, 0, &si, &pi)) {
    /* Handle error */
  }
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
}
```
This compliant solution relies on the `input` parameter being non-`const`. If it were `const`, the solution would need to create a copy of the parameter because the `CreateProcess()` function can modify the command-line arguments to be passed into the newly created process.

This solution creates the process such that the child process does not inherit any handles from the parent process, in compliance with [WIN03-C. Understand HANDLE inheritance](https://wiki.sei.cmu.edu/confluence/display/c/WIN03-C.+Understand+HANDLE+inheritance).

## Noncompliant Code Example (POSIX)

This noncompliant code invokes the C `system()` function to remove the `.config` file in the user's home directory.

```cpp
#include <stdlib.h>
 
void func(void) {
  system("rm ~/.config");
}

```
If the vulnerable program has elevated privileges, an attacker can manipulate the value of the `HOME` environment variable such that this program can remove any file named `.config` anywhere on the system.

## Compliant Solution (POSIX)

An alternative to invoking the `system()` call to execute an external program to perform a required operation is to implement the functionality directly in the program using existing library calls. This compliant solution calls the POSIX `[unlink()](http://pubs.opengroup.org/onlinepubs/9699919799/)` function to remove a file without invoking the `system()` function \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)[\]](http://pubs.opengroup.org/onlinepubs/9699919799/)

```cpp
#include <pwd.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
void func(void) {
  const char *file_format = "%s/.config";
  size_t len;
  char *pathname;
  struct passwd *pwd;

  /* Get /etc/passwd entry for current user */
  pwd = getpwuid(getuid());
  if (pwd == NULL) {
    /* Handle error */
  }

  /* Build full path name home dir from pw entry */

  len = strlen(pwd->pw_dir) + strlen(file_format) + 1;
  pathname = (char *)malloc(len);
  if (NULL == pathname) {
    /* Handle error */
  }
  int r = snprintf(pathname, len, file_format, pwd->pw_dir);
  if (r < 0 || r >= len) {
    /* Handle error */
  }
  if (unlink(pathname) != 0) {
    /* Handle error */
  }

  free(pathname);
}

```
The `unlink()` function is not susceptible to a symlink attack where the final component of `pathname `(the file name) is a symbolic link because `unlink()` will remove the symbolic link and not affect any file or directory named by the contents of the symbolic link. (See [FIO01-C. Be careful using functions that use file names for identification](https://wiki.sei.cmu.edu/confluence/display/c/FIO01-C.+Be+careful+using+functions+that+use+file+names+for+identification).) While this reduces the susceptibility of the `unlink()` function to symlink attacks, it does not eliminate it. The `unlink()` function is still susceptible if one of the directory names included in the `pathname` is a symbolic link. This could cause the `unlink()` function to delete a similarly named file in a different directory.

## Compliant Solution (Windows)

This compliant solution uses the Microsoft Windows [SHGetKnownFolderPath()](http://msdn.microsoft.com/en-us/library/windows/desktop/bb762188(v=vs.85).aspx) API to get the current user's My Documents folder, which is then combined with the file name to create the path to the file to be deleted. The file is then removed using the [DeleteFile()](http://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx) API.

```cpp
#include <Windows.h>
#include <ShlObj.h>
#include <Shlwapi.h>
 
#if defined(_MSC_VER)
  #pragma comment(lib, "Shlwapi")
#endif

void func(void) {
  HRESULT hr;
  LPWSTR path = 0;
  WCHAR full_path[MAX_PATH];

  hr = SHGetKnownFolderPath(&FOLDERID_Documents, 0, NULL, &path);
  if (FAILED(hr)) {
    /* Handle error */
  }
  if (!PathCombineW(full_path, path, L".config")) {
    /* Handle error */
  }
  CoTaskMemFree(path);
  if (!DeleteFileW(full_path)) {
    /* Handle error */
  }
}
```

## Exceptions

**ENV33-C-EX1**: It is permissible to call `system()` with a null pointer argument to determine the presence of a command processor for the system.

## Risk Assessments

If the command string passed to `system()`, `popen()`, or other function that invokes a command processor is not fully [sanitized](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-sanitize), the risk of [exploitation](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) is high. In the worst case scenario, an attacker can execute arbitrary system commands on the compromised machine with the privileges of the vulnerable process.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ENV33-C </td> <td> High </td> <td> Probable </td> <td> Medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>stdlib-use-system</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ENV33</strong> </td> <td> </td> </tr> <tr> <td> <a> Clang </a> </td> <td> 3.9 </td> <td> <code>cert-env33-c</code> </td> <td> Checked by <code>clang-tidy</code> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>BADFUNC.PATH.SYSTEM</strong> <strong>IO.INJ.COMMAND</strong> </td> <td> Use of system Command injection </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>DONT_CALL</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C5018</strong> <strong>C++5031</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>SV.CODE_INJECTION.SHELL_EXEC</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>588 S</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ENV33-a</strong> </td> <td> Do not call the 'system()' function from the 'stdlib.h' or 'cstdlib' library with an argument other than '0' (null pointer) </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>586</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule ENV33-C </a> </td> <td> Checks for unsafe call to a system function (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>5018</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>stdlib-use-system</strong> </td> <td> Fully checked </td> </tr> <tr> <td> <a> SonarQube C/C++ Plugin </a> </td> <td> 3.11 </td> <td> <strong><a>S990</a></strong> </td> <td> Detects uses of "abort", "exit", "getenv" and "system" from &lt;stdlib.h&gt; </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ENV33-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ENV03-C. Sanitize the environment when invoking external programs </a> . </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C++ Coding Standard </a> </td> <td> <a> ENV02-CPP. Do not call system() if you do not need a command processor </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> IDS07-J. Sanitize untrusted data passed to the Runtime.exec() method </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TR 24772:2013 </a> </td> <td> Unquoted Search Path or Element \[XZQ\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Calling system \[syscall\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-88 </a> , Argument Injection or Modification </td> <td> 2017-05-18: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-676 </a> </td> <td> 2017-05-18: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-88 and ENV33-C**

Intersection( CWE-88, ENV33-C) =

Allowing an argument to be injected during a call to system()

CWE-88 = Intersection( CWE-88, ENV33-C, list) where list =

* Allowing an argument to be injected during a call to a command interpreter besides system()
ENV33-C = Intersection( CWE-88, ENV33-C, list) where list =
* Other exploits to a call to system(), which include:
* Altering the pathname of the command to invoke (argv\[0\])
* Injection of a second command
* Redirection of standard input, output, or error
**CWE-78 and ENV33-C**

ENV33-C = Union( CWE-78, list), where list =

* Invoking system() with completely trusted arguments
**CWE-676 and ENV33-C**
* Independent( ENV33-C, CON33-C, STR31-C, EXP33-C, MSC30-C, ERR34-C)
* ENV33-C forbids calling system().
* CWE-676 does not indicate what functions are ‘potentially dangerous’; it only addresses strcpy() in its examples. Any C standard library function could be argued to be dangerous, and rebutted by saying that the function is safe when used properly. We will assume that CERT rules mapped to CWE-676 specify dangerous functions. So:
* CWE-676 = Union( ENV33-C, list) where list =
* Invocation of other dangerous functions, besides system().

## Bibliography

<table> <tbody> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>exec</code> XSH, System Interfaces, <code>popen</code> XSH, System Interfaces, <code>unlink</code> </td> </tr> <tr> <td> \[ <a> Wheeler 2004 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [ENV33-C: Do not call system()](https://wiki.sei.cmu.edu/confluence/display/c)
