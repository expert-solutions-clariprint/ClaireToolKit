(print_in_html(d))

( ?><p>
	This table is big and will be broken. Note that the thead and tfoot groups
	are repeated. Also note that the table has been scaled to fit in a page.
</p>

<table>
	<thead>
		<tr bgcolor="#FFAAFF"><th colspan=10>tr 1 of a thead group
		<tr bgcolor="#FFAAFF"><th rowspan=2 colspan=5>tr 2 of a thead group
			<td colspan=5>tr 2 of a thead group
		<tr bgcolor="#FFAAFF"><th colspan=5>tr 3 of a thead group
	</thead>
	<? (for r in (4 .. 101)
		( ?><tr><?
			(for c in (1 .. 10)
				( ?><td align=right>
						(<?= (r + 100000) ?>-<?= (c + 1000000) ?>)
						(<?= (r + 100) ?>-<?= (c + 100) ?>)
			<? )) ?>
	<? )) ?>
	<tfoot>
		<tr bgcolor="#FFFFAA"><th colspan=10>tr 1 of a tfoot group
		<tr bgcolor="#FFFFAA"><th rowspan=2 colspan=5>tr 2 of a tfoot group
			<td colspan=5>tr 2 of a tfoot group
		<tr bgcolor="#FFFFAA"><th colspan=5>tr 3 of a tfoot group
	</tfoot>
</table><?  )

(end_of_html(d))


/*
	<tfoot>
		<tr bgcolor="#FFFFAA"><th colspan=10>tr 1 of a tfoot group
		<tr bgcolor="#FFFFAA"><th rowspan=2 colspan=5>tr 2 of a tfoot group
			<td colspan=5>tr 2 of a tfoot group
		<tr bgcolor="#FFFFAA"><th colspan=5>tr 3 of a tfoot group
	</tfoot>
*/