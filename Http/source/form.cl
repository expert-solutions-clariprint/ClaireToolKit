
// *********************************************************************
// * CLAIRE                                            Sylvain Benilan *
// * form.cl                                                           *
// * Copyright (C) 2005 xl. All Rights Reserved                        *
// *********************************************************************


// *********************************************************************
// * part 1: form variables                                            *
// *********************************************************************


//<sb> @cat Simple form variables
// @section Request input processing
// The HTTP handler is able to read a request input which is either of content
// type multipart/form-data or application/x-www-form-urlencoded.
// These protocols are use by the client to send form variables. Form
// variables are usualy defined with a name and a value. When reading the
// input of a request the HTTP handler fills a table that associates a form
// variable names to its value both represented as string. Let's consider the
// following form :
// \code
// ?><form>
// 		<input type=text name='name'>
// 		<input type=submit>
// </form><?
// \/code
// When this form is submited by the client a new entry is added in the $ table
// with the key field_name and the value string that was
// entered by the client in the text input, such we can use :
// \code
// $["name"]
// \/code
// Notice that the $ table defaults to false such we can test the existence of
// a form variable with :
// \code
// if $["name"]
// 	...
// \/code
// Also notice that a form field that is left empty is usualy not part of the
// submited request.\br
// If the same variable name is used for multiple form variable then the entry
// in the $ table will be set to the last occurrence found during the request
// input processing.
// @cat

//<sb> @doc Simple form variables
// $ is filled by the request input processor with all values found for
// a given variable name.
claire/$[vname:string] : any := false
claire/$POST[vname:string] : any := false


//<sb> @cat Multivalued form variables
// @section Request input processing
// To handle multiple values for a given variable name one should use
// the bracket notation as follow :
// \code
// ?><form>
// 		<input type=text name='name[key1]' value='val1'>
// 		<input type=text name='name[key2]' value='val2'>
// 		<input type=text name='name[]' value='val3'>
// 		<input type=submit>
// </form><?
// \/code
// If the above form is submited as is (i.e. specified defulat values
// are left unchenged by the client) we would find entries in the $,
// $keys and, $value tables :
// \code
// $["name"] => list("val1", "val2", "val3")
// $keys["name"] => list("key1", "key2")
// $value["name", "key1"] => "val1"
// $value["name", "key2"] => "val2"
// \/code
// Notice that when we use the bracket notation for a variable name, $ is filled with all
// values found for that name and if the key enclosed by the brackets isn't empty then
// the $keys and $value would also be updated. $keys contains all found keys for a given
// name and $value contain the value for a given name/key pair.
// @cat


//<sb> @doc Multivalued form variables
// The $keys table is filled by the input processor with the list
// of keys found for a given variable name.
claire/$keys[vname:string] : any := false

//<sb> @doc Multivalued form variables
// The $value table is filled by the input processor the value of the
// the given variable name and key pair.
claire/$value[vname:string, key:string] : any := false


//<sb> @cat Uploads
// @section Request input processing
// Last, the input processor is able to read multipart/form-data encoded
// forms which may be used to make a form with an input of type file :
// \code
// ?><form method=POST enctype="multipart/form-data">
// 	<input type=file name="file">
// 	<input type=submit>
// </form><?
// \/code
// When such a form is submited, the request input processor create a new
// entry in the $ table (as for simple form variables) of the upload type.
// An upload correspond to a file, that would be been saved by the server
// on the hard disk at the file_path attribute of the upload :
// \code
// if $["file"]
// 	let f := fopen($["file"].file_path, "r")
// 	in ...
// \/code
// The directory where file are uploaded is taken from the environment
// variable WCL_UPLOAD_FOLDER.
// @cat

//<sb> @doc Uploads
// An upload object is created for a form input when it is of type file.
// original_name/original_path would contain the name/path of the file
// from the client-side point of view, content_type would contain the
// MIME type od the uploaded file (e.g. "text/plain"), file_size is the
// size of the file in bytes. file_folder is the path of the server-side
// directory where the server uploaded the file (It is taken as the value
// of the environment variable WCL_UPLOAD_FOLDER) and file_path is the
// server-side path of the uploaded file.
claire/upload <: ephemeral_object(
						claire/original_name:string,
						claire/original_path:string,
						claire/content_type:string,
						claire/file_size:integer,
						claire/file_folder:string,
						claire/file_path:string)
 

