(print_in_html(d))

nested_p(i:integer) : void ->
	(if (i > 0)
		( ?><p font-color=red>
				The following paragraph is big and nested (level <?= i ?>) !
			</p>
			<p align=justify border=1 padding=2><?
				(for j in (1 .. 100)
					( ?>how to fill a big paragraph (iteration <?= j ?>).<? ))
				//<sb> recurse
				?><? (nested_p(i - 1)) ?>
			</p><? ))

(nested_p(5))

(end_of_html(d))
