#if M == 0 /* Non-compliant */
/* Does 'M' expand to zero or is it undefined? */
#endif
#if defined(M) /* Compliant - M is not evaluated */
#if M == 0     /* Compliant - M is known to be defined */
/* 'M' must expand to zero. */
#endif
#endif
/* Compliant - B is only evaluated in ( B == 0 ) if it is defined */
#if defined(B) && (B == 0)
#endif