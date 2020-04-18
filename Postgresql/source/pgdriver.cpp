//*********************************************************************
//* Mysql                                             Sylvain Benilan *
//* Copyright (C) 2000 - 2003 xl. All Rights Reserved                 *
//*********************************************************************


#include <claire.h>
#include <Kernel.h>
#include <Core.h>
#include <Db.h>
#include <Postgresql.h>
#include <pgdriver.h>


/******************* ADAPTED FROM pg src *************************/

#define ISFIRSTOCTDIGIT(CH) ((CH) >= '0' && (CH) <= '3')
#define ISOCTDIGIT(CH) ((CH) >= '0' && (CH) <= '7')
#define OCTVAL(CH) ((CH) - '0')

/*
 *		PQunescapeBytea - converts the null terminated string representation
 *		of a bytea, strtext, into binary, filling a buffer. It returns a
 *		pointer to the buffer (or NULL on error), and the size of the
 *		buffer in retbuflen. The pointer may subsequently be used as an
 *		argument to the function free(3). It is the reverse of PQescapeBytea.
 *
 *		The following transformations are made:
 *		\\	 == ASCII 92 == \
 *		\ooo == a byte whose value = ooo (ooo is an octal number)
 *		\x	 == x (x is any character not matched by the above transformations)
 */
void PQunescapeBytea_mem(blob* p, const unsigned char *strtext, size_t maxlen)
{
	unsigned char buffer[256];
	size_t i,j;


	/*
	 * Length of input is max length of output, but add one to avoid
	 * unportable malloc(0) if input is zero-length.
	 */

	for (i = j = 0; i < maxlen;)
	{
		switch (strtext[i])
		{
			case '\\':
				i++;
				if (strtext[i] == '\\')
					buffer[j++] = strtext[i++];
				else
				{
					if ((ISFIRSTOCTDIGIT(strtext[i])) &&
						(ISOCTDIGIT(strtext[i + 1])) &&
						(ISOCTDIGIT(strtext[i + 2])))
					{
						int byte;

						byte = OCTVAL(strtext[i++]);
						byte = (byte << 3) + OCTVAL(strtext[i++]);
						byte = (byte << 3) + OCTVAL(strtext[i++]);
						buffer[j++] = byte;
					}
					else {
						Ctracef("Postgresql: strange escape sequence found\n");
					}
				}

				/*
				 * Note: if we see '\' followed by something that isn't a
				 * recognized escape sequence, we loop around having done
				 * nothing except advance i.  Therefore the something will
				 * be emitted as ordinary data on the next cycle. Corner
				 * case: '\' at end of string will just be discarded.
				 */
				break;

			default:
				buffer[j++] = strtext[i++];
				break;
		}
		
		if (j + 4 >= 256) {
			Core.write_port->fcall((int)p, (int)buffer, (int)j);
			j = 0;
		}
	}
	if (j > 0) Core.write_port->fcall((int)p, (int)buffer, (int)j);
}


