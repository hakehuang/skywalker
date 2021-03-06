/*********************************************************************
*filename: udpclient.c
*purpose: sync with the udp server
*edited by: Hake Huang(b20222@freescale.com) 
* modify form zhoulifa(zhoulifa@163.com) (http://zhoulifa.bokee.com)
* License: LGPL
* Thanks to: Google.com
*********************************************************************/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <errno.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <fcntl.h>

#include "udpsync.h"

int main(int argc, char **argv)
{
	struct sockaddr_in s_addr;
	int sock;
	int addr_len;
	int len, ret;
	char buff[1024];
	int ack = 0;
	struct timeval tv;
	socklen_t cmsg_len;

	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
		perror("socket");
		exit(errno);
	} else
		printf("create socket.\n\r");

	s_addr.sin_family = AF_INET;
	if (argv[2])
		s_addr.sin_port = htons(atoi(argv[2]));
	else
		s_addr.sin_port = htons(SERV_PORT);
	if (argv[1])
		s_addr.sin_addr.s_addr = inet_addr(argv[1]);
	else {
		printf("need server address\n");
		exit(0);
	}
	tv.tv_sec = 2;
	tv.tv_usec = 10000;
	cmsg_len =sizeof(struct timeval); 
	setsockopt( sock, SOL_SOCKET, SO_SNDTIMEO , &tv, cmsg_len ); 
	setsockopt( sock, SOL_SOCKET, SO_RCVTIMEO , &tv, cmsg_len ); 
	addr_len = sizeof(s_addr);
	if (argv[3])
		strcpy(buff, argv[3]);
	else
		strcpy(buff, "hello");
	while (1) {
		static count=0;
		if (ack == 0) {
#if 0
			if (connect(sock, (struct sockaddr *)&s_addr, addr_len)
			    == -1) {
				perror("connect");
				return 3;
			}
#endif
			len =
			    sendto(sock, buff, strlen(buff), 0,
				   (struct sockaddr *)&s_addr, addr_len);
			if (len < 0) {
				perror("send");
				printf("\n\rsend error.\n\r");
				return 3;
			}
		}
		if (len) {
			ssize_t rlen;
			socklen_t addr_len;
			struct sockaddr_in c_addr;
			char mesg[512];
			fd_set socks;
 			struct timeval t;
			FD_ZERO(&socks);
			FD_SET(sock, &socks);
			memset(mesg, 0, 512);
			addr_len = sizeof(c_addr);
 			t.tv_sec = 5;
			printf("start communication\n");
 			if (select(sock + 1, &socks, NULL, NULL, &t))
			{	
				rlen = recvfrom(sock, mesg, sizeof(mesg) - 1, 0,
					(struct sockaddr *)&c_addr, &addr_len);
				if (rlen < 0) {
					perror("recvfrom");
					exit(errno);
				}
				printf("receiver from server %s : %d\n", mesg,
			       strlen(mesg));
				if (NULL != strstr(mesg, "INIT"))
					ack = 0;
				else
					ack = 1;
				if(count++ == 100)
				{
					printf("receive message timeout\n");
					break;
				}
				if (NULL != strstr(mesg, "FNT")) {
					printf("receive end message\n");
					break;
				}
			} else {
				printf("receive message timeout\n");
				break;
			}
		} else {
			perror("send");
			break;
		}
		printf("check again\n");
	}
#if 0
	while (1) {
		len =
		    sendto(sock, buff, strlen(buff), 0,
			   (struct sockaddr *)&s_addr, addr_len);
		if (len < 0) {
			printf("\n\rsend error.\n\r");
			return 3;
		}
		sleep(INTERVAL);
		fprintf(stderr, "send success.\n\r");
	}
#endif
	/* printf("send success.\n\r"); */
	return 0;
}
