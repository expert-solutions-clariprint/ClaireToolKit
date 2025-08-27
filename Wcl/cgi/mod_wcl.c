/* ====================================================================
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2000-2003 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Apache" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software wit
 hout prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 * Portions of this software are based upon public domain software
 * originally written at the National Center for Supercomputing Applications,
 * University of Illinois, Urbana-Champaign.
 */

/*****************************************************************************/
/**  wcl_mod.c                                              Sylvain Benilan **/
/**  many things are issued from mod_cgi.c ...                              **/
/**  Copyright (C) 2004 xl, Sylvain Benilan. All Rights Reserved.           **/
/*****************************************************************************/

#include "apr.h"
#include "apr_strings.h"
#include "apr_thread_proc.h"    /* for RLIMIT stuff */
#include "apr_optional.h"
#include "apr_buckets.h"
#include "apr_lib.h"

#ifdef LION
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#define X64
#endif


#define APR_WANT_STRFUNC
#include "apr_want.h"

#define CORE_PRIVATE

#include "util_filter.h"
#include "ap_config.h"
#include "httpd.h"
#include "http_config.h"
#include "http_request.h"
#include "http_core.h"
#include "http_protocol.h"
#include "http_main.h"
#include "http_log.h"
#include "util_script.h"
#include "ap_mpm.h"
#include "mod_core.h"

#ifndef CLPC
#include <sys/un.h>
#include <netdb.h>
#endif

#define MOD_WCL_VERSION "v1.1.0"

module AP_MODULE_DECLARE_DATA wcl_module;


/*****************************************************************************/
/**   1. Debugging                                                          **/
/*****************************************************************************/

//<sb> compile with "-DDEBUG_WCL -DDEBUG_TTY" to have debug traces
// written on tty (require to start apache in single request mode -X)
// otherwise compile with "-DDEBUG_WCL" such traces are written
// in the file "logs/mod_wcl.log"/


#ifdef DEBUG_WCL
	#ifdef DEBUG_TTY
		#define DEBUG_FILE "/dev/tty"
	#else
		#define DEBUG_FILE "/var/log/apache2/mod_wcl.log"
	#endif
#endif


#ifdef DEBUG_WCL
	FILE *dbg = NULL;
	#ifdef X64
	#define PRINT_DEBUG(args) { \
			if(dbg == NULL) dbg = fopen(DEBUG_FILE, "a"); \
			if(dbg) { \
					fprintf(dbg, "[%ld]", getpid()); \
				fprintf args ; \
				fflush(dbg); } }
	#else
	#define PRINT_DEBUG(args) { \
			if(dbg == NULL) dbg = fopen(DEBUG_FILE, "a"); \
			if(dbg) { \
					fprintf(dbg, "[%d]", getpid()); \
				fprintf args ; \
				fflush(dbg); } }
	#endif
#else
	#define PRINT_DEBUG(args)
#endif


#if defined(DEBUG_WCL_POST)
	#define PRINT_DEBUG_POST(data, len) { \
			if(dbg == NULL) dbg = fopen(DEBUG_FILE, "a"); \
			if(dbg) {int i = 0; int sz = (int)len; \
				fprintf(dbg,"DATAS(%d)[", len); \
				for(;i < sz;i++) { \
					if(data[i] == '\r') fprintf(dbg,"\\r"); \
					else if(data[i] == '\0') fprintf(dbg,"\\0"); \
					else if(data[i] == '\n') fprintf(dbg,"\\n"); \
					else if(data[i] == '\t') fprintf(dbg,"\\t"); \
					else if(data[i] == '\\') fprintf(dbg,"\\\\"); \
					else putc(data[i],dbg); }\
				fprintf(dbg,"]\n"); \
				fflush(dbg); } }
#else
	#define PRINT_DEBUG_POST(data, len)
#endif
            

/*****************************************************************************/
/**   2. Configuration stuff                                                **/
/*****************************************************************************/


//<sb> per-directory config
typedef struct {
	apr_pool_t *pool;
	int starter_pid;
	void *next;
    const char *command;
    const char *tracefile;
    const char *filefilter;
    const char *sessionpath;
    const char *sessionname;
    const char *uploadpath;
    const char *soapserver;
    const char *maxpoststr;
    const char *casperip;
    const char *index;
    apr_port_t casperport;
    apr_size_t maxpost;
    int havemaxpost;
    int timeout;
    int iscasper;
	apr_proc_t *casper_proc;
	char *misconfigured_casper;
    apr_table_t *userenv;
    const char *autogzip;
	char* document_root;
	char *server_name;
    char *confdir; }			wcl_per_dir_conf;


// <sb> allow global chaining of configs
wcl_per_dir_conf *first_wcl_config = NULL;
wcl_per_dir_conf *current_wcl_config = NULL;

#define MERGE_STRING(field) \
	if (child-> field) \
    	c-> field = apr_pstrdup(p, child-> field); \
	else if(parent-> field) \
    	c-> field = apr_pstrdup(p, parent-> field); \
    else c-> field = NULL;


//<sb> merge dir configs
static void *merge_wcl_config(apr_pool_t *p, void *base, void *overrides) {
    wcl_per_dir_conf *c = (wcl_per_dir_conf*)apr_pcalloc(p, sizeof(wcl_per_dir_conf));
	c->pool = p;
	c->starter_pid = getpid();
    wcl_per_dir_conf *parent = base;
	wcl_per_dir_conf *child = overrides;
	PRINT_DEBUG((dbg,"merge_wcl_config [%s] with [%s]\n", parent->confdir, child->confdir))
	#ifdef X64
	PRINT_DEBUG((dbg,"                 [%lu] with [%lx]\n",(unsigned long) parent, (unsigned long)child))
	#else
	PRINT_DEBUG((dbg,"                 [%lu] with [%x]\n",(unsigned long) parent, (unsigned long)child))
	#endif
	
	c->userenv = apr_table_overlay(p, parent->userenv, child->userenv);
	MERGE_STRING(command)
	MERGE_STRING(index)
    MERGE_STRING(tracefile)
    MERGE_STRING(filefilter)
    MERGE_STRING(sessionpath)
    MERGE_STRING(sessionname)
    MERGE_STRING(uploadpath)
    MERGE_STRING(soapserver)
	c->misconfigured_casper = child->misconfigured_casper;
    if(parent->havemaxpost && !child->havemaxpost) {
    	c->havemaxpost = 1;
    	c->maxpost = parent->maxpost;
	} else {
		c->havemaxpost = child->havemaxpost;
		c->maxpost = child->maxpost;
	}
    if(parent->timeout != -1 && child->timeout == -1)
    	c->timeout = parent->timeout;
	else c->timeout = child->timeout;
	
	if(child->iscasper) {
    PRINT_DEBUG((dbg," child is casper !\n"))
    	c->iscasper = 1;
    	c->casperip = apr_pstrdup(p, child->casperip);
	} else if(parent->iscasper) {
		c->iscasper = 1;
    	c->casperip = apr_pstrdup(p, parent->casperip);
	} else c->iscasper = 0;
	
	if(child->casperport > 0) {
		c->casperport = child->casperport;
	} else if(parent->casperport > 0) {
		c->casperport = parent->casperport;
	}
    return c; }


