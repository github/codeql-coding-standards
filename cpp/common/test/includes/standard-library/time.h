#ifndef _GHLIBCPP_TIME
#define _GHLIBCPP_TIME

typedef unsigned long clock_t;
typedef unsigned long time_t;

typedef unsigned long size_t;
struct tm {
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;
};

clock_t clock(void);
double difftime(clock_t end, clock_t beginning);
time_t mktime(struct tm *timeptr);
time_t time(time_t *timer);
char *asctime(const struct tm *timeptr);

char *ctime(const time_t *timer);
struct tm *gmtime(const time_t *timer);
struct tm *localtime(const time_t *timer);
size_t strftime(char *ptr, size_t maxsize, const char *format,
                const struct tm *timeptr);

#endif // _GHLIBCPP_TIME