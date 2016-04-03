#include <string.h>
#include <stdlib.h>

char *ToStr(char *name) {
   char *p = malloc((strlen(name) + 1) * sizeof(char));
   strncpy(p, name, strlen(name));
   p[strlen(name)] = '\0';
   return p;
}