static void *create_wcl_config(apr_pool_t *p, char *s) {
    wcl_per_dir_conf *c = (wcl_per_dir_conf*)apr_pcalloc(p, sizeof(wcl_per_dir_conf));
	c->starter_pid = getpid();
	int len;
	c->pool = p;
	PRINT_DEBUG((dbg,"create_wcl_config [%s]\n", s))
    c->confdir = s ? s : "/";
    c->command = NULL;
    c->tracefile = NULL;
    c->filefilter = NULL;
    c->sessionpath = NULL;
    c->uploadpath = NULL;
    c->soapserver = NULL;
    c->index = NULL;
    c->maxpost = 0;
    c->havemaxpost = 0;
    c->timeout = -1;
    c->casperip = NULL;
    c->casperport = 0;
    c->iscasper = 0;
    c->userenv = apr_table_make(p, 0);
    //<sb> set default name for this service
    len = strlen(c->confdir);
    while (--len) {
    	if(c->confdir[len] == '\\' || c->confdir[len] == '/')
    		break;
    }
    c->sessionname = apr_pstrdup(p, c->confdir + len + 1);
    if(strlen(c->sessionname) == 0)
    	c->sessionname = "UNAMED_SESSION";
	if (current_wcl_config) {
		current_wcl_config->next = c;
		current_wcl_config = c;
	}
	if (first_wcl_config == NULL) {
		first_wcl_config = c;
		current_wcl_config = c;
	}
    return c; }

static void setup_server_attributes(wcl_per_dir_conf* wcl, cmd_parms *cmd) {
	if (wcl->server_name == NULL && cmd->server->server_hostname) {
		wcl->server_name = apr_pstrdup(cmd->pool, cmd->server->server_hostname);
	}
	if (wcl->document_root == NULL) {
		core_server_config *core = (core_server_config *)ap_get_module_config(cmd->server->module_config, &core_module);
		if (core && core->ap_document_root)
			wcl->document_root = apr_pstrdup(cmd->pool, core->ap_document_root);
	}
}


static const char *set_wclcommand(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->command = arg;
    if (!conf->command)
		return apr_pstrcat(cmd->pool, "Invalid WCL command line : ", arg, NULL);
    return NULL; }

static const char *set_wcltracefile(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->tracefile = arg; //ap_server_root_relative(cmd->pool, arg);
    if (!conf->tracefile) return apr_pstrcat(cmd->pool, "Invalid WCL trace file : ", arg, NULL);
    return NULL; }

static const char *set_wclfilefilter(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->filefilter = arg;
    if (!conf->filefilter) return apr_pstrcat(cmd->pool, "Invalid WCL file filter : ", arg, NULL);
    return NULL; }

static const char *set_wclsessionpath(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->sessionpath = arg; //ap_server_root_relative(cmd->pool, arg);
    if (!conf->sessionpath) return apr_pstrcat(cmd->pool, "Invalid WCL session path : ", arg, NULL);
    return NULL; }

static const char *set_wclsessionname(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->sessionname = arg;
    if (!conf->sessionname) return apr_pstrcat(cmd->pool, "Invalid WCL session name : ", arg, NULL);
    return NULL; }

static const char *set_wcluploadpath(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->uploadpath = arg; //ap_server_root_relative(cmd->pool, arg);
    if (!conf->uploadpath) return apr_pstrcat(cmd->pool, "Invalid WCL upload path : ", arg, NULL);
    return NULL; }

static const char *set_wclindex(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->index = arg; //ap_server_root_relative(cmd->pool, arg);
    if (!conf->index) return apr_pstrcat(cmd->pool, "Invalid WCL default index : ", arg, NULL);
    return NULL; }

static const char *set_wclmaxpost(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    if(arg) {
    	#ifdef WIN32
    	float f = (float)atof(arg);
    	#else
    	float f = strtof(arg, NULL);
    	#endif
    	if (f <= 0.0) return apr_pstrcat(cmd->pool, "Invalid WCL max post : ", arg, NULL);
    	else conf->maxpost = (int)(1024.0 * 1024.0 * f); }
    conf->havemaxpost = 1;
    conf->maxpoststr = arg;
    return NULL; }

static const char *set_wcltimeout(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    if(arg) {
    	int f = atoi(arg);
    	if (f <= 0) return apr_pstrcat(cmd->pool, "Invalid WCL timeout : ", arg, NULL);
    	else conf->timeout = f; }
    return NULL; }

static const char *set_wclsoapserver(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->soapserver = arg;
    if (!conf->soapserver) return apr_pstrcat(cmd->pool, "Invalid WCL soap server : ", arg, NULL);
    return NULL; }

static const char *set_wclautogzip(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    if(arg) {
    	if(strcmp(arg,"default")) {
    		int f = atoi(arg);
    		if (f < 1 || f > 9) return apr_pstrcat(cmd->pool, "Invalid WCL auto Gzip (expect integer in 1-9 or 'default'): ", arg, NULL);
    		else conf->autogzip = arg;
    	} else conf->autogzip = arg; }
    return NULL; }

static const char *set_wclcasperip(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    conf->casperip = arg;
    if (!conf->casperip) return apr_pstrcat(cmd->pool, "Invalid CASPER IP : ", arg, NULL);
    conf->iscasper = 1;
    return NULL; }

static const char *set_wclcasperport(cmd_parms *cmd, void *dummy, const char *arg) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    if(arg) {
    	int f = atoi(arg);
    	if (f <= 0) return apr_pstrcat(cmd->pool, "Invalid CASPER port : ", arg, NULL);
    	else conf->casperport = f; }
    conf->iscasper = 1;
    return NULL; }

static const char *set_wcluserenv(cmd_parms *cmd, void *dummy, const char *arg1, const char *arg2) {
    wcl_per_dir_conf *conf = (wcl_per_dir_conf*)dummy;
	setup_server_attributes(conf, cmd);
    apr_table_setn(conf->userenv, arg1, arg2);
    return NULL; }

static const command_rec wcl_cmds[] = {
	AP_INIT_RAW_ARGS("WclCommand", set_wclcommand, NULL, OR_ALL,
				"The command line used to start the WCL child process or a CASPER deamon"),
	AP_INIT_TAKE1("WclTraceFile", set_wcltracefile, NULL, OR_ALL,
				"The path to the trace file used for the WCL child execution"),
	AP_INIT_TAKE1("WclFileFilter", set_wclfilefilter, NULL, OR_ALL,
				"The filter used to check that the requested file match"),
	AP_INIT_TAKE1("WclSessionPath", set_wclsessionpath, NULL, OR_ALL,
				"The path where session files are saved"),
	AP_INIT_TAKE1("WclSessionName", set_wclsessionname, NULL, OR_ALL,
				"The used for session (i.e. cookie name)"),
	AP_INIT_TAKE1("WclUploadPath", set_wcluploadpath, NULL, OR_ALL,
				"The path where upload files are saved"),
	AP_INIT_TAKE1("WclMaxPost", set_wclmaxpost, NULL, OR_ALL,
				"POST limit in Mo"),
	AP_INIT_TAKE1("WclTimeout", set_wcltimeout, NULL, OR_ALL,
				"Maximum exectution time in second of the WCL child process"),
	AP_INIT_TAKE1("WclSoapServer", set_wclsoapserver, NULL, OR_ALL,
				"The path to the log file used by the WCL module"),
	AP_INIT_TAKE1("WclAutoGzip", set_wclautogzip, NULL, OR_ALL,
				"Enables Gzip compression on the fly (either default or an integer in the range 1-9)"),
	AP_INIT_TAKE1("WclCasperIp", set_wclcasperip, NULL, OR_ALL,
				"CASPER server host (may be the path of an UNIX domain socket)"),
	AP_INIT_TAKE1("WclCasperHost", set_wclcasperip, NULL, OR_ALL,
				"CASPER server host"),
	AP_INIT_TAKE1("WclCasperPort", set_wclcasperport, NULL, OR_ALL,
				"Port of a CASPER server"),
	AP_INIT_TAKE2("WclUserEnv", set_wcluserenv, NULL, OR_ALL,
				"Specify an additionnal environment variable"),
	AP_INIT_TAKE1("WclDefaultIndex", set_wclindex, NULL, OR_ALL,
				"Specify an additionnal environment variable"),
	{NULL}};


