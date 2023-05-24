#ifndef _GHLIBCPP_STDLIB
#define _GHLIBCPP_STDLIB

typedef unsigned long size_t;

void *calloc(size_t num, size_t size);
void free(void *ptr);
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);

void abort();

void exit(int code);
int system(const char *command);

char *getenv(const char *name);

int atoi(const char *str);
long int atol(const char *str);
long long int atoll(const char *str);
double atof(const char *str);

int rand(void);

#endif // _GHLIBCPP_STDLIB