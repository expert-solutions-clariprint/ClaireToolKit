

T_A			:: 1		/* host address */
T_NS		:: 2		/* authoritative server */
T_MD		:: 3		/* mail destination */
T_MF		:: 4		/* mail forwarder */
T_CNAME		:: 5		/* canonical name */
T_SOA		:: 6		/* start of authority zone */
T_MB		:: 7		/* mailbox domain name */
T_MG		:: 8		/* mail group member */
T_MR		:: 9		/* mail rename name */
T_NULL		:: 10		/* null resource record */
T_WKS		:: 11		/* well known service */
T_PTR		:: 12		/* domain name pointer */
T_HINFO		:: 13		/* host information */
T_MINFO		:: 14		/* mailbox information */
T_MX		:: 15		/* mail routing information */
T_TXT		:: 16		/* text strings */
T_RP		:: 17		/* responsible person */
T_AFSDB		:: 18		/* AFS cell database */
T_X25		:: 19		/* X_25 calling address */
T_ISDN		:: 20		/* ISDN calling address */
T_RT		:: 21		/* router */
T_NSAP		:: 22		/* NSAP address */
T_NSAP_PTR	:: 23		/* reverse NSAP lookup (deprecated) */
T_SIG		:: 24		/* security signature */
T_KEY		:: 25		/* security key */
T_PX		:: 26		/* X.400 mail mapping */
T_GPOS		:: 27		/* geographical position (withdrawn) */
T_AAAA		:: 28		/* IP6 Address */
T_LOC		:: 29		/* Location Information */
	/* non standard */
T_UINFO		:: 100		/* user (finger) information */
T_UID		:: 101		/* user ID */
T_GID		:: 102		/* group ID */
T_UNSPEC	:: 103		/* Unspecified format (binary data) */
	/* Query type values which do not appear in resource records */
T_AXFR		:: 252		/* transfer zone of authority */
T_MAILB		:: 253		/* transfer mailbox records */
T_MAILA		:: 254		/* transfer mail agent records */
T_ANY		:: 255		/* wildcard match */


resolve(domain:string, ty:integer) : set[string] ->
	let res := set<string>()
	in (externC("
			static int init = 0;
			u_char ubuf[512]; /* defined in arpa/nameser.h */
		    int responseLen;             /* buffer length */
			ns_msg handle;  /* handle for response message */
			int rrnum;  /* resource record number */
		    ns_rr rr;   /* expanded resource record */

			if (init == 0) {
				if (res_init() == -1)
					Cerrorno(74, _string_(\"res_init\"), 0);
				init = 1;
			}
		    
			responseLen = res_search(domain, C_IN, ty, ubuf, NS_PACKETSZ);
			
			if (responseLen != -1) {

				ns_initparse(ubuf, responseLen, &handle);

				for(rrnum = 0; rrnum < ns_msg_count(handle, ns_s_an); rrnum++) {

			        if (ns_parserr(&handle, ns_s_an, rrnum, &rr)) break;
		
					char buf[2048];

					size_t rdlen = ns_rr_rdlen(rr);
					const u_char *rdata = ns_rr_rdata(rr);
					 if(ns_rr_type(rr) == ns_t_a) {
						if (rdlen == NS_INADDRSZ) {
							inet_ntop(AF_INET, rdata, buf, 2048);
							res->addFast(_string_(GC_STRING(copy_string(buf))));
						}
					} else if(ns_rr_type(rr) == ns_t_aaaa) {
						if (rdlen == NS_IN6ADDRSZ) {
							inet_ntop(AF_INET6, rdata, buf, 2048);
							res->addFast(_string_(GC_STRING(copy_string(buf))));
						}
					} else if(ns_rr_type(rr) == ns_t_loc) {
						loc_ntoa(rdata, buf);
						res->addFast(_string_(GC_STRING(copy_string(buf))));
					} else if(ns_rr_type(rr) == ns_t_mx) {
						ns_name_uncompress(ns_msg_base(handle), ns_msg_end(handle), rdata + 2, buf, sizeof(buf));
						res->addFast(_string_(GC_STRING(copy_string(buf))));
					} else {
						ns_name_uncompress(ns_msg_base(handle), ns_msg_end(handle), rdata, buf, sizeof(buf));
						res->addFast(_string_(GC_STRING(copy_string(buf))));
					}
				}
			}"),
		res)


