(print_in_html(d))

( ?><p>Their is support for font/<b>b (bold)</b>/<i>i (italic)</i>/<u>u (underlined)</u>
	inline elements.</p><? )

( ?><p>Font element support attributes point-size/size/color/font-face/decoration.
		For instance, here are nested font elements that each perform a size=+1</p><? )

nested_font(level:integer) : void ->
	( ?><font size=+1>
			start iteration <?= level ?>
				&lt;<? (if (level > 1)
					nested_font(level - 1)) ?>&gt;
			end iteration <?= level ?></font><? )

( ?><p border=1><? (nested_font(8)) ?></p><? )


(end_of_html(d))
