(print_in_html(d))

my_class <: ephemeral_object(w%:float)

fill_area(self:pdf_document, data:my_class, w:float, h:float) : tuple(float, float) ->	
	(filled_rectangle(self, rectangle!(0., 100., data.w%, 0.), "green"),
	tuple(100., 100.))

( ?>
direct in the text	<area userdata=<? print(Core/Oid(my_class(w% = 50.))) ?>> voili voilou
<table>
	<? (for row in (1 .. 3)
		?><tr><?
			(for col in (1 .. 3)
				(if (row = 2 & col = 2)
					( ?><td>
						<area userdata=<? print(Core/Oid(my_class(w% = 50.))) ?>><? )
				else
					?><td>cell
						<?== row ?>,
						<?== col ?><? )) ?>
	<? ) ?>
</table><?  )

(end_of_html(d))