/*****************************************************************************/
/**   3. Tools                                                              **/
/*****************************************************************************/

#define RETURN_WCL_ERROR(r, msg) return misconfigured(r, "WCL", msg);

static apr_status_t misconfigured(request_rec *r, char *casperwcl, char *msg) {
   	PRINT_DEBUG((dbg,"%s: HTTP_INTERNAL_SERVER_ERROR : %s\n", casperwcl, msg))
	ap_set_content_type(r, "text/html");
	ap_rprintf(r, "<h1>Internal Server Error (%s)</h1>", casperwcl);
	ap_rprintf(r, "<p>%s</p>", msg);
	r->status = HTTP_INTERNAL_SERVER_ERROR;
	return OK;
}

static apr_status_t mod_wcl_error(request_rec *r, char *casperwcl, const char *fmt, va_list args) {
	char *msg = apr_pvsprintf(r->pool, fmt, args);
	// ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r, msg);
	ap_set_content_type(r, "text/html");
	ap_rprintf(r, "<h1>Internal Server Error (%s)</h1>", casperwcl);
	ap_rputs("<p style='white-space: pre'>", r);
	ap_rputs(ap_escape_html(r->pool, msg), r);
	ap_rputs("</p>", r);
	r->status = HTTP_INTERNAL_SERVER_ERROR;
	return OK;
}

static apr_status_t casper_error(request_rec *r, const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    apr_status_t st = mod_wcl_error(r, "CASPER", fmt, args);
    va_end(args);
	return st;
}

static apr_status_t wcl_error(request_rec *r, const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    apr_status_t st = mod_wcl_error(r, "WCL", fmt, args);
    va_end(args);
	return st;
}


int match_wildcard(const char* src, const char* w) {
	if(*src == 0 && *w == 0) return 1;
	if(*w == 0) return 0;
	if(*w == '#') w++;
	if(*w == '*') {
		if(w[1] == 0) return 1;
		if(*src == 0) return 0;
		if(w[1] == *src)
			return match_wildcard(src + 1, w + 2) || match_wildcard(++src, w);
		return match_wildcard(++src, w); }
	else if(*src == 0) return 0;
	else if(*w == '?') return match_wildcard(++src, ++w);
	if(*src != *w) return 0;
	else return match_wildcard(++src, ++w); }

//<sb> perform recursive subtitution of env vars in src.
// an env var XXX must appear as $(XXX) in the given source
static const char *env_substitute(apr_pool_t *p, wcl_per_dir_conf *conf, const char *src, apr_table_t *env) {
	int dollar = -1;
	int maxdollar = strlen(src) - 3; //<sb> e.g. [xxxx$(X)], -3 for at least "(X)"
	while(++dollar < maxdollar) {
		if(src[dollar] == '$' && src[dollar + 1] == '(') {
			const char *var = src + dollar + 2;
			const char *varend = var;
			const char *value = NULL;
			while(*varend && *varend != ')')
				varend++;
			if(*varend == '\0')
				return src; //<sb> subtitution failed - missing ')'
			const char *varname = apr_pstrndup(p, var, varend - var);
			if (apr_strnatcasecmp(varname, "DocumentRoot") == 0)
				value = conf->document_root;
			else if (apr_strnatcasecmp(varname, "ServerName") == 0)
				value = conf->server_name;
			else if (apr_strnatcasecmp(varname, "WclCasperIp") == 0)
				value = conf->casperip;
			else if (apr_strnatcasecmp(varname, "WclCasperPort") == 0)
				value = apr_psprintf(p, "%d", conf->casperport);
			else if (apr_strnatcasecmp(varname, "WclTimeout") == 0)
				value = apr_psprintf(p, "%d", conf->timeout);
			else if (apr_strnatcasecmp(varname, "WclCommand") == 0)
				value = conf->command;
			else if (apr_strnatcasecmp(varname, "WclFileFilter") == 0)
				value = conf->filefilter;
			else if (apr_strnatcasecmp(varname, "WclTraceFile") == 0)
				value = conf->tracefile;
			else if (apr_strnatcasecmp(varname, "WclSessionPath") == 0)
				value = conf->sessionpath;
			else if (apr_strnatcasecmp(varname, "WclSessionName") == 0)
				value = conf->sessionname;
			else if (apr_strnatcasecmp(varname, "WclUploadPath") == 0)
				value = conf->uploadpath;
			else if (apr_strnatcasecmp(varname, "WclSoapServer") == 0)
				value = conf->soapserver;
			else if (apr_strnatcasecmp(varname, "WclDefaultIndex") == 0)
				value = conf->index;
			else if (env)
				value = apr_table_get(env, varname);
			if (value == NULL)
				value = apr_table_get(conf->userenv, varname);
			if (value) {
				const char *former = apr_pstrndup(p, src, var - src - 2);
				const char *later = apr_pstrndup(p, varend + 1, strlen(varend + 1));
				const char *newstr = apr_pstrcat(p, former, value, later, NULL);
				return env_substitute(p, conf, newstr, env);
			}
			return src; //<sb> subtitution failed - unknown var
		}
	}
	return src;
}


static int add_a_user_var(void *a, const char *key, const char *value) {
	apr_table_t *t = a;
	apr_table_setn(t, key, value);
	return 1; }

static char *rm_session_id(char **str, apr_pool_t *p);
static char *rm_url_env_var(char **str, apr_pool_t *p);

