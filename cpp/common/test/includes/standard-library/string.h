#ifndef _GHLIBCPP_STRINGH
#define _GHLIBCPP_STRINGH

#include "errno.h"

typedef unsigned long size_t;

size_t strlen(const char *str);
char *strcpy(char *destination, const char *source);
char *strncpy(char *destination, const char *source, size_t num);

char *strcat(char *destination, const char *source);
char *strncat(char *destination, const char *source, size_t num);

int strcmp(const char *str1, const char *str2);
int strcoll(const char *str1, const char *str2);

int strncmp(const char *str1, const char *str2, size_t num);
size_t strxfrm(char *destination, const char *source, size_t num);

const char *strchr(const char *str, int character);
char *strchr(char *str, int character);

size_t strcspn(const char *str1, const char *str2);

const char *strpbrk(const char *str1, const char *str2);
char *strpbrk(char *str1, const char *str2);

const char *strrchr(const char *str, int character);
char *strrchr(char *str, int character);

size_t strspn(const char *str1, const char *str2);

const char *strstr(const char *str1, const char *str2);
char *strstr(char *str1, const char *str2);

char *strtok(char *str, const char *delimiters);
char *strerror(int errnum);

char *strdup(const char *);

void *memcpy(void *dest, const void *src, size_t count);
void *memset(void *dest, int ch, size_t count);
void *memmove(void *dest, const void *src, size_t count);
int memcmp(const void *lhs, const void *rhs, size_t count);

#endif // _GHLIBCPP_STRINGH