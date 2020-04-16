(print_in_html(d))

nested_tables1(nest:integer) : void ->
	( ?><table>
			<tr><td>nested (<?== nest ?>)
				<td><? (if (nest > 0) nested_tables1(nest - 1)
						else princ("end")) ?>
		</table><? )

nested_tables2(nest:integer) : void ->
	( ?><table>
			<tr><td>
				<? (if (nest > 0) nested_tables2(nest - 1)
					else princ("end")) ?>
				<td>nested (<?== nest ?>)
		</table><? )

nested_tables3(nest:integer) : void ->
	( ?><table align=center>
			<tr><td>
				<? (if (nest > 0) nested_tables3(nest - 1)
					else princ("end")) ?>
			<tr><td>nested (<?== nest ?>)
		</table><? )

(nested_tables1(6),
nested_tables2(6),
nested_tables3(6))

(end_of_html(d))