//<sb> have our own env filling method (CGI like)
static void build_wcl_env(request_rec *r, wcl_per_dir_conf *conf, int casper) {
    apr_table_t *e = r->subprocess_env;
	char *session_id;
	char *url_env_var;
	int url_var_idx = 0;
	const apr_array_header_t *hdrs_arr = apr_table_elts(r->headers_in);
	ap_add_common_vars(r);
	//<sb> if a SOAPAction is specified add it to the child env
	apr_table_get(r->headers_in, "SOAPAction");
	//<sb> in CASPER the PATH shouldn't be sent but inherited by CASPER server
	if(casper) apr_table_unset(e, "PATH");
    //<sb> extract the session id if present and cleanup the uri before ap_add_cgi_vars    
    session_id = rm_session_id(&r->uri, r->pool);
    //<sb> extract the URL env vars if present and cleanup the uri before ap_add_cgi_vars    
    while ((url_env_var = rm_url_env_var(&r->uri, r->pool)) != NULL) {
    	char vname[16];
        url_var_idx++;
    	apr_snprintf(vname, 16, "WCL_URL_VAR%d", url_var_idx);
    	apr_table_set(e, vname, url_env_var);
    }
	r->path_info = r->uri;
    PRINT_DEBUG((dbg,"---- build_wcl_env\n"))
    PRINT_DEBUG((dbg,"     URI=[%s]\n", r->uri))
    PRINT_DEBUG((dbg,"     PATH_INFO=[%s]\n", r->path_info))
    ap_add_cgi_vars(r);
	PRINT_DEBUG((dbg,"     PATH_TRANSLATED=[%s]\n", apr_table_get(e,"PATH_TRANSLATED")))
	PRINT_DEBUG((dbg,"     WCL_SESSION=[%s]\n", session_id))
	
    //<sb> setup WCL env
	apr_table_set(e, "MOD_WCL_VERSION", MOD_WCL_VERSION);
	if(session_id) apr_table_set(e, "WCL_SESSION", session_id);
	if(conf->maxpoststr) apr_table_set(e, "WCL_MAX_POST", conf->maxpoststr);
    if(conf->soapserver) apr_table_set(e, "WCL_SOAP_SERVER", conf->soapserver);
    if(conf->autogzip) apr_table_set(e, "WCL_AUTO_GZIP", conf->autogzip);
    if(conf->sessionname) apr_table_set(e, "WCL_SESSION_NAME", conf->sessionname);
	apr_table_do(add_a_user_var, e, conf->userenv, NULL);
	//<sb> vars that support substitution
	if(conf->tracefile) {
    	PRINT_DEBUG((dbg,"Perform substitution of %s=[%s]\n","WCL_TRACE_FILE",conf->tracefile))
		apr_table_set(e, "WCL_TRACE_FILE", env_substitute(r->pool, conf, (char*)conf->tracefile, e));
	}
    if(conf->uploadpath) {
    	PRINT_DEBUG((dbg,"Perform substitution of %s=[%s]\n","WCL_UPLOAD_FOLDER",conf->uploadpath))
    	apr_table_set(e, "WCL_UPLOAD_FOLDER", env_substitute(r->pool, conf, (char*)conf->uploadpath, e));
    }
    if(conf->sessionpath) {
    	PRINT_DEBUG((dbg,"Perform substitution of %s=[%s]\n","WCL_SESSION_PATH",conf->sessionpath))
    	apr_table_set(e, "WCL_SESSION_PATH", env_substitute(r->pool, conf, (char*)conf->sessionpath, e));
    }
}


/*****************************************************************************/
/**   4. Log stuff                                                          **/
/*****************************************************************************/


#define ERRFN_USERDATA_KEY         "WCLCHILDERRFN"


// Soak up stderr from a script and redirect it to the error log.
static void log_wcl_err(request_rec *r, apr_file_t *script_err) {
    char argsbuffer[HUGE_STRING_LEN];
    int first = 1;
    while (apr_file_gets(argsbuffer, HUGE_STRING_LEN, script_err) == APR_SUCCESS) {
    	if (first) {
    		first = 0;
			ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r, "[URI: %s] WCL stderr returned: %s", r->uri, argsbuffer);
		}
		else
			ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r, "%s", argsbuffer);
        } }


static void wcl_child_errfn(apr_pool_t *pool, apr_status_t err, const char *description) {
    request_rec *r;
    void *vr;
    apr_pool_userdata_get(&vr, ERRFN_USERDATA_KEY, pool);
    r = vr;
    PRINT_DEBUG((dbg,"WCL: child error [%s]\n", description))
    ap_log_rerror(APLOG_MARK, APLOG_ERR, err, r, "WCL: %s [URI: %s]", description, r->uri); }


/*****************************************************************************/
/**   5. WCL child stuff                                                    **/
/*****************************************************************************/


typedef struct {
    apr_int32_t   in_pipe;
    apr_int32_t   out_pipe;
    apr_int32_t   err_pipe;
    apr_proc_t    *proc; } wcl_exec_info_t;

static apr_status_t run_wcl_child(apr_file_t **script_out, apr_file_t **script_in, apr_file_t **script_err, 
                                  const char *command, const char * const argv[], request_rec *r, apr_pool_t *p,
                                  wcl_exec_info_t *e_info) {
    const char * const *env;
    apr_procattr_t *procattr;
    apr_status_t rc = APR_SUCCESS;
	#if defined(RLIMIT_CPU)  || defined(RLIMIT_NPROC) || defined(RLIMIT_DATA) || defined(RLIMIT_VMEM) || defined (RLIMIT_AS)
    core_dir_config *conf = ap_get_module_config(r->per_dir_config, &core_module);
	#endif
    wcl_per_dir_conf *dirconf = ap_get_module_config(r->per_dir_config, &wcl_module);
	RAISE_SIGSTOP(CGI_CHILD);
    PRINT_DEBUG((dbg,"  timeout= %dms\n", dirconf->timeout))
    PRINT_DEBUG((dbg,"  command= %s\n", command))    
    env = (const char * const *)ap_create_environment(p, r->subprocess_env);
    // Transmute ourselves into the script. NB only ISINDEX scripts get decoded arguments.
    if (((rc = apr_procattr_create(&procattr, p)) != APR_SUCCESS) ||
        ((rc = apr_procattr_io_set(procattr, e_info->in_pipe, e_info->out_pipe, e_info->err_pipe)) != APR_SUCCESS) ||
		#ifdef RLIMIT_CPU
        ((rc = apr_procattr_limit_set(procattr, APR_LIMIT_CPU, conf->limit_cpu)) != APR_SUCCESS) ||
		#endif
		#if defined(RLIMIT_DATA) || defined(RLIMIT_VMEM) || defined(RLIMIT_AS)
        ((rc = apr_procattr_limit_set(procattr, APR_LIMIT_MEM, conf->limit_mem)) != APR_SUCCESS) ||
		#endif
		#ifdef RLIMIT_NPROC
        ((rc = apr_procattr_limit_set(procattr, APR_LIMIT_NPROC, conf->limit_nproc)) != APR_SUCCESS) ||
		#endif
        ((rc = apr_procattr_cmdtype_set(procattr, APR_PROGRAM)) != APR_SUCCESS) ||
        ((rc = apr_procattr_detach_set(procattr, 0)) != APR_SUCCESS) ||
        ((rc = apr_procattr_error_check_set(procattr, 1)) != APR_SUCCESS) ||
        ((rc = apr_procattr_child_errfn_set(procattr, wcl_child_errfn)) != APR_SUCCESS))
        	ap_log_rerror(APLOG_MARK, APLOG_ERR, rc, r, "WCL: Couldn't set child process attributes %s [URI: %s]", command, r->uri);
    else {
        apr_pool_userdata_set(r, ERRFN_USERDATA_KEY, apr_pool_cleanup_null, p);
        e_info->proc = apr_pcalloc(p, sizeof(apr_proc_t));
        rc = ap_os_create_privileged_process(r, e_info->proc, command, argv, env, procattr, p);
		if (rc == APR_SUCCESS) {
			apr_interval_time_t to =
				dirconf->timeout == -1 ?
						(apr_interval_time_t)-1 :
						(apr_interval_time_t)dirconf->timeout * (apr_interval_time_t)1000;
        	if(to != -1)
	            apr_pool_note_subprocess(p, e_info->proc, APR_KILL_AFTER_TIMEOUT);
			else apr_pool_note_subprocess(p, e_info->proc, APR_JUST_WAIT);
			*script_in = e_info->proc->out;
            if (!*script_in) return APR_EBADF;
            apr_file_pipe_timeout_set(*script_in, to);
			*script_out = e_info->proc->in;
			if (!*script_out) return APR_EBADF;
			apr_file_pipe_timeout_set(*script_out, -1);
			*script_err = e_info->proc->err;
			if (!*script_err) return APR_EBADF;
			apr_file_pipe_timeout_set(*script_err, -1);
		}
	}
    return (rc); }


