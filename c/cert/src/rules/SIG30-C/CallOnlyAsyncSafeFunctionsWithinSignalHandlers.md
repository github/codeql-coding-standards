# SIG30-C: Call only asynchronous-safe functions within signal handlers

This query implements the CERT-C rule SIG30-C:

> Call only asynchronous-safe functions within signal handlers


## Description

Call only [asynchronous-safe functions](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safefunction) within signal handlers. For [strictly conforming](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-strictlyconforming) programs, only the C standard library functions `abort()`, `_Exit()`, `quick_exit()`, and `signal()` can be safely called from within a signal handler.

The C Standard, 7.14.1.1, paragraph 5 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states that if the signal occurs other than as the result of calling the `abort()` or `raise()` function, the behavior is [undefined](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) if

> ...the signal handler calls any function in the standard library other than the `abort` function, the `_Exit` function, the `quick_exit` function, or the `signal` function with the first argument equal to the signal number corresponding to the signal that caused the invocation of the handler.


Implementations may define a list of additional asynchronous-safe functions. These functions can also be called within a signal handler. This restriction applies to library functions as well as application-defined functions.

According to the C Rationale, 7.14.1.1 \[[C99 Rationale 2003](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-C992003)\],

> When a signal occurs, the normal flow of control of a program is interrupted. If a signal occurs that is being trapped by a signal handler, that handler is invoked. When it is finished, execution continues at the point at which the signal occurred. This arrangement can cause problems if the signal handler invokes a library function that was being executed at the time of the signal.


In general, it is not safe to invoke I/O functions from within signal handlers. Programmers should ensure a function is included in the list of an implementation's asynchronous-safe functions for all implementations the code will run on before using them in signal handlers.

## Noncompliant Code Example

In this noncompliant example, the C standard library functions `fputs()` and `free()` are called from the signal handler via the function `log_message()`. Neither function is [asynchronous-safe](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safefunction).

```cpp
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

enum { MAXLINE = 1024 };
char *info = NULL;

void log_message(void) {
  fputs(info, stderr);
}

void handler(int signum) {
  log_message();
  free(info);
  info = NULL;
}

int main(void) {
  if (signal(SIGINT, handler) == SIG_ERR) {
    /* Handle error */
  }
  info = (char *)malloc(MAXLINE);
  if (info == NULL) {
    /* Handle Error */
  }

  while (1) {
    /* Main loop program code */

    log_message();

    /* More program code */
  }
  return 0;
}

```

## Compliant Solution

Signal handlers should be as concise as possible—ideally by unconditionally setting a flag and returning. This compliant solution sets a flag of type `volatile sig_atomic_t` and returns; the `log_message()` and `free()` functions are called directly from `main()`:

```cpp
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

enum { MAXLINE = 1024 };
volatile sig_atomic_t eflag = 0;
char *info = NULL;

void log_message(void) {
  fputs(info, stderr);
}

void handler(int signum) {
  eflag = 1;
}

int main(void) {
  if (signal(SIGINT, handler) == SIG_ERR) {
    /* Handle error */
  }
  info = (char *)malloc(MAXLINE);
  if (info == NULL) {
    /* Handle error */
  }

  while (!eflag) {
    /* Main loop program code */

    log_message();

    /* More program code */
  }

  log_message();
  free(info);
  info = NULL;

  return 0;
}

```

## Noncompliant Code Example (longjmp())

Invoking the `longjmp()` function from within a signal handler can lead to [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) if it results in the invocation of any non-[asynchronous-safe](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safe) functions. Consequently, neither `longjmp()` nor the POSIX `siglongjmp()` functions should ever be called from within a signal handler.

