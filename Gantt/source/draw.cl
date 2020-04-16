
[private/setPositions(t:gTask,row:integer) : integer
->	//[0] setPositions ~S // t.title,		
	let res := row
	in (if not(t.needs) (
			t.draw_start := integer!(t.time_start),
			t.draw_row := row,
			res := row + 1,
			t.positioned? := true)
		else if forall( x in t.needs | x.positioned?)
			let min_start := 0.0 
			in (for x in t.needs min_start := max(x.time_start + x.time_duration,min_start),
				t.time_start := min_start,
				t.draw_row := row,
				t.positioned? := true),
		if (t.positioned?)
			for x in t.sub_tasks
				let r := row
				in (row := setPositions(x,row) + 1,
					res := row),
		res)]


[private/setPositions(g:gGraph) : integer
->	//[0] setPositions(gGraph) ,
	let row := 0
	in (for t in list{i in g.tasks | not(i.needs)}
			row := setPositions(t,row), // + 1,
		row
		)]


[draw(g:gGraph) : Gd/xlImage
->	//[0] draw() ,
	g.img := Gd/imageCreate(g.width,g.height),
	Gd/imageColorAllocate(g.img, g.back_color[1],g.back_color[2],g.back_color[3]),
//	g.time_line := checkCriticalPath(g),
	let nrows :=  setPositions(g)
	in (
		setColTitle(g),
		setScale(g),
		drawRules(g),
		g.row_height := (g.height - g.bottom_rules) / nrows,
		for t in g.tasks (if t.positioned? draw(t)),
		g.img)]
	

[drawRules(g:gGraph) : void
->	//[0] drawRules(),
	for i in g.rules draw(g,i)]

[draw(g:gGraph,r:gRule) : void
->	//[0] draw(gRraph, gRule),
	let h := Gd/height(r.font),
		im :=  g.img,
		coul := Gd/imageColorResolve(im,r.color[1],r.color[2],r.color[3])
	in (
		if (r.height < h) r.height := h else h := r.height,
		if ((g.row_title_width > 0) & known?(title,r)) (
			//[0] ici,
			Gd/imageString(im, r.font, 0, g.bottom_rules, r.title,coul)),
		//[0] g.row_title_width=~S // g.row_title_width, 
		g.bottom_rules :+  h,
		g.bottom_rules :+  1,
		Gd/imageLine(im,0, g.bottom_rules,g.width,g.bottom_rules,coul),
		let boffset := integer!(r.offset / r.scale),
			borne_inf := integer!(g.time_start / r.scale) - boffset,
			borne_sup := integer!(g.time_end / r.scale) - boffset
		in (//[0] g.time_start=~S  g.time_end=~S r.scale=~S// g.time_start ,g.time_end,r.scale,
			//[0] borne_inf=~S borne_sup=~S // borne_inf,borne_sup, 
			for i in (borne_inf .. borne_sup)
				let pos := getXFromTime(g,float!(i) * r.scale + r.offset)
				in (//[0]    i=~S   pos==~S // i,pos,
					Gd/imageLine(im, pos,g.bottom_rules - 2,pos,g.bottom_rules,coul),
					if (mod(i,r.step) = 0 ) (
						Gd/imageString(im,r.font, pos, g.bottom_rules - h, string!(i),coul),
						if (r.linestyle = 1)
							Gd/imageLine(im, pos,g.bottom_rules ,pos,g.height,coul),
						if (r.linestyle = 2)
							Gd/imageDashedLine(im, pos,g.bottom_rules ,pos,g.height,coul)))),
		g.bottom_rules :+  1,
		none)]

[setScale(g:gGraph) : void
->	//[0] setScale(),
	let min_start := 1e99,
		max_end := -1e99
	in (for t in g.tasks (
		let _end := t.time_start + t.time_duration
		in (//[0] title=~S  start=~S duration=~S end=~S // t.title, t.time_start, t.time_duration, _end,
			if (t.time_start < min_start) min_start := t.time_start,
			if (_end > max_end) max_end := _end)),
		//[0] Scale min_start=~S  max_end=~S  scale=~S //   min_start, max_end, g.time_scale,
		g.time_scale := float!(g.width - g.row_title_width) /  (max_end - min_start),
		g.time_end := max_end,
		g.time_start := min_start,
		if (g.time_end <= g.time_start) (g.time_end :=  g.time_start + 1.0 ,g.time_scale := 1.0) 
		)]

//		:float = 0.0,		// timestamp
//				time_duration:float = 0.0,	// hour


