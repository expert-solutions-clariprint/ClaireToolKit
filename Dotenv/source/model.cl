

[loadenv(filename:string) : void 
->  if (isfile?(filename))
        (//[1] loading environment variables from file ~A... // filename,
        let afile := fopen(filename, "r")
        in (while not(eof?(afile))
            let line := freadline(afile),
                eqpos := find(line, "=")
            in (//[2] processing line: ~A   eq:~S // line, eqpos,
                if (eqpos > 0 & length(line) > 2 & line[1] != '#' & (eqpos + 2) < length(line))
                    let key := trim(substring(line, 1, eqpos - 1)),
                        val := trim(substring(line, eqpos + 2,length(line)))
                    in (//[3] set env variable ~A : ~A // key, val,
                        setenv(key /+ "=" /+ val ),
                        none)),
                //[2] done,
                fclose(afile)))]

[loadenv() : void  -> loadenv(pwd() / ".env")] // overload for optional argument


[option_usage(self:{"-dotenv"}) : tuple(string,string,string) ->
	tuple("dotenv", "-dotenv", "Load environment variables from a .env file in the current directory.")]
			

[option_respond(self:{"-dotenv"},l: list) : void -> loadenv()]


[option_usage(self:{"-file-env"}) : tuple(string,string,string) ->
	tuple("dotenv", "-file-env <filename>", "Load environment variables from a specified file.")]
			

[option_respond(self:{"-file-env"},l: list) : void
-> if (not(l)) invalid_option_argument(),
   loadenv(l[1]),
   l << 1]

