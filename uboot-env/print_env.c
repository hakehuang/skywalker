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


int main(int argc, char ** argv)
{
  char device[512] = "/dev/mmcblk0";
  int i = 1,ct = argc - 1;
	char * penv = NULL;
	int bfd;
	unsigned char * buf, * pstr;
  uint32_t crcv;
	int offset = 768 * 1024;
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
				offset = 768 * 1024;
    }else if( 0 == strcmp(argv[i], "-f")){
		   if(i == ct)
			 {
				 printf("-d give a path and file name\n");
				 return -1;
			 }
        memset(device,0,sizeof(device));
        sprintf(device,"%s",argv[++i]);
				offset = 0;
		}else if(argv[i] != NULL){
      penv=argv[i];
    }
   i++;
  } 
  
	bfd=open(device,O_RDONLY);
	if(bfd < 0){
			 perror("open");
			 return 1;
	}
	pstr = (unsigned char *)mmap(NULL,CONFIG_ENV_SIZE,PROT_READ,MAP_SHARED,bfd,offset);
  if (pstr < 0)
	{
	  perror("mmap");
		return 2;
	}
	crcv = (uint32_t)pstr;
	buf = pstr + 4;/*skip the crc nubber*/
  while(*buf != '\0')
	{
		if(penv && 0 == strncmp(buf,penv,strlen(penv)))
		{
			char * pdata = buf + strlen(penv) + 1; 
			printf("%s\n", pdata);
			break;
		}
		if(penv == NULL)
			printf("%s\n",buf);
		while(*buf != '\0')
		{
				buf++;
		}
		buf++;
		if(*buf == '\0')
					break;
	}
OUT:
	munmap(pstr,CONFIG_ENV_SIZE);
	return 0;
}

