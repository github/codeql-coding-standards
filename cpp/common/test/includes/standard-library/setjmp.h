#ifndef _GHLIBCPP_SETJMP
#define _GHLIBCPP_SETJMP


struct __jmp_buf_tag
  {
      int x;
  };

typedef struct __jmp_buf_tag jmp_buf[1];

void longjmp (struct __jmp_buf_tag __env[1], int __val);
#define  setjmp(env) 0
#endif
