#ifndef _GHLIBCPP_STDLIB
#define _GHLIBCPP_STDLIB

typedef unsigned long size_t;

void *calloc(size_t num, size_t size);
void free(void *ptr);
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);
void *aligned_alloc(size_t, size_t);

[[noreturn]] void _Exit(int status) noexcept;
[[noreturn]] void abort(void) noexcept;
[[noreturn]] void quick_exit(int status) noexcept;
extern "C++" int atexit(void (*f)(void)) noexcept;
extern "C++" int at_quick_exit(void (*f)(void)) noexcept;

void exit(int code);
int system(const char *command);

char *getenv(const char *name);

int setenv(const char *, const char *, int);

int atoi(const char *str);
long int atol(const char *str);
long long int atoll(const char *str);
double atof(const char *str);

long int strtol(const char *str, char **endptr, int base);
long long int strtoll(const char *str, char **endptr, int base);
unsigned long int strtoul(const char *str, char **endptr, int base);
unsigned long long int strtoull(const char *str, char **endptr, int base);
double strtod(const char *str, char **endptr);
float strtof(const char *str, char **endptr);
long double strtold(const char *str, char **endptr);

int rand(void);

#endif // _GHLIBCPP_STDLIB
