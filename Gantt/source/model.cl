

gGraph <: ephemeral_object
gTask <: ephemeral_object
gRule <:  ephemeral_object

gGraph <: ephemeral_object(
			private/img:Gd/xlImage,  // gdImage of the graph

			width:integer, // width of th image
			height:integer, // heaith of the image
			
			title:string,  // title of the graph (unused)
			
			auto_placement:boolean = false,
			scale_relative:boolean = true, // true : relative, false : absolute 
			
			time_mode:integer = 0,  // 0 : automatic , 1 : use  time_start & time_end
			time_start:float,
			time_end:float,
			time_scale:float,
			
			back_color:tuple(integer,integer,integer)  = tuple(255,255,255),
	
			// color and sepator of rows 
			sep_color:tuple(integer,integer,integer) = tuple(0,0,0),
			sep_width:integer = 0,
		
			row_title_mode:integer = 0, // 0 : tasks title in column, 1 in tasks rectangle 
			row_title_width:integer = 0, // 0 : automatic width
			row_title_font:Gd/xlFont,
		
			row_space:integer = 1,
			row_separator:integer = 1, // 0: norow separator, 1 : line , 2: dashedline
			row_separator_color:tuple(integer,integer,integer) = tuple(120,120,120),
			private/row_height:integer = 0,

			private/bottom_rules:integer = 0,
			
			rules:list[gRule],
			tasks:list[gTask])

[close(self:gGraph) : gGraph
-> 	if unknown?(row_title_font,self) self.row_title_font := Gd/xlFontSmall(),
	self]

gTask <: ephemeral_object(
				graph:gGraph,
				title:string,
				time_start:float = 0.0,		// timestamp
				time_duration:float = 0.0,	// hour
				needs:list[gTask],
				completion:float = 1.0,
				color:tuple(integer,integer,integer) = tuple(255,255,255),

				private/drawed?:boolean = false,
				
				private/positioned?:boolean = false,
				private/draw_start:integer,
				private/draw_row:integer,

				private/drawed_top:integer,
				private/drawed_left:integer,

				private/sub_tasks:list[gTask]
				)

			
(inverse(graph) := tasks)
(inverse(sub_tasks) := needs)

gRule <: ephemeral_object(
			title:string,
			height:integer,
			font:Gd/xlFont,
			scale:float,
			offset:float,
			step:integer,
			color:tuple(integer,integer,integer) = tuple(0,0,0),
			linestyle:integer = 0,  // 0: noline,  1: solid, 2: Dashed 
			linewidth:integer = 1)


[close(self:gRule) : gRule
->	if unknown?(font,self) self.font := Gd/xlFontTiny(),
	self]