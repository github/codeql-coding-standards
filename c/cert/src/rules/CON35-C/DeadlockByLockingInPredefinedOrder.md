# CON35-C: Avoid deadlock by locking in a predefined order

This query implements the CERT-C rule CON35-C:

> Avoid deadlock by locking in a predefined order


## Description

Mutexes are used to prevent multiple threads from causing a data race by accessing shared resources at the same time. Sometimes, when locking mutexes, multiple threads hold each other's lock, and the program consequently deadlocks. Four conditions are required for deadlock to occur:

* Mutual exclusion
* Hold and wait
* No preemption
* Circular wait
Deadlock needs all four conditions, so preventing deadlock requires preventing any one of the four conditions. One simple solution is to lock the mutexes in a predefined order, which prevents circular wait.

## Noncompliant Code Example

The behavior of this noncompliant code example depends on the runtime environment and the platform's scheduler. The program is susceptible to deadlock if thread `thr1 `attempts to lock `ba2`'s mutex at the same time thread `thr2` attempts to lock `ba1`'s mutex in the `deposit()` function.

```cpp
#include <stdlib.h>
#include <threads.h>
 
typedef struct {
  int balance;
  mtx_t balance_mutex;
} bank_account;

typedef struct {
  bank_account *from;
  bank_account *to;
  int amount;
} transaction;

void create_bank_account(bank_account **ba,
                         int initial_amount) {
  bank_account *nba = (bank_account *)malloc(
    sizeof(bank_account)
  );
  if (nba == NULL) {
    /* Handle error */
  }

  nba->balance = initial_amount;
  if (thrd_success
      != mtx_init(&nba->balance_mutex, mtx_plain)) {
    /* Handle error */
  }

  *ba = nba;
}

int deposit(void *ptr) {
  transaction *args = (transaction *)ptr;

  if (thrd_success != mtx_lock(&args->from->balance_mutex)) {
    /* Handle error */
  }

  /* Not enough balance to transfer */
  if (args->from->balance < args->amount) {
    if (thrd_success
        != mtx_unlock(&args->from->balance_mutex)) {
      /* Handle error */
    }
    return -1; /* Indicate error */
  }
  if (thrd_success != mtx_lock(&args->to->balance_mutex)) {
    /* Handle error */
  }

  args->from->balance -= args->amount;
  args->to->balance += args->amount;

  if (thrd_success
      != mtx_unlock(&args->from->balance_mutex)) {
    /* Handle error */
  }

  if (thrd_success
      != mtx_unlock(&args->to->balance_mutex)) {
    /* Handle error */
  }

  free(ptr);
  return 0;
}

int main(void) {
  thrd_t thr1, thr2;
  transaction *arg1;
  transaction *arg2;
  bank_account *ba1;
  bank_account *ba2;

  create_bank_account(&ba1, 1000);
  create_bank_account(&ba2, 1000);

  arg1 = (transaction *)malloc(sizeof(transaction));
  if (arg1 == NULL) {
    /* Handle error */
  }
  arg2 = (transaction *)malloc(sizeof(transaction));
  if (arg2 == NULL) {
    /* Handle error */
  }
  arg1->from = ba1;
  arg1->to = ba2;
  arg1->amount = 100;

  arg2->from = ba2;
  arg2->to = ba1;
  arg2->amount = 100;

  /* Perform the deposits */
  if (thrd_success
     != thrd_create(&thr1, deposit, (void *)arg1)) {
    /* Handle error */
  }
  if (thrd_success
      != thrd_create(&thr2, deposit, (void *)arg2)) {
    /* Handle error */
  }
  return 0;
} 
```

## Compliant Solution

This compliant solution eliminates the circular wait condition by establishing a predefined order for locking in the `deposit()` function. Each thread will lock on the basis of the `bank_account` ID, which is set when the `bank_account struct` is initialized.

```cpp
#include <stdlib.h>
#include <threads.h>
 
typedef struct {
  int balance;
  mtx_t balance_mutex;
 
  /* Should not change after initialization */
  unsigned int id;
} bank_account;

typedef struct {
  bank_account *from;
  bank_account *to;
  int amount;
} transaction;

unsigned int global_id = 1;

void create_bank_account(bank_account **ba,
                         int initial_amount) {
  bank_account *nba = (bank_account *)malloc(
    sizeof(bank_account)
  );
  if (nba == NULL) {
    /* Handle error */
  }

  nba->balance = initial_amount;
  if (thrd_success
      != mtx_init(&nba->balance_mutex, mtx_plain)) {
    /* Handle error */
  }

  nba->id = global_id++;
  *ba = nba;
}

int deposit(void *ptr) {
  transaction *args = (transaction *)ptr;
  int result = -1;
  mtx_t *first;
  mtx_t *second;

  if (args->from->id == args->to->id) {
    return -1; /* Indicate error */
  }

  /* Ensure proper ordering for locking */
  if (args->from->id < args->to->id) {
    first = &args->from->balance_mutex;
    second = &args->to->balance_mutex;
  } else {
    first = &args->to->balance_mutex;
    second = &args->from->balance_mutex;
  }
  if (thrd_success != mtx_lock(first)) {
    /* Handle error */
  }
  if (thrd_success != mtx_lock(second)) {
    /* Handle error */
  }

  /* Not enough balance to transfer */
  if (args->from->balance >= args->amount) {
    args->from->balance -= args->amount;
    args->to->balance += args->amount;
    result = 0;
  }

  if (thrd_success != mtx_unlock(second)) {
    /* Handle error */
  }
  if (thrd_success != mtx_unlock(first)) {
    /* Handle error */
  }
  free(ptr);
  return result;
} 
```

## Risk Assessment

Deadlock prevents multiple threads from progressing, halting program execution. A [denial-of-service attack](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-denial-of-service) is possible if the attacker can create the conditions for deadlock.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> CON35-C </td> <td> Low </td> <td> Probable </td> <td> Medium </td> <td> <strong>P4</strong> </td> <td> <strong>L3</strong> </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for [vulnerabilities](https://wiki.sei.cmu.edu/confluence/display/c/BB.+Definitions#BB.Definitions-vulnerability) resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+CON35-C).

## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 22.04 </td> <td> <strong>deadlock</strong> </td> <td> Supported by sound analysis (deadlock alarm) </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 7.0p0 </td> <td> <strong>CONCURRENCY.LOCK.ORDER</strong> </td> <td> Conflicting lock order </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>ORDER_REVERSAL</strong> </td> <td> Fully implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2022.2 </td> <td> <strong>C1772, C1773</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2022.2 </td> <td> <strong>CONC.DL</strong> <strong>CONC.NO_UNLOCK</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2022.1 </td> <td> <strong>CERT_C-CON35-a</strong> </td> <td> Avoid double locking </td> </tr> <tr> <td> <a> PC-lint Plus </a> </td> <td> 1.4 </td> <td> <strong>2462</strong> </td> <td> Fully supported </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2022a </td> <td> <a> CERT C: Rule CON35-C </a> </td> <td> Checks for deadlock (rule fully covered) </td> </tr> <tr> <td> <a> PRQA QA-C </a> </td> <td> 9.7 </td> <td> <strong>1772,1773</strong> </td> <td> Enforced by MTA </td> </tr> </tbody> </table>


## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CERT Oracle Secure Coding Standard for Java </a> </td> <td> <a> LCK07-J. Avoid deadlock by requesting and releasing locks in the same order </a> </td> <td> Prior to 2018-01-12: CERT: Unspecified Relationship </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [CON35-C: Avoid deadlock by locking in a predefined order](https://wiki.sei.cmu.edu/confluence/display/c)
