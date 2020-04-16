(print_in_html(d))

( ?><p>note that paragraph support border</p>
	<p width=120 border=1>
		This paragraph is 120 pt wide and should be wrapped
	</p>
	<p width=100% border=1>
		This paragraph as wide as a page (width is 100%)
	</p>
	<p width=50% height=150 border=1>
		This paragraph have 50% width and 150 pt height
	</p>
	<p width=50% height=50% align=center border=1>
		This paragraph is centered and have 50% for both width and height
	</p>

	<p width=900 border=1>
		This paragraph as a width (900pt) that is greater than a A4 page. This should
		make this paragraph scaled to exactly fit a page.<br>
		second line
	</p>

<? )

(end_of_html(d))
