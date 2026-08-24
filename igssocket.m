#include "comment.header"

/* $Id: igssocket.m,v 1.3 1997/07/06 19:38:00 ergo Exp $ */

/*
 * $Log: igssocket.m,v $
 * Revision 1.3  1997/07/06 19:38:00  ergo
 * actual version
 *
 * Revision 1.3  1997/05/04 18:56:57  ergo
 * added time control for moves
 *
 */

/*   This file was converted from the igs client written by Adrienne Mariano.  */
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netdb.h>

#ifndef WINS			/* Usually want this... */
#include <netinet/in.h>
#else				/* ... but need these for WINS. */
#include <sys/in.h>
#include <sys/inet.h>
#endif

#include <fcntl.h>
#include <sys/errno.h>
#include <stdio.h>
#ifndef FD_ZERO
#include <sys/select.h>
#endif
#include "igs.h"

#import <appkit/appkit.h>
#import "GoApp.h"

/* For some odd systems, which don't put this in errno.h. */

extern int errno;

char servename[80];		/* = "129.24.14.70"; *//* "lacerta.unm.edu"; */
int serveport;			/* = 6969; */
int sock;
char inbuf[1000];
int inptr = 0;


void sethost(char *s)
{
  strcpy(servename, s);
}


void setport(int s)
{
  serveport = s;
}

#ifdef DEBUG
FILE *blah;
#endif

extern void incomingserver();
int writetosock;

int open_connection()
{
  struct sockaddr_in server;
  struct hostent *hp;
  int ipn;
  char s[80];

  sprintf(s, "Opening connection to %s %d\n", servename, serveport);
  [NXApp SetIGSStatus:s];
#ifdef DEBUG
  	{
    	int d;
    	char n[444];

    	d = 0;
    	do {
      		sprintf(n, "dump%d.igs", d);
      		blah = fopen(n, "r");
      		if (!blah) {
				blah = fopen(n, "w");
				if (blah)
	  				printf("Creating dump file %s\n", n);
				break;
      		}
      		fclose(blah);
      		d++;
      		if (d > 9) {
				printf("Too many dump files.  Type 'rm dump?.igs' and try again.\n");
				exit(1);
      		}
    	} while (1);

	}
#endif

  if (sscanf(servename, "%d.%d.%d.%d", &ipn, &ipn, &ipn, &ipn) == 4)
    server.sin_addr.s_addr = inet_addr(servename);
  else {
    hp = gethostbyname(servename);
    if (hp == 0) {
      puts("Unknown host");
      return -1;
    }
    bcopy(hp->h_addr, &server.sin_addr, hp->h_length);
  }

  server.sin_family = AF_INET;
  server.sin_port = htons(serveport);
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    perror("socket");
    return -1;
  }
  if (connect(sock, (struct sockaddr *) & server,
	      sizeof(struct sockaddr_in)) < 0) {
    perror("connect");
    return -1;
  }
/*  fcntl(sock, F_SETFL, FASYNC);
  fcntl(sock, F_SETOWN, getpid());
  signal(SIGIO, incomingserver);  */
  writetosock = 0;
  return 0;
}

void sendstr(char *buf)
{
  write(sock, buf, strlen(buf));
#ifdef DEBUG
  fprintf(blah, ">%s<\n", buf);
  fflush(blah);
#endif
}


int eatchar = 0;


/* struct timeval timeout = { 0L, 100000L }; */



int handlechar(char in)
{
	if (in == '\r')
    	return 0;
#ifdef DEBUG
  	fputc(in, blah);
  	fflush(blah);
#endif
  	if (eatchar) {
    	eatchar--;
    	return 0;
  	}
  	if (in == '\377') {
    	eatchar = 2;
    	return 0;
  	}
  	if (in == '\n') {
    	inbuf[inptr] = 0;
    	strcpy(retbuf, inbuf);
    	inptr = 0;
    	if (idle)
      		doserver();
    	return 1;
  	}
	else {
    	inbuf[inptr++] = in;
    	if (doneline(inbuf, inptr)) {
      		inbuf[inptr] = 0;
      		strcpy(retbuf, inbuf);
      		inptr = 0;
      		if (idle)
				doserver();
      		return 1;
    	}
  	}

	return 0;
}



int bufdata = 0, bufptr = 0;
char thebuf[1000];


void incomingserver()
{
	if (idle == 0) {
		#ifdef DEBUG
    	fprintf(blah,"busy...\n");
    	fflush(blah);
		#endif
    	return;
	}

  	bufptr = 0;
  	bufdata = read(sock, thebuf, 1000);
  	while (bufdata) {
      	bufdata--;
      	handlechar(thebuf[bufptr++]);
    }
}

int pollserver()
{
	int sel;
  	fd_set readers;

	FD_ZERO(&readers);
	while (1)
    	{
    	while (bufdata) {
			bufdata--;
			if (handlechar(thebuf[bufptr++]))
	  			return 1;
      	}
    	bufptr = 0;
    	FD_SET(sock, &readers);
    	sel = select(sock + 1, &readers, NULL, NULL, (struct timeval *) 0);
    	if (sel == -1) {
			if (errno != EINTR)	{ /* ^Z will do this */
	    		perror("select");
	    		return -1;
	  		}
			continue;
    	}
    	if (FD_ISSET(sock, &readers)) {
			bufdata = read(sock, thebuf, 1000);
			if (!bufdata) {
	  			return -1;
			}
			if (bufdata < 0) {
	    		perror("read");
	    		return -2;
	  		}
    	}
  	}
}
