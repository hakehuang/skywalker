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
#include <ctype.h>

#include "udpsync.h"

#define MAX_SIZE 512
#define MAX_CLIENT_NUMBER 100
/*platform name string length*/
#define PSIZE 32

typedef struct link_node{
   char platform[PSIZE];
	 char kver[2*PSIZE];
	 char bip[256];
   int status;
   struct link_node *next;
} tlink_node;

typedef struct link_list{
  tlink_node * node;
} tlink_list;


static char address_tlb[MAX_CLIENT_NUMBER][50];
static int  status_table[MAX_CLIENT_NUMBER];
static int acs = 0; /* zero based*/
static int ilog = 0;
static int gStatus = eSTART;
static tlink_list mplist;

static char cmds[256]="/rootfs/wb/gen-html.sh";

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
				printf("open connenction\n");
        if(FD_ISSET(sockfd,&rdset))
        {
            socklen_t addr_len;
            char * tmesg;
            struct sockaddr_in c_addr;
            tlink_node * cnode = mplist.node;
            addr_len = sizeof(c_addr); 
            memset(mesg,0,MAX_SIZE);
            rlen = recvfrom(sockfd, mesg, sizeof(mesg) - 1, 0,
            (struct sockaddr *) &c_addr, &addr_len);
            if (rlen < 0) {
            perror("recvfrom");
            exit(errno);
            }
            mesg[rlen] = '\0';
            tmesg = strstr(mesg,"_");
            if(tmesg == NULL)
                tmesg = mesg;
            else{
                while(cnode){
                  char temp[PSIZE];
                  strncpy(temp,mesg,tmesg - mesg);
                  temp[tmesg - mesg] = 0; 
                  if(strcmp(temp,cnode->platform) == 0)
                        break;   
                  if(cnode->next == NULL){
                     /*not found the platform insert one*/
                     cnode->next =(tlink_node *)malloc(sizeof(tlink_node));
                     strncpy(cnode->next->platform,temp,PSIZE);
                     cnode->next->status = eSTART;
                     strcpy(cnode->next->kver,"0");
										 memset(cnode->next->bip,0,256);
										 cnode=cnode->next;
										 cnode->next = NULL;
                     break;
                  }  
		  						cnode = cnode->next;
                }
								/*now cnode is the matched board or a new one*/
                if(cnode == NULL)
                {
                   cnode = (tlink_node *)malloc(sizeof(tlink_node));
                   strncpy(cnode->platform,mesg,tmesg - mesg);
                   cnode->platform[tmesg - mesg] = 0;
                   strcpy(cnode->kver,"0");
                   cnode->status = eSTART;
                   cnode->next = 0;
                   mplist.node = cnode;
                }
                tmesg++;
                if(NULL != strstr(tmesg,"NOREADY")){
	           			gStatus = eSTART;
                  cnode->status = eSTART; 
                }else if(NULL != strstr(tmesg,"READY")){
									char * kver;
		   						gStatus = eREADY;
                  cnode->status = eREADY;
									kver = strstr(tmesg,"KVER");
									if(NULL != kver)
									{
										memset(cnode->kver, 0, sizeof(cnode->kver));
										sprintf(cnode->kver,"KVER %s",kver+4);
										uprintf("kernel version is %s\n", cnode->kver);
									}
                }else if(NULL != strstr(tmesg,"TESTEND")){
									/*receive test finsih for certain platform*/
                  char icmd[256];
									sprintf(icmd,"%s %s",cmds,cnode->platform);
									uprintf("execute %s\n", icmd);
									system(icmd);
								}else if(NULL != strstr(tmesg,"UNREGIST")){
									memset(cnode->bip,0,256);
								}else if(NULL != strstr(tmesg,"REGIST")){
									sprintf(cnode->bip,"%s",inet_ntoa(c_addr.sin_addr));
								}else{
									gStatus = cnode->status; 
                	if (gStatus == eREADY){
		    						rlen = sendto(sockfd, "ACK", 3, 0,(struct sockaddr *) &c_addr, addr_len);
		    						rlen = sendto(sockfd, cnode->kver, strlen(cnode->kver), 0,(struct sockaddr *) &c_addr, addr_len);
									}else if(gStatus == eSTART)
		   							rlen = sendto(sockfd, "RES", 3, 0,(struct sockaddr *) &c_addr, addr_len);
								}
           		}//tmesg == NULL
            		if(NULL != strstr(tmesg,"FLUSH")){
               		while(cnode){
                   tlink_node * tmp = cnode;
                   cnode = cnode->next;
                   free(tmp); 
               		}
               	mplist.node = NULL;
	      				rlen = sendto(sockfd, "RES", 3, 0,(struct sockaddr *) &c_addr, addr_len);
            	}else if(NULL != strstr(tmesg,"EXIT")){
	    rlen = sendto(sockfd, "FNT", 3, 0,(struct sockaddr *) &c_addr, addr_len);
			         uprintf("exit program\n");
								goto EXIT;
				 }else if(NULL != strstr(tmesg,"HELLO")){
               printf("check all data\n");
               while(cnode){
		  rlen = sendto(sockfd, cnode->platform, strlen(cnode->platform), 0,(struct sockaddr *) &c_addr, addr_len);
                  printf("platform %s\n",cnode->platform);
                  if (cnode->status == eREADY)
		  	rlen = sendto(sockfd, "ready", 5, 0,(struct sockaddr *) &c_addr, addr_len);
                  else
		  	rlen = sendto(sockfd, "no ready", 8, 0,(struct sockaddr *) &c_addr, addr_len);
		  	rlen = sendto(sockfd, cnode->bip, strlen(cnode->bip), 0,(struct sockaddr *) &c_addr, addr_len);
                  cnode = cnode->next;
               }
	      rlen = sendto(sockfd, "LIST", 4, 0,(struct sockaddr *) &c_addr, addr_len);
            }else if(NULL != strstr(tmesg,"UNREGIST")){
	      rlen = sendto(sockfd, "UREG", 4, 0,(struct sockaddr *) &c_addr, addr_len);
            }else if(NULL != strstr(tmesg,"REGIST")){
	      rlen = sendto(sockfd, "REG", 3, 0,(struct sockaddr *) &c_addr, addr_len);
						}else{
		  rlen = sendto(sockfd, "query format <platform name>_hello",34,0,(struct sockaddr *) &c_addr, addr_len);
            }
            /*acknowledge client to over*/
	    rlen = sendto(sockfd, "FNT", 3, 0,(struct sockaddr *) &c_addr, addr_len);
            check_list(inet_ntoa(c_addr.sin_addr), ntohs(c_addr.sin_port));
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
EXIT:
     if(ilog)
        close(fd);
}

int daemon_init(void)   
{   
     pid_t pid;   
   if((pid = fork()) < 0)   
     return(-1);   
   else if(pid != 0)   
     exit(0); /* parent exit */   
 /* child continues */   
   setsid(); /* become session leader */   
   umask(0); /* clear file mode creation mask */   
   close(0); /* close stdin */   
   return(0);   
}  


int main(int argc, char **argv)
{
    int sockfd;
    int r;
    struct sockaddr_in servaddr;
  /*  pthread_t  threadA, threadB;*/

    daemon_init();
 
    if(argc >= 3)
    {
       printf("log start\n");
       if(strcmp(argv[2],"-l") == 0)
          ilog = 1;
    }
		if(argc ==4){
			 printf("execute cmd file %s after test\n",argv[3]);
       memset(cmds,0,sizeof(cmds));
			 strcpy(cmds,argv[3]);		   
		}

    mplist.node = NULL;
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
	  /*clean up*/	
		{
      tlink_node * cnode =  mplist.node; 
		  while(cnode){
         tlink_node * tmp = cnode;
         cnode = cnode->next;
         free(tmp); 
		  }
		}
    return 0;
}

