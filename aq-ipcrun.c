#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include "util.h"

void usage(char *);

int main(int argc, char **argv) {
	int s;
	int fdi;
	int fdo;
	int opt;
	size_t n;
	struct sockaddr_un a;
	
	fdi = 0;
	fdo = 1;
	
	while ((opt = getopt(argc, argv, "+r:w:")) != -1) {
		switch(opt) {
		case 'f':
			fdi = fdo = atoi(optarg);
			break;
		default:
			die(2, "Usage: %s sock prog ...\n", argv[0]);
		}
	}

	if ((s = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
		fail(111, "socket");
	}
	if (argc - optind < 2) {
		die(2, "Usage: %s [-r fd] [-w fd] sock prog ...\n", argv[0]);
	}
	
	memset(&a, 0, sizeof(a));
	a.sun_family = AF_UNIX;
	strncpy(a.sun_path, argv[optind], sizeof(a.sun_path)-1);
	n = strnlen(a.sun_path, sizeof(a.sun_path)-1) + sizeof(a.sun_family);
	
	if(connect(s, (struct sockaddr *)&a, n) < 0) {
		fail(111, "connect '%s'", a.sun_path);
	}
	if (dup2(s, fdi) < 0) {
		fail(111, "dup2 fd%d", fdi);
	}
	if (dup2(s, fdo) < 0) {
		fail(111, "dup2 fd%d", fdo);
	}
	execvp(argv[optind+1], &argv[optind+1]);
	fail(111, "exec %s", argv[optind+1]);
	return 111;
}
