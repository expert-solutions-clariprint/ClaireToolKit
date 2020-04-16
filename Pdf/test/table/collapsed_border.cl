(print_in_html(d))

( ?><p>Here is a normal table with a wide border :</p>

<table border=8 cellspacing=16>
	<tr>
		<td>cell
		<td>cell
		<td>cell
	<tr>
		<td>cell
		<td>cell
		<td>cell
</table><?  )


( ?><p>The same table with a collapsed border :</p>
	
	<table border=8 style='border-collapse: collapse'>
	<tr>
		<td>cell
		<td>cell
		<td>cell
	<tr>
		<td>cell
		<td>cell
		<td>cell
</table><?  )

( ?><p>The same table with a collapsed border and a thin border :</p>
	
	<table border=0.5 style='border-collapse: collapse'>
	<tr>
		<td>cell
		<td>cell
		<td>cell
	<tr>
		<td>cell
		<td>cell
		<td>cell
</table><?  )

(end_of_html(d))
