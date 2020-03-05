#ifndef __CHARGEN_H__
#define __CHARGEN_H__

#include "lwip/opt.h"

#if LWIP_SOCKET

#ifdef __cplusplus
extern "C" {
#endif

void chargen_init(void);

#ifdef __cplusplus
}
#endif

#endif /* LWIP_SOCKET */


#endif /* __CHARGEN_H__ */
