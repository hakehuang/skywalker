/*********************************************************************
*filename: udpserver.c
*purpose: sync with the udp server
*edited by: Hake Huang(b20222@freescale.com) 
* modify form zhoulifa(zhoulifa@163.com) (http://zhoulifa.bokee.com)
* License: LGPL
* Thanks to: Google.com
*********************************************************************/

#include<sys/socket.h>
#include<string.h>
#include<netinet/in.h>
#include <arpa/inet.h>
#include<stdio.h>
#include<stdlib.h>
#include<fcntl.h>
#include<sys/stat.h>
#include<unistd.h>
#include<errno.h>
#include<sys/select.h>
#include<sys/time.h>
#include<unistd.h>
#include<sys/types.h>
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <pthread.h>


#include "udpsync.h"

#define MAX_SIZE 512
#define MAX_CLIENT_NUMBER 100

static char address_tlb[MAX_CLIENT_NUMBER][50];
static int  status_table[MAX_CLIENT_NUMBER];
static int acs = 0; /* zero based*/
static int ilog = 0;
static int gStatus = eSTART;


#if DEBUG
#define uprintf printf
#else 
#define uprintf(a, b ...) 
#endif

int check_list(char * in, int port)
{
    int i;
    uprintf("receive from client %d at %x \n",acs, (unsigned int)&acs);
    uprintf("addr is %s\n", in);
    for(i = 0; i < acs; i++)
    {
        if(strcmp(in,address_tlb[i])==0)
        {
            status_table[i] += 1;
						uprintf("address table meet %d,%s\n",i, address_tlb[i]);
            return 1;   
        }
    }
		printf("add to address table\n");
    if(acs < MAX_CLIENT_NUMBER)
    {
      status_table[acs] = 1;
      strcpy(address_tlb[acs],in);
			uprintf("address table add %d,%s\n",acs, address_tlb[acs]);
      acs++;
    }
   return 0; 
}

