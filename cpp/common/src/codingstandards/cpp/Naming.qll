/*
 * WARNING: This file is auto generated! Do not modify directly!
 */

import cpp

/** Module to reason about standard library macro, object, and function names. */
module Naming {
  module Cpp14 {
    /** Holds if `s` is a standard library macro name. */
    predicate hasStandardLibraryMacroName(string s) {
      s = "NULL"
      or
      s = "USER_ADDR_NULL"
      or
      s = "SIG_ATOMIC_MAX"
      or
      s = "INT32_MAX"
      or
      s = "SIG_ATOMIC_MIN"
      or
      s = "INT32_MIN"
      or
      s = "WINT_MAX"
      or
      s = "WINT_MIN"
      or
      s = "WCHAR_MIN"
      or
      s = "WCHAR_MAX"
      or
      s = "SIZE_MAX"
      or
      s = "UINTPTR_MAX"
      or
      s = "PTRDIFF_MAX"
      or
      s = "INTMAX_MAX"
      or
      s = "PTRDIFF_MIN"
      or
      s = "INTMAX_MIN"
      or
      s = "UINTMAX_MAX"
      or
      s = "INTPTR_MIN"
      or
      s = "INTPTR_MAX"
      or
      s = "UINT_FAST64_MAX"
      or
      s = "UINT64_MAX"
      or
      s = "UINT_FAST32_MAX"
      or
      s = "UINT32_MAX"
      or
      s = "UINT_FAST16_MAX"
      or
      s = "UINT16_MAX"
      or
      s = "UINT_FAST8_MAX"
      or
      s = "UINT8_MAX"
      or
      s = "INT_FAST64_MAX"
      or
      s = "INT64_MAX"
      or
      s = "INT_FAST32_MAX"
      or
      s = "INT_FAST16_MAX"
      or
      s = "INT16_MAX"
      or
      s = "INT_FAST8_MAX"
      or
      s = "INT8_MAX"
      or
      s = "INT_FAST64_MIN"
      or
      s = "INT64_MIN"
      or
      s = "INT_FAST32_MIN"
      or
      s = "INT_FAST16_MIN"
      or
      s = "INT16_MIN"
      or
      s = "INT_FAST8_MIN"
      or
      s = "INT8_MIN"
      or
      s = "UINT_LEAST64_MAX"
      or
      s = "UINT_LEAST32_MAX"
      or
      s = "UINT_LEAST16_MAX"
      or
      s = "UINT_LEAST8_MAX"
      or
      s = "INT_LEAST64_MAX"
      or
      s = "INT_LEAST32_MAX"
      or
      s = "INT_LEAST16_MAX"
      or
      s = "INT_LEAST8_MAX"
      or
      s = "INT_LEAST64_MIN"
      or
      s = "INT_LEAST32_MIN"
      or
      s = "INT_LEAST16_MIN"
      or
      s = "INT_LEAST8_MIN"
      or
      s = "RENAME_EXCL"
      or
      s = "RENAME_SWAP"
      or
      s = "RENAME_SECLUDE"
      or
      s = "putchar_unlocked"
      or
      s = "putc_unlocked"
      or
      s = "getchar_unlocked"
      or
      s = "getc_unlocked"
      or
      s = "L_ctermid"
      or
      s = "stderr"
      or
      s = "stdout"
      or
      s = "stdin"
      or
      s = "SEEK_END"
      or
      s = "SEEK_CUR"
      or
      s = "SEEK_SET"
      or
      s = "TMP_MAX"
      or
      s = "L_tmpnam"
      or
      s = "P_tmpdir"
      or
      s = "FILENAME_MAX"
      or
      s = "FOPEN_MAX"
      or
      s = "EOF"
      or
      s = "BUFSIZ"
      or
      s = "CLOCK_THREAD_CPUTIME_ID"
      or
      s = "CLOCK_PROCESS_CPUTIME_ID"
      or
      s = "CLOCK_UPTIME_RAW_APPROX"
      or
      s = "CLOCK_UPTIME_RAW"
      or
      s = "CLOCK_MONOTONIC_RAW_APPROX"
      or
      s = "CLOCK_MONOTONIC_RAW"
      or
      s = "CLOCK_MONOTONIC"
      or
      s = "CLOCK_REALTIME"
      or
      s = "CLOCKS_PER_SEC"
      or
      s = "WEOF"
      or
      s = "FP_STATE_BYTES"
      or
      s = "FP_CHOP"
      or
      s = "FP_RND_UP"
      or
      s = "FP_RND_DOWN"
      or
      s = "FP_RND_NEAR"
      or
      s = "FP_PREC_64B"
      or
      s = "FP_PREC_53B"
      or
      s = "FP_PREC_24B"
      or
      s = "BADSIG"
      or
      s = "SIG_ERR"
      or
      s = "sv_onstack"
      or
      s = "SV_SIGINFO"
      or
      s = "SA_SIGINFO"
      or
      s = "SV_NOCLDSTOP"
      or
      s = "SA_NOCLDSTOP"
      or
      s = "SV_NODEFER"
      or
      s = "SA_NODEFER"
      or
      s = "SV_RESETHAND"
      or
      s = "SA_RESETHAND"
      or
      s = "SV_INTERRUPT"
      or
      s = "SA_RESTART"
      or
      s = "SV_ONSTACK"
      or
      s = "SA_ONSTACK"
      or
      s = "SIGSTKSZ"
      or
      s = "MINSIGSTKSZ"
      or
      s = "SS_DISABLE"
      or
      s = "SS_ONSTACK"
      or
      s = "SI_MESGQ"
      or
      s = "SI_ASYNCIO"
      or
      s = "SI_TIMER"
      or
      s = "SI_QUEUE"
      or
      s = "SI_USER"
      or
      s = "SIG_SETMASK"
      or
      s = "SIG_UNBLOCK"
      or
      s = "SIG_BLOCK"
      or
      s = "SA_USERSPACE_MASK"
      or
      s = "SA_64REGSET"
      or
      s = "SA_USERTRAMP"
      or
      s = "SA_NOCLDWAIT"
      or
      s = "sa_sigaction"
      or
      s = "sa_handler"
      or
      s = "POLL_HUP"
      or
      s = "POLL_PRI"
      or
      s = "POLL_ERR"
      or
      s = "POLL_MSG"
      or
      s = "POLL_OUT"
      or
      s = "POLL_IN"
      or
      s = "CLD_CONTINUED"
      or
      s = "CLD_STOPPED"
      or
      s = "CLD_TRAPPED"
      or
      s = "CLD_DUMPED"
      or
      s = "CLD_KILLED"
      or
      s = "CLD_EXITED"
      or
      s = "CLD_NOOP"
      or
      s = "TRAP_TRACE"
      or
      s = "TRAP_BRKPT"
      or
      s = "BUS_OBJERR"
      or
      s = "BUS_ADRERR"
      or
      s = "BUS_ADRALN"
      or
      s = "BUS_NOOP"
      or
      s = "SEGV_ACCERR"
      or
      s = "SEGV_MAPERR"
      or
      s = "SEGV_NOOP"
      or
      s = "FPE_INTOVF"
      or
      s = "FPE_INTDIV"
      or
      s = "FPE_FLTSUB"
      or
      s = "FPE_FLTINV"
      or
      s = "FPE_FLTRES"
      or
      s = "FPE_FLTUND"
      or
      s = "FPE_FLTOVF"
      or
      s = "FPE_FLTDIV"
      or
      s = "FPE_NOOP"
      or
      s = "ILL_BADSTK"
      or
      s = "ILL_COPROC"
      or
      s = "ILL_PRVREG"
      or
      s = "ILL_ILLADR"
      or
      s = "ILL_ILLOPN"
      or
      s = "ILL_PRVOPC"
      or
      s = "ILL_ILLTRP"
      or
      s = "ILL_ILLOPC"
      or
      s = "ILL_NOOP"
      or
      s = "SIGEV_THREAD"
      or
      s = "SIGEV_SIGNAL"
      or
      s = "SIGEV_NONE"
      or
      s = "SIG_HOLD"
      or
      s = "SIG_IGN"
      or
      s = "SIG_DFL"
      or
      s = "SIGUSR2"
      or
      s = "SIGUSR1"
      or
      s = "SIGINFO"
      or
      s = "SIGWINCH"
      or
      s = "SIGPROF"
      or
      s = "SIGVTALRM"
      or
      s = "SIGXFSZ"
      or
      s = "SIGXCPU"
      or
      s = "SIGIO"
      or
      s = "SIGTTOU"
      or
      s = "SIGTTIN"
      or
      s = "SIGCHLD"
      or
      s = "SIGCONT"
      or
      s = "SIGTSTP"
      or
      s = "SIGSTOP"
      or
      s = "SIGURG"
      or
      s = "SIGTERM"
      or
      s = "SIGALRM"
      or
      s = "SIGPIPE"
      or
      s = "SIGSYS"
      or
      s = "SIGSEGV"
      or
      s = "SIGBUS"
      or
      s = "SIGKILL"
      or
      s = "SIGFPE"
      or
      s = "SIGEMT"
      or
      s = "SIGIOT"
      or
      s = "SIGABRT"
      or
      s = "SIGTRAP"
      or
      s = "SIGILL"
      or
      s = "SIGQUIT"
      or
      s = "SIGINT"
      or
      s = "SIGHUP"
      or
      s = "NSIG"
      or
      s = "IOPOL_VFS_STATFS_FORCE_NO_DATA_VOLUME"
      or
      s = "IOPOL_VFS_STATFS_NO_DATA_VOLUME_DEFAULT"
      or
      s = "IOPOL_MATERIALIZE_DATALESS_FILES_ON"
      or
      s = "IOPOL_MATERIALIZE_DATALESS_FILES_OFF"
      or
      s = "IOPOL_MATERIALIZE_DATALESS_FILES_DEFAULT"
      or
      s = "IOPOL_ATIME_UPDATES_OFF"
      or
      s = "IOPOL_ATIME_UPDATES_DEFAULT"
      or
      s = "IOPOL_NORMAL"
      or
      s = "IOPOL_IMPORTANT"
      or
      s = "IOPOL_APPLICATION"
      or
      s = "IOPOL_STANDARD"
      or
      s = "IOPOL_UTILITY"
      or
      s = "IOPOL_THROTTLE"
      or
      s = "IOPOL_PASSIVE"
      or
      s = "IOPOL_DEFAULT"
      or
      s = "IOPOL_SCOPE_DARWIN_BG"
      or
      s = "IOPOL_SCOPE_THREAD"
      or
      s = "IOPOL_SCOPE_PROCESS"
      or
      s = "IOPOL_TYPE_VFS_STATFS_NO_DATA_VOLUME"
      or
      s = "IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES"
      or
      s = "IOPOL_TYPE_VFS_ATIME_UPDATES"
      or
      s = "IOPOL_TYPE_DISK"
      or
      s = "FOOTPRINT_INTERVAL_RESET"
      or
      s = "CPUMON_MAKE_FATAL"
      or
      s = "WAKEMON_MAKE_FATAL"
      or
      s = "WAKEMON_SET_DEFAULTS"
      or
      s = "WAKEMON_GET_PARAMS"
      or
      s = "WAKEMON_DISABLE"
      or
      s = "WAKEMON_ENABLE"
      or
      s = "RLIMIT_FOOTPRINT_INTERVAL"
      or
      s = "RLIMIT_THREAD_CPULIMITS"
      or
      s = "RLIMIT_CPU_USAGE_MONITOR"
      or
      s = "RLIMIT_WAKEUPS_MONITOR"
      or
      s = "RLIM_NLIMITS"
      or
      s = "RLIMIT_NOFILE"
      or
      s = "RLIMIT_NPROC"
      or
      s = "RLIMIT_MEMLOCK"
      or
      s = "RLIMIT_RSS"
      or
      s = "RLIMIT_AS"
      or
      s = "RLIMIT_CORE"
      or
      s = "RLIMIT_STACK"
      or
      s = "RLIMIT_DATA"
      or
      s = "RLIMIT_FSIZE"
      or
      s = "RLIMIT_CPU"
      or
      s = "RLIM_SAVED_CUR"
      or
      s = "RLIM_INFINITY"
      or
      s = "RLIM_SAVED_MAX"
      or
      s = "RUSAGE_INFO_CURRENT"
      or
      s = "RUSAGE_INFO_V4"
      or
      s = "RUSAGE_INFO_V3"
      or
      s = "RUSAGE_INFO_V2"
      or
      s = "RUSAGE_INFO_V1"
      or
      s = "RUSAGE_INFO_V0"
      or
      s = "ru_last"
      or
      s = "ru_first"
      or
      s = "RUSAGE_CHILDREN"
      or
      s = "RUSAGE_SELF"
      or
      s = "PRIO_DARWIN_NONUI"
      or
      s = "PRIO_DARWIN_BG"
      or
      s = "PRIO_MAX"
      or
      s = "PRIO_MIN"
      or
      s = "PRIO_DARWIN_PROCESS"
      or
      s = "PRIO_DARWIN_THREAD"
      or
      s = "PRIO_USER"
      or
      s = "PRIO_PGRP"
      or
      s = "PRIO_PROCESS"
      or
      s = "BYTE_ORDER"
      or
      s = "PDP_ENDIAN"
      or
      s = "BIG_ENDIAN"
      or
      s = "LITTLE_ENDIAN"
      or
      s = "w_stopsig"
      or
      s = "w_stopval"
      or
      s = "w_retcode"
      or
      s = "w_coredump"
      or
      s = "w_termsig"
      or
      s = "WAIT_MYPGRP"
      or
      s = "WAIT_ANY"
      or
      s = "WNOWAIT"
      or
      s = "WCONTINUED"
      or
      s = "WSTOPPED"
      or
      s = "WEXITED"
      or
      s = "WCOREFLAG"
      or
      s = "WUNTRACED"
      or
      s = "WNOHANG"
      or
      s = "alloca"
      or
      s = "MB_CUR_MAX"
      or
      s = "RAND_MAX"
      or
      s = "EXIT_SUCCESS"
      or
      s = "EXIT_FAILURE"
      or
      s = "MB_CUR_MAX_L"
      or
      s = "assert"
      or
      s = "ATOMIC_FLAG_INIT"
      or
      s = "ATOMIC_POINTER_LOCK_FREE"
      or
      s = "ATOMIC_LLONG_LOCK_FREE"
      or
      s = "ATOMIC_LONG_LOCK_FREE"
      or
      s = "ATOMIC_INT_LOCK_FREE"
      or
      s = "ATOMIC_SHORT_LOCK_FREE"
      or
      s = "ATOMIC_WCHAR_T_LOCK_FREE"
      or
      s = "ATOMIC_CHAR32_T_LOCK_FREE"
      or
      s = "ATOMIC_CHAR16_T_LOCK_FREE"
      or
      s = "ATOMIC_CHAR_LOCK_FREE"
      or
      s = "ATOMIC_BOOL_LOCK_FREE"
      or
      s = "QUAD_MIN"
      or
      s = "LLONG_MIN"
      or
      s = "QUAD_MAX"
      or
      s = "LLONG_MAX"
      or
      s = "UQUAD_MAX"
      or
      s = "ULLONG_MAX"
      or
      s = "SIZE_T_MAX"
      or
      s = "ULONG_MAX"
      or
      s = "WORD_BIT"
      or
      s = "SSIZE_MAX"
      or
      s = "LONG_MAX"
      or
      s = "LONG_BIT"
      or
      s = "LONG_MIN"
      or
      s = "INT_MIN"
      or
      s = "INT_MAX"
      or
      s = "UINT_MAX"
      or
      s = "SHRT_MIN"
      or
      s = "SHRT_MAX"
      or
      s = "USHRT_MAX"
      or
      s = "CHAR_MIN"
      or
      s = "CHAR_MAX"
      or
      s = "UCHAR_MAX"
      or
      s = "SCHAR_MIN"
      or
      s = "SCHAR_MAX"
      or
      s = "CLK_TCK"
      or
      s = "MB_LEN_MAX"
      or
      s = "CHAR_BIT"
      or
      s = "NZERO"
      or
      s = "RE_DUP_MAX"
      or
      s = "LINE_MAX"
      or
      s = "EXPR_NEST_MAX"
      or
      s = "EQUIV_CLASS_MAX"
      or
      s = "COLL_WEIGHTS_MAX"
      or
      s = "CHARCLASS_NAME_MAX"
      or
      s = "BC_STRING_MAX"
      or
      s = "BC_SCALE_MAX"
      or
      s = "BC_DIM_MAX"
      or
      s = "BC_BASE_MAX"
      or
      s = "PIPE_BUF"
      or
      s = "PATH_MAX"
      or
      s = "OPEN_MAX"
      or
      s = "UID_MAX"
      or
      s = "NGROUPS_MAX"
      or
      s = "NAME_MAX"
      or
      s = "MAX_INPUT"
      or
      s = "MAX_CANON"
      or
      s = "LINK_MAX"
      or
      s = "GID_MAX"
      or
      s = "CHILD_MAX"
      or
      s = "ARG_MAX"
      or
      s = "IOV_MAX"
      or
      s = "NL_TEXTMAX"
      or
      s = "NL_SETMAX"
      or
      s = "NL_NMAX"
      or
      s = "NL_MSGMAX"
      or
      s = "NL_LANGMAX"
      or
      s = "NL_ARGMAX"
      or
      s = "PASS_MAX"
      or
      s = "OFF_MAX"
      or
      s = "OFF_MIN"
      or
      s = "PTHREAD_STACK_MIN"
      or
      s = "PTHREAD_KEYS_MAX"
      or
      s = "PTHREAD_DESTRUCTOR_ITERATIONS"
      or
      s = "PLOSS"
      or
      s = "TLOSS"
      or
      s = "UNDERFLOW"
      or
      s = "OVERFLOW"
      or
      s = "SING"
      or
      s = "DOMAIN"
      or
      s = "X_TLOSS"
      or
      s = "HUGE"
      or
      s = "MAXFLOAT"
      or
      s = "FP_QNAN"
      or
      s = "FP_NAN"
      or
      s = "FP_SNAN"
      or
      s = "M_SQRT1_2"
      or
      s = "M_SQRT2"
      or
      s = "M_2_SQRTPI"
      or
      s = "M_2_PI"
      or
      s = "M_1_PI"
      or
      s = "M_PI_4"
      or
      s = "M_PI_2"
      or
      s = "M_PI"
      or
      s = "M_LN10"
      or
      s = "M_LN2"
      or
      s = "M_LOG10E"
      or
      s = "M_LOG2E"
      or
      s = "M_E"
      or
      s = "math_errhandling"
      or
      s = "MATH_ERREXCEPT"
      or
      s = "MATH_ERRNO"
      or
      s = "FP_ILOGBNAN"
      or
      s = "FP_ILOGB0"
      or
      s = "FP_SUPERNORMAL"
      or
      s = "FP_SUBNORMAL"
      or
      s = "FP_NORMAL"
      or
      s = "FP_ZERO"
      or
      s = "FP_INFINITE"
      or
      s = "INFINITY"
      or
      s = "HUGE_VALF"
      or
      s = "NAN"
      or
      s = "HUGE_VALL"
      or
      s = "HUGE_VAL"
      or
      s = "isunordered"
      or
      s = "islessgreater"
      or
      s = "islessequal"
      or
      s = "isless"
      or
      s = "isgreaterequal"
      or
      s = "isgreater"
      or
      s = "isnormal"
      or
      s = "isnan"
      or
      s = "isinf"
      or
      s = "isfinite"
      or
      s = "fpclassify"
      or
      s = "signbit"
      or
      s = "errno"
      or
      s = "ELAST"
      or
      s = "EQFULL"
      or
      s = "EOWNERDEAD"
      or
      s = "ENOTRECOVERABLE"
      or
      s = "ENOPOLICY"
      or
      s = "EOPNOTSUPP"
      or
      s = "ETIME"
      or
      s = "EPROTO"
      or
      s = "ENOSTR"
      or
      s = "ENOSR"
      or
      s = "ENOLINK"
      or
      s = "ENODATA"
      or
      s = "EMULTIHOP"
      or
      s = "EBADMSG"
      or
      s = "ENOATTR"
      or
      s = "EILSEQ"
      or
      s = "ENOMSG"
      or
      s = "EIDRM"
      or
      s = "ECANCELED"
      or
      s = "EBADMACHO"
      or
      s = "ESHLIBVERS"
      or
      s = "EBADARCH"
      or
      s = "EBADEXEC"
      or
      s = "EOVERFLOW"
      or
      s = "EDEVERR"
      or
      s = "EPWROFF"
      or
      s = "ENEEDAUTH"
      or
      s = "EAUTH"
      or
      s = "EFTYPE"
      or
      s = "ENOSYS"
      or
      s = "ENOLCK"
      or
      s = "EPROCUNAVAIL"
      or
      s = "EPROGMISMATCH"
      or
      s = "EPROGUNAVAIL"
      or
      s = "ERPCMISMATCH"
      or
      s = "EBADRPC"
      or
      s = "EREMOTE"
      or
      s = "ESTALE"
      or
      s = "EDQUOT"
      or
      s = "EUSERS"
      or
      s = "EPROCLIM"
      or
      s = "ENOTEMPTY"
      or
      s = "EHOSTUNREACH"
      or
      s = "EHOSTDOWN"
      or
      s = "ENAMETOOLONG"
      or
      s = "ELOOP"
      or
      s = "ECONNREFUSED"
      or
      s = "ETIMEDOUT"
      or
      s = "ETOOMANYREFS"
      or
      s = "ESHUTDOWN"
      or
      s = "ENOTCONN"
      or
      s = "EISCONN"
      or
      s = "ENOBUFS"
      or
      s = "ECONNRESET"
      or
      s = "ECONNABORTED"
      or
      s = "ENETRESET"
      or
      s = "ENETUNREACH"
      or
      s = "ENETDOWN"
      or
      s = "EADDRNOTAVAIL"
      or
      s = "EADDRINUSE"
      or
      s = "EAFNOSUPPORT"
      or
      s = "EPFNOSUPPORT"
      or
      s = "ENOTSUP"
      or
      s = "ESOCKTNOSUPPORT"
      or
      s = "EPROTONOSUPPORT"
      or
      s = "ENOPROTOOPT"
      or
      s = "EPROTOTYPE"
      or
      s = "EMSGSIZE"
      or
      s = "EDESTADDRREQ"
      or
      s = "ENOTSOCK"
      or
      s = "EALREADY"
      or
      s = "EINPROGRESS"
      or
      s = "EWOULDBLOCK"
      or
      s = "EAGAIN"
      or
      s = "ERANGE"
      or
      s = "EDOM"
      or
      s = "EPIPE"
      or
      s = "EMLINK"
      or
      s = "EROFS"
      or
      s = "ESPIPE"
      or
      s = "ENOSPC"
      or
      s = "EFBIG"
      or
      s = "ETXTBSY"
      or
      s = "ENOTTY"
      or
      s = "EMFILE"
      or
      s = "ENFILE"
      or
      s = "EINVAL"
      or
      s = "EISDIR"
      or
      s = "ENOTDIR"
      or
      s = "ENODEV"
      or
      s = "EXDEV"
      or
      s = "EEXIST"
      or
      s = "EBUSY"
      or
      s = "ENOTBLK"
      or
      s = "EFAULT"
      or
      s = "EACCES"
      or
      s = "ENOMEM"
      or
      s = "EDEADLK"
      or
      s = "ECHILD"
      or
      s = "EBADF"
      or
      s = "ENOEXEC"
      or
      s = "E2BIG"
      or
      s = "ENXIO"
      or
      s = "EIO"
      or
      s = "EINTR"
      or
      s = "ESRCH"
      or
      s = "ENOENT"
      or
      s = "EPERM"
      or
      s = "SCHED_RR"
      or
      s = "SCHED_FIFO"
      or
      s = "SCHED_OTHER"
      or
      s = "QOS_MIN_RELATIVE_PRIORITY"
      or
      s = "PTHREAD_ONCE_INIT"
      or
      s = "PTHREAD_COND_INITIALIZER"
      or
      s = "PTHREAD_RECURSIVE_MUTEX_INITIALIZER"
      or
      s = "PTHREAD_ERRORCHECK_MUTEX_INITIALIZER"
      or
      s = "PTHREAD_MUTEX_INITIALIZER"
      or
      s = "PTHREAD_RWLOCK_INITIALIZER"
      or
      s = "PTHREAD_MUTEX_POLICY_FIRSTFIT_NP"
      or
      s = "PTHREAD_MUTEX_POLICY_FAIRSHARE_NP"
      or
      s = "PTHREAD_MUTEX_DEFAULT"
      or
      s = "PTHREAD_MUTEX_NORMAL"
      or
      s = "PTHREAD_MUTEX_RECURSIVE"
      or
      s = "PTHREAD_MUTEX_ERRORCHECK"
      or
      s = "PTHREAD_PRIO_PROTECT"
      or
      s = "PTHREAD_PRIO_INHERIT"
      or
      s = "PTHREAD_PRIO_NONE"
      or
      s = "PTHREAD_PROCESS_PRIVATE"
      or
      s = "PTHREAD_PROCESS_SHARED"
      or
      s = "PTHREAD_SCOPE_PROCESS"
      or
      s = "PTHREAD_SCOPE_SYSTEM"
      or
      s = "PTHREAD_CANCELED"
      or
      s = "PTHREAD_CANCEL_ASYNCHRONOUS"
      or
      s = "PTHREAD_CANCEL_DEFERRED"
      or
      s = "PTHREAD_CANCEL_DISABLE"
      or
      s = "PTHREAD_CANCEL_ENABLE"
      or
      s = "PTHREAD_EXPLICIT_SCHED"
      or
      s = "PTHREAD_INHERIT_SCHED"
      or
      s = "PTHREAD_CREATE_DETACHED"
      or
      s = "PTHREAD_CREATE_JOINABLE"
      or
      s = "LC_MESSAGES"
      or
      s = "LC_TIME"
      or
      s = "LC_NUMERIC"
      or
      s = "LC_MONETARY"
      or
      s = "LC_CTYPE"
      or
      s = "LC_COLLATE"
      or
      s = "LC_ALL"
      or
      s = "LC_C_LOCALE"
      or
      s = "LC_GLOBAL_LOCALE"
      or
      s = "LC_TIME_MASK"
      or
      s = "LC_NUMERIC_MASK"
      or
      s = "LC_MONETARY_MASK"
      or
      s = "LC_MESSAGES_MASK"
      or
      s = "LC_CTYPE_MASK"
      or
      s = "LC_COLLATE_MASK"
      or
      s = "LC_ALL_MASK"
      or
      s = "FD_SETSIZE"
      or
      s = "FD_SET"
      or
      s = "FD_CLR"
      or
      s = "FD_ZERO"
      or
      s = "FD_ISSET"
      or
      s = "FD_COPY"
      or
      s = "NFDBITS"
      or
      s = "NBBY"
      or
      s = "NL_CAT_LOCALE"
      or
      s = "NL_SETD"
      or
      s = "FE_DFL_DISABLE_SSE_DENORMS_ENV"
      or
      s = "FE_DFL_ENV"
      or
      s = "FE_TOWARDZERO"
      or
      s = "FE_UPWARD"
      or
      s = "FE_DOWNWARD"
      or
      s = "FE_TONEAREST"
      or
      s = "FE_ALL_EXCEPT"
      or
      s = "FE_DENORMALOPERAND"
      or
      s = "FE_INVALID"
      or
      s = "FE_DIVBYZERO"
      or
      s = "FE_OVERFLOW"
      or
      s = "FE_UNDERFLOW"
      or
      s = "FE_INEXACT"
      or
      s = "LDBL_MIN"
      or
      s = "DBL_MIN"
      or
      s = "FLT_MIN"
      or
      s = "LDBL_EPSILON"
      or
      s = "DBL_EPSILON"
      or
      s = "FLT_EPSILON"
      or
      s = "LDBL_MAX"
      or
      s = "DBL_MAX"
      or
      s = "FLT_MAX"
      or
      s = "LDBL_MAX_10_EXP"
      or
      s = "DBL_MAX_10_EXP"
      or
      s = "FLT_MAX_10_EXP"
      or
      s = "LDBL_MAX_EXP"
      or
      s = "DBL_MAX_EXP"
      or
      s = "FLT_MAX_EXP"
      or
      s = "LDBL_MIN_10_EXP"
      or
      s = "DBL_MIN_10_EXP"
      or
      s = "FLT_MIN_10_EXP"
      or
      s = "LDBL_MIN_EXP"
      or
      s = "DBL_MIN_EXP"
      or
      s = "FLT_MIN_EXP"
      or
      s = "LDBL_DIG"
      or
      s = "DBL_DIG"
      or
      s = "FLT_DIG"
      or
      s = "LDBL_MANT_DIG"
      or
      s = "DBL_MANT_DIG"
      or
      s = "FLT_MANT_DIG"
      or
      s = "FLT_RADIX"
      or
      s = "FLT_ROUNDS"
      or
      s = "FLT_EVAL_METHOD"
      or
      s = "DECIMAL_DIG"
      or
      s = "SCNxMAX"
      or
      s = "SCNuMAX"
      or
      s = "SCNoMAX"
      or
      s = "SCNiMAX"
      or
      s = "SCNdMAX"
      or
      s = "SCNxPTR"
      or
      s = "SCNuPTR"
      or
      s = "SCNoPTR"
      or
      s = "SCNiPTR"
      or
      s = "SCNdPTR"
      or
      s = "SCNxFAST64"
      or
      s = "SCNx64"
      or
      s = "SCNuFAST64"
      or
      s = "SCNu64"
      or
      s = "SCNoFAST64"
      or
      s = "SCNo64"
      or
      s = "SCNiFAST64"
      or
      s = "SCNi64"
      or
      s = "SCNdFAST64"
      or
      s = "SCNd64"
      or
      s = "SCNxFAST32"
      or
      s = "SCNx32"
      or
      s = "SCNuFAST32"
      or
      s = "SCNu32"
      or
      s = "SCNoFAST32"
      or
      s = "SCNo32"
      or
      s = "SCNiFAST32"
      or
      s = "SCNi32"
      or
      s = "SCNdFAST32"
      or
      s = "SCNd32"
      or
      s = "SCNxFAST16"
      or
      s = "SCNx16"
      or
      s = "SCNuFAST16"
      or
      s = "SCNu16"
      or
      s = "SCNoFAST16"
      or
      s = "SCNo16"
      or
      s = "SCNiFAST16"
      or
      s = "SCNi16"
      or
      s = "SCNdFAST16"
      or
      s = "SCNd16"
      or
      s = "SCNxFAST8"
      or
      s = "SCNx8"
      or
      s = "SCNuFAST8"
      or
      s = "SCNu8"
      or
      s = "SCNoFAST8"
      or
      s = "SCNo8"
      or
      s = "SCNiFAST8"
      or
      s = "SCNi8"
      or
      s = "SCNdFAST8"
      or
      s = "SCNd8"
      or
      s = "SCNxLEAST64"
      or
      s = "SCNuLEAST64"
      or
      s = "SCNoLEAST64"
      or
      s = "SCNiLEAST64"
      or
      s = "SCNdLEAST64"
      or
      s = "SCNxLEAST32"
      or
      s = "SCNuLEAST32"
      or
      s = "SCNoLEAST32"
      or
      s = "SCNiLEAST32"
      or
      s = "SCNdLEAST32"
      or
      s = "SCNxLEAST16"
      or
      s = "SCNuLEAST16"
      or
      s = "SCNoLEAST16"
      or
      s = "SCNiLEAST16"
      or
      s = "SCNdLEAST16"
      or
      s = "SCNxLEAST8"
      or
      s = "SCNuLEAST8"
      or
      s = "SCNoLEAST8"
      or
      s = "SCNiLEAST8"
      or
      s = "SCNdLEAST8"
      or
      s = "PRIXMAX"
      or
      s = "PRIxMAX"
      or
      s = "PRIuMAX"
      or
      s = "PRIoMAX"
      or
      s = "PRIiMAX"
      or
      s = "PRIdMAX"
      or
      s = "PRIXPTR"
      or
      s = "PRIxPTR"
      or
      s = "PRIuPTR"
      or
      s = "PRIoPTR"
      or
      s = "PRIiPTR"
      or
      s = "PRIdPTR"
      or
      s = "PRIXFAST64"
      or
      s = "PRIX64"
      or
      s = "PRIxFAST64"
      or
      s = "PRIx64"
      or
      s = "PRIuFAST64"
      or
      s = "PRIu64"
      or
      s = "PRIoFAST64"
      or
      s = "PRIo64"
      or
      s = "PRIiFAST64"
      or
      s = "PRIi64"
      or
      s = "PRIdFAST64"
      or
      s = "PRId64"
      or
      s = "PRIXFAST32"
      or
      s = "PRIX32"
      or
      s = "PRIxFAST32"
      or
      s = "PRIx32"
      or
      s = "PRIuFAST32"
      or
      s = "PRIu32"
      or
      s = "PRIoFAST32"
      or
      s = "PRIo32"
      or
      s = "PRIiFAST32"
      or
      s = "PRIi32"
      or
      s = "PRIdFAST32"
      or
      s = "PRId32"
      or
      s = "PRIXFAST16"
      or
      s = "PRIX16"
      or
      s = "PRIxFAST16"
      or
      s = "PRIx16"
      or
      s = "PRIuFAST16"
      or
      s = "PRIu16"
      or
      s = "PRIoFAST16"
      or
      s = "PRIo16"
      or
      s = "PRIiFAST16"
      or
      s = "PRIi16"
      or
      s = "PRIdFAST16"
      or
      s = "PRId16"
      or
      s = "PRIXFAST8"
      or
      s = "PRIX8"
      or
      s = "PRIxFAST8"
      or
      s = "PRIx8"
      or
      s = "PRIuFAST8"
      or
      s = "PRIu8"
      or
      s = "PRIoFAST8"
      or
      s = "PRIo8"
      or
      s = "PRIiFAST8"
      or
      s = "PRIi8"
      or
      s = "PRIdFAST8"
      or
      s = "PRId8"
      or
      s = "PRIXLEAST64"
      or
      s = "PRIxLEAST64"
      or
      s = "PRIuLEAST64"
      or
      s = "PRIoLEAST64"
      or
      s = "PRIiLEAST64"
      or
      s = "PRIdLEAST64"
      or
      s = "PRIXLEAST32"
      or
      s = "PRIxLEAST32"
      or
      s = "PRIuLEAST32"
      or
      s = "PRIoLEAST32"
      or
      s = "PRIiLEAST32"
      or
      s = "PRIdLEAST32"
      or
      s = "PRIXLEAST16"
      or
      s = "PRIxLEAST16"
      or
      s = "PRIuLEAST16"
      or
      s = "PRIoLEAST16"
      or
      s = "PRIiLEAST16"
      or
      s = "PRIdLEAST16"
      or
      s = "PRIXLEAST8"
      or
      s = "PRIxLEAST8"
      or
      s = "PRIuLEAST8"
      or
      s = "PRIoLEAST8"
      or
      s = "PRIiLEAST8"
      or
      s = "PRIdLEAST8"
      or
      s = "setjmp"
      or
      s = "sigismember"
      or
      s = "sigfillset"
      or
      s = "sigemptyset"
      or
      s = "sigdelset"
      or
      s = "sigaddset"
      or
      s = "offsetof"
      or
      s = "CAST_USER_ADDR_T"
      or
      s = "UINTMAX_C"
      or
      s = "INTMAX_C"
      or
      s = "UINT64_C"
      or
      s = "UINT32_C"
      or
      s = "UINT16_C"
      or
      s = "UINT8_C"
      or
      s = "INT64_C"
      or
      s = "INT32_C"
      or
      s = "INT16_C"
      or
      s = "INT8_C"
      or
      s = "va_copy"
      or
      s = "va_arg"
      or
      s = "va_end"
      or
      s = "va_start"
      or
      s = "fileno_unlocked"
      or
      s = "clearerr_unlocked"
      or
      s = "ferror_unlocked"
      or
      s = "feof_unlocked"
      or
      s = "fwopen"
      or
      s = "fropen"
      or
      s = "sigmask"
      or
      s = "HTONLL"
      or
      s = "HTONS"
      or
      s = "HTONL"
      or
      s = "NTOHLL"
      or
      s = "NTOHS"
      or
      s = "NTOHL"
      or
      s = "htonll"
      or
      s = "ntohll"
      or
      s = "htonl"
      or
      s = "ntohl"
      or
      s = "htons"
      or
      s = "ntohs"
      or
      s = "W_STOPCODE"
      or
      s = "W_EXITCODE"
      or
      s = "WCOREDUMP"
      or
      s = "WTERMSIG"
      or
      s = "WIFSIGNALED"
      or
      s = "WIFEXITED"
      or
      s = "WIFSTOPPED"
      or
      s = "WIFCONTINUED"
      or
      s = "WSTOPSIG"
      or
      s = "WEXITSTATUS"
      or
      s = "ATOMIC_VAR_INIT"
      or
      s = "pthread_cleanup_pop"
      or
      s = "pthread_cleanup_push"
      or
      s = "howmany"
    }

