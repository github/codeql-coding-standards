#include <stdbool.h>
#include <stdio.h>
#include <string.h>

void func(const char *file_name) {
  FILE *file;
  if ((file = fopen(file_name, "wb")) == NULL) {
    /* Handle error */
  }

  /* Operate on the file */

  if (fclose(file) == EOF) {
    /* Handle error */
  }
}

int main(int argc, char **argv) {
  char file_name[20];
  scanf("%s", file_name);
  func(file_name);   // NON_COMPLIANT
  func("file_name"); // COMPLIANT
}

// --- Windows ---

typedef void *HANDLE;
#define GENERIC_READ 0x80000000
#define GENERIC_WRITE 0x40000000
#define OPEN_EXISTING 3
#define FILE_ATTRIBUTE_NORMAL 0x00000080
typedef const char *LPCTSTR;
typedef unsigned long DWORD;
typedef struct _SECURITY_ATTRIBUTES {
} * LPSECURITY_ATTRIBUTES;
typedef bool BOOL;
HANDLE CreateFile(LPCTSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode,
                  LPSECURITY_ATTRIBUTES lpSecurityAttributes,
                  DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes,
                  HANDLE hTemplateFile);
BOOL CloseHandle(HANDLE hObject);

void funcWin() {
  char file_name[20];
  scanf("%s", file_name);
  HANDLE hFile = CreateFile(file_name, // NON_COMPLIANT
                            GENERIC_READ | GENERIC_WRITE, 0, NULL,
                            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  CloseHandle(hFile);
}