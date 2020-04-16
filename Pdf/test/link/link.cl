(print_in_html(d))

( ?><p>A phrase with
		<a href="http://www.claire-language.com">a href to claire web site</a> inside
	</p>
	
	<p name=back_p>
		A phrase with a <a href=#skip_p>link to an anchor</a> inside
	</p><?

	(for i in (1 .. 100)
		( ?>A big text to test the previous anchor (iteration <?= i ?>). <? )) ?>

<p name=skip_p>
	this is out target paragraph,
	click <a href=#back_p>this link to go back</a>
</p><? )

(end_of_html(d))