[add_form_var(v1:string, v2:any) : void ->
	//[2] === add_form_var(~S, ~S) // v1, v2,
	if (right(v1, 2) = "[]")
		(v1 := substring(v1, 1, length(v1) - 2),
		if not($[v1]) $[v1] := list<any>(),
		if not($POST[v1]) $POST[v1] := list<any>(),
		$[v1] :add v2,
		$POST[v1] :add v2)
	else if (right(v1,1) = "]")
		(v1 := substring(v1, 1, length(v1) - 1),
		let tl := explode(v1, "[")
		in (if (length(tl) = 2)
				let tl1 := tl[1],
					tl2 := tl[2]
				in (if not($keys[tl1])
						$keys[tl1] := list<any>(),
					$keys[tl1] :add tl2,
					if not($[tl1])
						$[tl1] := list<any>(),
					if not($POST[tl1])
						$POST[tl1] := list<any>(),
					$[tl1] :add v2,
					$POST[tl1] :add v2,
					$value[tl1, tl2] := v2)))
	else (	$[v1] := v2,
			$POST[v1] := v2	)]



// *********************************************************************
// *   Part 2: form data                                               *
// *********************************************************************


[handle_form_data_from_env(self:http_handler) : void ->
	let ct := getenv("CONTENT_TYPE"),
		query_string? := (length(getenv("QUERY_STRING")) > 0)
	in (if match_wildcard?(ct, "*multipart/form-data*")
			(//[-100] == Handle form data with content-type multipart/form-data,
			handle_multipart_form_data(self, ct))
		else if (match_wildcard?(ct, "*application/x-www-form-urlencoded*") | query_string?)
			(//[-100] == Handle form data with content-type application/x-www-form-urlencoded,
			handle_x_www_form_urlencoded(self)))]


// *********************************************************************
// *   Part 3: form data (application/x-www-form-urlencoded)           *
// *********************************************************************

[handle_x_www_form_urlencoded(self:http_handler) : void ->
	//[-100] === Handle x-www-form-urlencoded on ~S // self.input,
	while not(eof?(self.input))
		let buf := freadline(self.input, "&"),
			l := explode(buf, "=") in
				(if (length(l) = 2)
					add_form_var(url_decode(l[1]), url_decode(l[2])))]

[handle_x_www_form_urlencoded(self:http_handler, p:port) : void ->
	//[-100] === Handle x-www-form-urlencoded on ~S // p,
	while not(eof?(p))
		let buf := freadline(p, "&"),
			l := explode(buf, "=") in
				(if (length(l) = 2)
					add_form_var(url_decode(l[1]), url_decode(l[2])))]


// *********************************************************************
// *   Part 4: form data (multipart/form-data)                         *
// *********************************************************************


[explode_content_disposition(line:string) : tuple(string, string, boolean) ->
	let varname := "", varfilename := "", havefile? := false
	in (for v in explode(rtrim(line), "; ")
			let tmp := explode(substring(v,1,length(v) - 1),"\"")
			in (if (length(tmp) = 1) tmp :add "",
				case tmp[1]
					({"name="} varname := tmp[2],
					{"filename="}
						(havefile? := true,
						varfilename := tmp[2]))),
		tuple(varname, varfilename, havefile?))]


[handle_multipart_form_data(self:http_handler, ct:string) : void ->
	//[-100] === handle_multipart_form_data on ~S // self.input,
	let boundary := ("--" /+ right(ct, length(ct) - find(ct,"boundary=") - 8)),
		cdisp := "",
		sub_ct := "",
		i := self.input
	in while not(eof?(i))
		let line := freadline(i)
		in (if (find(lower(line), "content-disposition:") = 1)
				cdisp := line,
			if (find(lower(line), "content-type:") = 1)
				sub_ct := substring(line, 15, length(line)),
			if (not(eof?(i)) & trim(line) = "" & length(cdisp) > 0)
				let (varname, varfilename, havefile?) :=
							 explode_content_disposition(cdisp)
				in let br := boundary_reader!(i, boundary)
				in (if havefile?
						(if (length(varfilename) > 0)
								let fu := upload(content_type = sub_ct,
											original_path = varfilename,
											file_size = 0,
											file_folder = getenv("WCL_UPLOAD_FOLDER"),
											original_name = last(explode(varfilename,"\\"))),
									path := fu.file_folder /
												getenv("WCL_SESSION_NAME") /+
												"-" /+ getenv("WCL_SESSION") /+
												"-" /+ varname /+
												"-" /+ fu.original_name,
									f := fopen(path, "w")
								in (fu.file_path := path,
									//[-100] == Upload ~A file [~A] // ct, path,
									fu.file_size := freadwrite(br, f),
									fclose(f),
									add_form_var(varname, fu))
						else freadwrite(br, null!()))
					else add_form_var(varname, fread(br)),
					fclose(br),
					cdisp := "",
					sub_ct := ""))]


