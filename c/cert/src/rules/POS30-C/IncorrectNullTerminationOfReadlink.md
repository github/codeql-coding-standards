# POS30-C: Use the readlink() function properly

This query implements the CERT-C rule POS30-C:

> Use the readlink() function properly


## Description

The `readlink()` function reads where a link points to. It makes **no** effort to null-terminate its second argument, `buffer`. Instead, it just returns the number of characters it has written.

## Noncompliant Code Example

If `len` is equal to `sizeof(buf)`, the null terminator is written 1 byte past the end of `buf`:

```cpp
char buf[1024];
ssize_t len = readlink("/usr/bin/perl", buf, sizeof(buf));
buf[len] = '\0';

```
An incorrect solution to this problem is to try to make `buf` large enough that it can always hold the result:

```cpp
long symlink_max;
size_t bufsize;
char *buf;
ssize_t len;

errno = 0;
symlink_max = pathconf("/usr/bin/", _PC_SYMLINK_MAX);
if (symlink_max == -1) {
  if (errno != 0) {
    /* handle error condition */
  }
  bufsize = 10000;
}
else {
  bufsize = symlink_max+1;
}

buf = (char *)malloc(bufsize);
if (buf == NULL) {
  /* handle error condition */
}

len = readlink("/usr/bin/perl", buf, bufsize);
buf[len] = '\0';

```
This modification incorrectly assumes that the symbolic link cannot be longer than the value of `SYMLINK_MAX` returned by `pathconf()`. However, the value returned by `pathconf()` is out of date by the time `readlink()` is called, so the off-by-one buffer-overflow risk is still present because, between the two calls, the location of `/usr/bin/perl` can change to a file system with a larger `SYMLINK_MAX` value. Also, if `SYMLINK_MAX` is indeterminate (that is, if `pathconf()` returned `-1` without setting `errno`), the code uses an arbitrary large buffer size (10,000) that it hopes will be sufficient, but there is a small chance that `readlink()` can return exactly this size.

An additional issue is that `readlink()` can return `-1` if it fails, causing an off-by-one underflow.

## Compliant Solution

This compliant solution ensures there is no overflow by reading in only `sizeof(buf)-1` characters. It also properly checks to see if an error has occurred:

```cpp
enum { BUFFERSIZE = 1024 };
char buf[BUFFERSIZE];
ssize_t len = readlink("/usr/bin/perl", buf, sizeof(buf)-1);

if (len != -1) {
  buf[len] = '\0';
}
else {
  /* handle error condition */
}

```

## Risk Assessment

Failing to properly null-terminate the result of `readlink()` can result in abnormal program termination and buffer-overflow vulnerabilities.

<table> <tbody> <tr> <th> Rule </th> <th> Severity </th> <th> Likelihood </th> <th> Remediation Cost </th> <th> Priority </th> <th> Level </th> </tr> <tr> <td> POS30-C </td> <td> high </td> <td> probable </td> <td> medium </td> <td> <strong>P12</strong> </td> <td> <strong>L1</strong> </td> </tr> </tbody> </table>


## Automated Detection

<table> <tbody> <tr> <th> Tool </th> <th> Version </th> <th> Checker </th> <th> Description </th> </tr> <tr> <td> <a> Astrée </a> </td> <td> 24.04 </td> <td> </td> <td> Supported: Can be checked with appropriate analysis stubs. </td> </tr> <tr> <td> <a> Axivion Bauhaus Suite </a> </td> <td> 7.2.0 </td> <td> <strong>CertC-POS30</strong> </td> <td> </td> </tr> <tr> <td> <a> CodeSonar </a> </td> <td> 9.0p0 </td> <td> <strong>LANG.MEM.BO</strong> <strong>LANG.MEM.TBA</strong> <strong>MISC.MEM.NTERM.CSTRING</strong> </td> <td> Buffer Overrun Tainted Buffer Access Unterminated C String </td> </tr> <tr> <td> <a> Compass/ROSE </a> </td> <td> </td> <td> </td> <td> </td> </tr> <tr> <td> <a> Coverity </a> </td> <td> 2017.07 </td> <td> <strong>READLINK</strong> </td> <td> Implemented </td> </tr> <tr> <td> <a> Helix QAC </a> </td> <td> 2024.4 </td> <td> <strong>C5033</strong> </td> <td> </td> </tr> <tr> <td> <a> Klocwork </a> </td> <td> 2024.4 </td> <td> <strong>ABV.GENERAL</strong> <strong>ABV.GENERAL.MULTIDIMENSION</strong> </td> <td> </td> </tr> <tr> <td> <a> Parasoft C/C++test </a> </td> <td> 2024.2 </td> <td> <strong>CERT_C-POS30-a</strong> <strong>CERT_C-POS30-b</strong> <strong>CERT_C-POS30-c</strong> </td> <td> Avoid overflow due to reading a not zero terminated string The values returned by functions 'read' and 'readlink' shall be used Use of possibly not null-terminated string with functions expecting null-terminated string </td> </tr> <tr> <td> <a> Polyspace Bug Finder </a> </td> <td> R2024b </td> <td> <a> CERT C: Rule POS30-C </a> </td> <td> Checks for misuse of readlink() (rule partially covered) </td> </tr> </tbody> </table>


## Related Vulnerabilities

Search for vulnerabilities resulting from the violation of this rule on the [CERT website](https://www.kb.cert.org/vulnotes/bymetric?searchview&query=FIELD+KEYWORDS+contains+POS30-C).

## Related Guidelines

[Key here](https://wiki.sei.cmu.edu/confluence/display/c/How+this+Coding+Standard+is+Organized#HowthisCodingStandardisOrganized-RelatedGuidelines) (explains table format and definitions)

<table> <tbody> <tr> <th> Taxonomy </th> <th> Taxonomy item </th> <th> Relationship </th> </tr> <tr> <td> <a> CWE 2.11 </a> </td> <td> <a> CWE-170 </a> , Improper null termination </td> <td> 2017-06-13: CERT: Rule subset of CWE </td> </tr> </tbody> </table>


## CERT-CWE Mapping Notes

[Key here](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152408#HowthisCodingStandardisOrganized-CERT-CWEMappingNotes) for mapping notes

**CWE-170 and POS30-C**

CWE-170 = Union( POS30-C, list) where list =

* Non-null terminated strings fed to functions other than POSIX readlink()

## Bibliography

<table> <tbody> <tr> <td> \[ <a> Ilja 2006 </a> \] </td> </tr> <tr> <td> \[ <a> Open Group 1997a </a> \] </td> </tr> <tr> <td> \[ <a> Open Group 2004 </a> \] </td> </tr> </tbody> </table>


## Implementation notes

None

## References

* CERT-C: [POS30-C: Use the readlink() function properly](https://wiki.sei.cmu.edu/confluence/display/c)