static void discard_script_output(apr_bucket_brigade *bb) {
    apr_bucket *e;
    const char *buf;
    apr_size_t len;
	PRINT_DEBUG((dbg,"discard_script_output\n["))
//    APR_BRIGADE_FOREACH(e, bb) {
	for (e = APR_BRIGADE_FIRST(bb);
		e != APR_BRIGADE_SENTINEL(bb);
		e = APR_BUCKET_NEXT(e)) {
        if (APR_BUCKET_IS_EOS(e) || apr_bucket_read(e, &buf, &len, APR_BLOCK_READ) != APR_SUCCESS)
        	break;
		#ifdef DEBUG_WCL
		{ int i = 0;
		for(;i < len;i++) {
			if(buf[i] == '\r') fprintf(dbg,"\\r");
			else if(buf[i] == '\0') fprintf(dbg,"\\0");
			else if(buf[i] == '\n') fprintf(dbg,"\\n");
			else if(buf[i] == '\t') fprintf(dbg,"\\t");
			else if(buf[i] == '\\') fprintf(dbg,"\\\\");
			else putc(buf[i],dbg); }
		}
		#endif

	}
	PRINT_DEBUG((dbg,"]\n"))
}

/*****************************************************************************/
/**   6. WCL handling                                                       **/
/*****************************************************************************/

static int debug_headers_out(void *a, const char *key, const char *value) {
	PRINT_DEBUG((dbg,"Header: [%s: %s]\n", key, value))
	return 1; }



static int process_wcl(request_rec *r, wcl_per_dir_conf *conf) {
    apr_file_t *script_out = NULL, *script_in = NULL, *script_err = NULL;
    apr_bucket_brigade *bb;
    apr_bucket *b;
    int seen_eos, child_stopped_reading;
    apr_pool_t *p;
    apr_status_t rv = OK;
    int ischunked;
    char **argv;
	const char *cmdline;
    wcl_exec_info_t e_info = {APR_CHILD_BLOCK, APR_CHILD_BLOCK, APR_CHILD_BLOCK, NULL};
    
    p = r->main ? r->main->pool : r->pool;
    
    PRINT_DEBUG((dbg,"WCL: Start request for uri [%s]\n", r->uri))
    PRINT_DEBUG((dbg,"Perform substitution of cmdline [%s]\n", conf->command))
    
    cmdline = env_substitute(r->pool, conf, conf->command, r->subprocess_env);
    if (apr_tokenize_to_argv(cmdline, &argv, r->pool) != APR_SUCCESS) {
		return wcl_error(r, "Invalid service's command line", cmdline);
    }

    PRINT_DEBUG((dbg,"  [%s]\n", cmdline))

    if ((rv = run_wcl_child(&script_out, &script_in, &script_err, argv[0], (const char * const *)argv, r, p, &e_info)) != APR_SUCCESS) {
		return wcl_error(r, "Couldn't create process for WCL service");
	}
    // Transfer any put/post args, CERN style...
    // Note that we already ignore SIGPIPE in the core server.
	PRINT_DEBUG((dbg,"WCL: child started...\n"))
    bb = apr_brigade_create(r->pool, r->connection->bucket_alloc);
    seen_eos = 0;
    child_stopped_reading = 0;
    ischunked = apr_table_get(r->subprocess_env, "HTTP_TRANSFER_ENCODING") != NULL;
    do {
        apr_bucket *bucket;
        rv = ap_get_brigade(r->input_filters, bb, AP_MODE_READBYTES, APR_BLOCK_READ, HUGE_STRING_LEN);
        if (rv != APR_SUCCESS) return rv;
		for (bucket = APR_BRIGADE_FIRST(bb);
			bucket != APR_BRIGADE_SENTINEL(bb);
			bucket = APR_BUCKET_NEXT(bucket)) {
//        APR_BRIGADE_FOREACH(bucket, bb) {
            const char *data;
            apr_size_t len;
            apr_size_t totallen = 0;
            if (APR_BUCKET_IS_EOS(bucket)) {
            	seen_eos = 1; 
            	if(ischunked)
					//<sb> don't check error, continue even if the child does not read
					// the null chunk
        			apr_file_write_full(script_out, "0\r\n\r\n", 5, NULL);
            	break; }
            // We can't do much with this.
            if (APR_BUCKET_IS_FLUSH(bucket)) continue;
            // If the child stopped, we still must read to EOS.
            if (child_stopped_reading) continue;
            apr_bucket_read(bucket, &data, &len, APR_BLOCK_READ);
            PRINT_DEBUG_POST(data, len)
            totallen += len;
			if(conf->havemaxpost && totallen > conf->maxpost) {
				ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r, "WCL: Request entity too large %ldbytes [URI: %s]", totallen, r->uri);
				PRINT_DEBUG((dbg,"WCL: HTTP_REQUEST_ENTITY_TOO_LARGE(1)\n"))
				return HTTP_REQUEST_ENTITY_TOO_LARGE; }
            // Keep writing data to the child until done or too much time elapses with no progress or an error occurs.
			if(ischunked) {
				//<sb> re-chunk !
				char chunksizestr[10];
            	apr_size_t chunksize; 
	#ifdef X64
            	chunksize = apr_snprintf(chunksizestr, 10, "%lx\r\n", len);
	#else
            	chunksize = apr_snprintf(chunksizestr, 10, "%x\r\n", len);
	#endif
            	if (apr_file_write_full(script_out, chunksizestr, chunksize, NULL) != APR_SUCCESS ||
            		apr_file_write_full(script_out, data, len, NULL) != APR_SUCCESS ||
            		apr_file_write_full(script_out, "\r\n", 2, NULL) != APR_SUCCESS)
            	    // silly script stopped reading, soak up remaining message
            	    child_stopped_reading = 1;
			} else if (apr_file_write_full(script_out, data, len, NULL) != APR_SUCCESS)
            	    // silly script stopped reading, soak up remaining message
            	    child_stopped_reading = 1; }
        apr_brigade_cleanup(bb);
    } while (!seen_eos);
    apr_file_flush(script_out);
    apr_file_close(script_out);
    // Handle script return...
    if (script_in) {
	    conn_rec *c = r->connection;
        const char *location;
        char sbuf[MAX_STRING_LEN];
        int ret;
        //apr_size_t nc = 200;
        PRINT_DEBUG((dbg,"WCL: Handle script return\n"))
        /*
        while (nc > 0) {
        	int i = 0;
        	nc = 200;
        	apr_file_read(script_in, sbuf, &nc);
			
			if(dbg == NULL) dbg = fopen(DEBUG_FILE, "a");
			fprintf(dbg,"DATA[");
			for(;i < nc;i++) {
					if(sbuf[i] == '\r') fprintf(dbg,"\\r");
					else if(sbuf[i] == '\0') fprintf(dbg,"\\0");
					else if(sbuf[i] == '\n') fprintf(dbg,"\\n");
					else if(sbuf[i] == '\t') fprintf(dbg,"\\t");
					else if(sbuf[i] == '\\') fprintf(dbg,"\\\\");
					else putc(sbuf[i],dbg); }
			fprintf(dbg,"]\n");
			fflush(dbg);
    	}*/
        
        b = apr_bucket_pipe_create(script_in, c->bucket_alloc);
        APR_BRIGADE_INSERT_TAIL(bb, b);
        b = apr_bucket_eos_create(c->bucket_alloc);
        APR_BRIGADE_INSERT_TAIL(bb, b);
        if ((ret = ap_scan_script_header_err_brigade(r, bb, sbuf))) {
            apr_proc_kill(e_info.proc, SIGKILL);
            #ifdef DEBUG_WCL
            	apr_table_do(debug_headers_out, NULL, r->headers_out, NULL);
				apr_table_do(debug_headers_out, NULL, r->err_headers_out, NULL);
            #endif
			return wcl_error(r, "Invalid returned HTTP header :\n\n%s", sbuf);
        }
        PRINT_DEBUG((dbg,"WCL: returned HTTP headers OK\n"))
        #ifdef DEBUG_WCL
            apr_table_do(debug_headers_out, NULL, r->headers_out, NULL);
			apr_table_do(debug_headers_out, NULL, r->err_headers_out, NULL);
        #endif
        location = apr_table_get(r->headers_out, "Location");
        if (location && location[0] == '/' && r->status == 200) {
            discard_script_output(bb);
            apr_brigade_destroy(bb);
            log_wcl_err(r, script_err);
            // This redirect needs to be a GET no matter what the original method was.
            r->method = apr_pstrdup(r->pool, "GET");
            r->method_number = M_GET;
            // We already read the message body (if any), so don't allow the redirected request to think it has one.
            apr_table_unset(r->headers_in, "Content-Length");
            ap_internal_redirect_handler(location, r);
            PRINT_DEBUG((dbg,"WCL: OK(1)\n"))
            return OK;
        } else if (location && r->status == 200) {
            // XX Note that if a script wants to produce its own Redirect body, it now has to explicitly
            // *say* "Status: 302"
            discard_script_output(bb);
            apr_brigade_destroy(bb);
            PRINT_DEBUG((dbg,"WCL: HTTP_MOVED_TEMPORARILY(1)\n"))
            return HTTP_MOVED_TEMPORARILY;
        }
        rv = ap_pass_brigade(r->output_filters, bb);
        // don't soak up script output if errors occurred writing it out...  otherwise, we prolong the
        //life of the script when the connection drops or we stopped sending output for some other reason
        /*if (rv != APR_SUCCESS && !r->connection->aborted) {
        	PRINT_DEBUG((dbg,"WCL: ap_pass_brigade error\n"))
        	//log_wcl_err(r, script_err);
			return HTTP_INTERNAL_SERVER_ERROR;
        }*/
        apr_file_close(script_err); }
    PRINT_DEBUG((dbg,"WCL: OK(2)\n"))
    return OK; } // NOT r->status, even if it has changed.

