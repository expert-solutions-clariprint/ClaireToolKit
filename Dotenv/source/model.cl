

[loadenv() : void 
->  let dotenv := pwd() / ".env"
    in (if (isfile?(dotenv))
        (//[1] loading environment variables from file ~A... // dotenv,
        let file := fopen(dotenv, "r")
        in (while not(eof?(file))
            let line := freadline(file),
                eqpos := find(line, "=")
            in (//[2] processing line: ~A   eq:~S // line, eqpos,
                if (eqpos > 0 & length(line) > 2 & line[1] != '#' & (eqpos + 2) < length(line))
                    let key := trim(substring(line, 1, eqpos - 1)),
                        val := trim(substring(line, eqpos + 2,length(line)))
                    in (//[3] set env variable ~A : ~A // key, val,
                        setenv(key /+ "=" /+ val ),
                        none)),
                //[2] done,
                fclose(file))))]


[option_usage(self:{"-dotenv"}) : tuple(string,string,string) ->
	tuple("dotenv", "-dotenv", "Load environment variables from a .env file in the current directory.")]
			

[option_respond(self:{"-dotenv"},l: list) : void -> loadenv()]