[private/setColTitle(g:gGraph) : void
->	//[0] setColTitle(),
	if (g.row_title_mode = 0) (
		//[0] setColTitle ici (),
		if (g.row_title_width = 0) (
			//[0] setColTitle la(),
			for t in g.tasks (
				//[0] setColTitle ~S : ~S // t.title,Gd/width(t.title,g.row_title_font),
				if (known?(title,t) & (Gd/width(t.title,g.row_title_font) > g.row_title_width))
					g.row_title_width := Gd/width(t.title,g.row_title_font))))
	else g.row_title_width := 0]


[private/getXFromTime(g:gGraph,t:float) : integer
-> integer!((t - g.time_start) * g.time_scale) + g.row_title_width]

[private/getXFromDuration(g:gGraph,t:float) : integer
-> integer!(t * g.time_scale)]
//	integer!((float!(g.width) * t) / g.time_line) ]

[private/getYRow(g:gGraph,row:integer) : integer
-> ((row * g.row_height) + g.bottom_rules)]

[draw(t:gTask,pos:integer) : integer
->	let left := 0,
		c := Gd/imageColorResolve(t.graph.img,255,100,100)
	in (//[0] draw task,
		if (known?(needs,t) & t.needs)
			for n in t.needs  (if (getEnd(n) > left) left := getEnd(n)),
		Gd/imageFilledRectangle(t.graph.img,
								getXFromDuration(t.graph,float!(left)),
								getYRow(t.graph,pos),
								left + getEnd(t),
								getYRow(t.graph,pos) + t.graph.row_height,
								c),
//		Gd/imageString(t.graph.img,
		t.drawed? := true,			
		for subt in list{i in t.sub_tasks | not(drawed?(i))}
			pos := draw(subt,pos) + 1,
		pos)]
		
TEST:any := 0
[draw(t:gTask) : integer
->	let c := Gd/imageColorResolve(t.graph.img,255,100,100),
		backcolor := Gd/imageColorResolve(t.graph.img,255,255,255),
		black := Gd/imageColorResolve(t.graph.img,0,0,0),
		linecolor := Gd/imageColorResolve(t.graph.img,
											t.graph.row_separator_color[1],
											t.graph.row_separator_color[2],
											t.graph.row_separator_color[3])
	in (//[0] draw task,
		t.draw_start := getXFromTime(t.graph,t.time_start),
		//[0] start:~S, drawtart=~S, sclale=~S, colwidth=~S //  t.time_start, t.draw_start, t.graph.time_scale, t.graph.row_title_width,
		Gd/imageFilledSmoothRectangle(t.graph.img,
								getXFromTime(t.graph, t.time_start),
								getYRow(t.graph,t.draw_row),
								getEnd(t),
								getYRow(t.graph,t.draw_row) + t.graph.row_height - t.graph.row_space,
								c,backcolor),
		if (t.graph.row_title_mode = 1)
			Gd/imageStringCenter(t.graph.img,
										Gd/xlFontTiny(),
										t.draw_start + integer!(t.time_duration) / 2,
										getYRow(t.graph,t.draw_row) + t.graph.row_height / 2,
										t.title,
										black),
		
		if (t.graph.row_title_mode = 0)
			Gd/imageString(t.graph.img,
							(if unknown?(row_title_font,t.graph) Gd/xlFontTiny() else t.graph.row_title_font),
							1,
							getYRow(t.graph,t.draw_row) + t.graph.row_height / 2,
							t.title,
							black),
		if (t.graph.row_separator = 1)
			Gd/imageLine(t.graph.img,
						0,
						getYRow(t.graph,t.draw_row) + t.graph.row_height,
						t.graph.width,
						getYRow(t.graph,t.draw_row) + t.graph.row_height,
						linecolor),
						
		for x in t.needs
			Gd/imageDashedLine(t.graph.img,
								t.draw_start,
								getYRow(t.graph,t.draw_row) + t.graph.row_height / 2, 
								x.draw_start + integer!(x.time_duration),
								getYRow(x.graph,x.draw_row) + t.graph.row_height / 2, 
								black),
		//[0] draw out,
		0)]

[private/checkCriticalPath(g:gGraph) : float
->	let val := 1.0
	in (for t in list{i in g.tasks | not(i.needs)}
			val := max(val,getCriticalPath(t)),
		val)]

[private/getCriticalPath(t:gTask) : float
-> 	//[0]  getCriticalPath(~S) // t.title,
	let maxi := 0.0
	in (for i in t.sub_tasks
			let p := getCriticalPath(i)
			in (maxi := max(p,maxi)),
		maxi + t.time_duration)]
	


[private/getEnd(t:gTask) : integer
-> getXFromTime(t.graph,t.time_start) + getXFromDuration(t.graph,t.time_duration)]