This noncompliant code example is similar to a [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in an old version of Sendmail \[[VU \#834865](http://www.kb.cert.org/vuls/id/834865)\]. The intent is to execute code in a `main()` loop, which also logs some data. Upon receiving a `SIGINT`, the program transfers out of the loop, logs the error, and terminates.

However, an attacker can [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) this noncompliant code example by generating a `SIGINT` just before the second `if` statement in `log_message()`. The result is that `longjmp()` transfers control back to `main()`, where `log_message()` is called again. However, the first `if` statement would not be executed this time (because `buf` is not set to `NULL` as a result of the interrupt), and the program would write to the invalid memory location referenced by `buf0`.

```cpp
#include <setjmp.h>
#include <signal.h>
#include <stdlib.h>

enum { MAXLINE = 1024 };
static jmp_buf env;

void handler(int signum) {
  longjmp(env, 1);
}

void log_message(char *info1, char *info2) {
  static char *buf = NULL;
  static size_t bufsize;
  char buf0[MAXLINE];

  if (buf == NULL) {
    buf = buf0;
    bufsize = sizeof(buf0);
  }

  /*
   * Try to fit a message into buf, else reallocate
   * it on the heap and then log the message.
   */

  /* Program is vulnerable if SIGINT is raised here */

  if (buf == buf0) {
    buf = NULL;
  }
}

int main(void) {
  if (signal(SIGINT, handler) == SIG_ERR) {
    /* Handle error */
  }
  char *info1;
  char *info2;

  /* info1 and info2 are set by user input here */

  if (setjmp(env) == 0) {
    while (1) {
      /* Main loop program code */
      log_message(info1, info2);
      /* More program code */
    }
  } else {
    log_message(info1, info2);
  }

  return 0;
}

```

## Compliant Solution

In this compliant solution, the call to `longjmp()` is removed; the signal handler sets an error flag instead:

```cpp
#include <signal.h>
#include <stdlib.h>

enum { MAXLINE = 1024 };
volatile sig_atomic_t eflag = 0;

void handler(int signum) {
  eflag = 1;
}

void log_message(char *info1, char *info2) {
  static char *buf = NULL;
  static size_t bufsize;
  char buf0[MAXLINE];

  if (buf == NULL) {
    buf = buf0;
    bufsize = sizeof(buf0);
  }

  /*
   * Try to fit a message into buf, else reallocate
   * it on the heap and then log the message.
   */
  if (buf == buf0) {
    buf = NULL;
  }
}

int main(void) {
  if (signal(SIGINT, handler) == SIG_ERR) {
    /* Handle error */
  }
  char *info1;
  char *info2;

  /* info1 and info2 are set by user input here */

  while (!eflag) {
    /* Main loop program code */
    log_message(info1, info2);
    /* More program code */
  }

  log_message(info1, info2);

  return 0;
}
```

## Noncompliant Code Example (raise())

In this noncompliant code example, the `int_handler()` function is used to carry out tasks specific to `SIGINT` and then raises `SIGTERM`. However, there is a nested call to the `raise()` function, which is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

```cpp
#include <signal.h>
#include <stdlib.h>
 
void term_handler(int signum) {
  /* SIGTERM handler */
}
 
void int_handler(int signum) {
  /* SIGINT handler */
  if (raise(SIGTERM) != 0) {
    /* Handle error */
  }
}
 
int main(void) {
  if (signal(SIGTERM, term_handler) == SIG_ERR) {
    /* Handle error */
  }
  if (signal(SIGINT, int_handler) == SIG_ERR) {
    /* Handle error */
  }
 
  /* Program code */
  if (raise(SIGINT) != 0) {
    /* Handle error */
  }
  /* More code */
 
  return EXIT_SUCCESS;
}

```

## Compliant Solution

In this compliant solution, `int_handler()` invokes `term_handler()` instead of raising `SIGTERM`:

```cpp
#include <signal.h>
#include <stdlib.h>
 
void term_handler(int signum) {
  /* SIGTERM handler */
}
 
void int_handler(int signum) {
  /* SIGINT handler */
  /* Pass control to the SIGTERM handler */
  term_handler(SIGTERM);
}
 
int main(void) {
  if (signal(SIGTERM, term_handler) == SIG_ERR) {
    /* Handle error */
  }
  if (signal(SIGINT, int_handler) == SIG_ERR) {
    /* Handle error */
  }
 
  /* Program code */
  if (raise(SIGINT) != 0) {
    /* Handle error */
  }
  /* More code */
 
  return EXIT_SUCCESS;
}

```

## Implementation Details

**POSIX**

The following table from the POSIX standard \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\] defines a set of functions that are [asynchronous-signal-safe](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safefunction). Applications may invoke these functions, without restriction, from a signal handler.

<table> <tbody> <tr> <td> <code>_Exit()</code> </td> <td> <code>fexecve()</code> </td> <td> <code>posix_trace_event()</code> </td> <td> <code>sigprocmask()</code> </td> </tr> <tr> <td> <code>_exit()</code> </td> <td> <code>fork()</code> </td> <td> <code>pselect()</code> </td> <td> <code>sigqueue()</code> </td> </tr> <tr> <td> <code>abort()</code> </td> <td> <code>fstat()</code> </td> <td> <code>pthread_kill()</code> </td> <td> <code>sigset()</code> </td> </tr> <tr> <td> <code>accept()</code> </td> <td> <code>fstatat()</code> </td> <td> <code>pthread_self()</code> </td> <td> <code>sigsuspend()</code> </td> </tr> <tr> <td> <code>access()</code> </td> <td> <code>fsync()</code> </td> <td> <code>pthread_sigmask()</code> </td> <td> <code>sleep()</code> </td> </tr> <tr> <td> <code>aio_error()</code> </td> <td> <code>ftruncate()</code> </td> <td> <code>raise()</code> </td> <td> <code>sockatmark()</code> </td> </tr> <tr> <td> <code>aio_return()</code> </td> <td> <code>futimens()</code> </td> <td> <code>read()</code> </td> <td> <code>socket()</code> </td> </tr> <tr> <td> <code>aio_suspend()</code> </td> <td> <code>getegid()</code> </td> <td> <code>readlink()</code> </td> <td> <code>socketpair()</code> </td> </tr> <tr> <td> <code>alarm()</code> </td> <td> <code>geteuid()</code> </td> <td> <code>readlinkat()</code> </td> <td> <code>stat()</code> </td> </tr> <tr> <td> <code>bind()</code> </td> <td> <code>getgid()</code> </td> <td> <code>recv()</code> </td> <td> <code>symlink()</code> </td> </tr> <tr> <td> <code>cfgetispeed()</code> </td> <td> <code>getgroups()</code> </td> <td> <code>recvfrom()</code> </td> <td> <code>symlinkat()</code> </td> </tr> <tr> <td> <code>cfgetospeed()</code> </td> <td> <code>getpeername()</code> </td> <td> <code>recvmsg()</code> </td> <td> <code>tcdrain()</code> </td> </tr> <tr> <td> <code>cfsetispeed()</code> </td> <td> <code>getpgrp()</code> </td> <td> <code>rename()</code> </td> <td> <code>tcflow()</code> </td> </tr> <tr> <td> <code>cfsetospeed()</code> </td> <td> <code>getpid()</code> </td> <td> <code>renameat()</code> </td> <td> <code>tcflush()</code> </td> </tr> <tr> <td> <code>chdir()</code> </td> <td> <code>getppid()</code> </td> <td> <code>rmdir()</code> </td> <td> <code>tcgetattr()</code> </td> </tr> <tr> <td> <code>chmod()</code> </td> <td> <code>getsockname()</code> </td> <td> <code>select()</code> </td> <td> <code>tcgetpgrp()</code> </td> </tr> <tr> <td> <code>chown()</code> </td> <td> <code>getsockopt()</code> </td> <td> <code>sem_post()</code> </td> <td> <code>tcsendbreak()</code> </td> </tr> <tr> <td> <code>clock_gettime()</code> </td> <td> <code>getuid()</code> </td> <td> <code>send()</code> </td> <td> <code>tcsetattr()</code> </td> </tr> <tr> <td> <code>close()</code> </td> <td> <code>kill()</code> </td> <td> <code>sendmsg()</code> </td> <td> <code>tcsetpgrp()</code> </td> </tr> <tr> <td> <code>connect()</code> </td> <td> <code>link()</code> </td> <td> <code>sendto()</code> </td> <td> <code>time()</code> </td> </tr> <tr> <td> <code>creat()</code> </td> <td> <code>linkat()</code> </td> <td> <code>setgid()</code> </td> <td> <code>timer_getoverrun()</code> </td> </tr> <tr> <td> <code>dup()</code> </td> <td> <code>listen()</code> </td> <td> <code>setpgid()</code> </td> <td> <code>timer_gettime()</code> </td> </tr> <tr> <td> <code>dup2()</code> </td> <td> <code>lseek()</code> </td> <td> <code>setsid()</code> </td> <td> <code>timer_settime()</code> </td> </tr> <tr> <td> <code>execl()</code> </td> <td> <code>lstat()</code> </td> <td> <code>setsockopt()</code> </td> <td> <code>times()</code> </td> </tr> <tr> <td> <code>execle()</code> </td> <td> <code>mkdir()</code> </td> <td> <code>setuid()</code> </td> <td> <code>umask()</code> </td> </tr> <tr> <td> <code>execv()</code> </td> <td> <code>mkdirat()</code> </td> <td> <code>shutdown()</code> </td> <td> <code>uname()</code> </td> </tr> <tr> <td> <code>execve()</code> </td> <td> <code>mkfifo()</code> </td> <td> <code>sigaction()</code> </td> <td> <code>unlink()</code> </td> </tr> <tr> <td> <code>faccessat()</code> </td> <td> <code>mkfifoat()</code> </td> <td> <code>sigaddset()</code> </td> <td> <code>unlinkat()</code> </td> </tr> <tr> <td> <code>fchdir()</code> </td> <td> <code>mknod()</code> </td> <td> <code>sigdelset()</code> </td> <td> <code>utime()</code> </td> </tr> <tr> <td> <code>fchmod()</code> </td> <td> <code>mknodat()</code> </td> <td> <code>sigemptyset()</code> </td> <td> <code>utimensat()</code> </td> </tr> <tr> <td> <code>fchmodat()</code> </td> <td> <code>open()</code> </td> <td> <code>sigfillset()</code> </td> <td> <code>utimes()</code> </td> </tr> <tr> <td> <code>fchown()</code> </td> <td> <code>openat()</code> </td> <td> <code>sigismember()</code> </td> <td> <code>wait()</code> </td> </tr> <tr> <td> <code>fchownat()</code> </td> <td> <code>pause()</code> </td> <td> <code>signal()</code> </td> <td> <code>waitpid()</code> </td> </tr> <tr> <td> <code>fcntl()</code> </td> <td> <code>pipe()</code> </td> <td> <code>sigpause()</code> </td> <td> <code>write()</code> </td> </tr> <tr> <td> <code>fdatasync()</code> </td> <td> <code>poll()</code> </td> <td> <code>sigpending()</code> </td> <td> <code> </code> </td> </tr> </tbody> </table>
All functions not listed in this table are considered to be unsafe with respect to signals. In the presence of signals, all POSIX functions behave as defined when called from or interrupted by a signal handler, with a single exception: when a signal interrupts an unsafe function and the signal handler calls an unsafe function, the behavior is undefined.


The C Standard, 7.14.1.1, paragraph 4 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\], states

> If the signal occurs as the result of calling the abort or raise function, the signal handler shall not call the raise function.


However, in the description of `signal()`, POSIX \[[IEEE Std 1003.1:2013](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-IEEEStd1003.1-2013)\] states

> This restriction does not apply to POSIX applications, as POSIX.1-2008 requires `raise()` to be async-signal-safe.


See also [undefined behavior 131.](https://wiki.sei.cmu.edu/confluence/display/c/CC.+Undefined+Behavior#CC.UndefinedBehavior-ub_131)

**OpenBSD**

The OpenBSD [signal()](http://www.openbsd.org/cgi-bin/man.cgi?query=signal) manual page lists a few additional functions that are asynchronous-safe in OpenBSD but "probably not on other systems" \[[OpenBSD](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-OpenBSD)\], including `snprintf()`, `vsnprintf()`, and `syslog_r()` but only when the `syslog_data struct` is initialized as a local variable.

## Risk Assessment

Invoking functions that are not [asynchronous-safe](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-asynchronous-safefunction) from within a signal handler is [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> SIG30-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-unsafe-call</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-SIG30</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.2p0 </td> <td> <strong>BADFUNC.SIGNAL</strong> </td> <td> Use of signal </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of the rule for single-file programs </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.4 </td> <td> <strong>C2028, C2030</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>88 D, 89 D </strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.2 </td> <td> <strong>CERT_C-SIG30-a</strong> </td> <td> Properly define signal handlers </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2670, 2761</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule SIG30-C </a> </td> <td> Checks for function called from signal handler not asynchronous-safe (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>2028, 2030</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>signal-handler-unsafe-call</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Splint </a> </td> <td> 3.1.1 </td> <td> </td> <td> </td> </tr> </tbody> </table>


## Related Vulnerabilities

For an overview of software vulnerabilities resulting from improper signal handling, see Michal Zalewski's paper "Delivering Signals for Fun and Profit" \[[Zalewski 2001](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Zalewski01)\].

CERT Vulnerability Note [VU \#834865](http://www.kb.cert.org/vuls/id/834865), "Sendmail signal I/O race condition," describes a vulnerability resulting from a violation of this rule. Another notable case where using the `longjmp()` function in a signal handler caused a serious vulnerability is [wu-ftpd 2.4](http://seclists.org/bugtraq/1997/Jan/0011.html) \[[Greenman 1997](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-Greenman97)\]. The effective user ID is set to 0 in one signal handler. If a second signal interrupts the first, a call is made to `longjmp()`, returning the program to the main thread but without lowering the user's privileges. These escalated privileges can be used for further exploitation.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+SIG30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Calling functions in the C Standard Library other than <code>abort</code> , <code>_Exit</code> , and <code>signal</code> from within a signal handler \[asyncsig\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-479 </a> , Signal Handler Use of a Non-reentrant Function </td> <td> 2017-07-10: CERT: Exact </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> C99 Rationale 2003 </a> \] </td> <td> Subclause 5.2.3, "Signals and Interrupts" Subclause 7.14.1.1, "The <code>signal</code> Function" </td> </tr> <tr> <td> \[ <a> Dowd 2006 </a> \] </td> <td> Chapter 13, "Synchronization and State" </td> </tr> <tr> <td> \[ <a> Greenman 1997 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> IEEE Std 1003.1:2013 </a> \] </td> <td> XSH, System Interfaces, <code>longjmp</code> XSH, System Interfaces, <code>raise</code> </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 7.14.1.1, "The <code>signal</code> Function" </td> </tr> <tr> <td> \[ <a> OpenBSD </a> \] </td> <td> <a> signal() Man Page </a> </td> </tr> <tr> <td> \[ <a> VU \#834865 </a> \] </td> <td> </td> </tr> <tr> <td> \[ <a> Zalewski 2001 </a> \] </td> <td> "Delivering Signals for Fun and Profit" </td> </tr> </tbody> </table>
adjust column widths


## Implementation notes

None

## References

* CERT-C: [SIG30-C: Call only asynchronous-safe functions within signal handlers](https://wiki.sei.cmu.edu/confluence/display/c)
