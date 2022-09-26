# CON34-C: Declare objects shared between threads with appropriate storage durations

This query implements the CERT-C rule CON34-C:

> Declare objects shared between threads with appropriate storage durations


## Description

Accessing the automatic or thread-local variables of one thread from another thread is [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) and can cause invalid memory accesses because the execution of threads can be interwoven within the constraints of the synchronization model. As a result, the referenced stack frame or thread-local variable may no longer be valid when another thread tries to access it. Shared static variables can be protected by thread synchronization mechanisms.

However, automatic (local) variables cannot be shared in the same manner because the referenced stack frame's thread would need to stop executing, or some other mechanism must be employed to ensure that the referenced stack frame is still valid. Do not access automatic or thread-local objects from a thread other than the one with which the object is associated. See [DCL30-C. Declare objects with appropriate storage durations](https://wiki.sei.cmu.edu/confluence/display/c/DCL30-C.+Declare+objects+with+appropriate+storage+durations) for information on how to declare objects with appropriate storage durations when data is not being shared between threads.

Noncompliant Code Example (Automatic Storage Duration)

This noncompliant code example passes the address of a variable to a child thread, which prints it out. The variable has automatic storage duration. Depending on the execution order, the child thread might reference the variable after the variable's lifetime in the parent thread. This would cause the child thread to access an invalid memory location.

```cpp
#include <threads.h>
#include <stdio.h>

int child_thread(void *val) {
  int *res = (int *)val;
  printf("Result: %d\n", *res);
  return 0;
}

void create_thread(thrd_t *tid) {
  int val = 1;
  if (thrd_success != thrd_create(tid, child_thread, &val)) {
    /* Handle error */
  }
}

int main(void) {
  thrd_t tid;
  create_thread(&tid);
  
  if (thrd_success != thrd_join(tid, NULL)) {
    /* Handle error */
  }
  return 0;
}

```

## Noncompliant Code Example (Automatic Storage Duration)

One practice is to ensure that all objects with automatic storage duration shared between threads are declared such that their lifetime extends past the lifetime of the threads. This can be accomplished using a thread synchronization mechanism, such as `thrd_join()`. In this code example, `val` is declared in `main()`, where `thrd_join()` is called. Because the parent thread waits until the child thread completes before continuing its execution, the shared objects have a lifetime at least as great as the thread.

```cpp
#include <threads.h>
#include <stdio.h>

int child_thread(void *val) {
  int *result = (int *)val;
  printf("Result: %d\n", *result);  /* Correctly prints 1 */
  return 0;
}
 
void create_thread(thrd_t *tid, int *val) {
  if (thrd_success != thrd_create(tid, child_thread, val)) {
    /* Handle error */
  }
}
 
int main(void) {
  int val = 1;
  thrd_t tid;
  create_thread(&tid, &val);
  if (thrd_success != thrd_join(tid, NULL)) {
    /* Handle error */
  }
  return 0;
}
```

## 

