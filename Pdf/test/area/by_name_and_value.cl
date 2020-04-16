(print_in_html(d))

fill_area(self:pdf_document, n:{"my_area"}, v:{"0"}, w:float, h:float) : void ->	
	(filled_rectangle(self, rectangle!(0., 100., 100., 0.), "yellow"),
	tuple(100.,100.))

( ?><table>
	<? (for row in (1 .. 3)
		?><tr><?
			(for col in (1 .. 3)
				(if (row = 2 & col = 2)
					( ?><td>
						<area name=my_area value=0><? )
				else
					?><td>cell
						<?== row ?>,
						<?== col ?><? )) ?>
	<? ) ?>
</table><?  )

(end_of_html(d))
