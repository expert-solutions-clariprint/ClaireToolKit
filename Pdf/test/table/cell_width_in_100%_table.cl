(print_in_html(d))


( ?><p>The following 100% tables have sidding columns 10 pt wide. This width
	constraint is not satisfied, the minimun required width is taken instead :</p><? )

( ?><table width=100% >
		<tr><td width=10>cell
			<td>cell
			<td width=10>cell
</table><? )

( ?><p>The following 100% tables have sidding columns 60 pt wide,
	here the width constraint is satisfied</p><? )

( ?><table width=100% >
		<tr><td width=60>cell
			<td>cell
			<td width=60>cell
</table><? )

( ?><p>The following 100% tables have first sidding columns 10 pt wide,
	here the constraint can't be satisfied due to the second row which
	in turn is used as the minimun required width :</p><? )

( ?><table width=100% >
		<tr><td width=10>cell
			<td>cell
			<td width=10>cell
		<tr><td>bigger_cell
			<td>cell
			<td>also_a_bigger_cell
</table><? )


(end_of_html(d))
