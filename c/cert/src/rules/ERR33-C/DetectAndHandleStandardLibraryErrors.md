# ERR33-C: Detect and handle standard library errors

This query implements the CERT-C rule ERR33-C:

> Detect and handle standard library errors


## Description

The majority of the standard library functions, including I/O functions and memory allocation functions, return either a valid value or a value of the correct return type that indicates an error (for example, −1 or a null pointer). Assuming that all calls to such functions will succeed and failing to check the return value for an indication of an error is a dangerous practice that may lead to [unexpected](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-unexpectedbehavior) or [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) when an error occurs. It is essential that programs detect and appropriately handle all errors in accordance with an error-handling policy.

The successful completion or failure of each of the standard library functions listed in the following table shall be determined either by comparing the function’s return value with the value listed in the column labeled “Error Return” or by calling one of the library functions mentioned in the footnotes.

**Standard Library Functions**

<table> <tbody> <tr> <th> Function </th> <th> Successful Return </th> <th> Error Return </th> </tr> <tr> <td> <code>aligned_alloc()</code> </td> <td> Pointer to space </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>asctime_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>at_quick_exit()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>atexit()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>bsearch()</code> </td> <td> Pointer to matching element </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>bsearch_s()</code> </td> <td> Pointer to matching element </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>btowc()</code> </td> <td> Converted wide character </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>c16rtomb()</code> </td> <td> Number of bytes </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>c32rtomb()</code> </td> <td> Number of bytes </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>calloc()</code> </td> <td> Pointer to space </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>clock()</code> </td> <td> Processor time </td> <td> <code>(clock_t)(-1)</code> </td> </tr> <tr> <td> <code>cnd_broadcast()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>cnd_init()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_nomem</code> or <code>thrd_error</code> </td> </tr> <tr> <td> <code>cnd_signal()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>cnd_timedwait()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_timedout</code> or <code>thrd_error</code> </td> </tr> <tr> <td> <code>cnd_wait()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>ctime_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>fclose()</code> </td> <td> <code>0</code> </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fflush()</code> </td> <td> <code>0</code> </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fgetc()</code> </td> <td> Character read </td> <td> <code>EOF</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>fgetpos()</code> </td> <td> <code>0</code> </td> <td> Nonzero, <code>errno &gt; 0</code> </td> </tr> <tr> <td> <code>fgets()</code> </td> <td> Pointer to string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>fgetwc()</code> </td> <td> Wide character read </td> <td> <code>WEOF</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>fopen()</code> </td> <td> Pointer to stream </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>fopen_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>fprintf()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>fprintf_s()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>fputc()</code> </td> <td> Character written </td> <td> <code>EOF</code> <sup> 2 </sup> </td> </tr> <tr> <td> <code>fputs()</code> </td> <td> Nonnegative </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fputwc()</code> </td> <td> Wide character written </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>fputws()</code> </td> <td> Nonnegative </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fread()</code> </td> <td> Elements read </td> <td> Elements read </td> </tr> <tr> <td> <code>freopen()</code> </td> <td> Pointer to stream </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>freopen_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>fscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fseek()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>fsetpos()</code> </td> <td> <code>0</code> </td> <td> Nonzero, <code>errno &gt; 0</code> </td> </tr> <tr> <td> <code>ftell()</code> </td> <td> File position </td> <td> <code>−1L</code> , <code>errno &gt; 0</code> </td> </tr> <tr> <td> <code>fwprintf()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>fwprintf_s()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>fwrite()</code> </td> <td> Elements written </td> <td> Elements written </td> </tr> <tr> <td> <code>fwscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>fwscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>getc()</code> </td> <td> Character read </td> <td> <code>EOF</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>getchar()</code> </td> <td> Character read </td> <td> <code>EOF</code> <sup> 1 </sup> </td> </tr> <tr> <td> <code>getenv()</code> </td> <td> Pointer to string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>getenv_s()</code> </td> <td> Pointer to string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>gets_s()</code> </td> <td> Pointer to string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>getwc()</code> </td> <td> Wide character read </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>getwchar()</code> </td> <td> Wide character read </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>gmtime()</code> </td> <td> Pointer to broken-down time </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>gmtime_s()</code> </td> <td> Pointer to broken-down time </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>localtime()</code> </td> <td> Pointer to broken-down time </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>localtime_s()</code> </td> <td> Pointer to broken-down time </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>malloc()</code> </td> <td> Pointer to space </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>mblen(), s != NULL</code> </td> <td> Number of bytes </td> <td> <code>−1</code> </td> </tr> <tr> <td> <code>mbrlen(), s != NULL</code> </td> <td> Number of bytes or status </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>mbrtoc16()</code> </td> <td> Number of bytes or status </td> <td> <code>(size_t)(-1)</code> , <code>errno == EILSEQ</code> </td> </tr> <tr> <td> <code>mbrtoc32()</code> </td> <td> Number of bytes or status </td> <td> <code>(size_t)(-1)</code> , <code>errno == EILSEQ</code> </td> </tr> <tr> <td> <code>mbrtowc(), s != NULL</code> </td> <td> Number of bytes or status </td> <td> <code>(size_t)(-1)</code> , <code>errno == EILSEQ</code> </td> </tr> <tr> <td> <code>mbsrtowcs()</code> </td> <td> Number of non-null elements </td> <td> <code>(size_t)(-1)</code> , <code>errno == EILSEQ</code> </td> </tr> <tr> <td> <code>mbsrtowcs_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>mbstowcs()</code> </td> <td> Number of non-null elements </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>mbstowcs_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>mbtowc(), s != NULL</code> </td> <td> Number of bytes </td> <td> <code>−1</code> </td> </tr> <tr> <td> <code>memchr()</code> </td> <td> Pointer to located character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>mktime()</code> </td> <td> Calendar time </td> <td> <code>(time_t)(-1)</code> </td> </tr> <tr> <td> <code>mtx_init()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>mtx_lock()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>mtx_timedlock()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_timedout</code> or <code>thrd_error</code> </td> </tr> <tr> <td> <code>mtx_trylock()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_busy</code> or <code>thrd_error</code> </td> </tr> <tr> <td> <code>mtx_unlock()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>printf_s()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>putc()</code> </td> <td> Character written </td> <td> <code>EOF</code> <sup> 2 </sup> </td> </tr> <tr> <td> <code>putwc()</code> </td> <td> Wide character written </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>raise()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>realloc()</code> </td> <td> Pointer to space </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>remove()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>rename()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>setlocale()</code> </td> <td> Pointer to string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>setvbuf()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>scanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>scanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>signal()</code> </td> <td> Pointer to previous function </td> <td> <code>SIG_ERR</code> , <code>errno &gt; 0</code> </td> </tr> <tr> <td> <code>snprintf()</code> </td> <td> Number of characters that would be written (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>snprintf_s()</code> </td> <td> Number of characters that would be written (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>sprintf()</code> </td> <td> Number of non-null characters written </td> <td> Negative </td> </tr> <tr> <td> <code>sprintf_s()</code> </td> <td> Number of non-null characters written </td> <td> Negative </td> </tr> <tr> <td> <code>sscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>sscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>strchr()</code> </td> <td> Pointer to located character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strerror_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>strftime()</code> </td> <td> Number of non-null characters </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>strpbrk()</code> </td> <td> Pointer to located character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strrchr()</code> </td> <td> Pointer to located character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strstr()</code> </td> <td> Pointer to located string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strtod()</code> </td> <td> Converted value </td> <td> <code>0</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtof()</code> </td> <td> Converted value </td> <td> <code>0</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtoimax()</code> </td> <td> Converted value </td> <td> <code>INTMAX_MAX</code> or <code>INTMAX_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtok()</code> </td> <td> Pointer to first character of a token </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strtok_s()</code> </td> <td> Pointer to first character of a token </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>strtol()</code> </td> <td> Converted value </td> <td> <code>LONG_MAX</code> or <code>LONG_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtold()</code> </td> <td> Converted value </td> <td> <code>0, errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtoll()</code> </td> <td> Converted value </td> <td> <code>LLONG_MAX</code> or <code>LLONG_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtoumax()</code> </td> <td> Converted value </td> <td> <code>UINTMAX_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtoul()</code> </td> <td> Converted value </td> <td> <code>ULONG_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strtoull()</code> </td> <td> Converted value </td> <td> <code>ULLONG_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>strxfrm()</code> </td> <td> Length of transformed string </td> <td> <code>&gt;= n</code> </td> </tr> <tr> <td> <code>swprintf()</code> </td> <td> Number of non-null wide characters </td> <td> Negative </td> </tr> <tr> <td> <code>swprintf_s()</code> </td> <td> Number of non-null wide characters </td> <td> Negative </td> </tr> <tr> <td> <code>swscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>swscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>thrd_create()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_nomem</code> or <code>thrd_error</code> </td> </tr> <tr> <td> <code>thrd_detach()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>thrd_join()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>thrd_sleep()</code> </td> <td> <code>0</code> </td> <td> Negative </td> </tr> <tr> <td> <code>time()</code> </td> <td> Calendar time </td> <td> <code>(time_t)(-1)</code> </td> </tr> <tr> <td> <code>timespec_get()</code> </td> <td> Base </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>tmpfile()</code> </td> <td> Pointer to stream </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>tmpfile_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>tmpnam()</code> </td> <td> Non-null pointer </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>tmpnam_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>tss_create()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>tss_get()</code> </td> <td> Value of thread-specific storage </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>tss_set()</code> </td> <td> <code>thrd_success</code> </td> <td> <code>thrd_error</code> </td> </tr> <tr> <td> <code>ungetc()</code> </td> <td> Character pushed back </td> <td> <code>EOF</code> (see <a> below </a> ) </td> </tr> <tr> <td> <code>ungetwc()</code> </td> <td> Character pushed back </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>vfprintf()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vfprintf_s()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vfscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vfscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vfwprintf()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vfwprintf_s()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vfwscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vfwscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vprintf_s()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vsnprintf()</code> </td> <td> Number of characters that would be written (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vsnprintf_s()</code> </td> <td> Number of characters that would be written (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vsprintf()</code> </td> <td> Number of non-null characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vsprintf_s()</code> </td> <td> Number of non-null characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vsscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vsscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vswprintf()</code> </td> <td> Number of non-null wide characters </td> <td> Negative </td> </tr> <tr> <td> <code>vswprintf_s()</code> </td> <td> Number of non-null wide characters </td> <td> Negative </td> </tr> <tr> <td> <code>vswscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vswscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vwprintf_s()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>vwscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>vwscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>wcrtomb()</code> </td> <td> Number of bytes stored </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>wcschr()</code> </td> <td> Pointer to located wide character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcsftime()</code> </td> <td> Number of non-null wide characters </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>wcspbrk()</code> </td> <td> Pointer to located wide character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcsrchr()</code> </td> <td> Pointer to located wide character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcsrtombs()</code> </td> <td> Number of non-null bytes </td> <td> <code>(size_t)(-1)</code> , <code>errno == EILSEQ</code> </td> </tr> <tr> <td> <code>wcsrtombs_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>wcsstr()</code> </td> <td> Pointer to located wide string </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcstod()</code> </td> <td> Converted value </td> <td> <code>0</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstof()</code> </td> <td> Converted value </td> <td> <code>0</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstoimax()</code> </td> <td> Converted value </td> <td> <code>INTMAX_MAX</code> or <code>INTMAX_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstok()</code> </td> <td> Pointer to first wide character of a token </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcstok_s()</code> </td> <td> Pointer to first wide character of a token </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wcstol()</code> </td> <td> Converted value </td> <td> <code>LONG_MAX</code> or <code>LONG_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstold()</code> </td> <td> Converted value </td> <td> <code>0</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstoll()</code> </td> <td> Converted value </td> <td> <code>LLONG_MAX</code> or <code>LLONG_MIN</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstombs()</code> </td> <td> Number of non-null bytes </td> <td> <code>(size_t)(-1)</code> </td> </tr> <tr> <td> <code>wcstombs_s()</code> </td> <td> <code>0</code> </td> <td> Nonzero </td> </tr> <tr> <td> <code>wcstoumax()</code> </td> <td> Converted value </td> <td> <code>UINTMAX_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstoul()</code> </td> <td> Converted value </td> <td> <code>ULONG_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcstoull()</code> </td> <td> Converted value </td> <td> <code>ULLONG_MAX</code> , <code>errno == ERANGE</code> </td> </tr> <tr> <td> <code>wcsxfrm()</code> </td> <td> Length of transformed wide string </td> <td> <code>&gt;= n</code> </td> </tr> <tr> <td> <code>wctob()</code> </td> <td> Converted character </td> <td> <code>EOF</code> </td> </tr> <tr> <td> <code>wctomb(), s != NULL</code> </td> <td> Number of bytes stored </td> <td> <code>−1</code> </td> </tr> <tr> <td> <code>wctomb_s(), s != NULL</code> </td> <td> Number of bytes stored </td> <td> <code>−1</code> </td> </tr> <tr> <td> <code>wctrans()</code> </td> <td> Valid argument to <code> towctrans</code> </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>wctype()</code> </td> <td> Valid argument to <code> iswctype</code> </td> <td> <code>0</code> </td> </tr> <tr> <td> <code>wmemchr()</code> </td> <td> Pointer to located wide character </td> <td> <code>NULL</code> </td> </tr> <tr> <td> <code>wprintf_s()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>wscanf()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>wscanf_s()</code> </td> <td> Number of conversions (nonnegative) </td> <td> <code>EOF</code> (negative) </td> </tr> </tbody> </table>
Note: According to [FIO35-C](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152389)[. Use feof() and ferror() to detect end-of-file and file errors when sizeof(int) == sizeof(char)](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152389), callers should verify end-of-file and file errors for the functions in this table as follows:


<sup>1 </sup>By calling `ferror()` and `feof()`<sup>2 </sup>By calling `ferror()`

The `ungetc()` function does not set the error indicator even when it fails, so it is not possible to check for errors reliably unless it is known that the argument is not equal to `EOF`. The C Standard \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-ISO-IEC9899-2011)\] states that "one character of pushback is guaranteed," so this should not be an issue if, at most, one character is ever pushed back before reading again. (See [FIO13-C](https://wiki.sei.cmu.edu/confluence/display/c/FIO13-C.+Never+push+back+anything+other+than+one+read+character)[. Never push back anything other than one read character](https://wiki.sei.cmu.edu/confluence/display/c/FIO13-C.+Never+push+back+anything+other+than+one+read+character).)

## Noncompliant Code Example (setlocale())

In this noncompliant code example, the function `utf8_to_wcs()` attempts to convert a sequence of UTF-8 characters to wide characters. It first invokes `setlocale()` to set the global locale to the implementation-defined `en_US.UTF-8` but does not check for failure. The `setlocale()` function will fail by returning a null pointer, for example, when the locale is not installed. The function may fail for other reasons as well, such as the lack of resources. Depending on the sequence of characters pointed to by `utf8`, the subsequent call to `mbstowcs()` may fail or result in the function storing an unexpected sequence of wide characters in the supplied buffer `wcs`.

```cpp
#include <locale.h>
#include <stdlib.h>
 
int utf8_to_wcs(wchar_t *wcs, size_t n, const char *utf8,
                size_t *size) {
  if (NULL == size) {
    return -1;
  }
  setlocale(LC_CTYPE, "en_US.UTF-8");
  *size = mbstowcs(wcs, utf8, n);
  return 0;
}

```

## Compliant Solution (setlocale())

This compliant solution checks the value returned by `setlocale()` and avoids calling `mbstowcs()` if the function fails. The function also takes care to restore the locale to its initial setting before returning control to the caller.

```cpp
#include <locale.h>
#include <stdlib.h>
 
int utf8_to_wcs(wchar_t *wcs, size_t n, const char *utf8,
                size_t *size) {
  if (NULL == size) {
    return -1;
  }
  const char *save = setlocale(LC_CTYPE, "en_US.UTF-8");
  if (NULL == save) {
    return -1;
  }

  *size = mbstowcs(wcs, utf8, n);
  if (NULL == setlocale(LC_CTYPE, save)) {
    return -1;
  }
  return 0;
}

```

## Noncompliant Code Example (calloc())

In this noncompliant code example, `temp_num`,` tmp2`, and `num_of_records` are derived from a [tainted source](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-taintedsource). Consequently, an attacker can easily cause `calloc()` to fail by providing a large value for `num_of_records`.

```cpp
#include <stdlib.h>
#include <string.h>
 
enum { SIG_DESC_SIZE = 32 };

typedef struct {
  char sig_desc[SIG_DESC_SIZE];
} signal_info;
 
void func(size_t num_of_records, size_t temp_num,
          const char *tmp2, size_t tmp2_size_bytes) {
  signal_info *start = (signal_info *)calloc(num_of_records,
                                          sizeof(signal_info));

  if (tmp2 == NULL) {
    /* Handle error */
  } else if (temp_num > num_of_records) {
    /* Handle error */
  } else if (tmp2_size_bytes < SIG_DESC_SIZE) {
    /* Handle error */
  }

  signal_info *point = start + temp_num - 1;
  memcpy(point->sig_desc, tmp2, SIG_DESC_SIZE);
  point->sig_desc[SIG_DESC_SIZE - 1] = '\0';
  /* ... */
  free(start);
}
```
When `calloc()` fails, it returns a null pointer that is assigned to `start`. If `start` is null, an attacker can provide a value for `temp_num` that, when scaled by `sizeof(signal_info)`, references a writable address to which control is eventually transferred. The contents of the string referenced by `tmp2` can then be used to overwrite the address, resulting in an arbitrary code execution [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability).

## Compliant Solution (calloc())

To correct this error, ensure the pointer returned by `calloc()` is not null:

```cpp
#include <stdlib.h>
#include <string.h>

enum { SIG_DESC_SIZE = 32 };

typedef struct {
  char sig_desc[SIG_DESC_SIZE];
} signal_info;
 
void func(size_t num_of_records, size_t temp_num,
          const char *tmp2, size_t tmp2_size_bytes) {
  signal_info *start = (signal_info *)calloc(num_of_records,
                                           sizeof(signal_info));
  if (start == NULL) {
    /* Handle allocation error */
  } else if (tmp2 == NULL) {
    /* Handle error */
  } else if (temp_num > num_of_records) {
    /* Handle error */
  } else if (tmp2_size_bytes < SIG_DESC_SIZE) {
    /* Handle error */
  }

  signal_info *point = start + temp_num - 1; 
  memcpy(point->sig_desc, tmp2, SIG_DESC_SIZE);
  point->sig_desc[SIG_DESC_SIZE - 1] = '\0';
  /* ... */
  free(start);
}
```

## Noncompliant Code Example (realloc())

This noncompliant code example calls `realloc()` to resize the memory referred to by `p`. However, if `realloc()` fails, it returns a null pointer and the connection between the original block of memory and `p` is lost, resulting in a memory leak.

```cpp
#include <stdlib.h>
 
void *p;
void func(size_t new_size) {
  if (new_size == 0) {
    /* Handle error */
  }
  p = realloc(p, new_size);
  if (p == NULL) {
   /* Handle error */
  }
}
```
This code example complies with [MEM04-C](https://wiki.sei.cmu.edu/confluence/display/c/MEM04-C.+Beware+of+zero-length+allocations)[. Do not perform zero-length allocations](https://wiki.sei.cmu.edu/confluence/display/c/MEM04-C.+Beware+of+zero-length+allocations).

## Compliant Solution (realloc())

In this compliant solution, the result of `realloc()` is assigned to the temporary pointer `q` and validated before it is assigned to the original pointer `p`:

```cpp
#include <stdlib.h>
 
void *p;
void func(size_t new_size) {
  void *q;

  if (new_size == 0) {
    /* Handle error */
  }
 
  q = realloc(p, new_size);
  if (q == NULL) {
   /* Handle error */
  } else {
    p = q;
  }
}
```

## Noncompliant Code Example (fseek())

In this noncompliant code example, the `fseek()` function is used to set the file position to a location `offset` in the file referred to by `file` prior to reading a sequence of bytes from the file. However, if an I/O error occurs during the seek operation, the subsequent read will fill the buffer with the wrong contents.

```cpp
#include <stdio.h>
 
size_t read_at(FILE *file, long offset,
               void *buf, size_t nbytes) {
  fseek(file, offset, SEEK_SET);
  return fread(buf, 1, nbytes, file);
}

```

## Compliant Solution (fseek())

According to the C Standard, the `fseek()` function returns a nonzero value to indicate that an error occurred. This compliant solution tests for this condition before reading from a file to eliminate the chance of operating on the wrong portion of the file if `fseek()` fails:

```cpp
#include <stdio.h>
 
size_t read_at(FILE *file, long offset,
               void *buf, size_t nbytes) {
  if (fseek(file, offset, SEEK_SET) != 0) {
    /* Indicate error to caller */
    return 0;
  }
  return fread(buf, 1, nbytes, file);
}

```

## Noncompliant Code Example (snprintf())

In this noncompliant code example, `snprintf()` is assumed to succeed. However, if the call fails (for example, because of insufficient memory, as described in GNU libc bug [441945](http://bugzilla.redhat.com/show_bug.cgi?id=441945)), the subsequent call to `log_message()` has [undefined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-undefinedbehavior) because the character buffer is uninitialized and need not be null-terminated.

```cpp
#include <stdio.h>
 
extern void log_message(const char *);

void f(int i, int width, int prec) {
  char buf[40];
  snprintf(buf, sizeof(buf), "i = %*.*i", width, prec, i);
  log_message(buf);
  /* ... */
}

```

## Compliant Solution (snprintf())

This compliant solution does not assume that `snprintf()` will succeed regardless of its arguments. It tests the return value of `snprintf()` before subsequently using the formatted buffer. This compliant solution also treats the case where the static buffer is not large enough for `snprintf()` to append the terminating null character as an error.

```cpp
#include <stdio.h>
#include <string.h>
 
extern void log_message(const char *);

void f(int i, int width, int prec) {
  char buf[40];
  int n;
  n = snprintf(buf, sizeof(buf), "i = %*.*i", width, prec, i);
  if (n < 0 || n >= sizeof(buf)) {
    /* Handle snprintf() error */
    strcpy(buf, "unknown error");
  }
  log_message(buf);
}

```

## Compliant Solution (snprintf(null))

If unknown, the length of the formatted string can be discovered by invoking `snprintf()` with a null buffer pointer to determine the size required for the output, then dynamically allocating a buffer of sufficient size, and finally calling `snprintf()` again to format the output into the dynamically allocated buffer. Even with this approach, the success of all calls still needs to be tested, and any errors must be appropriately handled. A possible optimization is to first attempt to format the string into a reasonably small buffer allocated on the stack and, only when the buffer turns out to be too small, dynamically allocate one of a sufficient size:

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
extern void log_message(const char *); 
 
void f(int i, int width, int prec) {
  char buffer[20];
  char *buf = buffer;
  int n  = sizeof(buffer);
  const char fmt[] = "i = %*.*i";

  n = snprintf(buf, n, fmt, width, prec, i);
  if (n < 0) {
    /* Handle snprintf() error */
    strcpy(buffer, "unknown error");
    goto write_log;
  }

  if (n < sizeof(buffer)) {
    goto write_log;
  }

  buf = (char *)malloc(n + 1);
  if (NULL == buf) {
    /* Handle malloc() error */
    strcpy(buffer, "unknown error");
    goto write_log;
  }

  n = snprintf(buf, n, fmt, width, prec, i);
  if (n < 0) {
    /* Handle snprintf() error */
    strcpy(buffer, "unknown error");
  }

write_log:
  log_message(buf);

  if (buf != buffer) {
    free(buf);
  }
}

```
This solution uses the `goto` statement, as suggested in [MEM12-C](https://wiki.sei.cmu.edu/confluence/display/c/MEM12-C.+Consider+using+a+goto+chain+when+leaving+a+function+on+error+when+using+and+releasing+resources)[. Consider using a goto chain when leaving a function on error when using and releasing resources](https://wiki.sei.cmu.edu/confluence/display/c/MEM12-C.+Consider+using+a+goto+chain+when+leaving+a+function+on+error+when+using+and+releasing+resources).

## Exceptions

**ERR33-C-EX1:** It is acceptable to ignore the return value of a function if:

* that function cannot fail.
* its return value is inconsequential; that is, it does not indicate an error.
* it is one of a handful of functions whose return values are not traditionally checked. These functions are listed in the following table:
**Functions for which Return Values Need Not Be Checked**

<table> <tbody> <tr> <th> Function </th> <th> Successful Return </th> <th> Error Return </th> </tr> <tr> <td> <code>putchar()</code> </td> <td> Character written </td> <td> <code>EOF</code> </td> </tr> <tr> <td> <code>putwchar()</code> </td> <td> Wide character written </td> <td> <code>WEOF</code> </td> </tr> <tr> <td> <code>puts()</code> </td> <td> Nonnegative </td> <td> <code>EOF</code> (negative) </td> </tr> <tr> <td> <code>printf()</code> , <code>vprintf()</code> </td> <td> Number of characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>wprintf()</code> , <code>vwprintf()</code> </td> <td> Number of wide characters (nonnegative) </td> <td> Negative </td> </tr> <tr> <td> <code>kill_dependency()</code> </td> <td> The input parameter </td> <td> NA </td> </tr> <tr> <td> <code>memcpy()</code> , <code>wmemcpy()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>memmove()</code> , <code>wmemmove()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>strcpy()</code> , <code>wcscpy()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>strncpy()</code> , <code>wcsncpy()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>strcat()</code> , <code>wcscat()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>strncat()</code> , <code>wcsncat()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> <tr> <td> <code>memset()</code> , <code>wmemset()</code> </td> <td> The destination input parameter </td> <td> NA </td> </tr> </tbody> </table>
The function's results should be explicitly cast to `void` to signify programmer intent:


```cpp
int main() {
  (void) printf("Hello, world\n"); // printf() return value safely ignored
}

```

## Risk Assessment

Failing to detect error conditions can lead to unpredictable results, including [abnormal program termination](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-abnormaltermination) and [denial-of-service attacks](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service) or, in some situations, could even allow an attacker to run arbitrary code.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> ERR33-C </td> <td> High </td> <td> Likely </td> <td> Medium </td> <td> <strong>P18</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>error-information-unusederror-information-unused-computed</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-ERR33</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>LANG.FUNCS.IRV</strong> </td> <td> Ignored return value </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> Can detect violations of this recommendation when checking for violations of <a> EXP12-C. Do not ignore values returned by functions </a> and <a> EXP34-C </a> <a> . Do not dereference null pointers </a> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>MISRA C 2012 Rule 22.8</strong> <strong><strong>MISRA C 2012 Rule 22.9</strong></strong> <strong><strong><strong>MISRA C 2012 Rule 22.10</strong></strong></strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.3 </td> <td> <strong>C3200</strong> <strong>C++2820, C++2821, C++2822, C++2823, C++2824, C++2930, C++2931, C++2932, C++2933, C++2934, C++3802, C++3803, C++3804</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.3 </td> <td> <strong>NPD.CHECK.MUST</strong> <strong>NPD.FUNC.MUST</strong> <strong>SV.RVT.RETVAL_NOTTESTED</strong> </td> <td> </td> </tr> <tr> <td> <a> LDRA tool suite </a> </td> <td> 9.7.1 </td> <td> <strong>80 D</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-ERR33-a</strong> <strong>CERT_C-ERR33-b</strong> <strong>CERT_C-ERR33-c</strong> <strong>CERT_C-ERR33-d</strong> </td> <td> The value returned by a function having non-void return type shall be used The value returned by a function having non-void return type shall be used Avoid null pointer dereferencing Always check the returned value of non-void function </td> </tr> <tr> <td> <a> Parasoft Insure++ </a> </td> <td> </td> <td> </td> <td> Runtime analysis </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>534</strong> </td> <td> Partially supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022b </td> <td> <a> CERT C: Rule ERR33-C </a> </td> <td> Checks for: Errno not checkedrrno not checked, return value of a sensitive function not checkedeturn value of a sensitive function not checked, unprotected dynamic memory allocationnprotected dynamic memory allocation. Rule partially covered. </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>3200</strong> </td> <td> Partially implemented </td> </tr> <tr> <td> <a> PRQA QA-C++ </a> </td> <td> 4.4 </td> <td> <strong>2820, 2821, 2822, 2823, 2824, 2930, 2931, </strong> <strong>2932, 2933, 2934, 3802, 3803, 3804</strong> </td> <td> </td> </tr> <tr> <td> <a> RuleChecker </a> </td> <td> 22.04 </td> <td> <strong>error-information-unused</strong> </td> <td> Partially checked </td> </tr> <tr> <td> <a> TrustInSoft Analyzer </a> </td> <td> 1.38 </td> <td> <strong>pointer arithmetic</strong> </td> <td> Exhaustively verified. </td> </tr> </tbody> </table>


## Related Vulnerabilities

The [vulnerability](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) in Adobe Flash \[[VU\#159523](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography#AA.Bibliography-VU%23159523)\] arises because Flash neglects to check the return value from `calloc()`. Even when `calloc()` returns a null pointer, Flash writes to an offset from the return value. Dereferencing a null pointer usually results in a program crash, but dereferencing an offset from a null pointer allows an [exploit](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-exploit) to succeed without crashing the program.

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+ERR33-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> ERR00-C. Adopt and implement a consistent and comprehensive error-handling policy </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> EXP34-C </a> <a> . Do not dereference null pointers </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> FIO13-C </a> <a> . Never push back anything other than one read character </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MEM04-C </a> <a> . Do not perform zero-length allocations </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> MEM12-C </a> <a> . Consider using a goto chain when leaving a function on error when using and releasing resources </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> ERR10-CPP. Check for error conditions </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CERT C </a> </td> <td> <a> FIO04-CPP. Detect and handle input and output errors </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> ISO/IEC TS 17961:2013 </a> </td> <td> Failing to detect and handle standard library errors \[liberr\] </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-252 </a> , Unchecked Return Value </td> <td> 2017-07-06: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-253 </a> , Incorrect Check of Function Return Value </td> <td> 2017-07-06: CERT: Partial overlap </td> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-391 </a> , Unchecked Error Condition </td> <td> 2017-07-06: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-252/CWE-253/CWE-391 and ERR33-C/POS34-C**

Independent( ERR33-C, POS54-C, FLP32-C, ERR34-C) Intersection( CWE-252, CWE-253) = Ø CWE-391 = Union( CWE-252, CWE-253) CWE-391 = Union( ERR33-C, POS34-C, list) where list =

* Ignoring return values of functions outside the C or POSIX standard libraries

## Bibliography

<table> <tbody> <tr> <td> \[ <a> DHS 2006 </a> \] </td> <td> <a> Handle All Errors Safely </a> </td> </tr> <tr> <td> \[ <a> Henricson 1997 </a> \] </td> <td> Recommendation 12.1, "Check for All Errors Reported from Functions" </td> </tr> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> Subclause 7.21.7.10, "The <code>ungetc</code> Function" </td> </tr> <tr> <td> \[ <a> VU\#159523 </a> \] </td> <td> </td> </tr> </tbody> </table>


## Implementation notes

The rule is enforced in the context of a single function.

## References

* CERT-C: [ERR33-C: Detect and handle standard library errors](https://wiki.sei.cmu.edu/confluence/display/c)
