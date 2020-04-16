(print_in_html(d))

( ?><p>An XObject is a graphic object that can be referenced from
	anywhere in your document with the element xobject. An XObject
	is referenced using a pair of name/value</p><? )

(end_of_html(d))

(print_in_html(d))

( ?><p bgcolor=GREENYELLOW border=1 bordercolor=red>
	This is an XObject
	</p><? )

(end_of_html_xobject(d, "my_xobject", 100.))

(print_in_html(d))

( ?><p>This paragraph makes a reference to our
		xobject <xobject name=my_xobject></p><? )


( ?><p>The following nested table make various reference to our xobject</p><? )

nested_xobject_table(nest:integer) : void ->
	( ?><table cellpadding=4 cellspacing=4 width=100% >
			<tr><td width=30% >
					<xobject name=my_xobject>
				<? (if (nest > 0)
					( ?><td><? nested_xobject_table(nest - 1) ?><? )) ?>
		</table><? )

(nested_xobject_table(4))

(end_of_html(d))
