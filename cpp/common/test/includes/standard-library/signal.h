#ifndef _GHLIBCPP_SIGNAL
#define _GHLIBCPP_SIGNAL

typedef int sig_atomic_t;
void (*signal(int, void (*func)(int)))(int);
int raise(int);

#endif // _GHLIBCPP_SIGNAL