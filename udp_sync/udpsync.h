/*********************************************************************
*filename: udpsync.h
*purpose: sync with the udp server
*edited by: Hake Huang(b20222@freescale.com) 
* modify form zhoulifa(zhoulifa@163.com) (http://zhoulifa.bokee.com)
* License: LGPL
* Thanks to: Google.com
*********************************************************************/

#ifndef _UDPSYNC_H_
#define _UDPSYNC_H_

#ifdef _CPLUSPLUS_
extern "C"{
#endif


#define SERV_PORT 12500
#define INTERVAL 300
#define DEBUG 1
#define LESTEN_PORT 13500

enum {eSTART, eSTOP, eREADY};

#ifdef _CPLUSPLUS_
}
#endif

#endif
