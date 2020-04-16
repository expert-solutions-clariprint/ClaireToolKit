(print_in_html(d))

( ?><table>
	<? (for row in (1 .. 7)
		?><tr><?
			(for col in (1 .. 7)
				?><td>cell
					<?== row ?>,
					<?== col ?>
		<? ) ?>
	<? ) ?>
</table><?  )

(end_of_html(d))
