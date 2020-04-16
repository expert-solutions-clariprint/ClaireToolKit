(print_in_html(d))

( ?><p border=1 background=test/image/webclaire.png>
		This paragraph defines a background image
	</p><? )

( ?><p border=1 background-style=scale background=test/image/webclaire.png>
		This paragraph defines a background image with scale attribute
	</p><? )

( ?><p border=1 width=30% height=30% background=test/image/webclaire.png>
		This paragraph defines a background image
		and size constraints (30% width/height).
	</p><? )

( ?><p border=1 width=30% height=30% background-style=scale background=test/image/webclaire.png>
		This paragraph defines a background image
		and size constraints (30% width/height).<br>
		Additionaly, the background-style attribute
		is here set to "scale".
	</p><? )

( ?><p>And here as a backgroud of a table cell : </p>
	<table>
		<tr><td>cell
			<td background=test/image/webclaire.png>cell
		<tr><td>cell
			<td>cell
	</table><? )

( ?><p>Or even as a table background : </p>
	<table background=test/image/webclaire.png>
		<tr><td>cell
			<td>cell
		<tr><td>cell
			<td>cell
	</table><? )

(end_of_html(d))
