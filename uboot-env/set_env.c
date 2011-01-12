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
  char device[512] = "/dev/mmcblk0";
  int i = 1,ct = argc - 1;
	char * penv = NULL, * pdata = NULL;
	int bfd;
	unsigned char * buf, * pstr;
  uint32_t crcv, crcnv;
	unsigned int env_size = CONFIG_ENV_SIZE - sizeof(uint32_t);
	int offset = 0;
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
			break;
    }
   i++;
  }
	if(penv == NULL)
		return 0;
	if(i == ct)
  	pdata = argv[i+1];

	bfd=open(device,O_RDONLY);
	if(bfd < 0){
			 perror("open");
			 return 1;
	}
	pstr = (unsigned char *)mmap(NULL,256*1024,PROT_READ,MAP_SHARED,bfd,offset);
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
			break;
		}
		while(*buf != '\0')
		{
				buf++;
		}
		buf++;
		if(*buf == '\0')
					break;
	}
	if (buf != '\0'){
	/*exist env remove it first*/	
	  unsigned char * fstr = buf + strlen(buf);
		if (*fstr == '\0' && *(fstr + 1) != '\0'){
			fstr++;
	  	memcpy(buf,fstr,256 * 1024 + (pstr - fstr));
			memset(buf + 256*1024 - fstr + pstr, 0, fstr - buf);
		}
		while(*buf!='\0' || *(buf+1) != '\0')
			buf++;
		buf++;
	}
	if(buf == '\0' && pdata != NULL)
	{
		/*new add env*/
		strncpy(buf,penv,strlen(penv));
		buf += strlen(penv);
		*buf = ' ';
		buf++;
		strncpy(buf,pdata,strlen(pdata));
	}
	crcnv = crc32(0,pstr + 4, env_size);
	if (crcnv != crcv)
		*((uint32_t *)pstr) = crcnv;
OUT:
	munmap(pstr,256*1024);
	return 0;
}

