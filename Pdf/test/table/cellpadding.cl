(print_in_html(d))

(for n in (1 .. 7)
	( ?><table cellpadding=<?= (3 * n) ?>>
			<tr><td>cellpadding <?= (3 * n) ?>
		</table><? ))

(end_of_html(d))

