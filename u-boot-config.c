/*generate the u-boot config
 * 
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
		 printf("%s, -s,<infile>,<outfile> \n", argv[0]);
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
	 #if 0
	 while(env_size > 1){
	 envs.crc = crc32(0,envs.data, env_size);
	 printf("crc32 %lx, at %d \n", envs.crc, env_size);
	 env_size--;
	 if(envs.crc == 0x7d1690a1)
		  break;
   }
#endif
	 envs.crc = crc32(0,envs.data, env_size);
   /*write to auto src image*/
   OUT = fopen(argv[3],"wb");
	 if(OUT == NULL){
		 printf("can not create file %s\n",argv[3]);
		 return 1;
		 }
	 pdata = envs.data;
	 printf("data %lx, first line %s \n", envs.crc, envs.data);
#if 1
	 {
		 int i = 0;
	 while(i < 1024){
		 printf("%x ", envs.data[i]);
		 i++;
     if(i%32 == 0)
			 printf("\n");
		 }
	}
#endif
   len = fwrite(&envs,sizeof(envs),1, OUT);
	 fclose(OUT);
   return 0;
}
