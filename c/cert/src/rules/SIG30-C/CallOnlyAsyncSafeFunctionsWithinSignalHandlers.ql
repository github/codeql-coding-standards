/**
 * @id c/cert/call-only-async-safe-functions-within-signal-handlers
 * @name SIG30-C: Call only asynchronous-safe functions within signal handlers
 * @description Call only asynchronous-safe functions within signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Signal
import semmle.code.cpp.dataflow.DataFlow

/**
 * Does not access an external variable except
 * to assign a value to a volatile static variable of `sig_atomic_t` type
 */
class AsyncSafeVariableAccess extends VariableAccess {
  AsyncSafeVariableAccess() {
    this.getTarget() instanceof StackVariable
    or
    this.getTarget().(StaticStorageDurationVariable).getType().(SigAtomicType).isVolatile() and
    this.isModified()
  }
}

abstract class AsyncSafeFunction extends Function { }

/**
 * C standard library ayncronous-safe functions
 */
class CAsyncSafeFunction extends AsyncSafeFunction {
  //tion, or the signal function with the first argument equal to the signal number corresponding to the signal that caused the invocation of the handler
  CAsyncSafeFunction() { this.hasGlobalName(["abort", "_Exit", "quick_exit", "signal"]) }
}

/**
 * POSIX defined ayncronous-safe functions
 */
class PosixAsyncSafeFunction extends AsyncSafeFunction {
  PosixAsyncSafeFunction() {
    this.hasGlobalName([
        "_Exit", "_exit", "abort", "accept", "access", "aio_error", "aio_return", "aio_suspend",
        "alarm", "bind", "cfgetispeed", "cfgetospeed", "cfsetispeed", "cfsetospeed", "chdir",
        "chmod", "chown", "clock_gettime", "close", "connect", "creat", "dup", "dup2", "execl",
        "execle", "execv", "execve", "faccessat", "fchdir", "fchmod", "fchmodat", "fchown",
        "fchownat", "fcntl", "fdatasync", "fexecve", "fork", "fstat", "fstatat", "fsync",
        "ftruncate", "futimens", "getegid", "geteuid", "getgid", "getgroups", "getpeername",
        "getpgrp", "getpid", "getppid", "getsockname", "getsockopt", "getuid", "kill", "link",
        "linkat", "listen", "lseek", "lstat", "mkdir", "mkdirat", "mkfifo", "mkfifoat", "mknod",
        "mknodat", "open", "openat", "pause", "pipe", "poll", "posix_trace_event", "pselect",
        "pthread_kill", "pthread_self", "pthread_sigmask", "raise", "read", "readlink",
        "readlinkat", "recv", "recvfrom", "recvmsg", "rename", "renameat", "rmdir", "select",
        "sem_post", "send", "sendmsg", "sendto", "setgid", "setpgid", "setsid", "setsockopt",
        "setuid", "shutdown", "sigaction", "sigaddset", "sigdelset", "sigemptyset", "sigfillset",
        "sigismember", "signal", "sigpause", "sigpending", "sigprocmask", "sigqueue", "sigset",
        "sigsuspend", "sleep", "sockatmark", "socket", "socketpair", "stat", "symlink", "symlinkat",
        "tcdrain", "tcflow", "tcflush", "tcgetattr", "tcgetpgrp", "tcsendbreak", "tcsetattr",
        "tcsetpgrp", "time", "timer_getoverrun", "timer_gettime", "timer_settime", "times", "umask",
        "uname", "unlink", "unlinkat", "utime", "utimensat", "utimes", "wait", "waitpid", "write"
      ])
  }
}

/**
 * Application defined ayncronous-safe functions
 */
class ApplicationAsyncSafeFunction extends AsyncSafeFunction {
  pragma[nomagic]
  ApplicationAsyncSafeFunction() {
    // Application-defined
    this.hasDefinition() and
    exists(this.getFile().getRelativePath()) and
    // Only references async-safe variables
    not exists(VariableAccess va |
      this = va.getEnclosingFunction() and not va instanceof AsyncSafeVariableAccess
    ) and
    // Only calls async-safe functions
    not exists(Function f | this.calls(f) and not f instanceof AsyncSafeFunction)
  }
}

/**
 * Call to function `raise` within a signal handler with mismatching signals
 * ```
 * void int_handler(int signum) {
 *   raise(SIGTERM);
 * }
 * int main(void) {
 *   signal(SIGINT, int_handler);
 * }
 * ```
 */
class AsyncUnsafeRaiseCall extends FunctionCall {
  AsyncUnsafeRaiseCall() {
    this.getTarget().hasGlobalName("raise") and
    exists(SignalHandler handler |
      handler = this.getEnclosingFunction() and
      not handler.getRegistration().getArgument(0).getValue() = this.getArgument(0).getValue() and
      not DataFlow::localFlow(DataFlow::parameterNode(handler.getParameter(0)),
        DataFlow::exprNode(this.getArgument(0)))
    )
  }
}

from FunctionCall fc, SignalHandler handler
where
  not isExcluded(fc, SignalHandlersPackage::callOnlyAsyncSafeFunctionsWithinSignalHandlersQuery()) and
  handler = fc.getEnclosingFunction() and
  (
    not fc.getTarget() instanceof AsyncSafeFunction
    or
    fc instanceof AsyncUnsafeRaiseCall
  )
select fc, "Asyncronous-unsafe function calls within a $@ can lead to undefined behavior.",
  handler.getRegistration(), "signal handler"
