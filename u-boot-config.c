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

#include <environment.h>

#define MAX_BUF 1024
uint32_t  crc32 (uint32_t crc, const unsigned char *buf, unsigned int len);


int main(int argc, char ** argv)
{
	size_t len = 0;
	FILE * IN, *OUT;
	unsigned char *pdata;
	unsigned int env_size=CONFIG_ENV_SIZE - sizeof(uint32_t);
	env_t envs;
	char buf[MAX_BUF];
  
	 if(strcmp(argv[1], "-h") == 0 || argc < 4){
		 printf("%s -s <infile> <outfile> \n", argv[0]);
		 return 0;
		 }

   memset(&envs,0,sizeof(envs));
   /*read from config file*/
   IN = fopen(argv[2],"r");
	 if(IN == NULL){
		 printf("can not read file %s\n",argv[2]);
		 return 1;
		 }
   fseek(IN, 0L,SEEK_SET);
	 pdata = envs.data;
   while(!feof(IN)){
	 	memset(buf,0,sizeof(buf));
	 	fgets(buf,MAX_BUF - 32,IN);
		len = strlen(buf);
		printf("read env %s, len %d\n", buf, len);
	 	if(len > 1 ){
			 memcpy(pdata, buf, len);
			 pdata = pdata + len - 1;
			 *pdata = 0;
			 pdata++;
	 	}
	 }
	 fclose(IN);
	 printf("env size %d == %d\n", env_size, sizeof(envs.data));
	 envs.crc = crc32(0,envs.data, env_size);
   /*write to auto src image*/
   OUT = fopen(argv[3],"wb");
	 if(OUT == NULL){
		 printf("can not create file %s\n",argv[3]);
		 return 1;
		 }
	 pdata = envs.data;
	 printf("data %lx, first line %s \n", envs.crc, envs.data);
   len = fwrite(&envs,sizeof(envs),1, OUT);
	 fclose(OUT);
   return 0;
}
