(print_in_html(d))

( ?><p>Here is a line filled with a word composed of 150 'W' characters.
	Such a line is wider than a page and this text should be scaled in
	order to fit the page :</p><? )

( ?><?= make_string(150, 'W') ?><? )

(end_of_html(d))
