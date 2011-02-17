/*
 * Copyright (C) 2010 Freescale Semiconductor, Inc. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>

uint32_t  crc32 (uint32_t crc, const unsigned char *buf, unsigned int len);

int main(int argc, char ** argv)
{
  int i = 1,ct = argc - 1;
	char * penv = NULL, * pdata = NULL;
	int bfd;
	unsigned char * buf, * pstr;
  uint32_t crcv, crcnv;
	unsigned int env_size = CONFIG_ENV_SIZE - sizeof(uint32_t);
	int offset = 768 * 1024;
	int need_update = 0;
  char device[512] = "/dev/mmcblk0";
	char env_name[256];
  while(1)
  {
   if(i > ct)
     break;
   if(0==strcmp(argv[i],"-d")){
		   if(i == ct)
			 {
				 printf("-d give a device node\n");
				 return -1;
			 }
        memset(device,0,sizeof(device));
        sprintf(device,"%s",argv[++i]);
				offset = 768*1024;
    }else if(0 == strcmp(argv[i],"-f")){
			if(i == ct)
			 {
				 printf("-d give a device node\n");
				 return -1;
			 }
        memset(device,0,sizeof(device));
        sprintf(device,"%s",argv[++i]);
				offset = 0;
		}else if(argv[i] != NULL){
      penv=argv[i];
			sprintf(env_name, "%s=", penv);
			printf("penv is set to %s\n", penv);
			break;
    }
   i++;
  }
	if(penv == NULL)
		return 0;
	if(++i == ct){
  	pdata = argv[i];
		printf("set to %s\n",pdata);
	}

	bfd=open(device,O_RDWR);
	if(bfd < 0){
			 perror("open");
			 return 1;
	}
	pstr = (unsigned char *)mmap(NULL,CONFIG_ENV_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED,bfd,offset);
  if (pstr < 0)
	{
	  perror("mmap");
		return 2;
	}
	crcv = (uint32_t)pstr;
	buf = pstr + sizeof(uint32_t);/*skip the crc nubber*/
  while(*buf != '\0')
	{
		if(penv && 0 == strncmp(buf,env_name,strlen(env_name)))
			break;
		while(*buf != '\0')
				buf++;
		buf++;
		if(*buf == '\0')
					break;
	}
	if (buf != '\0'){
		/*exist env remove it first*/	
	  unsigned char * fstr = buf + strlen(buf);
		int gsize = 0;
		if(*(fstr + 1) != '\0'){
			/*not the last one*/
			fstr++;
			gsize = CONFIG_ENV_SIZE - (long)(fstr - pstr);
			printf("the success is %s\n", fstr);
	  	memcpy(buf,fstr,gsize);
		  memset(pstr + gsize, '\0', (long)(fstr - buf));
			printf("next env is %s\n", buf);
			while(*buf!='\0' || *(buf+1) != '\0')
				buf++;
			buf++;
		}else{
			/*is the last one*/
			printf("the buff is at %s \n", buf);
		  memset(buf, '\0', CONFIG_ENV_SIZE - (long)(buf - pstr));	
		}
		need_update = 1;
	}
	if(*buf == '\0' && pdata != NULL)
	{
		/*new add env*/
		char * pp = buf;
		strncpy(pp,penv,strlen(penv));
		pp += strlen(penv);
		*pp = '=';
		pp++;
		strncpy(pp,pdata,strlen(pdata));
		printf("the env set to %s\n",buf);
		need_update = 1;
	}
	if(need_update){
		crcnv = crc32(0,pstr + sizeof(uint32_t), env_size);
		if (crcnv != crcv)
			*((uint32_t *)pstr) = crcnv;
	}
OUT:
	munmap(pstr,CONFIG_ENV_SIZE);
	fsync(bfd);
	close(bfd);
	return 0;
}