/*****************************************************************************/
/**   6. CASPER handling                                                    **/
/*****************************************************************************/

//<sb> we don't use the APR socket API because CASPER may be
// configure with an UNIX socket which AFAIK is not provided by the APR...
// UNIX socket will be used when CASPER runs on the same host as apache
// and would provide better communication performance.
// So we have to carrefully handle an allocated socket descriptor such
// to keep the descriptor table in a clean state after the CASPER request


static int casper_send(int fd, const char *data, int len) {
	int r = 0;
	while (r < len) {
		int n = send(fd, data + r, len - r, 0);
		if (n == -1) {
			if(errno != EINTR)
				return -1;
		} else if (n == 0) break;
		else r += n;
	}
	return r;
}

static int casper_recv(int fd, const char *data, int len) {
	int r = 0;
	while (r < len) {
		int n = recv(fd, (char*)(data + r), len - r, 0);
		if (n == -1) {
			if(errno != EINTR)
				return -1;
		} else if (n == 0) break;
		else r += n;
	}
	return r;
}

static int send_a_var(void *a, const char *key, const char *value) {
	int s = (int)a;
	if(casper_send(s, key, strlen(key)) < 0 ||
		casper_send(s, "=", 1) < 0 ||
		casper_send(s, value, strlen(value) + 1) < 0)
		return 0;
	return 1; }

//<sb> created either a UNIX socket or a normal connected socket
int casper_connect(wcl_per_dir_conf *conf) {
	int fd;
	const char *addr = conf->casperip ? conf->casperip : "127.0.0.1";
	if (addr[0] == '/') {
	#ifndef CLPC
	    struct sockaddr_un unix_addr;
		memset(&unix_addr, 0, sizeof(struct sockaddr_un));
		unix_addr.sun_family = AF_UNIX;
		strcpy(unix_addr.sun_path, addr);
		fd = socket(AF_UNIX, SOCK_STREAM, 0);
		if (fd < 0)
			return -1;
		if(connect(fd, (struct sockaddr*)&unix_addr, sizeof(struct sockaddr_un)) < 0) {
			close(fd);
			return -1;
		}
	#endif
    } else {
    	struct sockaddr_in in_addr;
    	memset(&in_addr, 0, sizeof(struct sockaddr_in));
		in_addr.sin_addr.s_addr = inet_addr(addr);
		in_addr.sin_family = AF_INET;
		in_addr.sin_port = htons(conf->casperport);
		fd = socket(AF_INET, SOCK_STREAM, 0);
		if (fd < 0)
			return -1;
		if((addr[0] >= '0' && addr[0] <= '9') || *addr == 0) {
			if(*addr == 0) in_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
			else in_addr.sin_addr.s_addr = inet_addr(addr);
		} else {
			struct hostent *servent;
			if((servent = gethostbyname(addr)) == 0) {
				close(fd);
				return -1;
			}
			memcpy(&in_addr.sin_addr, servent->h_addr, servent->h_length);
		}
		if(connect(fd, (struct sockaddr *)&in_addr, sizeof(struct sockaddr_in)) < 0) {
			close(fd);
			return -1;
		}
	}
	return fd;
}

void casper_close(int fd) {
	close(fd);
}

//<sb> ap_scan_script_header_err_core handler that take a socket
// as argument - fill w with a line read from the socket
static int getsfunc_CASPER(char *w, int len, void *psock)
{
	int fd = (int)psock;
	int n = 0;
	do {
		if (casper_recv(fd, w, 1) != 1)
			return 0;
		n++;
		if (*w == '\n') {
			w++;
			break;
		}
		w++;
	} while (n < len);
	*w = 0;
	return 1;
}


