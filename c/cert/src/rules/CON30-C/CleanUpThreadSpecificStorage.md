# CON30-C: Clean up thread-specific storage

This query implements the CERT-C rule CON30-C:

> Clean up thread-specific storage


## Description

The `tss_create()` function creates a thread-specific storage pointer identified by a key. Threads can allocate thread-specific storage and associate the storage with a key that uniquely identifies the storage by calling the `tss_set()` function. If not properly freed, this memory may be leaked. Ensure that thread-specific storage is freed.

## Noncompliant Code Example

In this noncompliant code example, each thread dynamically allocates storage in the `get_data()` function, which is then associated with the global key by the call to `tss_set()` in the `add_data()` function. This memory is subsequently leaked when the threads terminate.

```cpp
#include <threads.h>
#include <stdlib.h>

/* Global key to the thread-specific storage */
tss_t key;
enum { MAX_THREADS = 3 };

int *get_data(void) {
  int *arr = (int *)malloc(2 * sizeof(int));
  if (arr == NULL) {
    return arr;  /* Report error  */
  }
  arr[0] = 10;
  arr[1] = 42;
  return arr;
}

int add_data(void) {
  int *data = get_data();
  if (data == NULL) {
    return -1;	/* Report error */
  }

  if (thrd_success != tss_set(key, (void *)data)) {
    /* Handle error */
  }
  return 0;
}

void print_data(void) {
  /* Get this thread's global data from key */
  int *data = tss_get(key);

  if (data != NULL) {
    /* Print data */
  } 
}

int function(void *dummy) {
  if (add_data() != 0) {
    return -1;	/* Report error */
  }
  print_data();
  return 0;
}

int main(void) {
  thrd_t thread_id[MAX_THREADS];

  /* Create the key before creating the threads */
  if (thrd_success != tss_create(&key, NULL)) {
    /* Handle error */
  }

  /* Create threads that would store specific storage */
  for (size_t i = 0; i < MAX_THREADS; i++) {
    if (thrd_success != thrd_create(&thread_id[i], function, NULL)) {
      /* Handle error */
    }
  }

  for (size_t i = 0; i < MAX_THREADS; i++) {
    if (thrd_success != thrd_join(thread_id[i], NULL)) {
      /* Handle error */
    }
  }

  tss_delete(key);
  return 0;
}

```

## Compliant Solution

In this compliant solution, each thread explicitly frees the thread-specific storage returned by the `tss_get()` function before terminating:

```cpp
#include <threads.h>
#include <stdlib.h>
 
/* Global key to the thread-specific storage */
tss_t key;
 
int function(void *dummy) {
  if (add_data() != 0) {
    return -1;	/* Report error */
  }
  print_data();
  free(tss_get(key));
  return 0;
}

/* ... Other functions are unchanged */

```

## Compliant Solution

This compliant solution invokes a destructor function registered during the call to `tss_create()` to automatically free any thread-specific storage:

```cpp
#include <threads.h>
#include <stdlib.h>

/* Global key to the thread-specific storage */
tss_t key;
enum { MAX_THREADS = 3 };

/* ... Other functions are unchanged */

void destructor(void *data) {
  free(data);
}
 
int main(void) {
  thrd_t thread_id[MAX_THREADS];

  /* Create the key before creating the threads */
  if (thrd_success != tss_create(&key, destructor)) {
    /* Handle error */
  }

  /* Create threads that would store specific storage */
  for (size_t i = 0; i < MAX_THREADS; i++) {
    if (thrd_success != thrd_create(&thread_id[i], function, NULL)) {
      /* Handle error */
    }
  }

  for (size_t i = 0; i < MAX_THREADS; i++) {
    if (thrd_success != thrd_join(thread_id[i], NULL)) {
      /* Handle error */
    }
  }

  tss_delete(key);
  return 0;
}
```

## Risk Assessment

Failing to free thread-specific objects results in memory leaks and could result in a [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service).

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON30-C </td> <td> Medium </td> <td> Unlikely </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> </td> <td> Supported, but no explicit checker </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.1p0 </td> <td> <strong>ALLOC.LEAK</strong> </td> <td> Leak </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>ALLOC_FREE_MISMATCH</strong> </td> <td> Partially implemented, correct implementation is more involved </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C1780, C1781, C1782, C1783, C1784</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON30-a</strong> </td> <td> Ensure resources are freed </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON30-C </a> </td> <td> Checks for thread-specific memory leak (rule fully covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON30-C).

## Implementation notes

This query does not attempt to ensure that the deallocation function in fact deallocates memory and instead assumes the contract is valid. Additionally, this query requires that all `tss_create` calls are bookended by calls to `tss_delete`, even if a thread is not created.

## References

* CERT-C: [CON30-C: Clean up thread-specific storage](https://wiki.sei.cmu.edu/confluence/display/c)
