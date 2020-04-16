(print_in_html(d))

( ?><p font-color=red>The following paragraph is justified and have multiple page break inside</p>
	<p align=justify><?
		(for i in (1 .. 280)
			( ?>This is a big paragraph (iteration <?= i ?>). <? )) ?>
	</p><? )

(end_of_html(d))