void * message_sock(void * in)
{
    int sockfd;
    struct sockaddr_in servaddr;
     int ret,fd;
    mode_t fdmode = (S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
    char mesg[MAX_SIZE];
    fd_set rdset;
    struct timeval tv;
    int rlen,wlen;
    int i;
    
    
    sockfd = socket(AF_INET,SOCK_DGRAM,0); /*create a socket*/

    /*init servaddr*/
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(LESTEN_PORT);
    
    /*bind address and port to socket*/
    if(bind(sockfd,(struct sockaddr *)&servaddr,sizeof(servaddr)) == -1)
    {
            perror("bind error");
            exit(-1);
    }
    
    while(1)
    {
        tv.tv_sec = 1;
        tv.tv_usec = 0;

        FD_ZERO(&rdset);
        FD_SET(sockfd,&rdset);

	if(gStatus == eSTOP)
	   break;
       
        ret = select(sockfd+1,&rdset,NULL,NULL,&tv);
        if(ret == -1)
        {
            printf("select error %s\n",strerror(errno));
            exit(-1);
        }
        else if(ret==0)
        {
           /* printf("select timeout,continue circle\n");*/
            /* now check the status of client*/
            
            continue;
        }
       
        if(FD_ISSET(sockfd,&rdset))
        {
            socklen_t addr_len;
            struct sockaddr_in c_addr;
            
            addr_len = sizeof(c_addr);
            
            memset(mesg,0,MAX_SIZE);
            rlen = recvfrom(sockfd, mesg, sizeof(mesg) - 1, 0,
            (struct sockaddr *) &c_addr, &addr_len);
            if (rlen < 0) 
            {
            perror("recvfrom");
            exit(errno);
            }
            mesg[rlen] = '\0';
            if(strcmp(mesg,"Get")==0)
            {
                rlen = sendto(sockfd, address_tlb, sizeof(address_tlb), 0,(struct sockaddr *) &c_addr, addr_len);
                if (rlen < 0) 
                    printf("\n\rsend error.\n\r");
                rlen = sendto(sockfd, status_table, sizeof(status_table), 0,(struct sockaddr *) &c_addr, addr_len);
                if (rlen < 0) 
                    printf("\n\rsend error.\n\r");
            }else if(strcmp(mesg,"Stop")==0){
							gStatus = eSTOP;
						}else if(strcmp(mesg,"hello") == 0){
							rlen = sendto(sockfd, "ACK", 3, 0,(struct sockaddr *) &c_addr, addr_len);
                if (rlen < 0) 
                    printf("\n\rsend error.\n\r");
							}
        }
    
    }/*while*/
}

void * check_client( void * in)
{
    int i;
    char env[64]; 
    uprintf("child client start!\n"); 
    while(1)
    {
         if(gStatus == eSTOP)
	     break;
        /*check every 5 mintues*/
        sleep(INTERVAL);
         uprintf("server updating %d at %x\n",acs,(unsigned int)&acs);
        if(acs)
        {
            memset(env,0,sizeof(env));
            uprintf("server updating\n");
            for(i =0; i < acs; i++)
            {
              status_table[i] -= 1;
              uprintf("now check %d\n", acs);
              if(status_table[i] <= -2)
              {
	        char inform[16];
                sprintf(inform," %d",i);
                /* lost contact in 10 minutes */
                strcat(env,inform);
                uprintf("found lost\n");
              }
            }
	    uprintf("env is %s\n", env);
        }
    
    }/*while*/  

}

void recvUDP(char * name,int sockfd)
{
    int ret,fd;
    mode_t fdmode = (S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
    char mesg[MAX_SIZE];
    fd_set rdset;
    struct timeval tv;
    int rlen,wlen;
    int i;
    
    if(NULL == name)
        ilog = 0;    
    
    if(ilog)
    {
        fd = open(name,O_RDWR|O_CREAT|O_APPEND,fdmode);
        if(fd == -1)
        {
            printf("open file %s error:%s",name,strerror(errno));
            exit(-1);
        }
    }

    while(1)
    {
        tv.tv_sec = 1;
        tv.tv_usec = 0;

        FD_ZERO(&rdset);
        FD_SET(sockfd,&rdset);

	if(gStatus == eSTOP)
	    break;
       
        ret = select(sockfd+1,&rdset,NULL,NULL,&tv);
        if(ret == -1)
        {
            printf("select error %s\n",strerror(errno));
            exit(-1);
        }
        else if(ret==0)
        {
           /* printf("select timeout,continue circle\n");*/
            /* now check the status of client*/     
            continue;
        }
        if(FD_ISSET(sockfd,&rdset))
        {
            socklen_t addr_len;
            struct sockaddr_in c_addr;
            addr_len = sizeof(c_addr); 
            memset(mesg,0,MAX_SIZE);
            rlen = recvfrom(sockfd, mesg, sizeof(mesg) - 1, 0,
            (struct sockaddr *) &c_addr, &addr_len);
            if (rlen < 0) {
            perror("recvfrom");
            exit(errno);
            }
            mesg[rlen] = '\0';
						if(NULL != strstr("READY",mesg))
						{
						  gStatus = eREADY;
							printf("build image ready.\n");
						}else if(NULL != strstr("NOREADY",mesg)){
							gStatus = eSTART;
							printf("build image in process.\n");
						}
            check_list(inet_ntoa(c_addr.sin_addr), ntohs(c_addr.sin_port));
						if (gStatus == eREADY)
							rlen = sendto(sockfd, "ACK", 3, 0,(struct sockaddr *) &c_addr, addr_len);
						else if(gStatus == eSTART){
							rlen = sendto(sockfd, "RES", 3, 0,(struct sockaddr *) &c_addr, addr_len);
						}
            if (rlen < 0) 
               printf("\n\rsend error.\n\r");
            if(ilog)
            {
                wlen = write(fd,mesg,rlen);
                if(wlen != rlen )
                {
                    printf("write error %s\n",strerror(errno));
                    exit(-1);
                }
            }       
        }
    }/*while*/
     if(ilog)
        close(fd);
}



int main(int argc, char **argv)
{
    int sockfd;
    int r;
    struct sockaddr_in servaddr;
    pthread_t  threadA, threadB;

    if(argc == 3)
    {
       printf("log start\n");
       if(strcmp(argv[2],"-l") == 0)
          ilog = 1;
    }


    sockfd = socket(AF_INET,SOCK_DGRAM,0); /*create a socket*/

    /*init servaddr*/
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(SERV_PORT);

    /*bind address and port to socket*/
    if(bind(sockfd,(struct sockaddr *)&servaddr,sizeof(servaddr)) == -1)
    {
            perror("bind error");
            exit(-1);
    }
    
    gStatus = eSTART;
    r = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, r & ~O_NONBLOCK);
   /* 
    if( 0 != pthread_create(&threadA,NULL,check_client,NULL))
    {
      perror("pthread");
      exit(1);
    }
    
    if( 0 != pthread_create(&threadB,NULL,message_sock,NULL))
    {
      perror("pthread");
      exit(1);
    }
   */
    
    recvUDP(argv[1],sockfd);

    return 0;

}

