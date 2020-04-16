
#include <claire.h>
#include <Kernel.h>
#include <gd.h>


int mysink(void *context, const char *buffer, int len)
{
	PortObject* p = (PortObject*)context;	
	int i = 0;
	p->puts((void*)buffer, len);
	return len;
}

void gdImagePngPort(gdImagePtr im, PortObject* p)
{
	gdSink sk;
	sk.sink = mysink;
	sk.context = p;
	gdIOCtx *out = gdNewSSCtx(NULL, &sk);
	gdImagePngCtx(im, out);
	free(out);
}

void gdImageJpegPort(gdImagePtr im, PortObject* p, int qual)
{
	gdSink sk;
	sk.sink = mysink;
	sk.context = p;
	gdIOCtx *out = gdNewSSCtx(NULL, &sk);
	gdImageJpegCtx(im, out, qual);
	free(out);
}
