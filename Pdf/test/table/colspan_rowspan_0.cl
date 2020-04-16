(print_in_html(d))

( ?><p>The following tables have a column with a <b>null colspan</b>. The
	colspan is then infered by the table's column count:</p><? )

( ?><table border=1>
	<tr><td>cell<td>cell<td>cell<td>cell
	<tr><th colspan=0>cell with colspan=0
	<tr><td>cell<td>cell<td>cell<td>cell
</table><? )


( ?><p>The following tables have a non-last column with a <b>null colspan</b>. The
	colspan is then infered by the table's column count:</p><? )

( ?><table border=1>
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
	<tr><th colspan=0>cell with colspan=0<td>cell
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
</table><? )


( ?><p>The following tables have a column with a <b>null rowspan</b>. The
	rowspan is then infered by the table's row count:</p><? )

( ?><table border=1>
	<tr><th rowspan=0>cell with rowspan=0<td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell
</table><? )

( ?><p>The following tables have a non-first column with a <b>null colspan</b>. The
	colspan is then infered by the table's column count:</p><? )

( ?><table border=1>
	<tr><td>cell<td>cell<td>cell<td>cell
	<tr><td>cell<th colspan=0>cell with colspan=0
	<tr><td>cell<td>cell<td>cell<td>cell
</table><? )

( ?><p>The following tables have a non-first column with a <b>null rowspan</b>. The
	rowspan is then infered by the table's column count:</p><? )

( ?><table border=1>
	<tr><td>cell<td>cell<td>cell<td>cell
	<tr><td>cell<th rowspan=0>cell with rowspan=0<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell
</table><? )


( ?><p>And some more complex samples:</p><? )

( ?><table border=1>
	<tr><td colspan=0>colspan=0
	<tr><td rowspan=2>rowspan=2<td colspan=0>colspan=0
	<tr><td>cell<td>cell<td colspan=0>colspan=0
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
</table><? )



( ?><table page-break-inside=avoid border=1>
	<tr><td colspan=0>colspan=0<td rowspan=0>rowspan=0
	<tr><td rowspan=0>rowspan=0<td colspan=0>colspan=0
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell<td>cell
	<tr><td colspan=0>colspan=0
	<tr><td rowspan=0>rowspan=0<td colspan=0>colspan=0
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
	<tr><td>cell<td>cell<td>cell<td>cell<td>cell
</table><? )


(end_of_html(d))
