


[test() : void
-> let  g := gGraph(width = 300, height = 200),
		tasks := make_table(string,(gTask U {unknown}),unknown) 
	in (
		tasks["t1"] := gTask(graph = g, title = "t1",time_duration = 80.0),
		tasks["t2"] := gTask(graph = g, title = "t2",time_duration = 20.0),

		tasks["t3"] := gTask(graph = g,
							title = "t3",
							time_duration = 40.0,
							needs = list(tasks["t2"],tasks["t1"])),

		tasks["t4"] := gTask(graph = g,
							title = "t4",
							time_duration = 25.0,
							needs = list(tasks["t3"])),
		
		tasks["t5"] := gTask(graph = g,
							title = "t5",
							time_duration = 35.0,
							needs = list(tasks["t1"], tasks["t3"])),
//		tasks["t3"].needs :add tasks["t5"],
		//[0] génération de l'image : ,
		Gd/imagePngFile(draw(g),"test.png"))]

[test2() : void
-> let  g := gGraph(width = 300, height = 200),
		tasks := make_table(string,(gTask U {unknown}),unknown) 
	in (
		tasks["t1"] := gTask(graph = g,
							title = "t1",
							time_start = 00.0,
							time_duration = 80.0),
		tasks["t2"] := gTask(graph = g,
							title = "t2",
							time_start = 20.0,
							time_duration = 20.0),

		tasks["t3"] := gTask(graph = g,
							title = "t3",
							time_start = 23.0,
							time_duration = 40.0),

		tasks["t4"] := gTask(graph = g,
							title = "t4",
							time_start = 10.0,
							time_duration = 25.0),
		tasks["t5"] := gTask(graph = g,
							title = "t5",
							time_start = -3.0,
							time_duration = 35.0),
		g.rules :add gRule(title = "jours",
			scale = 24.0,
			step = 1,
			linestyle = 0,
			linewidth = 1),
		g.rules :add gRule(title = "heures",
			scale = 1.0,
			step = 4,
			linestyle = 0,
			linewidth = 1),

//		tasks["t3"].needs :add tasks["t5"],
		//[0] génération de l'image : ,
		Gd/imagePngFile(draw(g),"test.png"))]
