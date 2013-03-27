#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include "util.h"

void die(const int code, const char *errstr, ...) {
	va_list ap;

	va_start(ap, errstr);
	vfprintf(stderr, errstr, ap);
	va_end(ap);
	exit(code);
}

void fail(const int code, const char *errstr, ...) {
	va_list ap;
	char prefix[50];

	va_start(ap, errstr);
	vsnprintf(prefix, sizeof prefix, errstr, ap);
	va_end(ap);
	perror(prefix);
	exit(code);
}
