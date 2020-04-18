//*********************************************************************
//* PgSQL                                             Sylvain Benilan *
//* Copyright (C) 2005 xl. All Rights Reserved                        *
//*********************************************************************

#ifndef __PGSQL_DRIVER_H__
#define __PGSQL_DRIVER_H__

extern void PQunescapeBytea_mem(blob* p, const unsigned char *strtext, size_t maxlen);
extern char *pg_encoding_to_char(int encoding_id);

#endif