static int process_casper(request_rec *r, wcl_per_dir_conf *conf) {
    apr_bucket_brigade *bb;
    int seen_eos, child_stopped_reading;
    apr_pool_t *p = r->main ? r->main->pool : r->pool;
    apr_status_t rv = OK;
    int ischunked;
	int sock;
    
    PRINT_DEBUG((dbg,"CASPER: Start request for uri [%s]\n", r->uri))

	if (conf->misconfigured_casper)
		return casper_error(r, "Misconfigured service :\n%s", conf->misconfigured_casper);

    // Transfer any put/post args, CERN style...
    // Note that we already ignore SIGPIPE in the core server.
    bb = apr_brigade_create(r->pool, r->connection->bucket_alloc);

    sock = casper_connect(conf);
    
    if(sock < 0)
		return casper_error(r, "Failed to connect CASPER on %s", conf->casperip);
    
    //<sb> send an header with CASPER environment "v1=a1\0v2=a2\0 ... \0"
    if(apr_table_do(send_a_var, (void*)sock, r->subprocess_env, NULL) == FALSE ||
    		casper_send(sock, "\0", 1) < 0) {
		casper_close(sock);
		return casper_error(r, "Failed to send CASPER environment");
    }

    seen_eos = 0;
    child_stopped_reading = 0;
    ischunked = apr_table_get(r->subprocess_env, "HTTP_TRANSFER_ENCODING") != NULL;
    do {
        apr_bucket *bucket;
        rv = ap_get_brigade(r->input_filters, bb, AP_MODE_READBYTES, APR_BLOCK_READ, HUGE_STRING_LEN);
        if (rv != APR_SUCCESS) {
			casper_close(sock);
			return rv;
		}
		for (bucket = APR_BRIGADE_FIRST(bb);
			bucket != APR_BRIGADE_SENTINEL(bb);
			bucket = APR_BUCKET_NEXT(bucket)) {
//        APR_BRIGADE_FOREACH(bucket, bb) {
            const char *data;
            apr_size_t len;
            apr_size_t totallen = 0;
            if (APR_BUCKET_IS_EOS(bucket)) {
            	seen_eos = 1;
            	if(ischunked)
            		casper_send(sock, "0\r\n\r\n", 5);
        		break;
        	}
            // We can't do much with this.
            if (APR_BUCKET_IS_FLUSH(bucket)) continue;
            // If the child stopped, we still must read to EOS.
            if (child_stopped_reading) continue;
            apr_bucket_read(bucket, &data, &len, APR_BLOCK_READ);
            PRINT_DEBUG_POST(data, len)
            totallen += len;
			if(conf->havemaxpost && totallen > conf->maxpost) {
				ap_log_rerror(APLOG_MARK, APLOG_ERR, rv, r, "CASPER: Request entity too large %d bytes [URI: %s]", totallen, r->uri);
				PRINT_DEBUG((dbg,"CASPER: HTTP_REQUEST_ENTITY_TOO_LARGE(1)\n"))
				casper_close(sock);
				return HTTP_REQUEST_ENTITY_TOO_LARGE; }
            // Keep writing data to the child until done or too much time elapses with no progress or an error occurs.
			if(ischunked) {
				//<sb> re-chunk !
				char chunksizestr[10];
            	apr_size_t chunksize;
            	chunksize = apr_snprintf(chunksizestr, 10, "%x\r\n", len);
            	if (casper_send(sock, chunksizestr, chunksize) < 0 ||
            		casper_send(sock, data, len) < 0 ||
            		casper_send(sock, "\r\n", 2) < 0)
            	    // silly script stopped reading, soak up remaining message
            	    child_stopped_reading = 1;
			} else if (casper_send(sock, data, len) < 0)
            	    // silly script stopped reading, soak up remaining message
            	    child_stopped_reading = 1; }
        apr_brigade_cleanup(bb);
    } while (!seen_eos);
    // Handle script return...
    {
		conn_rec *c = r->connection;
		char sbuf[MAX_STRING_LEN];
		int ret;
		int rc;
		apr_size_t len = MAX_STRING_LEN;
		PRINT_DEBUG((dbg,"CASPER: handle script return\n"))
		
		
		if ((ret = ap_scan_script_header_err_core(r, NULL, getsfunc_CASPER, (void*)sock))) {
			casper_close(sock);
			return casper_error(r, "CASPER returned an invalid HTTP header");
		}
		
		//<sb> We had a problem in getting all data returned by Casper.
		// apr_socket_recv uses read(2) and casper uses send(2) and
		// read(2) sometimes returns 0 (with errno == 0) prior to EOF ?!
		// claire now uses write(2) for any unix descriptor (including socket)
		do {
			rc = casper_recv(sock, sbuf, MAX_STRING_LEN);
			if (r->connection->aborted) {
				PRINT_DEBUG((dbg,"CASPER: connection aborted\n", rc))
				casper_close(sock);
				return HTTP_INTERNAL_SERVER_ERROR;
			}
			if (rc > 0) {
				PRINT_DEBUG((dbg,"CASPER: write back %d bytes\n", rc))
				PRINT_DEBUG_POST(sbuf, rc)
				if(ap_rwrite(sbuf, rc, r) == -1) {
					PRINT_DEBUG((dbg,"CASPER: CLIENT CONNECTION CLOSED\n"))
					break;
				}
			}
		} while(rc > 0);
		
		casper_close(sock);
		
	}
	PRINT_DEBUG((dbg,"CASPER: OK(2)\n"))
    return OK; } // NOT r->status, even if it has changed.


//<sb> generic request handler, check the corresponding conf to drive
// the request appropriately.
static int wcl_handler(request_rec *r) {
    wcl_per_dir_conf *conf;
    apr_pool_t *p;
    int result;
    p = r->main ? r->main->pool : r->pool;
    conf = ap_get_module_config(r->per_dir_config, &wcl_module);
	if (conf && conf->filefilter)
                {PRINT_DEBUG((dbg,"wcl_handler: <Location %s> test uri %s with filter %s\n", conf->confdir, r->uri, conf->filefilter))}
        else
                {PRINT_DEBUG((dbg,"wcl_handler: no conf or filefilter!\n"))}
       
	if(conf == NULL || conf->filefilter == NULL || 
		(!conf->iscasper && conf->command == NULL) ||
		match_wildcard(r->uri, conf->filefilter) == 0)
		return DECLINED;
    if (r->method_number == M_OPTIONS) {
        r->allowed |= (AP_METHOD_BIT << M_GET);
        r->allowed |= (AP_METHOD_BIT << M_POST);
        return DECLINED; }
    build_wcl_env(r, conf, conf->iscasper);
	result = conf->iscasper ?
					process_casper(r, conf) : 
					process_wcl(r, conf);
	return result; }

/*****************************************************************************/
/**   4. Translation (session URL)                                          **/
/*****************************************************************************/

//<sb> cleanup an URL that contains a session ID
static char *rm_session_id(char **str, apr_pool_t *p) {
	char *tr = *str;
	char *session_id = NULL;
	PRINT_DEBUG((dbg,"rm_session_id [%s] -> ", *str))
	if(*str) {
		while(*tr) { //<sb> rm session id if found
			if(*tr >= '0' && *tr <= '9') { //<sb> possibly a session id
				int i = 1;
				for( ; tr[i] ; i++) {
					if(!(tr[i] >= '0' && tr[i] <= '9')) break; }
				if(i == 26) { //<sb> actualy a session id
					session_id = apr_pstrndup(p, tr, 26);
					int session_id_length = 26;
					if (tr[i + 1] == '/') session_id_length++;
					*str = apr_pstrcat(p, apr_pstrndup(p, *str, tr - *str), tr + session_id_length, NULL);
					break; } }
			tr++; }
		PRINT_DEBUG((dbg,"[%s] : %s\n", *str,session_id)) }
	return session_id; }

//<sb> cleanup an URL that contains env var definitions
static char *rm_url_env_var(char **str, apr_pool_t *p) {
	char *tr = *str;
	char *envvar = NULL;
	PRINT_DEBUG((dbg,"rm_url_env_var [%s] -> ", *str))	
	if(*str) {
		while(*tr) {
			if(*tr == '/' && tr[1] == '$') {
				int i = 0;
				while (tr[i+2] != '\0' && tr[i+2] != '/') i++;
				envvar = apr_pstrndup(p, tr+2, i);
				*str = apr_pstrcat(p, apr_pstrndup(p, *str, tr - *str), tr + i + 2, NULL);
				break;
			}
			tr++; }
		PRINT_DEBUG((dbg,"[%s]\n", *str))
		PRINT_DEBUG((dbg,"url env var [%s]\n", envvar))
		}
	return envvar;
}