However, the C Standard, 6.2.4 paragraphs 4 and 5 \[[ISO/IEC 9899:2011](https://wiki.sei.cmu.edu/confluence/display/c/AA.+Bibliography)\], states:

> The result of attempting to indirectly access an object with thread storage duration from a thread other than the one with which the object is associated is implementation-defined. . . .


The result of attempting to indirectly access an object with automatic storage duration from a thread other than the one with which the object is associated is implementation-defined.

Therefore this example relies on [implementation-defined behavior](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-implementation-definedbehavior) and is nonportable.

## Compliant Solution (Static Storage Duration)

This compliant solution stores the value in an object having static storage duration. The lifetime of this object is the entire execution of the program; consequently, it can be safely accessed by any thread.

```cpp
#include <threads.h>
#include <stdio.h>

int child_thread(void *v) {
  int *result = (int *)v;
  printf("Result: %d\n", *result);  /* Correctly prints 1 */
  return 0;
}
 
void create_thread(thrd_t *tid) {
  static int val = 1;
  if (thrd_success != thrd_create(tid, child_thread, &val)) {
    /* Handle error */
  }
}
 
int main(void) {
  thrd_t tid;
  create_thread(&tid);
  if (thrd_success != thrd_join(tid, NULL)) {
    /* Handle error */
  }
  return 0;
}

```

## Compliant Solution (Allocated Storage Duration)

This compliant solution stores the value passed to the child thread in a dynamically allocated object. Because this object will persist until explicitly freed, the child thread can safely access its value.

```cpp
#include <threads.h>
#include <stdio.h>
#include <stdlib.h>

int child_thread(void *val) {
  int *result = (int *)val;
  printf("Result: %d\n", *result); /* Correctly prints 1 */
  return 0;
}
 
void create_thread(thrd_t *tid, int *value) {
  *value = 1;
  if (thrd_success != thrd_create(tid, child_thread,
                                  value)) {
    /* Handle error */
  }
}
 
int main(void) {
  thrd_t tid;
  int *value = (int *)malloc(sizeof(int));
  if (!value) {
    /* Handle error */
  }
  create_thread(&tid, value);
  if (thrd_success != thrd_join(tid, NULL)) {
    /* Handle error */
  }
  free(value);
  return 0;
}

```

## Noncompliant Code Example (Thread-Specific Storage)

In this noncompliant code example, the value is stored in thread-specific storage of the parent thread. However, because thread-specific data is available only to the thread that stores it, the `child_thread()` function will set `result` to a null value.

```cpp
#include <threads.h>
#include <stdio.h>
#include <stdlib.h>
 
static tss_t key; 
 
int child_thread(void *v) {
  void *result = tss_get(*(tss_t *)v);
  printf("Result: %d\n", *(int *)result);
  return 0;
}
 
int create_thread(void *thrd) {
  int *val = (int *)malloc(sizeof(int));
  if (val == NULL) {
    /* Handle error */
  }
  *val = 1;
  if (thrd_success != tss_set(key, val)) {
    /* Handle error */
  }
  if (thrd_success != thrd_create((thrd_t *)thrd,
                                  child_thread, &key)) {
    /* Handle error */
  }
  return 0;
}

int main(void) {
  thrd_t parent_tid, child_tid;

  if (thrd_success != tss_create(&key, free)) {
    /* Handle error */
  }
  if (thrd_success != thrd_create(&parent_tid, create_thread,
                                  &child_tid)) {
    /* Handle error */
  }
  if (thrd_success != thrd_join(parent_tid, NULL)) {
    /* Handle error */
  }
  if (thrd_success != thrd_join(child_tid, NULL)) {
    /* Handle error */
  }
  tss_delete(key);
  return 0;
} 
```

## Compliant Solution (Thread-Specific Storage)

This compliant solution illustrates how thread-specific storage can be combined with a call to a thread synchronization mechanism, such as `thrd_join()`. Because the parent thread waits until the child thread completes before continuing its execution, the child thread is guaranteed to access a valid live object.

```cpp
#include <threads.h>
#include <stdio.h>
#include <stdlib.h>

static tss_t key;

int child_thread(void *v) {
  int *result = v;
  printf("Result: %d\n", *result); /* Correctly prints 1 */
  return 0;
}

int create_thread(void *thrd) {
  int *val = (int *)malloc(sizeof(int));
  if (val == NULL) {
    /* Handle error */
  }
  *val = 1;
  if (thrd_success != tss_set(key, val)) {
    /* Handle error */
  }
  /* ... */
  void *v = tss_get(key);
  if (thrd_success != thrd_create((thrd_t *)thrd,
                                   child_thread, v)) {
    /* Handle error */
  }
  return 0;
}

int main(void) {
  thrd_t parent_tid, child_tid;

  if (thrd_success != tss_create(&key, free)) {
  /* Handle error */
  }
  if (thrd_success != thrd_create(&parent_tid, create_thread,
                                  &child_tid)) {
    /* Handle error */
  }
  if (thrd_success != thrd_join(parent_tid, NULL)) {
    /* Handle error */
  }
  if (thrd_success != thrd_join(child_tid, NULL)) {
    /* Handle error */
  }
  tss_delete(key);
return 0;
} 
```
This compliant solution uses pointer-to-integer and integer-to-pointer conversions, which have implementation-defined behavior. (See [INT36-C. Converting a pointer to integer or integer to pointer](https://wiki.sei.cmu.edu/confluence/display/c/INT36-C.+Converting+a+pointer+to+integer+or+integer+to+pointer).)

## Compliant Solution (Thread-Local Storage, Windows, Visual Studio)

Similar to the preceding compliant solution, this compliant solution uses thread-local storage combined with thread synchronization to ensure the child thread is accessing a valid live object. It uses the Visual Studio–specific [__declspec(thread)](http://msdn.microsoft.com/en-us/library/9w1sdazb.aspx) language extension to provide the thread-local storage and the `[WaitForSingleObject()](http://msdn.microsoft.com/en-us/library/windows/desktop/ms687032(v=vs.85).aspx)` API to provide the synchronization.

```cpp
#include <Windows.h>
#include <stdio.h>

DWORD WINAPI child_thread(LPVOID v) {
  int *result = (int *)v;
  printf("Result: %d\n", *result);  /* Correctly prints 1 */
  return NULL;
}

int create_thread(HANDLE *tid) {
  /* Declare val as a thread-local value */
  __declspec(thread) int val = 1;
  *tid = create_thread(NULL, 0, child_thread, &val, 0, NULL);
  return *tid == NULL;
}

int main(void) {
  HANDLE tid;
 
  if (create_thread(&tid)) {
    /* Handle error */
  }
 
  if (WAIT_OBJECT_0 != WaitForSingleObject(tid, INFINITE)) {
    /* Handle error */
  }
  CloseHandle(tid);
 
  return 0;
}

```

## Noncompliant Code Example (OpenMP, parallel)

It is important to note that local data can be used securely with threads when using other thread interfaces, so the programmer need not always copy data into nonlocal memory when sharing data with threads. For example, the `shared` keyword in *<sup>®<a>The OpenMP API Specification for Parallel Programming</a></sup>* \[[OpenMP](http://openmp.org/wp/)\] can be used in combination with OpenMP's threading interface to share local memory without having to worry about whether local automatic variables remain valid.

In this noncompliant code example, a variable `j` is declared outside a `parallel` `#pragma` and not listed as a private variable. In OpenMP, variables outside a `parallel #pragma` are shared unless designated as `private`.

```cpp
#include <omp.h>
#include <stdio.h>
 
int main(void) {
  int j = 0;
  #pragma omp parallel
  {
    int t = omp_get_thread_num();
    printf("Running thread - %d\n", t);
    for (int i = 0; i < 5050; i++) {
    j++; /* j not private; could be a race condition */
    }
    printf("Just ran thread - %d\n", t);
    printf("loop count %d\n", j);
  }
return 0;
}
```

## Compliant Solution (OpenMP, parallel, private)

In this compliant solution, the variable `j` is declared outside of the `parallel` `#pragma` but is explicitly labeled as `private`:

```cpp
#include <omp.h>
#include <stdio.h>

int main(void) {
  int j = 0;
  #pragma omp parallel private(j)
  {
    int t = omp_get_thread_num();
    printf("Running thread - %d\n", t);
    for (int i = 0; i < 5050; i++) {
    j++;
    }
    printf("Just ran thread - %d\n", t);
    printf("loop count %d\n", j);
  }
return 0;
}
```

## Risk Assessment

Threads that reference the stack of other threads can potentially overwrite important information on the stack, such as function pointers and return addresses. The compiler may not generate warnings if the programmer allows one thread to access another thread's local variables, so a programmer may not catch a potential error at compile time. The remediation cost for this error is high because analysis tools have difficulty diagnosing problems with concurrency and race conditions.

<table> <tbody> <tr> <th> Recommendation </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON34-C </td> <td> Medium </td> <td> Probable </td> <td> High </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>CONCURRENCY.LOCALARG</strong> </td> <td> Local Variable Passed to Thread </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C4926, C4927, C4928</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON34-a</strong> </td> <td> Declare objects shared between POSIX threads with appropriate storage durations </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON34-C </a> </td> <td> Checks for automatic or thread local variable escaping from a C11 thread (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>4926, 4927, 4928</strong> </td> <td> Enforced by QAC </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON34-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT C Secure Coding Standard </a> </td> <td> <a> DCL30-C. Declare objects with appropriate storage durations </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Bibliography

<table> <tbody> <tr> <td> \[ <a> ISO/IEC 9899:2011 </a> \] </td> <td> 6.2.4, "Storage Durations of Objects" </td> </tr> <tr> <td> \[ <a> OpenMP </a> \] </td> <td> <em> <sup> ® <a> The OpenMP API Specification for Parallel Programming </a> </sup> </em> </td> </tr> </tbody> </table>


## Implementation notes

This query does not consider Windows implementations or OpenMP implementations. This query is primarily about excluding cases wherein the storage duration of a variable is appropriate. As such, this query is not concerned if the appropriate synchronization mechanisms are used, such as sequencing calls to `thrd_join` and `free`. An audit query is supplied to handle some of those cases.

## References

* CERT-C: [CON34-C: Declare objects shared between threads with appropriate storage durations](https://wiki.sei.cmu.edu/confluence/display/c)