    /** Holds if `s` is a standard library object name. */
    predicate hasStandardLibraryObjectName(string s) {
      s = "nothrow"
      or
      s = "sys_errlist"
      or
      s = "sys_nerr"
      or
      s = "daylight"
      or
      s = "timezone"
      or
      s = "getdate_err"
      or
      s = "tzname"
      or
      s = "suboptarg"
      or
      s = "signgam"
      or
      s = "sys_siglist"
      or
      s = "sys_signame"
    }

    /** Gets the qualified object name for the unqualifed name `s`, if any. */
    string getQualifiedStandardLibraryObjectName(string s) {
      s = "nothrow" and result = "std::nothrow"
      or
      s = "sys_errlist" and result = "sys_errlist"
      or
      s = "sys_nerr" and result = "sys_nerr"
      or
      s = "daylight" and result = "daylight"
      or
      s = "timezone" and result = "timezone"
      or
      s = "getdate_err" and result = "getdate_err"
      or
      s = "tzname" and result = "tzname"
      or
      s = "suboptarg" and result = "suboptarg"
      or
      s = "signgam" and result = "signgam"
      or
      s = "sys_siglist" and result = "sys_siglist"
      or
      s = "sys_signame" and result = "sys_signame"
    }

    /** Holds if `s` is a standard library top-level function name. */
    predicate hasStandardLibraryFunctionName(string s) {
      s = "end"
      or
      s = "end"
      or
      s = "begin"
      or
      s = "begin"
      or
      s = "iter_swap"
      or
      s = "swap"
      or
      s = "get"
      or
      s = "forward"
      or
      s = "move"
      or
      s = "declval"
      or
      s = "addressof"
      or
      s = "flsll"
      or
      s = "flsl"
      or
      s = "fls"
      or
      s = "ffsll"
      or
      s = "ffsl"
      or
      s = "strncasecmp"
      or
      s = "strcasecmp"
      or
      s = "ffs"
      or
      s = "rindex"
      or
      s = "index"
      or
      s = "bzero"
      or
      s = "bcopy"
      or
      s = "bcmp"
      or
      s = "timingsafe_bcmp"
      or
      s = "swab"
      or
      s = "strsep"
      or
      s = "strmode"
      or
      s = "strlcpy"
      or
      s = "strlcat"
      or
      s = "strnstr"
      or
      s = "strcasestr"
      or
      s = "memset_pattern16"
      or
      s = "memset_pattern8"
      or
      s = "memset_pattern4"
      or
      s = "memmem"
      or
      s = "strsignal"
      or
      s = "strnlen"
      or
      s = "strndup"
      or
      s = "stpncpy"
      or
      s = "stpcpy"
      or
      s = "memccpy"
      or
      s = "strdup"
      or
      s = "strerror_r"
      or
      s = "strtok_r"
      or
      s = "strlen"
      or
      s = "strerror"
      or
      s = "memset"
      or
      s = "strtok"
      or
      s = "strstr"
      or
      s = "strspn"
      or
      s = "strrchr"
      or
      s = "strpbrk"
      or
      s = "strcspn"
      or
      s = "strchr"
      or
      s = "memchr"
      or
      s = "strxfrm"
      or
      s = "strcoll"
      or
      s = "strncmp"
      or
      s = "strcmp"
      or
      s = "memcmp"
      or
      s = "strncat"
      or
      s = "strcat"
      or
      s = "strncpy"
      or
      s = "strcpy"
      or
      s = "memmove"
      or
      s = "memcpy"
      or
      s = "renameatx_np"
      or
      s = "renamex_np"
      or
      s = "renameat"
      or
      s = "ctermid"
      or
      s = "funopen"
      or
      s = "zopen"
      or
      s = "vasprintf"
      or
      s = "setlinebuf"
      or
      s = "setbuffer"
      or
      s = "fpurge"
      or
      s = "fmtcheck"
      or
      s = "fgetln"
      or
      s = "ctermid_r"
      or
      s = "asprintf"
      or
      s = "open_memstream"
      or
      s = "fmemopen"
      or
      s = "getline"
      or
      s = "getline"
      or
      s = "getdelim"
      or
      s = "vdprintf"
      or
      s = "dprintf"
      or
      s = "ftello"
      or
      s = "fseeko"
      or
      s = "tempnam"
      or
      s = "putw"
      or
      s = "getw"
      or
      s = "putchar_unlocked"
      or
      s = "putc_unlocked"
      or
      s = "getchar_unlocked"
      or
      s = "getc_unlocked"
      or
      s = "funlockfile"
      or
      s = "ftrylockfile"
      or
      s = "flockfile"
      or
      s = "popen"
      or
      s = "pclose"
      or
      s = "fileno"
      or
      s = "fdopen"
      or
      s = "gets"
      or
      s = "vprintf"
      or
      s = "puts"
      or
      s = "putchar"
      or
      s = "printf"
      or
      s = "vscanf"
      or
      s = "scanf"
      or
      s = "getchar"
      or
      s = "tmpnam"
      or
      s = "tmpfile"
      or
      s = "rename"
      or
      s = "remove"
      or
      s = "remove"
      or
      s = "freopen"
      or
      s = "fopen"
      or
      s = "perror"
      or
      s = "ferror"
      or
      s = "feof"
      or
      s = "clearerr"
      or
      s = "rewind"
      or
      s = "ftell"
      or
      s = "fsetpos"
      or
      s = "fseek"
      or
      s = "fgetpos"
      or
      s = "fwrite"
      or
      s = "fread"
      or
      s = "ungetc"
      or
      s = "putc"
      or
      s = "getc"
      or
      s = "fputs"
      or
      s = "fputc"
      or
      s = "fgets"
      or
      s = "fgetc"
      or
      s = "vsprintf"
      or
      s = "vsnprintf"
      or
      s = "vsscanf"
      or
      s = "vfscanf"
      or
      s = "vfprintf"
      or
      s = "sscanf"
      or
      s = "sprintf"
      or
      s = "snprintf"
      or
      s = "fscanf"
      or
      s = "fprintf"
      or
      s = "setvbuf"
      or
      s = "setbuf"
      or
      s = "fflush"
      or
      s = "fclose"
      or
      s = "time"
      or
      s = "clock_settime"
      or
      s = "clock_gettime_nsec_np"
      or
      s = "clock_gettime"
      or
      s = "clock_getres"
      or
      s = "nanosleep"
      or
      s = "timegm"
      or
      s = "timelocal"
      or
      s = "time2posix"
      or
      s = "tzsetwall"
      or
      s = "posix2time"
      or
      s = "localtime_r"
      or
      s = "gmtime_r"
      or
      s = "ctime_r"
      or
      s = "asctime_r"
      or
      s = "tzset"
      or
      s = "strptime"
      or
      s = "getdate"
      or
      s = "strftime"
      or
      s = "localtime"
      or
      s = "gmtime"
      or
      s = "ctime"
      or
      s = "asctime"
      or
      s = "mktime"
      or
      s = "difftime"
      or
      s = "clock"
      or
      s = "isspecial"
      or
      s = "isrune"
      or
      s = "isphonogram"
      or
      s = "isnumber"
      or
      s = "isideogram"
      or
      s = "ishexnumber"
      or
      s = "digittoint"
      or
      s = "toascii"
      or
      s = "isascii"
      or
      s = "toupper"
      or
      s = "toupper"
      or
      s = "tolower"
      or
      s = "tolower"
      or
      s = "isxdigit"
      or
      s = "isxdigit"
      or
      s = "isupper"
      or
      s = "isupper"
      or
      s = "isspace"
      or
      s = "isspace"
      or
      s = "ispunct"
      or
      s = "ispunct"
      or
      s = "isprint"
      or
      s = "isprint"
      or
      s = "islower"
      or
      s = "islower"
      or
      s = "isgraph"
      or
      s = "isgraph"
      or
      s = "isdigit"
      or
      s = "isdigit"
      or
      s = "iscntrl"
      or
      s = "iscntrl"
      or
      s = "isblank"
      or
      s = "isalpha"
      or
      s = "isalpha"
      or
      s = "isalnum"
      or
      s = "isalnum"
      or
      s = "towupper"
      or
      s = "towlower"
      or
      s = "wctype"
      or
      s = "iswctype"
      or
      s = "iswxdigit"
      or
      s = "iswupper"
      or
      s = "iswspace"
      or
      s = "iswpunct"
      or
      s = "iswprint"
      or
      s = "iswlower"
      or
      s = "iswgraph"
      or
      s = "iswdigit"
      or
      s = "iswcntrl"
      or
      s = "iswalpha"
      or
      s = "iswalnum"
      or
      s = "wcslcpy"
      or
      s = "wcslcat"
      or
      s = "fgetwln"
      or
      s = "open_wmemstream"
      or
      s = "wcsnrtombs"
      or
      s = "wcsnlen"
      or
      s = "wcsncasecmp"
      or
      s = "wcscasecmp"
      or
      s = "wcsdup"
      or
      s = "wcpncpy"
      or
      s = "wcpcpy"
      or
      s = "mbsnrtowcs"
      or
      s = "wcwidth"
      or
      s = "wcswidth"
      or
      s = "wprintf"
      or
      s = "vwprintf"
      or
      s = "putwchar"
      or
      s = "wscanf"
      or
      s = "vwscanf"
      or
      s = "getwchar"
      or
      s = "wcsrtombs"
      or
      s = "mbsrtowcs"
      or
      s = "wcrtomb"
      or
      s = "mbrtowc"
      or
      s = "mbrlen"
      or
      s = "mbsinit"
      or
      s = "wctob"
      or
      s = "btowc"
      or
      s = "wcsftime"
      or
      s = "wmemset"
      or
      s = "wmemmove"
      or
      s = "wmemcpy"
      or
      s = "wmemcmp"
      or
      s = "wcstok"
      or
      s = "wcsspn"
      or
      s = "wcslen"
      or
      s = "wcscspn"
      or
      s = "wmemchr"
      or
      s = "wcsstr"
      or
      s = "wcsrchr"
      or
      s = "wcspbrk"
      or
      s = "wcschr"
      or
      s = "wcsxfrm"
      or
      s = "wcsncmp"
      or
      s = "wcscoll"
      or
      s = "wcscmp"
      or
      s = "wcsncat"
      or
      s = "wcscat"
      or
      s = "wcsncpy"
      or
      s = "wcscpy"
      or
      s = "wcstoull"
      or
      s = "wcstoul"
      or
      s = "wcstoll"
      or
      s = "wcstol"
      or
      s = "wcstold"
      or
      s = "wcstof"
      or
      s = "wcstod"
      or
      s = "ungetwc"
      or
      s = "putwc"
      or
      s = "getwc"
      or
      s = "fwide"
      or
      s = "fputws"
      or
      s = "fputwc"
      or
      s = "fgetws"
      or
      s = "fgetwc"
      or
      s = "vswscanf"
      or
      s = "vfwscanf"
      or
      s = "swscanf"
      or
      s = "vswprintf"
      or
      s = "vfwprintf"
      or
      s = "swprintf"
      or
      s = "fwscanf"
      or
      s = "fwprintf"
      or
      s = "exchange"
      or
      s = "make_pair"
      or
      s = "move_if_noexcept"
      or
      s = "swap_ranges"
      or
      s = "signal"
      or
      s = "sigvec"
      or
      s = "sigaction"
      or
      s = "setrlimit"
      or
      s = "setiopolicy_np"
      or
      s = "setpriority"
      or
      s = "getrusage"
      or
      s = "getrlimit"
      or
      s = "getiopolicy_np"
      or
      s = "getpriority"
      or
      s = "wait"
      or
      s = "wait4"
      or
      s = "wait3"
      or
      s = "waitid"
      or
      s = "waitpid"
      or
      s = "alloca"
      or
      s = "posix_memalign"
      or
      s = "valloc"
      or
      s = "realloc"
      or
      s = "malloc"
      or
      s = "free"
      or
      s = "calloc"
      or
      s = "strtouq"
      or
      s = "strtoq"
      or
      s = "reallocf"
      or
      s = "srandomdev"
      or
      s = "sranddev"
      or
      s = "sradixsort"
      or
      s = "rpmatch"
      or
      s = "radixsort"
      or
      s = "qsort_r"
      or
      s = "qsort_b"
      or
      s = "psort_r"
      or
      s = "psort_b"
      or
      s = "psort"
      or
      s = "mergesort_b"
      or
      s = "mergesort"
      or
      s = "heapsort_b"
      or
      s = "heapsort"
      or
      s = "setprogname"
      or
      s = "getprogname"
      or
      s = "getloadavg"
      or
      s = "getbsize"
      or
      s = "devname_r"
      or
      s = "devname"
      or
      s = "daemon"
      or
      s = "cgetustr"
      or
      s = "cgetstr"
      or
      s = "cgetset"
      or
      s = "cgetnum"
      or
      s = "cgetnext"
      or
      s = "cgetmatch"
      or
      s = "cgetfirst"
      or
      s = "cgetent"
      or
      s = "cgetclose"
      or
      s = "cgetcap"
      or
      s = "bsearch_b"
      or
      s = "atexit_b"
      or
      s = "arc4random_uniform"
      or
      s = "arc4random_stir"
      or
      s = "arc4random_buf"
      or
      s = "arc4random_addrandom"
      or
      s = "arc4random"
      or
      s = "unsetenv"
      or
      s = "unlockpt"
      or
      s = "srandom"
      or
      s = "srand48"
      or
      s = "setstate"
      or
      s = "setkey"
      or
      s = "setenv"
      or
      s = "seed48"
      or
      s = "realpath"
      or
      s = "rand_r"
      or
      s = "random"
      or
      s = "putenv"
      or
      s = "ptsname_r"
      or
      s = "ptsname"
      or
      s = "posix_openpt"
      or
      s = "nrand48"
      or
      s = "mrand48"
      or
      s = "mkstemp"
      or
      s = "mktemp"
      or
      s = "lrand48"
      or
      s = "lcong48"
      or
      s = "l64a"
      or
      s = "jrand48"
      or
      s = "initstate"
      or
      s = "grantpt"
      or
      s = "getsubopt"
      or
      s = "gcvt"
      or
      s = "fcvt"
      or
      s = "erand48"
      or
      s = "ecvt"
      or
      s = "drand48"
      or
      s = "a64l"
      or
      s = "wcstombs"
      or
      s = "mbstowcs"
      or
      s = "wctomb"
      or
      s = "mbtowc"
      or
      s = "mblen"
      or
      s = "lldiv"
      or
      s = "ldiv"
      or
      s = "div"
      or
      s = "llabs"
      or
      s = "labs"
      or
      s = "abs"
      or
      s = "abs"
      or
      s = "qsort"
      or
      s = "bsearch"
      or
      s = "system"
      or
      s = "getenv"
      or
      s = "exit"
      or
      s = "atexit"
      or
      s = "abort"
      or
      s = "srand"
      or
      s = "rand"
      or
      s = "strtoull"
      or
      s = "strtoul"
      or
      s = "strtoll"
      or
      s = "strtol"
      or
      s = "strtold"
      or
      s = "strtof"
      or
      s = "strtod"
      or
      s = "atoll"
      or
      s = "atol"
      or
      s = "atoi"
      or
      s = "atof"
      or
      s = "rethrow_if_nested"
      or
      s = "throw_with_nested"
      or
      s = "make_exception_ptr"
      or
      s = "rethrow_exception"
      or
      s = "current_exception"
      or
      s = "uncaught_exceptions"
      or
      s = "uncaught_exception"
      or
      s = "terminate"
      or
      s = "get_terminate"
      or
      s = "set_terminate"
      or
      s = "unexpected"
      or
      s = "get_unexpected"
      or
      s = "set_unexpected"
      or
      s = "get_new_handler"
      or
      s = "set_new_handler"
      or
      s = "min"
      or
      s = "max"
      or
      s = "cref"
      or
      s = "ref"
      or
      s = "crend"
      or
      s = "crbegin"
      or
      s = "rend"
      or
      s = "rbegin"
      or
      s = "cend"
      or
      s = "cbegin"
      or
      s = "move_backward"
      or
      s = "copy_backward"
      or
      s = "copy"
      or
      s = "make_move_iterator"
      or
      s = "inserter"
      or
      s = "front_inserter"
      or
      s = "back_inserter"
      or
      s = "make_reverse_iterator"
      or
      s = "prev"
      or
      s = "next"
      or
      s = "distance"
      or
      s = "advance"
      or
      s = "equal"
      or
      s = "tuple_cat"
      or
      s = "forward_as_tuple"
      or
      s = "make_tuple"
      or
      s = "tie"
      or
      s = "atomic_signal_fence"
      or
      s = "atomic_thread_fence"
      or
      s = "atomic_flag_clear_explicit"
      or
      s = "atomic_flag_clear"
      or
      s = "atomic_flag_test_and_set_explicit"
      or
      s = "atomic_flag_test_and_set"
      or
      s = "atomic_fetch_xor_explicit"
      or
      s = "atomic_fetch_xor"
      or
      s = "atomic_fetch_or_explicit"
      or
      s = "atomic_fetch_or"
      or
      s = "atomic_fetch_and_explicit"
      or
      s = "atomic_fetch_and"
      or
      s = "atomic_fetch_sub_explicit"
      or
      s = "atomic_fetch_sub"
      or
      s = "atomic_fetch_add_explicit"
      or
      s = "atomic_fetch_add"
      or
      s = "atomic_compare_exchange_strong_explicit"
      or
      s = "atomic_compare_exchange_weak_explicit"
      or
      s = "atomic_compare_exchange_strong"
      or
      s = "atomic_compare_exchange_weak"
      or
      s = "atomic_exchange_explicit"
      or
      s = "atomic_exchange"
      or
      s = "atomic_load_explicit"
      or
      s = "atomic_load"
      or
      s = "atomic_store_explicit"
      or
      s = "atomic_store"
      or
      s = "atomic_init"
      or
      s = "atomic_is_lock_free"
      or
      s = "kill_dependency"
      or
      s = "align"
      or
      s = "undeclare_reachable"
      or
      s = "undeclare_no_pointers"
      or
      s = "declare_no_pointers"
      or
      s = "declare_reachable"
      or
      s = "get_pointer_safety"
      or
      s = "get_deleter"
      or
      s = "const_pointer_cast"
      or
      s = "dynamic_pointer_cast"
      or
      s = "static_pointer_cast"
      or
      s = "allocate_shared"
      or
      s = "make_shared"
      or
      s = "uninitialized_fill_n"
      or
      s = "uninitialized_fill"
      or
      s = "uninitialized_copy_n"
      or
      s = "uninitialized_copy"
      or
      s = "make_unique"
      or
      s = "return_temporary_buffer"
      or
      s = "get_temporary_buffer"
      or
      s = "lock"
      or
      s = "unique"
      or
      s = "bind"
      or
      s = "mem_fn"
      or
      s = "mem_fun_ref"
      or
      s = "mem_fun"
      or
      s = "ptr_fun"
      or
      s = "bind2nd"
      or
      s = "bind1st"
      or
      s = "not2"
      or
      s = "not1"
      or
      s = "prev_permutation"
      or
      s = "next_permutation"
      or
      s = "lexicographical_compare"
      or
      s = "set_symmetric_difference"
      or
      s = "set_difference"
      or
      s = "set_intersection"
      or
      s = "set_union"
      or
      s = "includes"
      or
      s = "nth_element"
      or
      s = "partial_sort_copy"
      or
      s = "partial_sort"
      or
      s = "sort_heap"
      or
      s = "make_heap"
      or
      s = "pop_heap"
      or
      s = "push_heap"
      or
      s = "is_heap"
      or
      s = "is_heap_until"
      or
      s = "stable_sort"
      or
      s = "inplace_merge"
      or
      s = "merge"
      or
      s = "binary_search"
      or
      s = "equal_range"
      or
      s = "upper_bound"
      or
      s = "lower_bound"
      or
      s = "sort"
      or
      s = "is_sorted"
      or
      s = "is_sorted_until"
      or
      s = "stable_partition"
      or
      s = "partition_point"
      or
      s = "partition_copy"
      or
      s = "partition"
      or
      s = "is_partitioned"
      or
      s = "shuffle"
      or
      s = "random_shuffle"
      or
      s = "minmax"
      or
      s = "minmax_element"
      or
      s = "max_element"
      or
      s = "min_element"
      or
      s = "rotate_copy"
      or
      s = "rotate"
      or
      s = "reverse_copy"
      or
      s = "reverse"
      or
      s = "unique_copy"
      or
      s = "remove_copy_if"
      or
      s = "remove_copy"
      or
      s = "remove_if"
      or
      s = "generate_n"
      or
      s = "generate"
      or
      s = "fill"
      or
      s = "fill_n"
      or
      s = "replace_copy_if"
      or
      s = "replace_copy"
      or
      s = "replace_if"
      or
      s = "replace"
      or
      s = "transform"
      or
      s = "copy_n"
      or
      s = "copy_if"
      or
      s = "search_n"
      or
      s = "search"
      or
      s = "is_permutation"
      or
      s = "mismatch"
      or
      s = "count_if"
      or
      s = "count"
      or
      s = "adjacent_find"
      or
      s = "find_first_of"
      or
      s = "find_end"
      or
      s = "find_if_not"
      or
      s = "find_if"
      or
      s = "find"
      or
      s = "for_each"
      or
      s = "none_of"
      or
      s = "any_of"
      or
      s = "all_of"
      or
      s = "nextwctype"
      or
      s = "iswspecial"
      or
      s = "iswrune"
      or
      s = "iswphonogram"
      or
      s = "iswnumber"
      or
      s = "iswideogram"
      or
      s = "iswhexnumber"
      or
      s = "iswascii"
      or
      s = "wctrans"
      or
      s = "towctrans"
      or
      s = "iswblank"
      or
      s = "to_wstring"
      or
      s = "stold"
      or
      s = "stod"
      or
      s = "stof"
      or
      s = "stoull"
      or
      s = "stoll"
      or
      s = "stoul"
      or
      s = "stol"
      or
      s = "stoi"
      or
      s = "to_string"
      or
      s = "significand"
      or
      s = "gamma"
      or
      s = "finite"
      or
      s = "drem"
      or
      s = "roundtol"
      or
      s = "rinttol"
      or
      s = "scalb"
      or
      s = "yn"
      or
      s = "y1"
      or
      s = "y0"
      or
      s = "jn"
      or
      s = "j1"
      or
      s = "j0"
      or
      s = "truncl"
      or
      s = "tgammal"
      or
      s = "scalbnl"
      or
      s = "scalblnl"
      or
      s = "roundl"
      or
      s = "rintl"
      or
      s = "remquol"
      or
      s = "remainderl"
      or
      s = "nexttowardl"
      or
      s = "nextafterl"
      or
      s = "nearbyintl"
      or
      s = "nanl"
      or
      s = "lroundl"
      or
      s = "lrintl"
      or
      s = "logbl"
      or
      s = "log2l"
      or
      s = "log1pl"
      or
      s = "llroundl"
      or
      s = "llrintl"
      or
      s = "lgammal"
      or
      s = "ilogbl"
      or
      s = "hypotl"
      or
      s = "fminl"
      or
      s = "fmaxl"
      or
      s = "fmal"
      or
      s = "fdiml"
      or
      s = "expm1l"
      or
      s = "exp2l"
      or
      s = "erfcl"
      or
      s = "erfl"
      or
      s = "copysignl"
      or
      s = "cbrtl"
      or
      s = "atanhl"
      or
      s = "asinhl"
      or
      s = "acoshl"
      or
      s = "tanhl"
      or
      s = "tanl"
      or
      s = "sqrtl"
      or
      s = "sinhl"
      or
      s = "sinl"
      or
      s = "powl"
      or
      s = "modfl"
      or
      s = "log10l"
      or
      s = "logl"
      or
      s = "ldexpl"
      or
      s = "frexpl"
      or
      s = "fmodl"
      or
      s = "floorl"
      or
      s = "fabsl"
      or
      s = "expl"
      or
      s = "coshl"
      or
      s = "cosl"
      or
      s = "ceill"
      or
      s = "atan2l"
      or
      s = "atanl"
      or
      s = "asinl"
      or
      s = "acosl"
      or
      s = "truncf"
      or
      s = "trunc"
      or
      s = "tgammaf"
      or
      s = "tgamma"
      or
      s = "scalbnf"
      or
      s = "scalbn"
      or
      s = "scalblnf"
      or
      s = "scalbln"
      or
      s = "roundf"
      or
      s = "round"
      or
      s = "rintf"
      or
      s = "rint"
      or
      s = "remquof"
      or
      s = "remquo"
      or
      s = "remainderf"
      or
      s = "remainder"
      or
      s = "nexttowardf"
      or
      s = "nexttoward"
      or
      s = "nextafterf"
      or
      s = "nextafter"
      or
      s = "nearbyintf"
      or
      s = "nearbyint"
      or
      s = "nanf"
      or
      s = "nan"
      or
      s = "lroundf"
      or
      s = "lround"
      or
      s = "lrintf"
      or
      s = "lrint"
      or
      s = "logbf"
      or
      s = "logb"
      or
      s = "log2f"
      or
      s = "log2"
      or
      s = "log1pf"
      or
      s = "log1p"
      or
      s = "llroundf"
      or
      s = "llround"
      or
      s = "llrintf"
      or
      s = "llrint"
      or
      s = "lgammaf"
      or
      s = "lgamma"
      or
      s = "ilogbf"
      or
      s = "ilogb"
      or
      s = "hypotf"
      or
      s = "hypot"
      or
      s = "fminf"
      or
      s = "fmin"
      or
      s = "fmaxf"
      or
      s = "fmax"
      or
      s = "fma"
      or
      s = "fmaf"
      or
      s = "fdimf"
      or
      s = "fdim"
      or
      s = "expm1f"
      or
      s = "expm1"
      or
      s = "exp2f"
      or
      s = "exp2"
      or
      s = "erfcf"
      or
      s = "erfc"
      or
      s = "erff"
      or
      s = "erf"
      or
      s = "copysignf"
      or
      s = "copysign"
      or
      s = "cbrtf"
      or
      s = "cbrt"
      or
      s = "atanhf"
      or
      s = "atanh"
      or
      s = "atanh"
      or
      s = "asinhf"
      or
      s = "asinh"
      or
      s = "asinh"
      or
      s = "acoshf"
      or
      s = "acosh"
      or
      s = "acosh"
      or
      s = "tanhf"
      or
      s = "tanh"
      or
      s = "tanh"
      or
      s = "tanf"
      or
      s = "tan"
      or
      s = "tan"
      or
      s = "sqrtf"
      or
      s = "sqrt"
      or
      s = "sqrt"
      or
      s = "sinhf"
      or
      s = "sinh"
      or
      s = "sinh"
      or
      s = "sinf"
      or
      s = "sin"
      or
      s = "sin"
      or
      s = "powf"
      or
      s = "pow"
      or
      s = "pow"
      or
      s = "modff"
      or
      s = "modf"
      or
      s = "log10f"
      or
      s = "log10"
      or
      s = "log10"
      or
      s = "logf"
      or
      s = "log"
      or
      s = "log"
      or
      s = "ldexpf"
      or
      s = "ldexp"
      or
      s = "frexpf"
      or
      s = "frexp"
      or
      s = "fmodf"
      or
      s = "fmod"
      or
      s = "floorf"
      or
      s = "floor"
      or
      s = "fabsf"
      or
      s = "fabs"
      or
      s = "expf"
      or
      s = "exp"
      or
      s = "exp"
      or
      s = "coshf"
      or
      s = "cosh"
      or
      s = "cosh"
      or
      s = "cosf"
      or
      s = "cos"
      or
      s = "cos"
      or
      s = "ceilf"
      or
      s = "ceil"
      or
      s = "atan2f"
      or
      s = "atan2"
      or
      s = "atan2"
      or
      s = "atanf"
      or
      s = "atan"
      or
      s = "atan"
      or
      s = "asinf"
      or
      s = "asin"
      or
      s = "asin"
      or
      s = "acosf"
      or
      s = "acos"
      or
      s = "acos"
      or
      s = "isunordered"
      or
      s = "islessgreater"
      or
      s = "islessequal"
      or
      s = "isless"
      or
      s = "isgreaterequal"
      or
      s = "isgreater"
      or
      s = "isnormal"
      or
      s = "isnan"
      or
      s = "isinf"
      or
      s = "isfinite"
      or
      s = "fpclassify"
      or
      s = "signbit"
      or
      s = "make_error_code"
      or
      s = "make_error_condition"
      or
      s = "system_category"
      or
      s = "generic_category"
      or
      s = "sched_get_priority_max"
      or
      s = "sched_get_priority_min"
      or
      s = "sched_yield"
      or
      s = "qos_class_main"
      or
      s = "qos_class_self"
      or
      s = "pthread_override_qos_class_end_np"
      or
      s = "pthread_override_qos_class_start_np"
      or
      s = "pthread_get_qos_class_np"
      or
      s = "pthread_set_qos_class_self_np"
      or
      s = "pthread_attr_get_qos_class_np"
      or
      s = "pthread_attr_set_qos_class_np"
      or
      s = "pthread_yield_np"
      or
      s = "pthread_from_mach_thread_np"
      or
      s = "pthread_create_suspended_np"
      or
      s = "pthread_cond_timedwait_relative_np"
      or
      s = "pthread_cond_signal_thread_np"
      or
      s = "pthread_get_stackaddr_np"
      or
      s = "pthread_get_stacksize_np"
      or
      s = "pthread_mach_thread_np"
      or
      s = "pthread_main_np"
      or
      s = "pthread_setname_np"
      or
      s = "pthread_getname_np"
      or
      s = "pthread_threadid_np"
      or
      s = "pthread_is_threaded_np"
      or
      s = "pthread_testcancel"
      or
      s = "pthread_setspecific"
      or
      s = "pthread_setschedparam"
      or
      s = "pthread_setconcurrency"
      or
      s = "pthread_setcanceltype"
      or
      s = "pthread_setcancelstate"
      or
      s = "pthread_self"
      or
      s = "pthread_rwlockattr_setpshared"
      or
      s = "pthread_rwlockattr_init"
      or
      s = "pthread_rwlockattr_getpshared"
      or
      s = "pthread_rwlockattr_destroy"
      or
      s = "pthread_rwlock_unlock"
      or
      s = "pthread_rwlock_wrlock"
      or
      s = "pthread_rwlock_trywrlock"
      or
      s = "pthread_rwlock_tryrdlock"
      or
      s = "pthread_rwlock_rdlock"
      or
      s = "pthread_rwlock_init"
      or
      s = "pthread_rwlock_destroy"
      or
      s = "pthread_once"
      or
      s = "pthread_mutexattr_setpolicy_np"
      or
      s = "pthread_mutexattr_settype"
      or
      s = "pthread_mutexattr_setpshared"
      or
      s = "pthread_mutexattr_setprotocol"
      or
      s = "pthread_mutexattr_setprioceiling"
      or
      s = "pthread_mutexattr_init"
      or
      s = "pthread_mutexattr_getpolicy_np"
      or
      s = "pthread_mutexattr_gettype"
      or
      s = "pthread_mutexattr_getpshared"
      or
      s = "pthread_mutexattr_getprotocol"
      or
      s = "pthread_mutexattr_getprioceiling"
      or
      s = "pthread_mutexattr_destroy"
      or
      s = "pthread_mutex_unlock"
      or
      s = "pthread_mutex_trylock"
      or
      s = "pthread_mutex_setprioceiling"
      or
      s = "pthread_mutex_lock"
      or
      s = "pthread_mutex_init"
      or
      s = "pthread_mutex_getprioceiling"
      or
      s = "pthread_mutex_destroy"
      or
      s = "pthread_key_delete"
      or
      s = "pthread_key_create"
      or
      s = "pthread_join"
      or
      s = "pthread_getspecific"
      or
      s = "pthread_getschedparam"
      or
      s = "pthread_getconcurrency"
      or
      s = "pthread_exit"
      or
      s = "pthread_equal"
      or
      s = "pthread_detach"
      or
      s = "pthread_create"
      or
      s = "pthread_condattr_setpshared"
      or
      s = "pthread_condattr_getpshared"
      or
      s = "pthread_condattr_init"
      or
      s = "pthread_condattr_destroy"
      or
      s = "pthread_cond_wait"
      or
      s = "pthread_cond_timedwait"
      or
      s = "pthread_cond_signal"
      or
      s = "pthread_cond_init"
      or
      s = "pthread_cond_destroy"
      or
      s = "pthread_cond_broadcast"
      or
      s = "pthread_cancel"
      or
      s = "pthread_attr_setstacksize"
      or
      s = "pthread_attr_setstackaddr"
      or
      s = "pthread_attr_setstack"
      or
      s = "pthread_attr_setscope"
      or
      s = "pthread_attr_setschedpolicy"
      or
      s = "pthread_attr_setschedparam"
      or
      s = "pthread_attr_setinheritsched"
      or
      s = "pthread_attr_setguardsize"
      or
      s = "pthread_attr_setdetachstate"
      or
      s = "pthread_attr_init"
      or
      s = "pthread_attr_getstacksize"
      or
      s = "pthread_attr_getstackaddr"
      or
      s = "pthread_attr_getstack"
      or
      s = "pthread_attr_getscope"
      or
      s = "pthread_attr_getschedpolicy"
      or
      s = "pthread_attr_getschedparam"
      or
      s = "pthread_attr_getinheritsched"
      or
      s = "pthread_attr_getguardsize"
      or
      s = "pthread_attr_getdetachstate"
      or
      s = "pthread_attr_destroy"
      or
      s = "pthread_atfork"
      or
      s = "pthread_sigmask"
      or
      s = "pthread_kill"
      or
      s = "try_lock"
      or
      s = "call_once"
      or
      s = "localeconv"
      or
      s = "setlocale"
      or
      s = "toupper_l"
      or
      s = "tolower_l"
      or
      s = "isxdigit_l"
      or
      s = "isupper_l"
      or
      s = "isspecial_l"
      or
      s = "isspace_l"
      or
      s = "isrune_l"
      or
      s = "ispunct_l"
      or
      s = "isprint_l"
      or
      s = "isphonogram_l"
      or
      s = "isnumber_l"
      or
      s = "islower_l"
      or
      s = "isideogram_l"
      or
      s = "ishexnumber_l"
      or
      s = "isgraph_l"
      or
      s = "isdigit_l"
      or
      s = "iscntrl_l"
      or
      s = "isblank_l"
      or
      s = "isalpha_l"
      or
      s = "isalnum_l"
      or
      s = "digittoint_l"
      or
      s = "wctype_l"
      or
      s = "towupper_l"
      or
      s = "towlower_l"
      or
      s = "iswxdigit_l"
      or
      s = "iswupper_l"
      or
      s = "iswspace_l"
      or
      s = "iswpunct_l"
      or
      s = "iswprint_l"
      or
      s = "iswlower_l"
      or
      s = "iswgraph_l"
      or
      s = "iswdigit_l"
      or
      s = "iswctype_l"
      or
      s = "iswcntrl_l"
      or
      s = "iswalpha_l"
      or
      s = "iswalnum_l"
      or
      s = "vasprintf_l"
      or
      s = "asprintf_l"
      or
      s = "vdprintf_l"
      or
      s = "dprintf_l"
      or
      s = "vsscanf_l"
      or
      s = "vsnprintf_l"
      or
      s = "vscanf_l"
      or
      s = "vfscanf_l"
      or
      s = "snprintf_l"
      or
      s = "vsprintf_l"
      or
      s = "vprintf_l"
      or
      s = "vfprintf_l"
      or
      s = "sscanf_l"
      or
      s = "sprintf_l"
      or
      s = "scanf_l"
      or
      s = "printf_l"
      or
      s = "fscanf_l"
      or
      s = "fprintf_l"
      or
      s = "wctomb_l"
      or
      s = "wcstombs_l"
      or
      s = "strtouq_l"
      or
      s = "strtoull_l"
      or
      s = "strtoul_l"
      or
      s = "strtoq_l"
      or
      s = "strtoll_l"
      or
      s = "strtold_l"
      or
      s = "strtol_l"
      or
      s = "strtof_l"
      or
      s = "strtod_l"
      or
      s = "mbtowc_l"
      or
      s = "mbstowcs_l"
      or
      s = "mblen_l"
      or
      s = "atoll_l"
      or
      s = "atol_l"
      or
      s = "atoi_l"
      or
      s = "atof_l"
      or
      s = "strncasecmp_l"
      or
      s = "strcasestr_l"
      or
      s = "strcasecmp_l"
      or
      s = "strxfrm_l"
      or
      s = "strcoll_l"
      or
      s = "strptime_l"
      or
      s = "strftime_l"
      or
      s = "fgetwln_l"
      or
      s = "wcsnrtombs_l"
      or
      s = "wcsncasecmp_l"
      or
      s = "wcscasecmp_l"
      or
      s = "mbsnrtowcs_l"
      or
      s = "wcstoull_l"
      or
      s = "wcstoll_l"
      or
      s = "wcstold_l"
      or
      s = "wcstof_l"
      or
      s = "vwscanf_l"
      or
      s = "vswscanf_l"
      or
      s = "vfwscanf_l"
      or
      s = "wscanf_l"
      or
      s = "wprintf_l"
      or
      s = "wcwidth_l"
      or
      s = "wctob_l"
      or
      s = "wcsxfrm_l"
      or
      s = "wcswidth_l"
      or
      s = "wcstoul_l"
      or
      s = "wcstol_l"
      or
      s = "wcstod_l"
      or
      s = "wcsrtombs_l"
      or
      s = "wcsftime_l"
      or
      s = "wcscoll_l"
      or
      s = "wcrtomb_l"
      or
      s = "vwprintf_l"
      or
      s = "vswprintf_l"
      or
      s = "vfwprintf_l"
      or
      s = "ungetwc_l"
      or
      s = "swscanf_l"
      or
      s = "swprintf_l"
      or
      s = "putwchar_l"
      or
      s = "putwc_l"
      or
      s = "mbsrtowcs_l"
      or
      s = "mbsinit_l"
      or
      s = "mbrtowc_l"
      or
      s = "mbrlen_l"
      or
      s = "getwchar_l"
      or
      s = "getwc_l"
      or
      s = "fwscanf_l"
      or
      s = "fwprintf_l"
      or
      s = "fputws_l"
      or
      s = "fputwc_l"
      or
      s = "fgetws_l"
      or
      s = "fgetwc_l"
      or
      s = "btowc_l"
      or
      s = "wctrans_l"
      or
      s = "towctrans_l"
      or
      s = "nextwctype_l"
      or
      s = "iswspecial_l"
      or
      s = "iswrune_l"
      or
      s = "iswphonogram_l"
      or
      s = "iswnumber_l"
      or
      s = "iswideogram_l"
      or
      s = "iswhexnumber_l"
      or
      s = "iswblank_l"
      or
      s = "uselocale"
      or
      s = "querylocale"
      or
      s = "newlocale"
      or
      s = "localeconv_l"
      or
      s = "freelocale"
      or
      s = "duplocale"
      or
      s = "use_facet"
      or
      s = "has_facet"
      or
      s = "defaultfloat"
      or
      s = "hexfloat"
      or
      s = "scientific"
      or
      s = "fixed"
      or
      s = "oct"
      or
      s = "hex"
      or
      s = "dec"
      or
      s = "right"
      or
      s = "left"
      or
      s = "internal"
      or
      s = "nounitbuf"
      or
      s = "unitbuf"
      or
      s = "nouppercase"
      or
      s = "uppercase"
      or
      s = "noskipws"
      or
      s = "skipws"
      or
      s = "noshowpos"
      or
      s = "showpos"
      or
      s = "noshowpoint"
      or
      s = "showpoint"
      or
      s = "noshowbase"
      or
      s = "showbase"
      or
      s = "noboolalpha"
      or
      s = "boolalpha"
      or
      s = "iostream_category"
      or
      s = "makedev"
      or
      s = "minor"
      or
      s = "major"
      or
      s = "catclose"
      or
      s = "catgets"
      or
      s = "catopen"
      or
      s = "get_time"
      or
      s = "flush"
      or
      s = "ends"
      or
      s = "endl"
      or
      s = "ws"
      or
      s = "polar"
      or
      s = "proj"
      or
      s = "conj"
      or
      s = "norm"
      or
      s = "arg"
      or
      s = "imag"
      or
      s = "real"
      or
      s = "feupdateenv"
      or
      s = "fesetenv"
      or
      s = "feholdexcept"
      or
      s = "fegetenv"
      or
      s = "fesetround"
      or
      s = "fegetround"
      or
      s = "fetestexcept"
      or
      s = "fesetexceptflag"
      or
      s = "feraiseexcept"
      or
      s = "fegetexceptflag"
      or
      s = "feclearexcept"
      or
      s = "wcstoumax_l"
      or
      s = "wcstoimax_l"
      or
      s = "strtoumax_l"
      or
      s = "strtoimax_l"
      or
      s = "wcstoumax"
      or
      s = "wcstoimax"
      or
      s = "strtoumax"
      or
      s = "strtoimax"
      or
      s = "imaxdiv"
      or
      s = "imaxabs"
      or
      s = "notify_all_at_thread_exit"
      or
      s = "setjmp"
      or
      s = "longjmperror"
      or
      s = "siglongjmp"
      or
      s = "sigsetjmp"
      or
      s = "longjmp"
      or
      s = "sigsetmask"
      or
      s = "sigblock"
      or
      s = "psignal"
      or
      s = "sigwait"
      or
      s = "sigsuspend"
      or
      s = "sigset"
      or
      s = "sigrelse"
      or
      s = "sigprocmask"
      or
      s = "sigpending"
      or
      s = "sigpause"
      or
      s = "sigismember"
      or
      s = "siginterrupt"
      or
      s = "sigignore"
      or
      s = "sighold"
      or
      s = "sigfillset"
      or
      s = "sigemptyset"
      or
      s = "sigdelset"
      or
      s = "sigaltstack"
      or
      s = "sigaddset"
      or
      s = "killpg"
      or
      s = "kill"
      or
      s = "bsd_signal"
      or
      s = "raise"
      or
      s = "quoted"
      or
      s = "put_time"
      or
      s = "put_money"
      or
      s = "get_money"
      or
      s = "setw"
      or
      s = "setprecision"
      or
      s = "setfill"
      or
      s = "setbase"
      or
      s = "setiosflags"
      or
      s = "resetiosflags"
      or
      s = "async"
      or
      s = "future_category"
      or
      s = "iota"
      or
      s = "adjacent_difference"
      or
      s = "partial_sum"
      or
      s = "inner_product"
      or
      s = "accumulate"
      or
      s = "lgamma_r"
      or
      s = "generate_canonical"
      or
      s = "regex_replace"
      or
      s = "regex_match"
      or
      s = "regex_search"
    }