//<sb> remove session id from URI for file that are not handled by mod_wcl.
// Typicaly for images from a wcl sript that may contain a session id within
// its URL. The deal is to remove the session id we can find and decline.
// Note the APR_HOOK_REALLY_FIRST status of this handler.
static int wcl_translate(request_rec *r) {
	wcl_per_dir_conf *conf;
    apr_pool_t *p;
    char *test_uri;
    int len;
    p = r->main ? r->main->pool : r->pool;
    conf = ap_get_module_config(r->per_dir_config, &wcl_module);
	if (conf && conf->filefilter)
		{PRINT_DEBUG((dbg,"wcl_translate: <Location %s> test uri %s with filter %s\n", conf->confdir, r->uri, conf->filefilter))}
 	else
		{PRINT_DEBUG((dbg,"wcl_translate: no conf or filefilter!\n"))}
	//<sb> check wheither the default index should be appended
	test_uri = apr_pstrdup(p, r->uri);
	rm_session_id(&test_uri, p);
	while (rm_url_env_var(&test_uri, p));
	//<sb> if the requested uri is / then append the default index
	len = strlen(test_uri);
	if (len > 0 && test_uri[len-1] == '/' && conf->index)
		r->uri = apr_pstrcat(p, r->uri, conf->index, NULL);
	else if (len == 0 && conf->index)
		r->uri = apr_pstrcat(p, r->uri, "/", conf->index, NULL);
	//<sb> else (images...) rm session id/env vars from the uri
	else if(conf && conf->filefilter && !match_wildcard(r->uri, conf->filefilter))
		r->uri = test_uri;
    return DECLINED;
}

/*****************************************************************************/
/**   5. Setup                                                              **/
/*****************************************************************************/

apr_status_t stop_casper_server(void *casper_conf) {
	wcl_per_dir_conf *conf = (wcl_per_dir_conf*)casper_conf;
	if (conf->starter_pid == getpid()) {
		PRINT_DEBUG((dbg,"Stop casper service pid %d\n", conf->casper_proc->pid))
		PRINT_DEBUG((dbg,"  %s\n", conf->command))
		//<sb> kills the casper server
		apr_proc_kill(conf->casper_proc, SIGKILL);
		//<sb> the casper server may be a master process having
		// preforked children ready to handle connections,
		// the loop bellow simulates connections that will make
		// remaining children to exit gracefully...
		int sock;
		do {
	    	sock = casper_connect(conf);
			if (sock > 0) {
				casper_close(sock);
			}
		} while (sock > 0);
	}
	return OK;
}

static int start_casper_servers(apr_pool_t *pconf, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *s) {
	PRINT_DEBUG((dbg,"start_casper_servers...\n"))
	wcl_per_dir_conf *aconf = first_wcl_config;
	//<sb> walk through configs and start casper service if needed
	while (aconf) {
		if (aconf->iscasper && aconf->command) {
			aconf->command =
				env_substitute(aconf->pool, aconf, aconf->command, NULL);
			aconf->casperip =
				env_substitute(aconf->pool, aconf, aconf->casperip, NULL);
			char **argv;
			apr_procattr_t *procattr;
    		apr_status_t rc = APR_SUCCESS;
			if ((rc = apr_tokenize_to_argv(aconf->command, &argv, pconf)) != APR_SUCCESS) {
		        PRINT_DEBUG((dbg,"CASPER: Invalid command line [%s]\n", aconf->command))
		        ap_log_perror(APLOG_MARK, APLOG_ERR, rc, plog, "CASPER: Invalid command line [%s]", aconf->command);
				aconf->misconfigured_casper = "Invalid command line";
		    } else if (((rc = apr_procattr_create(&procattr, pconf)) != APR_SUCCESS) ||
				((rc = apr_procattr_io_set(procattr, APR_NO_PIPE, APR_FULL_NONBLOCK, APR_NO_PIPE)) != APR_SUCCESS) ||
		        ((rc = apr_procattr_cmdtype_set(procattr, APR_PROGRAM_ENV)) != APR_SUCCESS) ||
		        ((rc = apr_procattr_error_check_set(procattr, 1)) != APR_SUCCESS)) {
		        PRINT_DEBUG((dbg,"CASPER: Invalid command line [%s]\n", aconf->command))
		        ap_log_perror(APLOG_MARK, APLOG_ERR, rc, plog, "CASPER: Invalid command line [%s]", aconf->command);
				aconf->misconfigured_casper = "Invalid command line";
		    } else {
		        aconf->casper_proc = apr_pcalloc(pconf, sizeof(apr_proc_t));
		        if ((rc = apr_proc_create(aconf->casper_proc, argv[0], argv, NULL, procattr, pconf)) != APR_SUCCESS) {
					aconf->casper_proc = NULL;
					aconf->misconfigured_casper = "Could not create CASPER daemon process (file not found?)";
		        	PRINT_DEBUG((dbg,"CASPER: Invalid command line [%s] [%d]\n", aconf->command, rc))
		        	ap_log_perror(APLOG_MARK, APLOG_ERR, rc, plog, "CASPER: failed to start daemon [%s]", aconf->command);
				}
			}
		}
		aconf = (wcl_per_dir_conf*)aconf->next;
	}
	//<sb> walk through configs again and check for early exit after a little sleep
	aconf = first_wcl_config;
	apr_sleep(apr_time_from_sec(1));
	while (aconf) {
		if (aconf->iscasper && aconf->command && aconf->misconfigured_casper == NULL) {
			apr_exit_why_e why;
			int exitcode;
			apr_status_t st = apr_proc_wait(aconf->casper_proc, &exitcode, &why, APR_NOWAIT);
			if (st == APR_CHILD_DONE) {
				char output[HUGE_STRING_LEN];
				apr_size_t sz = HUGE_STRING_LEN - 1;
				apr_file_read(aconf->casper_proc->out, output, &sz);
				output[sz] = '\0';
				aconf->misconfigured_casper = apr_psprintf(aconf->pool, "Early exit of CASPER daemon :\n\n%s", output);
				//aconf->misconfigured_casper = "Early exit of CASPER daemon (invalid option?)";
				
				aconf->casper_proc = NULL;
			} else {
				//<sb> create a subpool of the config pool and attach
				// a cleanup callback to it such to properly kill the
				// casper service when the config is freed
				apr_pool_t *cleanup;
				apr_pool_create(&cleanup, aconf->pool);
	#ifdef X64
				char *key = apr_psprintf(aconf->pool, "CASPER-CLEANUP-CONF(%lx)", aconf);
	#else
				char *key = apr_psprintf(aconf->pool, "CASPER-CLEANUP-CONF(%x)", aconf);
	#endif
				apr_pool_userdata_set(aconf, key, stop_casper_server, cleanup);
				PRINT_DEBUG((dbg,"Casper service started pid %d\n", aconf->casper_proc->pid))
			}
		}
		aconf = (wcl_per_dir_conf*)aconf->next;
	}
	return OK;
}

static void register_hooks(apr_pool_t *p) {
	#ifndef LION
	ap_hook_pre_mpm(start_casper_servers,NULL,NULL,APR_HOOK_LAST);
	#endif
	ap_hook_translate_name(wcl_translate, NULL, NULL, APR_HOOK_REALLY_FIRST);
	ap_hook_handler(wcl_handler, NULL, NULL, APR_HOOK_REALLY_FIRST);
}

module AP_MODULE_DECLARE_DATA wcl_module = {
    STANDARD20_MODULE_STUFF,
    create_wcl_config,       /* dir config creater                  */
    merge_wcl_config,       /* dir merger - default is to override */
    NULL, /* server config                       */
    NULL,    /* merge server config                 */
    wcl_cmds,                /* command apr_table_t                 */
    register_hooks           /* register hooks                      */
};
