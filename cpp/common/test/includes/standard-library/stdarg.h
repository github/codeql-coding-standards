
typedef __builtin_va_list va_list;
#define va_arg(v, p) __builtin_va_arg(v, p)
#define va_end(v) __builtin_va_end(v)
#define va_start(v, l) __builtin_va_start(v, l)
#define va_copy(d, s) __builtin_va_copy(d, s)