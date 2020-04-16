


md5(self:string) : string ->
	let len := length(self)
	in (externC("unsigned char digest[16]"),
		externC("unsigned char res[33]"),
		externC("CLMD5_CTX ctx"),
		externC("MD5Init(&ctx)"),
		externC("MD5Update(&ctx,(unsigned char*)self,len)"),
		externC("MD5Final(digest, &ctx)"),
		externC("int i;int j;for(i = 0, j = 0; i < 16;i++, j += 2) {"),
		externC("sprintf(((char*)res)+j,\"%.2x\",digest[i]);}"),
		copy(externC("(char*)res",string), 32))

md5_digest(self:string) : string ->
	let len := length(self)
	in (externC("unsigned char digest[16]"),
		externC("CLMD5_CTX ctx"),
		externC("MD5Init(&ctx)"),
		externC("MD5Update(&ctx,(unsigned char*)self,len)"),
		externC("MD5Final(digest, &ctx)"),
		copy(externC("(char*)digest",string), 16))

md5_file(self:string) : string ->
	let f := fopen(self,"rb")
	in (externC("unsigned char digest[16]"),
		externC("unsigned char res[33]"),
		externC("CLMD5_CTX ctx"),
		externC("MD5Init(&ctx)"),
		while not(eof?(f))
			let raw := fread(f, 4096),
				len := length(raw)
			in externC("MD5Update(&ctx,(unsigned char*)raw,len)"),
		externC("MD5Final(digest, &ctx)"),
		externC("int i;int j;for(i = 0, j = 0; i < 16;i++, j += 2) {"),
		externC("sprintf(((char*)res)+j,\"%.2x\",digest[i]);}"),
		copy(externC("(char*)res",string), 32))

md5_file_digest(self:string) : string ->
	let f := fopen(self,"rb")
	in (externC("unsigned char digest[16]"),
		externC("CLMD5_CTX ctx"),
		externC("MD5Init(&ctx)"),
		while not(eof?(f))
			let raw := fread(f, 4096),
				len := length(raw)
			in externC("MD5Update(&ctx,(unsigned char*)raw,len)"),
		externC("MD5Final(digest, &ctx)"),
		copy(externC("(char*)digest",string), 16))