    /** Gets the qualified function name for the unqualifed name `s`, if any. */
    string getQualifiedStandardLibraryFunctionName(string s) {
      s = "end" and result = "std::end"
      or
      s = "end" and result = "std::__1::end"
      or
      s = "begin" and result = "std::begin"
      or
      s = "begin" and result = "std::__1::begin"
      or
      s = "iter_swap" and result = "std::__1::iter_swap"
      or
      s = "swap" and result = "std::__1::swap"
      or
      s = "get" and result = "std::__1::get"
      or
      s = "forward" and result = "std::__1::forward"
      or
      s = "move" and result = "std::__1::move"
      or
      s = "declval" and result = "std::__1::declval"
      or
      s = "addressof" and result = "std::__1::addressof"
      or
      s = "flsll" and result = "flsll"
      or
      s = "flsl" and result = "flsl"
      or
      s = "fls" and result = "fls"
      or
      s = "ffsll" and result = "ffsll"
      or
      s = "ffsl" and result = "ffsl"
      or
      s = "strncasecmp" and result = "strncasecmp"
      or
      s = "strcasecmp" and result = "strcasecmp"
      or
      s = "ffs" and result = "ffs"
      or
      s = "rindex" and result = "rindex"
      or
      s = "index" and result = "index"
      or
      s = "bzero" and result = "bzero"
      or
      s = "bcopy" and result = "bcopy"
      or
      s = "bcmp" and result = "bcmp"
      or
      s = "timingsafe_bcmp" and result = "timingsafe_bcmp"
      or
      s = "swab" and result = "swab"
      or
      s = "strsep" and result = "strsep"
      or
      s = "strmode" and result = "strmode"
      or
      s = "strlcpy" and result = "strlcpy"
      or
      s = "strlcat" and result = "strlcat"
      or
      s = "strnstr" and result = "strnstr"
      or
      s = "strcasestr" and result = "strcasestr"
      or
      s = "memset_pattern16" and result = "memset_pattern16"
      or
      s = "memset_pattern8" and result = "memset_pattern8"
      or
      s = "memset_pattern4" and result = "memset_pattern4"
      or
      s = "memmem" and result = "memmem"
      or
      s = "strsignal" and result = "strsignal"
      or
      s = "strnlen" and result = "strnlen"
      or
      s = "strndup" and result = "strndup"
      or
      s = "stpncpy" and result = "stpncpy"
      or
      s = "stpcpy" and result = "stpcpy"
      or
      s = "memccpy" and result = "memccpy"
      or
      s = "strdup" and result = "strdup"
      or
      s = "strerror_r" and result = "strerror_r"
      or
      s = "strtok_r" and result = "strtok_r"
      or
      s = "strlen" and result = "strlen"
      or
      s = "strerror" and result = "strerror"
      or
      s = "memset" and result = "memset"
      or
      s = "strtok" and result = "strtok"
      or
      s = "strstr" and result = "strstr"
      or
      s = "strspn" and result = "strspn"
      or
      s = "strrchr" and result = "strrchr"
      or
      s = "strpbrk" and result = "strpbrk"
      or
      s = "strcspn" and result = "strcspn"
      or
      s = "strchr" and result = "strchr"
      or
      s = "memchr" and result = "memchr"
      or
      s = "strxfrm" and result = "strxfrm"
      or
      s = "strcoll" and result = "strcoll"
      or
      s = "strncmp" and result = "strncmp"
      or
      s = "strcmp" and result = "strcmp"
      or
      s = "memcmp" and result = "memcmp"
      or
      s = "strncat" and result = "strncat"
      or
      s = "strcat" and result = "strcat"
      or
      s = "strncpy" and result = "strncpy"
      or
      s = "strcpy" and result = "strcpy"
      or
      s = "memmove" and result = "memmove"
      or
      s = "memcpy" and result = "memcpy"
      or
      s = "renameatx_np" and result = "renameatx_np"
      or
      s = "renamex_np" and result = "renamex_np"
      or
      s = "renameat" and result = "renameat"
      or
      s = "ctermid" and result = "ctermid"
      or
      s = "funopen" and result = "funopen"
      or
      s = "zopen" and result = "zopen"
      or
      s = "vasprintf" and result = "vasprintf"
      or
      s = "setlinebuf" and result = "setlinebuf"
      or
      s = "setbuffer" and result = "setbuffer"
      or
      s = "fpurge" and result = "fpurge"
      or
      s = "fmtcheck" and result = "fmtcheck"
      or
      s = "fgetln" and result = "fgetln"
      or
      s = "ctermid_r" and result = "ctermid_r"
      or
      s = "asprintf" and result = "asprintf"
      or
      s = "open_memstream" and result = "open_memstream"
      or
      s = "fmemopen" and result = "fmemopen"
      or
      s = "getline" and result = "getline"
      or
      s = "getline" and result = "std::__1::getline"
      or
      s = "getdelim" and result = "getdelim"
      or
      s = "vdprintf" and result = "vdprintf"
      or
      s = "dprintf" and result = "dprintf"
      or
      s = "ftello" and result = "ftello"
      or
      s = "fseeko" and result = "fseeko"
      or
      s = "tempnam" and result = "tempnam"
      or
      s = "putw" and result = "putw"
      or
      s = "getw" and result = "getw"
      or
      s = "putchar_unlocked" and result = "putchar_unlocked"
      or
      s = "putc_unlocked" and result = "putc_unlocked"
      or
      s = "getchar_unlocked" and result = "getchar_unlocked"
      or
      s = "getc_unlocked" and result = "getc_unlocked"
      or
      s = "funlockfile" and result = "funlockfile"
      or
      s = "ftrylockfile" and result = "ftrylockfile"
      or
      s = "flockfile" and result = "flockfile"
      or
      s = "popen" and result = "popen"
      or
      s = "pclose" and result = "pclose"
      or
      s = "fileno" and result = "fileno"
      or
      s = "fdopen" and result = "fdopen"
      or
      s = "gets" and result = "gets"
      or
      s = "vprintf" and result = "vprintf"
      or
      s = "puts" and result = "puts"
      or
      s = "putchar" and result = "putchar"
      or
      s = "printf" and result = "printf"
      or
      s = "vscanf" and result = "vscanf"
      or
      s = "scanf" and result = "scanf"
      or
      s = "getchar" and result = "getchar"
      or
      s = "tmpnam" and result = "tmpnam"
      or
      s = "tmpfile" and result = "tmpfile"
      or
      s = "rename" and result = "rename"
      or
      s = "remove" and result = "remove"
      or
      s = "remove" and result = "std::__1::remove"
      or
      s = "freopen" and result = "freopen"
      or
      s = "fopen" and result = "fopen"
      or
      s = "perror" and result = "perror"
      or
      s = "ferror" and result = "ferror"
      or
      s = "feof" and result = "feof"
      or
      s = "clearerr" and result = "clearerr"
      or
      s = "rewind" and result = "rewind"
      or
      s = "ftell" and result = "ftell"
      or
      s = "fsetpos" and result = "fsetpos"
      or
      s = "fseek" and result = "fseek"
      or
      s = "fgetpos" and result = "fgetpos"
      or
      s = "fwrite" and result = "fwrite"
      or
      s = "fread" and result = "fread"
      or
      s = "ungetc" and result = "ungetc"
      or
      s = "putc" and result = "putc"
      or
      s = "getc" and result = "getc"
      or
      s = "fputs" and result = "fputs"
      or
      s = "fputc" and result = "fputc"
      or
      s = "fgets" and result = "fgets"
      or
      s = "fgetc" and result = "fgetc"
      or
      s = "vsprintf" and result = "vsprintf"
      or
      s = "vsnprintf" and result = "vsnprintf"
      or
      s = "vsscanf" and result = "vsscanf"
      or
      s = "vfscanf" and result = "vfscanf"
      or
      s = "vfprintf" and result = "vfprintf"
      or
      s = "sscanf" and result = "sscanf"
      or
      s = "sprintf" and result = "sprintf"
      or
      s = "snprintf" and result = "snprintf"
      or
      s = "fscanf" and result = "fscanf"
      or
      s = "fprintf" and result = "fprintf"
      or
      s = "setvbuf" and result = "setvbuf"
      or
      s = "setbuf" and result = "setbuf"
      or
      s = "fflush" and result = "fflush"
      or
      s = "fclose" and result = "fclose"
      or
      s = "time" and result = "time"
      or
      s = "clock_settime" and result = "clock_settime"
      or
      s = "clock_gettime_nsec_np" and result = "clock_gettime_nsec_np"
      or
      s = "clock_gettime" and result = "clock_gettime"
      or
      s = "clock_getres" and result = "clock_getres"
      or
      s = "nanosleep" and result = "nanosleep"
      or
      s = "timegm" and result = "timegm"
      or
      s = "timelocal" and result = "timelocal"
      or
      s = "time2posix" and result = "time2posix"
      or
      s = "tzsetwall" and result = "tzsetwall"
      or
      s = "posix2time" and result = "posix2time"
      or
      s = "localtime_r" and result = "localtime_r"
      or
      s = "gmtime_r" and result = "gmtime_r"
      or
      s = "ctime_r" and result = "ctime_r"
      or
      s = "asctime_r" and result = "asctime_r"
      or
      s = "tzset" and result = "tzset"
      or
      s = "strptime" and result = "strptime"
      or
      s = "getdate" and result = "getdate"
      or
      s = "strftime" and result = "strftime"
      or
      s = "localtime" and result = "localtime"
      or
      s = "gmtime" and result = "gmtime"
      or
      s = "ctime" and result = "ctime"
      or
      s = "asctime" and result = "asctime"
      or
      s = "mktime" and result = "mktime"
      or
      s = "difftime" and result = "difftime"
      or
      s = "clock" and result = "clock"
      or
      s = "isspecial" and result = "isspecial"
      or
      s = "isrune" and result = "isrune"
      or
      s = "isphonogram" and result = "isphonogram"
      or
      s = "isnumber" and result = "isnumber"
      or
      s = "isideogram" and result = "isideogram"
      or
      s = "ishexnumber" and result = "ishexnumber"
      or
      s = "digittoint" and result = "digittoint"
      or
      s = "toascii" and result = "toascii"
      or
      s = "isascii" and result = "isascii"
      or
      s = "toupper" and result = "toupper"
      or
      s = "toupper" and result = "std::__1::toupper"
      or
      s = "tolower" and result = "tolower"
      or
      s = "tolower" and result = "std::__1::tolower"
      or
      s = "isxdigit" and result = "isxdigit"
      or
      s = "isxdigit" and result = "std::__1::isxdigit"
      or
      s = "isupper" and result = "isupper"
      or
      s = "isupper" and result = "std::__1::isupper"
      or
      s = "isspace" and result = "isspace"
      or
      s = "isspace" and result = "std::__1::isspace"
      or
      s = "ispunct" and result = "ispunct"
      or
      s = "ispunct" and result = "std::__1::ispunct"
      or
      s = "isprint" and result = "isprint"
      or
      s = "isprint" and result = "std::__1::isprint"
      or
      s = "islower" and result = "islower"
      or
      s = "islower" and result = "std::__1::islower"
      or
      s = "isgraph" and result = "isgraph"
      or
      s = "isgraph" and result = "std::__1::isgraph"
      or
      s = "isdigit" and result = "isdigit"
      or
      s = "isdigit" and result = "std::__1::isdigit"
      or
      s = "iscntrl" and result = "iscntrl"
      or
      s = "iscntrl" and result = "std::__1::iscntrl"
      or
      s = "isblank" and result = "isblank"
      or
      s = "isalpha" and result = "isalpha"
      or
      s = "isalpha" and result = "std::__1::isalpha"
      or
      s = "isalnum" and result = "isalnum"
      or
      s = "isalnum" and result = "std::__1::isalnum"
      or
      s = "towupper" and result = "towupper"
      or
      s = "towlower" and result = "towlower"
      or
      s = "wctype" and result = "wctype"
      or
      s = "iswctype" and result = "iswctype"
      or
      s = "iswxdigit" and result = "iswxdigit"
      or
      s = "iswupper" and result = "iswupper"
      or
      s = "iswspace" and result = "iswspace"
      or
      s = "iswpunct" and result = "iswpunct"
      or
      s = "iswprint" and result = "iswprint"
      or
      s = "iswlower" and result = "iswlower"
      or
      s = "iswgraph" and result = "iswgraph"
      or
      s = "iswdigit" and result = "iswdigit"
      or
      s = "iswcntrl" and result = "iswcntrl"
      or
      s = "iswalpha" and result = "iswalpha"
      or
      s = "iswalnum" and result = "iswalnum"
      or
      s = "wcslcpy" and result = "wcslcpy"
      or
      s = "wcslcat" and result = "wcslcat"
      or
      s = "fgetwln" and result = "fgetwln"
      or
      s = "open_wmemstream" and result = "open_wmemstream"
      or
      s = "wcsnrtombs" and result = "wcsnrtombs"
      or
      s = "wcsnlen" and result = "wcsnlen"
      or
      s = "wcsncasecmp" and result = "wcsncasecmp"
      or
      s = "wcscasecmp" and result = "wcscasecmp"
      or
      s = "wcsdup" and result = "wcsdup"
      or
      s = "wcpncpy" and result = "wcpncpy"
      or
      s = "wcpcpy" and result = "wcpcpy"
      or
      s = "mbsnrtowcs" and result = "mbsnrtowcs"
      or
      s = "wcwidth" and result = "wcwidth"
      or
      s = "wcswidth" and result = "wcswidth"
      or
      s = "wprintf" and result = "wprintf"
      or
      s = "vwprintf" and result = "vwprintf"
      or
      s = "putwchar" and result = "putwchar"
      or
      s = "wscanf" and result = "wscanf"
      or
      s = "vwscanf" and result = "vwscanf"
      or
      s = "getwchar" and result = "getwchar"
      or
      s = "wcsrtombs" and result = "wcsrtombs"
      or
      s = "mbsrtowcs" and result = "mbsrtowcs"
      or
      s = "wcrtomb" and result = "wcrtomb"
      or
      s = "mbrtowc" and result = "mbrtowc"
      or
      s = "mbrlen" and result = "mbrlen"
      or
      s = "mbsinit" and result = "mbsinit"
      or
      s = "wctob" and result = "wctob"
      or
      s = "btowc" and result = "btowc"
      or
      s = "wcsftime" and result = "wcsftime"
      or
      s = "wmemset" and result = "wmemset"
      or
      s = "wmemmove" and result = "wmemmove"
      or
      s = "wmemcpy" and result = "wmemcpy"
      or
      s = "wmemcmp" and result = "wmemcmp"
      or
      s = "wcstok" and result = "wcstok"
      or
      s = "wcsspn" and result = "wcsspn"
      or
      s = "wcslen" and result = "wcslen"
      or
      s = "wcscspn" and result = "wcscspn"
      or
      s = "wmemchr" and result = "wmemchr"
      or
      s = "wcsstr" and result = "wcsstr"
      or
      s = "wcsrchr" and result = "wcsrchr"
      or
      s = "wcspbrk" and result = "wcspbrk"
      or
      s = "wcschr" and result = "wcschr"
      or
      s = "wcsxfrm" and result = "wcsxfrm"
      or
      s = "wcsncmp" and result = "wcsncmp"
      or
      s = "wcscoll" and result = "wcscoll"
      or
      s = "wcscmp" and result = "wcscmp"
      or
      s = "wcsncat" and result = "wcsncat"
      or
      s = "wcscat" and result = "wcscat"
      or
      s = "wcsncpy" and result = "wcsncpy"
      or
      s = "wcscpy" and result = "wcscpy"
      or
      s = "wcstoull" and result = "wcstoull"
      or
      s = "wcstoul" and result = "wcstoul"
      or
      s = "wcstoll" and result = "wcstoll"
      or
      s = "wcstol" and result = "wcstol"
      or
      s = "wcstold" and result = "wcstold"
      or
      s = "wcstof" and result = "wcstof"
      or
      s = "wcstod" and result = "wcstod"
      or
      s = "ungetwc" and result = "ungetwc"
      or
      s = "putwc" and result = "putwc"
      or
      s = "getwc" and result = "getwc"
      or
      s = "fwide" and result = "fwide"
      or
      s = "fputws" and result = "fputws"
      or
      s = "fputwc" and result = "fputwc"
      or
      s = "fgetws" and result = "fgetws"
      or
      s = "fgetwc" and result = "fgetwc"
      or
      s = "vswscanf" and result = "vswscanf"
      or
      s = "vfwscanf" and result = "vfwscanf"
      or
      s = "swscanf" and result = "swscanf"
      or
      s = "vswprintf" and result = "vswprintf"
      or
      s = "vfwprintf" and result = "vfwprintf"
      or
      s = "swprintf" and result = "swprintf"
      or
      s = "fwscanf" and result = "fwscanf"
      or
      s = "fwprintf" and result = "fwprintf"
      or
      s = "exchange" and result = "std::__1::exchange"
      or
      s = "make_pair" and result = "std::__1::make_pair"
      or
      s = "move_if_noexcept" and result = "std::__1::move_if_noexcept"
      or
      s = "swap_ranges" and result = "std::__1::swap_ranges"
      or
      s = "signal" and result = "signal"
      or
      s = "sigvec" and result = "sigvec"
      or
      s = "sigaction" and result = "sigaction"
      or
      s = "setrlimit" and result = "setrlimit"
      or
      s = "setiopolicy_np" and result = "setiopolicy_np"
      or
      s = "setpriority" and result = "setpriority"
      or
      s = "getrusage" and result = "getrusage"
      or
      s = "getrlimit" and result = "getrlimit"
      or
      s = "getiopolicy_np" and result = "getiopolicy_np"
      or
      s = "getpriority" and result = "getpriority"
      or
      s = "wait" and result = "wait"
      or
      s = "wait4" and result = "wait4"
      or
      s = "wait3" and result = "wait3"
      or
      s = "waitid" and result = "waitid"
      or
      s = "waitpid" and result = "waitpid"
      or
      s = "alloca" and result = "alloca"
      or
      s = "posix_memalign" and result = "posix_memalign"
      or
      s = "valloc" and result = "valloc"
      or
      s = "realloc" and result = "realloc"
      or
      s = "malloc" and result = "malloc"
      or
      s = "free" and result = "free"
      or
      s = "calloc" and result = "calloc"
      or
      s = "strtouq" and result = "strtouq"
      or
      s = "strtoq" and result = "strtoq"
      or
      s = "reallocf" and result = "reallocf"
      or
      s = "srandomdev" and result = "srandomdev"
      or
      s = "sranddev" and result = "sranddev"
      or
      s = "sradixsort" and result = "sradixsort"
      or
      s = "rpmatch" and result = "rpmatch"
      or
      s = "radixsort" and result = "radixsort"
      or
      s = "qsort_r" and result = "qsort_r"
      or
      s = "qsort_b" and result = "qsort_b"
      or
      s = "psort_r" and result = "psort_r"
      or
      s = "psort_b" and result = "psort_b"
      or
      s = "psort" and result = "psort"
      or
      s = "mergesort_b" and result = "mergesort_b"
      or
      s = "mergesort" and result = "mergesort"
      or
      s = "heapsort_b" and result = "heapsort_b"
      or
      s = "heapsort" and result = "heapsort"
      or
      s = "setprogname" and result = "setprogname"
      or
      s = "getprogname" and result = "getprogname"
      or
      s = "getloadavg" and result = "getloadavg"
      or
      s = "getbsize" and result = "getbsize"
      or
      s = "devname_r" and result = "devname_r"
      or
      s = "devname" and result = "devname"
      or
      s = "daemon" and result = "daemon"
      or
      s = "cgetustr" and result = "cgetustr"
      or
      s = "cgetstr" and result = "cgetstr"
      or
      s = "cgetset" and result = "cgetset"
      or
      s = "cgetnum" and result = "cgetnum"
      or
      s = "cgetnext" and result = "cgetnext"
      or
      s = "cgetmatch" and result = "cgetmatch"
      or
      s = "cgetfirst" and result = "cgetfirst"
      or
      s = "cgetent" and result = "cgetent"
      or
      s = "cgetclose" and result = "cgetclose"
      or
      s = "cgetcap" and result = "cgetcap"
      or
      s = "bsearch_b" and result = "bsearch_b"
      or
      s = "atexit_b" and result = "atexit_b"
      or
      s = "arc4random_uniform" and result = "arc4random_uniform"
      or
      s = "arc4random_stir" and result = "arc4random_stir"
      or
      s = "arc4random_buf" and result = "arc4random_buf"
      or
      s = "arc4random_addrandom" and result = "arc4random_addrandom"
      or
      s = "arc4random" and result = "arc4random"
      or
      s = "unsetenv" and result = "unsetenv"
      or
      s = "unlockpt" and result = "unlockpt"
      or
      s = "srandom" and result = "srandom"
      or
      s = "srand48" and result = "srand48"
      or
      s = "setstate" and result = "setstate"
      or
      s = "setkey" and result = "setkey"
      or
      s = "setenv" and result = "setenv"
      or
      s = "seed48" and result = "seed48"
      or
      s = "realpath" and result = "realpath"
      or
      s = "rand_r" and result = "rand_r"
      or
      s = "random" and result = "random"
      or
      s = "putenv" and result = "putenv"
      or
      s = "ptsname_r" and result = "ptsname_r"
      or
      s = "ptsname" and result = "ptsname"
      or
      s = "posix_openpt" and result = "posix_openpt"
      or
      s = "nrand48" and result = "nrand48"
      or
      s = "mrand48" and result = "mrand48"
      or
      s = "mkstemp" and result = "mkstemp"
      or
      s = "mktemp" and result = "mktemp"
      or
      s = "lrand48" and result = "lrand48"
      or
      s = "lcong48" and result = "lcong48"
      or
      s = "l64a" and result = "l64a"
      or
      s = "jrand48" and result = "jrand48"
      or
      s = "initstate" and result = "initstate"
      or
      s = "grantpt" and result = "grantpt"
      or
      s = "getsubopt" and result = "getsubopt"
      or
      s = "gcvt" and result = "gcvt"
      or
      s = "fcvt" and result = "fcvt"
      or
      s = "erand48" and result = "erand48"
      or
      s = "ecvt" and result = "ecvt"
      or
      s = "drand48" and result = "drand48"
      or
      s = "a64l" and result = "a64l"
      or
      s = "wcstombs" and result = "wcstombs"
      or
      s = "mbstowcs" and result = "mbstowcs"
      or
      s = "wctomb" and result = "wctomb"
      or
      s = "mbtowc" and result = "mbtowc"
      or
      s = "mblen" and result = "mblen"
      or
      s = "lldiv" and result = "lldiv"
      or
      s = "ldiv" and result = "ldiv"
      or
      s = "div" and result = "div"
      or
      s = "llabs" and result = "llabs"
      or
      s = "labs" and result = "labs"
      or
      s = "abs" and result = "abs"
      or
      s = "abs" and result = "std::__1::abs"
      or
      s = "qsort" and result = "qsort"
      or
      s = "bsearch" and result = "bsearch"
      or
      s = "system" and result = "system"
      or
      s = "getenv" and result = "getenv"
      or
      s = "exit" and result = "exit"
      or
      s = "atexit" and result = "atexit"
      or
      s = "abort" and result = "abort"
      or
      s = "srand" and result = "srand"
      or
      s = "rand" and result = "rand"
      or
      s = "strtoull" and result = "strtoull"
      or
      s = "strtoul" and result = "strtoul"
      or
      s = "strtoll" and result = "strtoll"
      or
      s = "strtol" and result = "strtol"
      or
      s = "strtold" and result = "strtold"
      or
      s = "strtof" and result = "strtof"
      or
      s = "strtod" and result = "strtod"
      or
      s = "atoll" and result = "atoll"
      or
      s = "atol" and result = "atol"
      or
      s = "atoi" and result = "atoi"
      or
      s = "atof" and result = "atof"
      or
      s = "rethrow_if_nested" and result = "std::rethrow_if_nested"
      or
      s = "throw_with_nested" and result = "std::throw_with_nested"
      or
      s = "make_exception_ptr" and result = "std::make_exception_ptr"
      or
      s = "rethrow_exception" and result = "std::rethrow_exception"
      or
      s = "current_exception" and result = "std::current_exception"
      or
      s = "uncaught_exceptions" and result = "std::uncaught_exceptions"
      or
      s = "uncaught_exception" and result = "std::uncaught_exception"
      or
      s = "terminate" and result = "std::terminate"
      or
      s = "get_terminate" and result = "std::get_terminate"
      or
      s = "set_terminate" and result = "std::set_terminate"
      or
      s = "unexpected" and result = "std::unexpected"
      or
      s = "get_unexpected" and result = "std::get_unexpected"
      or
      s = "set_unexpected" and result = "std::set_unexpected"
      or
      s = "get_new_handler" and result = "std::get_new_handler"
      or
      s = "set_new_handler" and result = "std::set_new_handler"
      or
      s = "min" and result = "std::__1::min"
      or
      s = "max" and result = "std::__1::max"
      or
      s = "cref" and result = "std::__1::cref"
      or
      s = "ref" and result = "std::__1::ref"
      or
      s = "crend" and result = "std::__1::crend"
      or
      s = "crbegin" and result = "std::__1::crbegin"
      or
      s = "rend" and result = "std::__1::rend"
      or
      s = "rbegin" and result = "std::__1::rbegin"
      or
      s = "cend" and result = "std::__1::cend"
      or
      s = "cbegin" and result = "std::__1::cbegin"
      or
      s = "move_backward" and result = "std::__1::move_backward"
      or
      s = "copy_backward" and result = "std::__1::copy_backward"
      or
      s = "copy" and result = "std::__1::copy"
      or
      s = "make_move_iterator" and result = "std::__1::make_move_iterator"
      or
      s = "inserter" and result = "std::__1::inserter"
      or
      s = "front_inserter" and result = "std::__1::front_inserter"
      or
      s = "back_inserter" and result = "std::__1::back_inserter"
      or
      s = "make_reverse_iterator" and result = "std::__1::make_reverse_iterator"
      or
      s = "prev" and result = "std::__1::prev"
      or
      s = "next" and result = "std::__1::next"
      or
      s = "distance" and result = "std::__1::distance"
      or
      s = "advance" and result = "std::__1::advance"
      or
      s = "equal" and result = "std::__1::equal"
      or
      s = "tuple_cat" and result = "std::__1::tuple_cat"
      or
      s = "forward_as_tuple" and result = "std::__1::forward_as_tuple"
      or
      s = "make_tuple" and result = "std::__1::make_tuple"
      or
      s = "tie" and result = "std::__1::tie"
      or
      s = "atomic_signal_fence" and result = "std::__1::atomic_signal_fence"
      or
      s = "atomic_thread_fence" and result = "std::__1::atomic_thread_fence"
      or
      s = "atomic_flag_clear_explicit" and result = "std::__1::atomic_flag_clear_explicit"
      or
      s = "atomic_flag_clear" and result = "std::__1::atomic_flag_clear"
      or
      s = "atomic_flag_test_and_set_explicit" and
      result = "std::__1::atomic_flag_test_and_set_explicit"
      or
      s = "atomic_flag_test_and_set" and result = "std::__1::atomic_flag_test_and_set"
      or
      s = "atomic_fetch_xor_explicit" and result = "std::__1::atomic_fetch_xor_explicit"
      or
      s = "atomic_fetch_xor" and result = "std::__1::atomic_fetch_xor"
      or
      s = "atomic_fetch_or_explicit" and result = "std::__1::atomic_fetch_or_explicit"
      or
      s = "atomic_fetch_or" and result = "std::__1::atomic_fetch_or"
      or
      s = "atomic_fetch_and_explicit" and result = "std::__1::atomic_fetch_and_explicit"
      or
      s = "atomic_fetch_and" and result = "std::__1::atomic_fetch_and"
      or
      s = "atomic_fetch_sub_explicit" and result = "std::__1::atomic_fetch_sub_explicit"
      or
      s = "atomic_fetch_sub" and result = "std::__1::atomic_fetch_sub"
      or
      s = "atomic_fetch_add_explicit" and result = "std::__1::atomic_fetch_add_explicit"
      or
      s = "atomic_fetch_add" and result = "std::__1::atomic_fetch_add"
      or
      s = "atomic_compare_exchange_strong_explicit" and
      result = "std::__1::atomic_compare_exchange_strong_explicit"
      or
      s = "atomic_compare_exchange_weak_explicit" and
      result = "std::__1::atomic_compare_exchange_weak_explicit"
      or
      s = "atomic_compare_exchange_strong" and result = "std::__1::atomic_compare_exchange_strong"
      or
      s = "atomic_compare_exchange_weak" and result = "std::__1::atomic_compare_exchange_weak"
      or
      s = "atomic_exchange_explicit" and result = "std::__1::atomic_exchange_explicit"
      or
      s = "atomic_exchange" and result = "std::__1::atomic_exchange"
      or
      s = "atomic_load_explicit" and result = "std::__1::atomic_load_explicit"
      or
      s = "atomic_load" and result = "std::__1::atomic_load"
      or
      s = "atomic_store_explicit" and result = "std::__1::atomic_store_explicit"
      or
      s = "atomic_store" and result = "std::__1::atomic_store"
      or
      s = "atomic_init" and result = "std::__1::atomic_init"
      or
      s = "atomic_is_lock_free" and result = "std::__1::atomic_is_lock_free"
      or
      s = "kill_dependency" and result = "std::__1::kill_dependency"
      or
      s = "align" and result = "std::__1::align"
      or
      s = "undeclare_reachable" and result = "std::__1::undeclare_reachable"
      or
      s = "undeclare_no_pointers" and result = "std::__1::undeclare_no_pointers"
      or
      s = "declare_no_pointers" and result = "std::__1::declare_no_pointers"
      or
      s = "declare_reachable" and result = "std::__1::declare_reachable"
      or
      s = "get_pointer_safety" and result = "std::__1::get_pointer_safety"
      or
      s = "get_deleter" and result = "std::__1::get_deleter"
      or
      s = "const_pointer_cast" and result = "std::__1::const_pointer_cast"
      or
      s = "dynamic_pointer_cast" and result = "std::__1::dynamic_pointer_cast"
      or
      s = "static_pointer_cast" and result = "std::__1::static_pointer_cast"
      or
      s = "allocate_shared" and result = "std::__1::allocate_shared"
      or
      s = "make_shared" and result = "std::__1::make_shared"
      or
      s = "uninitialized_fill_n" and result = "std::__1::uninitialized_fill_n"
      or
      s = "uninitialized_fill" and result = "std::__1::uninitialized_fill"
      or
      s = "uninitialized_copy_n" and result = "std::__1::uninitialized_copy_n"
      or
      s = "uninitialized_copy" and result = "std::__1::uninitialized_copy"
      or
      s = "make_unique" and result = "std::__1::make_unique"
      or
      s = "return_temporary_buffer" and result = "std::__1::return_temporary_buffer"
      or
      s = "get_temporary_buffer" and result = "std::__1::get_temporary_buffer"
      or
      s = "lock" and result = "std::__1::lock"
      or
      s = "unique" and result = "std::__1::unique"
      or
      s = "bind" and result = "std::__1::bind"
      or
      s = "mem_fn" and result = "std::__1::mem_fn"
      or
      s = "mem_fun_ref" and result = "std::__1::mem_fun_ref"
      or
      s = "mem_fun" and result = "std::__1::mem_fun"
      or
      s = "ptr_fun" and result = "std::__1::ptr_fun"
      or
      s = "bind2nd" and result = "std::__1::bind2nd"
      or
      s = "bind1st" and result = "std::__1::bind1st"
      or
      s = "not2" and result = "std::__1::not2"
      or
      s = "not1" and result = "std::__1::not1"
      or
      s = "prev_permutation" and result = "std::__1::prev_permutation"
      or
      s = "next_permutation" and result = "std::__1::next_permutation"
      or
      s = "lexicographical_compare" and result = "std::__1::lexicographical_compare"
      or
      s = "set_symmetric_difference" and result = "std::__1::set_symmetric_difference"
      or
      s = "set_difference" and result = "std::__1::set_difference"
      or
      s = "set_intersection" and result = "std::__1::set_intersection"
      or
      s = "set_union" and result = "std::__1::set_union"
      or
      s = "includes" and result = "std::__1::includes"
      or
      s = "nth_element" and result = "std::__1::nth_element"
      or
      s = "partial_sort_copy" and result = "std::__1::partial_sort_copy"
      or
      s = "partial_sort" and result = "std::__1::partial_sort"
      or
      s = "sort_heap" and result = "std::__1::sort_heap"
      or
      s = "make_heap" and result = "std::__1::make_heap"
      or
      s = "pop_heap" and result = "std::__1::pop_heap"
      or
      s = "push_heap" and result = "std::__1::push_heap"
      or
      s = "is_heap" and result = "std::__1::is_heap"
      or
      s = "is_heap_until" and result = "std::__1::is_heap_until"
      or
      s = "stable_sort" and result = "std::__1::stable_sort"
      or
      s = "inplace_merge" and result = "std::__1::inplace_merge"
      or
      s = "merge" and result = "std::__1::merge"
      or
      s = "binary_search" and result = "std::__1::binary_search"
      or
      s = "equal_range" and result = "std::__1::equal_range"
      or
      s = "upper_bound" and result = "std::__1::upper_bound"
      or
      s = "lower_bound" and result = "std::__1::lower_bound"
      or
      s = "sort" and result = "std::__1::sort"
      or
      s = "is_sorted" and result = "std::__1::is_sorted"
      or
      s = "is_sorted_until" and result = "std::__1::is_sorted_until"
      or
      s = "stable_partition" and result = "std::__1::stable_partition"
      or
      s = "partition_point" and result = "std::__1::partition_point"
      or
      s = "partition_copy" and result = "std::__1::partition_copy"
      or
      s = "partition" and result = "std::__1::partition"
      or
      s = "is_partitioned" and result = "std::__1::is_partitioned"
      or
      s = "shuffle" and result = "std::__1::shuffle"
      or
      s = "random_shuffle" and result = "std::__1::random_shuffle"
      or
      s = "minmax" and result = "std::__1::minmax"
      or
      s = "minmax_element" and result = "std::__1::minmax_element"
      or
      s = "max_element" and result = "std::__1::max_element"
      or
      s = "min_element" and result = "std::__1::min_element"
      or
      s = "rotate_copy" and result = "std::__1::rotate_copy"
      or
      s = "rotate" and result = "std::__1::rotate"
      or
      s = "reverse_copy" and result = "std::__1::reverse_copy"
      or
      s = "reverse" and result = "std::__1::reverse"
      or
      s = "unique_copy" and result = "std::__1::unique_copy"
      or
      s = "remove_copy_if" and result = "std::__1::remove_copy_if"
      or
      s = "remove_copy" and result = "std::__1::remove_copy"
      or
      s = "remove_if" and result = "std::__1::remove_if"
      or
      s = "generate_n" and result = "std::__1::generate_n"
      or
      s = "generate" and result = "std::__1::generate"
      or
      s = "fill" and result = "std::__1::fill"
      or
      s = "fill_n" and result = "std::__1::fill_n"
      or
      s = "replace_copy_if" and result = "std::__1::replace_copy_if"
      or
      s = "replace_copy" and result = "std::__1::replace_copy"
      or
      s = "replace_if" and result = "std::__1::replace_if"
      or
      s = "replace" and result = "std::__1::replace"
      or
      s = "transform" and result = "std::__1::transform"
      or
      s = "copy_n" and result = "std::__1::copy_n"
      or
      s = "copy_if" and result = "std::__1::copy_if"
      or
      s = "search_n" and result = "std::__1::search_n"
      or
      s = "search" and result = "std::__1::search"
      or
      s = "is_permutation" and result = "std::__1::is_permutation"
      or
      s = "mismatch" and result = "std::__1::mismatch"
      or
      s = "count_if" and result = "std::__1::count_if"
      or
      s = "count" and result = "std::__1::count"
      or
      s = "adjacent_find" and result = "std::__1::adjacent_find"
      or
      s = "find_first_of" and result = "std::__1::find_first_of"
      or
      s = "find_end" and result = "std::__1::find_end"
      or
      s = "find_if_not" and result = "std::__1::find_if_not"
      or
      s = "find_if" and result = "std::__1::find_if"
      or
      s = "find" and result = "std::__1::find"
      or
      s = "for_each" and result = "std::__1::for_each"
      or
      s = "none_of" and result = "std::__1::none_of"
      or
      s = "any_of" and result = "std::__1::any_of"
      or
      s = "all_of" and result = "std::__1::all_of"
      or
      s = "nextwctype" and result = "nextwctype"
      or
      s = "iswspecial" and result = "iswspecial"
      or
      s = "iswrune" and result = "iswrune"
      or
      s = "iswphonogram" and result = "iswphonogram"
      or
      s = "iswnumber" and result = "iswnumber"
      or
      s = "iswideogram" and result = "iswideogram"
      or
      s = "iswhexnumber" and result = "iswhexnumber"
      or
      s = "iswascii" and result = "iswascii"
      or
      s = "wctrans" and result = "wctrans"
      or
      s = "towctrans" and result = "towctrans"
      or
      s = "iswblank" and result = "iswblank"
      or
      s = "to_wstring" and result = "std::__1::to_wstring"
      or
      s = "stold" and result = "std::__1::stold"
      or
      s = "stod" and result = "std::__1::stod"
      or
      s = "stof" and result = "std::__1::stof"
      or
      s = "stoull" and result = "std::__1::stoull"
      or
      s = "stoll" and result = "std::__1::stoll"
      or
      s = "stoul" and result = "std::__1::stoul"
      or
      s = "stol" and result = "std::__1::stol"
      or
      s = "stoi" and result = "std::__1::stoi"
      or
      s = "to_string" and result = "std::__1::to_string"
      or
      s = "significand" and result = "significand"
      or
      s = "gamma" and result = "gamma"
      or
      s = "finite" and result = "finite"
      or
      s = "drem" and result = "drem"
      or
      s = "roundtol" and result = "roundtol"
      or
      s = "rinttol" and result = "rinttol"
      or
      s = "scalb" and result = "scalb"
      or
      s = "yn" and result = "yn"
      or
      s = "y1" and result = "y1"
      or
      s = "y0" and result = "y0"
      or
      s = "jn" and result = "jn"
      or
      s = "j1" and result = "j1"
      or
      s = "j0" and result = "j0"
      or
      s = "truncl" and result = "truncl"
      or
      s = "tgammal" and result = "tgammal"
      or
      s = "scalbnl" and result = "scalbnl"
      or
      s = "scalblnl" and result = "scalblnl"
      or
      s = "roundl" and result = "roundl"
      or
      s = "rintl" and result = "rintl"
      or
      s = "remquol" and result = "remquol"
      or
      s = "remainderl" and result = "remainderl"
      or
      s = "nexttowardl" and result = "nexttowardl"
      or
      s = "nextafterl" and result = "nextafterl"
      or
      s = "nearbyintl" and result = "nearbyintl"
      or
      s = "nanl" and result = "nanl"
      or
      s = "lroundl" and result = "lroundl"
      or
      s = "lrintl" and result = "lrintl"
      or
      s = "logbl" and result = "logbl"
      or
      s = "log2l" and result = "log2l"
      or
      s = "log1pl" and result = "log1pl"
      or
      s = "llroundl" and result = "llroundl"
      or
      s = "llrintl" and result = "llrintl"
      or
      s = "lgammal" and result = "lgammal"
      or
      s = "ilogbl" and result = "ilogbl"
      or
      s = "hypotl" and result = "hypotl"
      or
      s = "fminl" and result = "fminl"
      or
      s = "fmaxl" and result = "fmaxl"
      or
      s = "fmal" and result = "fmal"
      or
      s = "fdiml" and result = "fdiml"
      or
      s = "expm1l" and result = "expm1l"
      or
      s = "exp2l" and result = "exp2l"
      or
      s = "erfcl" and result = "erfcl"
      or
      s = "erfl" and result = "erfl"
      or
      s = "copysignl" and result = "copysignl"
      or
      s = "cbrtl" and result = "cbrtl"
      or
      s = "atanhl" and result = "atanhl"
      or
      s = "asinhl" and result = "asinhl"
      or
      s = "acoshl" and result = "acoshl"
      or
      s = "tanhl" and result = "tanhl"
      or
      s = "tanl" and result = "tanl"
      or
      s = "sqrtl" and result = "sqrtl"
      or
      s = "sinhl" and result = "sinhl"
      or
      s = "sinl" and result = "sinl"
      or
      s = "powl" and result = "powl"
      or
      s = "modfl" and result = "modfl"
      or
      s = "log10l" and result = "log10l"
      or
      s = "logl" and result = "logl"
      or
      s = "ldexpl" and result = "ldexpl"
      or
      s = "frexpl" and result = "frexpl"
      or
      s = "fmodl" and result = "fmodl"
      or
      s = "floorl" and result = "floorl"
      or
      s = "fabsl" and result = "fabsl"
      or
      s = "expl" and result = "expl"
      or
      s = "coshl" and result = "coshl"
      or
      s = "cosl" and result = "cosl"
      or
      s = "ceill" and result = "ceill"
      or
      s = "atan2l" and result = "atan2l"
      or
      s = "atanl" and result = "atanl"
      or
      s = "asinl" and result = "asinl"
      or
      s = "acosl" and result = "acosl"
      or
      s = "truncf" and result = "truncf"
      or
      s = "trunc" and result = "trunc"
      or
      s = "tgammaf" and result = "tgammaf"
      or
      s = "tgamma" and result = "tgamma"
      or
      s = "scalbnf" and result = "scalbnf"
      or
      s = "scalbn" and result = "scalbn"
      or
      s = "scalblnf" and result = "scalblnf"
      or
      s = "scalbln" and result = "scalbln"
      or
      s = "roundf" and result = "roundf"
      or
      s = "round" and result = "round"
      or
      s = "rintf" and result = "rintf"
      or
      s = "rint" and result = "rint"
      or
      s = "remquof" and result = "remquof"
      or
      s = "remquo" and result = "remquo"
      or
      s = "remainderf" and result = "remainderf"
      or
      s = "remainder" and result = "remainder"
      or
      s = "nexttowardf" and result = "nexttowardf"
      or
      s = "nexttoward" and result = "nexttoward"
      or
      s = "nextafterf" and result = "nextafterf"
      or
      s = "nextafter" and result = "nextafter"
      or
      s = "nearbyintf" and result = "nearbyintf"
      or
      s = "nearbyint" and result = "nearbyint"
      or
      s = "nanf" and result = "nanf"
      or
      s = "nan" and result = "nan"
      or
      s = "lroundf" and result = "lroundf"
      or
      s = "lround" and result = "lround"
      or
      s = "lrintf" and result = "lrintf"
      or
      s = "lrint" and result = "lrint"
      or
      s = "logbf" and result = "logbf"
      or
      s = "logb" and result = "logb"
      or
      s = "log2f" and result = "log2f"
      or
      s = "log2" and result = "log2"
      or
      s = "log1pf" and result = "log1pf"
      or
      s = "log1p" and result = "log1p"
      or
      s = "llroundf" and result = "llroundf"
      or
      s = "llround" and result = "llround"
      or
      s = "llrintf" and result = "llrintf"
      or
      s = "llrint" and result = "llrint"
      or
      s = "lgammaf" and result = "lgammaf"
      or
      s = "lgamma" and result = "lgamma"
      or
      s = "ilogbf" and result = "ilogbf"
      or
      s = "ilogb" and result = "ilogb"
      or
      s = "hypotf" and result = "hypotf"
      or
      s = "hypot" and result = "hypot"
      or
      s = "fminf" and result = "fminf"
      or
      s = "fmin" and result = "fmin"
      or
      s = "fmaxf" and result = "fmaxf"
      or
      s = "fmax" and result = "fmax"
      or
      s = "fma" and result = "fma"
      or
      s = "fmaf" and result = "fmaf"
      or
      s = "fdimf" and result = "fdimf"
      or
      s = "fdim" and result = "fdim"
      or
      s = "expm1f" and result = "expm1f"
      or
      s = "expm1" and result = "expm1"
      or
      s = "exp2f" and result = "exp2f"
      or
      s = "exp2" and result = "exp2"
      or
      s = "erfcf" and result = "erfcf"
      or
      s = "erfc" and result = "erfc"
      or
      s = "erff" and result = "erff"
      or
      s = "erf" and result = "erf"
      or
      s = "copysignf" and result = "copysignf"
      or
      s = "copysign" and result = "copysign"
      or
      s = "cbrtf" and result = "cbrtf"
      or
      s = "cbrt" and result = "cbrt"
      or
      s = "atanhf" and result = "atanhf"
      or
      s = "atanh" and result = "atanh"
      or
      s = "atanh" and result = "std::__1::atanh"
      or
      s = "asinhf" and result = "asinhf"
      or
      s = "asinh" and result = "asinh"
      or
      s = "asinh" and result = "std::__1::asinh"
      or
      s = "acoshf" and result = "acoshf"
      or
      s = "acosh" and result = "acosh"
      or
      s = "acosh" and result = "std::__1::acosh"
      or
      s = "tanhf" and result = "tanhf"
      or
      s = "tanh" and result = "tanh"
      or
      s = "tanh" and result = "std::__1::tanh"
      or
      s = "tanf" and result = "tanf"
      or
      s = "tan" and result = "tan"
      or
      s = "tan" and result = "std::__1::tan"
      or
      s = "sqrtf" and result = "sqrtf"
      or
      s = "sqrt" and result = "sqrt"
      or
      s = "sqrt" and result = "std::__1::sqrt"
      or
      s = "sinhf" and result = "sinhf"
      or
      s = "sinh" and result = "sinh"
      or
      s = "sinh" and result = "std::__1::sinh"
      or
      s = "sinf" and result = "sinf"
      or
      s = "sin" and result = "sin"
      or
      s = "sin" and result = "std::__1::sin"
      or
      s = "powf" and result = "powf"
      or
      s = "pow" and result = "pow"
      or
      s = "pow" and result = "std::__1::pow"
      or
      s = "modff" and result = "modff"
      or
      s = "modf" and result = "modf"
      or
      s = "log10f" and result = "log10f"
      or
      s = "log10" and result = "log10"
      or
      s = "log10" and result = "std::__1::log10"
      or
      s = "logf" and result = "logf"
      or
      s = "log" and result = "log"
      or
      s = "log" and result = "std::__1::log"
      or
      s = "ldexpf" and result = "ldexpf"
      or
      s = "ldexp" and result = "ldexp"
      or
      s = "frexpf" and result = "frexpf"
      or
      s = "frexp" and result = "frexp"
      or
      s = "fmodf" and result = "fmodf"
      or
      s = "fmod" and result = "fmod"
      or
      s = "floorf" and result = "floorf"
      or
      s = "floor" and result = "floor"
      or
      s = "fabsf" and result = "fabsf"
      or
      s = "fabs" and result = "fabs"
      or
      s = "expf" and result = "expf"
      or
      s = "exp" and result = "exp"
      or
      s = "exp" and result = "std::__1::exp"
      or
      s = "coshf" and result = "coshf"
      or
      s = "cosh" and result = "cosh"
      or
      s = "cosh" and result = "std::__1::cosh"
      or
      s = "cosf" and result = "cosf"
      or
      s = "cos" and result = "cos"
      or
      s = "cos" and result = "std::__1::cos"
      or
      s = "ceilf" and result = "ceilf"
      or
      s = "ceil" and result = "ceil"
      or
      s = "atan2f" and result = "atan2f"
      or
      s = "atan2" and result = "atan2"
      or
      s = "atan2" and result = "std::__1::atan2"
      or
      s = "atanf" and result = "atanf"
      or
      s = "atan" and result = "atan"
      or
      s = "atan" and result = "std::__1::atan"
      or
      s = "asinf" and result = "asinf"
      or
      s = "asin" and result = "asin"
      or
      s = "asin" and result = "std::__1::asin"
      or
      s = "acosf" and result = "acosf"
      or
      s = "acos" and result = "acos"
      or
      s = "acos" and result = "std::__1::acos"
      or
      s = "isunordered" and result = "isunordered"
      or
      s = "islessgreater" and result = "islessgreater"
      or
      s = "islessequal" and result = "islessequal"
      or
      s = "isless" and result = "isless"
      or
      s = "isgreaterequal" and result = "isgreaterequal"
      or
      s = "isgreater" and result = "isgreater"
      or
      s = "isnormal" and result = "isnormal"
      or
      s = "isnan" and result = "isnan"
      or
      s = "isinf" and result = "isinf"
      or
      s = "isfinite" and result = "isfinite"
      or
      s = "fpclassify" and result = "fpclassify"
      or
      s = "signbit" and result = "signbit"
      or
      s = "make_error_code" and result = "std::__1::make_error_code"
      or
      s = "make_error_condition" and result = "std::__1::make_error_condition"
      or
      s = "system_category" and result = "std::__1::system_category"
      or
      s = "generic_category" and result = "std::__1::generic_category"
      or
      s = "sched_get_priority_max" and result = "sched_get_priority_max"
      or
      s = "sched_get_priority_min" and result = "sched_get_priority_min"
      or
      s = "sched_yield" and result = "sched_yield"
      or
      s = "qos_class_main" and result = "qos_class_main"
      or
      s = "qos_class_self" and result = "qos_class_self"
      or
      s = "pthread_override_qos_class_end_np" and result = "pthread_override_qos_class_end_np"
      or
      s = "pthread_override_qos_class_start_np" and result = "pthread_override_qos_class_start_np"
      or
      s = "pthread_get_qos_class_np" and result = "pthread_get_qos_class_np"
      or
      s = "pthread_set_qos_class_self_np" and result = "pthread_set_qos_class_self_np"
      or
      s = "pthread_attr_get_qos_class_np" and result = "pthread_attr_get_qos_class_np"
      or
      s = "pthread_attr_set_qos_class_np" and result = "pthread_attr_set_qos_class_np"
      or
      s = "pthread_yield_np" and result = "pthread_yield_np"
      or
      s = "pthread_from_mach_thread_np" and result = "pthread_from_mach_thread_np"
      or
      s = "pthread_create_suspended_np" and result = "pthread_create_suspended_np"
      or
      s = "pthread_cond_timedwait_relative_np" and result = "pthread_cond_timedwait_relative_np"
      or
      s = "pthread_cond_signal_thread_np" and result = "pthread_cond_signal_thread_np"
      or
      s = "pthread_get_stackaddr_np" and result = "pthread_get_stackaddr_np"
      or
      s = "pthread_get_stacksize_np" and result = "pthread_get_stacksize_np"
      or
      s = "pthread_mach_thread_np" and result = "pthread_mach_thread_np"
      or
      s = "pthread_main_np" and result = "pthread_main_np"
      or
      s = "pthread_setname_np" and result = "pthread_setname_np"
      or
      s = "pthread_getname_np" and result = "pthread_getname_np"
      or
      s = "pthread_threadid_np" and result = "pthread_threadid_np"
      or
      s = "pthread_is_threaded_np" and result = "pthread_is_threaded_np"
      or
      s = "pthread_testcancel" and result = "pthread_testcancel"
      or
      s = "pthread_setspecific" and result = "pthread_setspecific"
      or
      s = "pthread_setschedparam" and result = "pthread_setschedparam"
      or
      s = "pthread_setconcurrency" and result = "pthread_setconcurrency"
      or
      s = "pthread_setcanceltype" and result = "pthread_setcanceltype"
      or
      s = "pthread_setcancelstate" and result = "pthread_setcancelstate"
      or
      s = "pthread_self" and result = "pthread_self"
      or
      s = "pthread_rwlockattr_setpshared" and result = "pthread_rwlockattr_setpshared"
      or
      s = "pthread_rwlockattr_init" and result = "pthread_rwlockattr_init"
      or
      s = "pthread_rwlockattr_getpshared" and result = "pthread_rwlockattr_getpshared"
      or
      s = "pthread_rwlockattr_destroy" and result = "pthread_rwlockattr_destroy"
      or
      s = "pthread_rwlock_unlock" and result = "pthread_rwlock_unlock"
      or
      s = "pthread_rwlock_wrlock" and result = "pthread_rwlock_wrlock"
      or
      s = "pthread_rwlock_trywrlock" and result = "pthread_rwlock_trywrlock"
      or
      s = "pthread_rwlock_tryrdlock" and result = "pthread_rwlock_tryrdlock"
      or
      s = "pthread_rwlock_rdlock" and result = "pthread_rwlock_rdlock"
      or
      s = "pthread_rwlock_init" and result = "pthread_rwlock_init"
      or
      s = "pthread_rwlock_destroy" and result = "pthread_rwlock_destroy"
      or
      s = "pthread_once" and result = "pthread_once"
      or
      s = "pthread_mutexattr_setpolicy_np" and result = "pthread_mutexattr_setpolicy_np"
      or
      s = "pthread_mutexattr_settype" and result = "pthread_mutexattr_settype"
      or
      s = "pthread_mutexattr_setpshared" and result = "pthread_mutexattr_setpshared"
      or
      s = "pthread_mutexattr_setprotocol" and result = "pthread_mutexattr_setprotocol"
      or
      s = "pthread_mutexattr_setprioceiling" and result = "pthread_mutexattr_setprioceiling"
      or
      s = "pthread_mutexattr_init" and result = "pthread_mutexattr_init"
      or
      s = "pthread_mutexattr_getpolicy_np" and result = "pthread_mutexattr_getpolicy_np"
      or
      s = "pthread_mutexattr_gettype" and result = "pthread_mutexattr_gettype"
      or
      s = "pthread_mutexattr_getpshared" and result = "pthread_mutexattr_getpshared"
      or
      s = "pthread_mutexattr_getprotocol" and result = "pthread_mutexattr_getprotocol"
      or
      s = "pthread_mutexattr_getprioceiling" and result = "pthread_mutexattr_getprioceiling"
      or
      s = "pthread_mutexattr_destroy" and result = "pthread_mutexattr_destroy"
      or
      s = "pthread_mutex_unlock" and result = "pthread_mutex_unlock"
      or
      s = "pthread_mutex_trylock" and result = "pthread_mutex_trylock"
      or
      s = "pthread_mutex_setprioceiling" and result = "pthread_mutex_setprioceiling"
      or
      s = "pthread_mutex_lock" and result = "pthread_mutex_lock"
      or
      s = "pthread_mutex_init" and result = "pthread_mutex_init"
      or
      s = "pthread_mutex_getprioceiling" and result = "pthread_mutex_getprioceiling"
      or
      s = "pthread_mutex_destroy" and result = "pthread_mutex_destroy"
      or
      s = "pthread_key_delete" and result = "pthread_key_delete"
      or
      s = "pthread_key_create" and result = "pthread_key_create"
      or
      s = "pthread_join" and result = "pthread_join"
      or
      s = "pthread_getspecific" and result = "pthread_getspecific"
      or
      s = "pthread_getschedparam" and result = "pthread_getschedparam"
      or
      s = "pthread_getconcurrency" and result = "pthread_getconcurrency"
      or
      s = "pthread_exit" and result = "pthread_exit"
      or
      s = "pthread_equal" and result = "pthread_equal"
      or
      s = "pthread_detach" and result = "pthread_detach"
      or
      s = "pthread_create" and result = "pthread_create"
      or
      s = "pthread_condattr_setpshared" and result = "pthread_condattr_setpshared"
      or
      s = "pthread_condattr_getpshared" and result = "pthread_condattr_getpshared"
      or
      s = "pthread_condattr_init" and result = "pthread_condattr_init"
      or
      s = "pthread_condattr_destroy" and result = "pthread_condattr_destroy"
      or
      s = "pthread_cond_wait" and result = "pthread_cond_wait"
      or
      s = "pthread_cond_timedwait" and result = "pthread_cond_timedwait"
      or
      s = "pthread_cond_signal" and result = "pthread_cond_signal"
      or
      s = "pthread_cond_init" and result = "pthread_cond_init"
      or
      s = "pthread_cond_destroy" and result = "pthread_cond_destroy"
      or
      s = "pthread_cond_broadcast" and result = "pthread_cond_broadcast"
      or
      s = "pthread_cancel" and result = "pthread_cancel"
      or
      s = "pthread_attr_setstacksize" and result = "pthread_attr_setstacksize"
      or
      s = "pthread_attr_setstackaddr" and result = "pthread_attr_setstackaddr"
      or
      s = "pthread_attr_setstack" and result = "pthread_attr_setstack"
      or
      s = "pthread_attr_setscope" and result = "pthread_attr_setscope"
      or
      s = "pthread_attr_setschedpolicy" and result = "pthread_attr_setschedpolicy"
      or
      s = "pthread_attr_setschedparam" and result = "pthread_attr_setschedparam"
      or
      s = "pthread_attr_setinheritsched" and result = "pthread_attr_setinheritsched"
      or
      s = "pthread_attr_setguardsize" and result = "pthread_attr_setguardsize"
      or
      s = "pthread_attr_setdetachstate" and result = "pthread_attr_setdetachstate"
      or
      s = "pthread_attr_init" and result = "pthread_attr_init"
      or
      s = "pthread_attr_getstacksize" and result = "pthread_attr_getstacksize"
      or
      s = "pthread_attr_getstackaddr" and result = "pthread_attr_getstackaddr"
      or
      s = "pthread_attr_getstack" and result = "pthread_attr_getstack"
      or
      s = "pthread_attr_getscope" and result = "pthread_attr_getscope"
      or
      s = "pthread_attr_getschedpolicy" and result = "pthread_attr_getschedpolicy"
      or
      s = "pthread_attr_getschedparam" and result = "pthread_attr_getschedparam"
      or
      s = "pthread_attr_getinheritsched" and result = "pthread_attr_getinheritsched"
      or
      s = "pthread_attr_getguardsize" and result = "pthread_attr_getguardsize"
      or
      s = "pthread_attr_getdetachstate" and result = "pthread_attr_getdetachstate"
      or
      s = "pthread_attr_destroy" and result = "pthread_attr_destroy"
      or
      s = "pthread_atfork" and result = "pthread_atfork"
      or
      s = "pthread_sigmask" and result = "pthread_sigmask"
      or
      s = "pthread_kill" and result = "pthread_kill"
      or
      s = "try_lock" and result = "std::__1::try_lock"
      or
      s = "call_once" and result = "std::__1::call_once"
      or
      s = "localeconv" and result = "localeconv"
      or
      s = "setlocale" and result = "setlocale"
      or
      s = "toupper_l" and result = "toupper_l"
      or
      s = "tolower_l" and result = "tolower_l"
      or
      s = "isxdigit_l" and result = "isxdigit_l"
      or
      s = "isupper_l" and result = "isupper_l"
      or
      s = "isspecial_l" and result = "isspecial_l"
      or
      s = "isspace_l" and result = "isspace_l"
      or
      s = "isrune_l" and result = "isrune_l"
      or
      s = "ispunct_l" and result = "ispunct_l"
      or
      s = "isprint_l" and result = "isprint_l"
      or
      s = "isphonogram_l" and result = "isphonogram_l"
      or
      s = "isnumber_l" and result = "isnumber_l"
      or
      s = "islower_l" and result = "islower_l"
      or
      s = "isideogram_l" and result = "isideogram_l"
      or
      s = "ishexnumber_l" and result = "ishexnumber_l"
      or
      s = "isgraph_l" and result = "isgraph_l"
      or
      s = "isdigit_l" and result = "isdigit_l"
      or
      s = "iscntrl_l" and result = "iscntrl_l"
      or
      s = "isblank_l" and result = "isblank_l"
      or
      s = "isalpha_l" and result = "isalpha_l"
      or
      s = "isalnum_l" and result = "isalnum_l"
      or
      s = "digittoint_l" and result = "digittoint_l"
      or
      s = "wctype_l" and result = "wctype_l"
      or
      s = "towupper_l" and result = "towupper_l"
      or
      s = "towlower_l" and result = "towlower_l"
      or
      s = "iswxdigit_l" and result = "iswxdigit_l"
      or
      s = "iswupper_l" and result = "iswupper_l"
      or
      s = "iswspace_l" and result = "iswspace_l"
      or
      s = "iswpunct_l" and result = "iswpunct_l"
      or
      s = "iswprint_l" and result = "iswprint_l"
      or
      s = "iswlower_l" and result = "iswlower_l"
      or
      s = "iswgraph_l" and result = "iswgraph_l"
      or
      s = "iswdigit_l" and result = "iswdigit_l"
      or
      s = "iswctype_l" and result = "iswctype_l"
      or
      s = "iswcntrl_l" and result = "iswcntrl_l"
      or
      s = "iswalpha_l" and result = "iswalpha_l"
      or
      s = "iswalnum_l" and result = "iswalnum_l"
      or
      s = "vasprintf_l" and result = "vasprintf_l"
      or
      s = "asprintf_l" and result = "asprintf_l"
      or
      s = "vdprintf_l" and result = "vdprintf_l"
      or
      s = "dprintf_l" and result = "dprintf_l"
      or
      s = "vsscanf_l" and result = "vsscanf_l"
      or
      s = "vsnprintf_l" and result = "vsnprintf_l"
      or
      s = "vscanf_l" and result = "vscanf_l"
      or
      s = "vfscanf_l" and result = "vfscanf_l"
      or
      s = "snprintf_l" and result = "snprintf_l"
      or
      s = "vsprintf_l" and result = "vsprintf_l"
      or
      s = "vprintf_l" and result = "vprintf_l"
      or
      s = "vfprintf_l" and result = "vfprintf_l"
      or
      s = "sscanf_l" and result = "sscanf_l"
      or
      s = "sprintf_l" and result = "sprintf_l"
      or
      s = "scanf_l" and result = "scanf_l"
      or
      s = "printf_l" and result = "printf_l"
      or
      s = "fscanf_l" and result = "fscanf_l"
      or
      s = "fprintf_l" and result = "fprintf_l"
      or
      s = "wctomb_l" and result = "wctomb_l"
      or
      s = "wcstombs_l" and result = "wcstombs_l"
      or
      s = "strtouq_l" and result = "strtouq_l"
      or
      s = "strtoull_l" and result = "strtoull_l"
      or
      s = "strtoul_l" and result = "strtoul_l"
      or
      s = "strtoq_l" and result = "strtoq_l"
      or
      s = "strtoll_l" and result = "strtoll_l"
      or
      s = "strtold_l" and result = "strtold_l"
      or
      s = "strtol_l" and result = "strtol_l"
      or
      s = "strtof_l" and result = "strtof_l"
      or
      s = "strtod_l" and result = "strtod_l"
      or
      s = "mbtowc_l" and result = "mbtowc_l"
      or
      s = "mbstowcs_l" and result = "mbstowcs_l"
      or
      s = "mblen_l" and result = "mblen_l"
      or
      s = "atoll_l" and result = "atoll_l"
      or
      s = "atol_l" and result = "atol_l"
      or
      s = "atoi_l" and result = "atoi_l"
      or
      s = "atof_l" and result = "atof_l"
      or
      s = "strncasecmp_l" and result = "strncasecmp_l"
      or
      s = "strcasestr_l" and result = "strcasestr_l"
      or
      s = "strcasecmp_l" and result = "strcasecmp_l"
      or
      s = "strxfrm_l" and result = "strxfrm_l"
      or
      s = "strcoll_l" and result = "strcoll_l"
      or
      s = "strptime_l" and result = "strptime_l"
      or
      s = "strftime_l" and result = "strftime_l"
      or
      s = "fgetwln_l" and result = "fgetwln_l"
      or
      s = "wcsnrtombs_l" and result = "wcsnrtombs_l"
      or
      s = "wcsncasecmp_l" and result = "wcsncasecmp_l"
      or
      s = "wcscasecmp_l" and result = "wcscasecmp_l"
      or
      s = "mbsnrtowcs_l" and result = "mbsnrtowcs_l"
      or
      s = "wcstoull_l" and result = "wcstoull_l"
      or
      s = "wcstoll_l" and result = "wcstoll_l"
      or
      s = "wcstold_l" and result = "wcstold_l"
      or
      s = "wcstof_l" and result = "wcstof_l"
      or
      s = "vwscanf_l" and result = "vwscanf_l"
      or
      s = "vswscanf_l" and result = "vswscanf_l"
      or
      s = "vfwscanf_l" and result = "vfwscanf_l"
      or
      s = "wscanf_l" and result = "wscanf_l"
      or
      s = "wprintf_l" and result = "wprintf_l"
      or
      s = "wcwidth_l" and result = "wcwidth_l"
      or
      s = "wctob_l" and result = "wctob_l"
      or
      s = "wcsxfrm_l" and result = "wcsxfrm_l"
      or
      s = "wcswidth_l" and result = "wcswidth_l"
      or
      s = "wcstoul_l" and result = "wcstoul_l"
      or
      s = "wcstol_l" and result = "wcstol_l"
      or
      s = "wcstod_l" and result = "wcstod_l"
      or
      s = "wcsrtombs_l" and result = "wcsrtombs_l"
      or
      s = "wcsftime_l" and result = "wcsftime_l"
      or
      s = "wcscoll_l" and result = "wcscoll_l"
      or
      s = "wcrtomb_l" and result = "wcrtomb_l"
      or
      s = "vwprintf_l" and result = "vwprintf_l"
      or
      s = "vswprintf_l" and result = "vswprintf_l"
      or
      s = "vfwprintf_l" and result = "vfwprintf_l"
      or
      s = "ungetwc_l" and result = "ungetwc_l"
      or
      s = "swscanf_l" and result = "swscanf_l"
      or
      s = "swprintf_l" and result = "swprintf_l"
      or
      s = "putwchar_l" and result = "putwchar_l"
      or
      s = "putwc_l" and result = "putwc_l"
      or
      s = "mbsrtowcs_l" and result = "mbsrtowcs_l"
      or
      s = "mbsinit_l" and result = "mbsinit_l"
      or
      s = "mbrtowc_l" and result = "mbrtowc_l"
      or
      s = "mbrlen_l" and result = "mbrlen_l"
      or
      s = "getwchar_l" and result = "getwchar_l"
      or
      s = "getwc_l" and result = "getwc_l"
      or
      s = "fwscanf_l" and result = "fwscanf_l"
      or
      s = "fwprintf_l" and result = "fwprintf_l"
      or
      s = "fputws_l" and result = "fputws_l"
      or
      s = "fputwc_l" and result = "fputwc_l"
      or
      s = "fgetws_l" and result = "fgetws_l"
      or
      s = "fgetwc_l" and result = "fgetwc_l"
      or
      s = "btowc_l" and result = "btowc_l"
      or
      s = "wctrans_l" and result = "wctrans_l"
      or
      s = "towctrans_l" and result = "towctrans_l"
      or
      s = "nextwctype_l" and result = "nextwctype_l"
      or
      s = "iswspecial_l" and result = "iswspecial_l"
      or
      s = "iswrune_l" and result = "iswrune_l"
      or
      s = "iswphonogram_l" and result = "iswphonogram_l"
      or
      s = "iswnumber_l" and result = "iswnumber_l"
      or
      s = "iswideogram_l" and result = "iswideogram_l"
      or
      s = "iswhexnumber_l" and result = "iswhexnumber_l"
      or
      s = "iswblank_l" and result = "iswblank_l"
      or
      s = "uselocale" and result = "uselocale"
      or
      s = "querylocale" and result = "querylocale"
      or
      s = "newlocale" and result = "newlocale"
      or
      s = "localeconv_l" and result = "localeconv_l"
      or
      s = "freelocale" and result = "freelocale"
      or
      s = "duplocale" and result = "duplocale"
      or
      s = "use_facet" and result = "std::__1::use_facet"
      or
      s = "has_facet" and result = "std::__1::has_facet"
      or
      s = "defaultfloat" and result = "std::__1::defaultfloat"
      or
      s = "hexfloat" and result = "std::__1::hexfloat"
      or
      s = "scientific" and result = "std::__1::scientific"
      or
      s = "fixed" and result = "std::__1::fixed"
      or
      s = "oct" and result = "std::__1::oct"
      or
      s = "hex" and result = "std::__1::hex"
      or
      s = "dec" and result = "std::__1::dec"
      or
      s = "right" and result = "std::__1::right"
      or
      s = "left" and result = "std::__1::left"
      or
      s = "internal" and result = "std::__1::internal"
      or
      s = "nounitbuf" and result = "std::__1::nounitbuf"
      or
      s = "unitbuf" and result = "std::__1::unitbuf"
      or
      s = "nouppercase" and result = "std::__1::nouppercase"
      or
      s = "uppercase" and result = "std::__1::uppercase"
      or
      s = "noskipws" and result = "std::__1::noskipws"
      or
      s = "skipws" and result = "std::__1::skipws"
      or
      s = "noshowpos" and result = "std::__1::noshowpos"
      or
      s = "showpos" and result = "std::__1::showpos"
      or
      s = "noshowpoint" and result = "std::__1::noshowpoint"
      or
      s = "showpoint" and result = "std::__1::showpoint"
      or
      s = "noshowbase" and result = "std::__1::noshowbase"
      or
      s = "showbase" and result = "std::__1::showbase"
      or
      s = "noboolalpha" and result = "std::__1::noboolalpha"
      or
      s = "boolalpha" and result = "std::__1::boolalpha"
      or
      s = "iostream_category" and result = "std::__1::iostream_category"
      or
      s = "makedev" and result = "makedev"
      or
      s = "minor" and result = "minor"
      or
      s = "major" and result = "major"
      or
      s = "catclose" and result = "catclose"
      or
      s = "catgets" and result = "catgets"
      or
      s = "catopen" and result = "catopen"
      or
      s = "get_time" and result = "std::__1::get_time"
      or
      s = "flush" and result = "std::__1::flush"
      or
      s = "ends" and result = "std::__1::ends"
      or
      s = "endl" and result = "std::__1::endl"
      or
      s = "ws" and result = "std::__1::ws"
      or
      s = "polar" and result = "std::__1::polar"
      or
      s = "proj" and result = "std::__1::proj"
      or
      s = "conj" and result = "std::__1::conj"
      or
      s = "norm" and result = "std::__1::norm"
      or
      s = "arg" and result = "std::__1::arg"
      or
      s = "imag" and result = "std::__1::imag"
      or
      s = "real" and result = "std::__1::real"
      or
      s = "feupdateenv" and result = "feupdateenv"
      or
      s = "fesetenv" and result = "fesetenv"
      or
      s = "feholdexcept" and result = "feholdexcept"
      or
      s = "fegetenv" and result = "fegetenv"
      or
      s = "fesetround" and result = "fesetround"
      or
      s = "fegetround" and result = "fegetround"
      or
      s = "fetestexcept" and result = "fetestexcept"
      or
      s = "fesetexceptflag" and result = "fesetexceptflag"
      or
      s = "feraiseexcept" and result = "feraiseexcept"
      or
      s = "fegetexceptflag" and result = "fegetexceptflag"
      or
      s = "feclearexcept" and result = "feclearexcept"
      or
      s = "wcstoumax_l" and result = "wcstoumax_l"
      or
      s = "wcstoimax_l" and result = "wcstoimax_l"
      or
      s = "strtoumax_l" and result = "strtoumax_l"
      or
      s = "strtoimax_l" and result = "strtoimax_l"
      or
      s = "wcstoumax" and result = "wcstoumax"
      or
      s = "wcstoimax" and result = "wcstoimax"
      or
      s = "strtoumax" and result = "strtoumax"
      or
      s = "strtoimax" and result = "strtoimax"
      or
      s = "imaxdiv" and result = "imaxdiv"
      or
      s = "imaxabs" and result = "imaxabs"
      or
      s = "notify_all_at_thread_exit" and result = "std::__1::notify_all_at_thread_exit"
      or
      s = "setjmp" and result = "setjmp"
      or
      s = "longjmperror" and result = "longjmperror"
      or
      s = "siglongjmp" and result = "siglongjmp"
      or
      s = "sigsetjmp" and result = "sigsetjmp"
      or
      s = "longjmp" and result = "longjmp"
      or
      s = "sigsetmask" and result = "sigsetmask"
      or
      s = "sigblock" and result = "sigblock"
      or
      s = "psignal" and result = "psignal"
      or
      s = "sigwait" and result = "sigwait"
      or
      s = "sigsuspend" and result = "sigsuspend"
      or
      s = "sigset" and result = "sigset"
      or
      s = "sigrelse" and result = "sigrelse"
      or
      s = "sigprocmask" and result = "sigprocmask"
      or
      s = "sigpending" and result = "sigpending"
      or
      s = "sigpause" and result = "sigpause"
      or
      s = "sigismember" and result = "sigismember"
      or
      s = "siginterrupt" and result = "siginterrupt"
      or
      s = "sigignore" and result = "sigignore"
      or
      s = "sighold" and result = "sighold"
      or
      s = "sigfillset" and result = "sigfillset"
      or
      s = "sigemptyset" and result = "sigemptyset"
      or
      s = "sigdelset" and result = "sigdelset"
      or
      s = "sigaltstack" and result = "sigaltstack"
      or
      s = "sigaddset" and result = "sigaddset"
      or
      s = "killpg" and result = "killpg"
      or
      s = "kill" and result = "kill"
      or
      s = "bsd_signal" and result = "bsd_signal"
      or
      s = "raise" and result = "raise"
      or
      s = "quoted" and result = "std::__1::quoted"
      or
      s = "put_time" and result = "std::__1::put_time"
      or
      s = "put_money" and result = "std::__1::put_money"
      or
      s = "get_money" and result = "std::__1::get_money"
      or
      s = "setw" and result = "std::__1::setw"
      or
      s = "setprecision" and result = "std::__1::setprecision"
      or
      s = "setfill" and result = "std::__1::setfill"
      or
      s = "setbase" and result = "std::__1::setbase"
      or
      s = "setiosflags" and result = "std::__1::setiosflags"
      or
      s = "resetiosflags" and result = "std::__1::resetiosflags"
      or
      s = "async" and result = "std::__1::async"
      or
      s = "future_category" and result = "std::__1::future_category"
      or
      s = "iota" and result = "std::__1::iota"
      or
      s = "adjacent_difference" and result = "std::__1::adjacent_difference"
      or
      s = "partial_sum" and result = "std::__1::partial_sum"
      or
      s = "inner_product" and result = "std::__1::inner_product"
      or
      s = "accumulate" and result = "std::__1::accumulate"
      or
      s = "lgamma_r" and result = "std::__1::lgamma_r"
      or
      s = "generate_canonical" and result = "std::__1::generate_canonical"
      or
      s = "regex_replace" and result = "std::__1::regex_replace"
      or
      s = "regex_match" and result = "std::__1::regex_match"
      or
      s = "regex_search" and result = "std::__1::regex_search"
    }
  }
}
