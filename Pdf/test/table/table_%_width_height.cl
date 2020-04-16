(print_in_html(d))

( ?><p>The following tables have various width percentage,
		single row/cell</p><? )

(for i in (1 .. 10)
	( ?><table width=<?== (i * 10) ?>% >
			<tr><td><?== (i * 10) ?>% table
		</table><? ))

( ?><p>The following centered table have the both width and height
		set to 40% and have few rows/cells</p><? )

( ?><table align=center width=40% height=40% >
	<? (for r in (1 .. 5)
		( ?><tr><?
			(for c in (1 .. 5)
				( ?><td><?= r ?> <?= c ?><? ))
			?><? )) ?>
</table><? )

( ?><p>Embeded centered tables that defines 50% width/height
		constraint :</p><? )

( ?><table align=center width=40% height=40% >
		<tr><td>
			<table align=center width=40% height=40% >
				<tr><td valign=middle>
					<table align=center width=40% height=40% >
						<tr><td>innermost table's cell
					</table>	
			</table>	
</table><? )

( ?><p>Embeded centered tables that defines 100% width/height
		constraint :</p><? )

( ?><table width=100% height=100% >
		<tr><td>
			<table width=100% height=100% >
				<tr><td>
					<table width=100% height=100% >
						<tr><td>
							Innermost table having both height and
							width set to 100%
					</table>
			</table>
</table><? )


( ?><p>100% table with various cells width constraints</p><? )

( ?><table width=100%>
		<tr><td width=200>width=200
			<td width=200>width=200
</table><? )

( ?><table width=100%>
		<tr><td width=200>width=200
			<td width=50% >width=50%
</table><? )


(end_of_html(d))
