(print_in_html(d))

( ?><p>The following tables have the first column with various width percentage</p><? )

(for i in (1 .. 10)
	( ?><table>
			<tr><td width=<?= (i * 10) ?>% >
					width <?== (i * 10) ?>%
				<td>any cell
				<td>any cell
			<tr><td>any cell
				<td>any cell
				<td>any cell
		</table><? ))

( ?><p>The following table have cells width % constraints such the sum is 100%
		(overflow), the constraint cannot be satisfied. In such a case the maximum
		available width is distributed on columns requiring a percentage of the
		width :</p><? )

( ?><table>
	<tr><td width=50% >width 50%
		<td>any cell
		<td>any cell
	<tr><td>any cell
		<td width=50%>width 50%
		<td>any cell
</table><? )

( ?><p>The following table adds a 40% height constraint on a cell</p><? ) 

( ?><table>
	<tr><td width=50% >width 50%
		<td>any cell
		<td>any cell
	<tr><td>any cell
		<td width=50% height=40% >width 50%, height 40%
		<td>any cell
</table><? )


(end_of_html(d))
