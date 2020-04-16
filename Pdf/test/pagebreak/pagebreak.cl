(print_in_html(d))

( ?><p>Three pagebreak policies can be defined for an element :</p>
	<table>
		<tr>
			<th>policy<th>avoid<th>auto<th>always
		<tr align=center font-color=blue>
			<td>page-break-before<td>X<td>X<td>X
		<tr align=center font-color=green>
			<td>page-break-indide<td>X<td>X<td>-
		<tr align=center font-color=red>
			<td>page-break-after<td>X<td>X<td>X
	</table>
	<p>Dummy text<br>
		Still dummy<br>
		an again...</p>

<p border=1 style='page-break-inside: avoid; page-break-after: avoid'>
	<font size=+1 color=red>
		This paragrah is short and <b>avoid page break after</b>.
		This paragraph fit the bottom of the previous page but
		should be broken before due to the policy constraint of the
		next paragraph.
	</font>
</p>

<p border=1 style='page-break-inside: avoid'>
	<font size=+1 color=green>
		This paragragh <b>avoids page break inside</b> and is relatively long.
		Since both this paragrah and its former are bigger than the previous page
		remaining space a page break has been inserted before the previous paragrah.
	</font>
	<br>
	<br>
	<? (for i in (1 .. 100)
			( ?>Some text to fill the paragraph (<?== i ?>). <? )) ?></p>

<p border=1 style='page-break-after: avoid; page-break-inside: avoid'>
	<font size=+1 color=red>
		This paragrah is short and <b>avoid page break after</b>.
		This paragraph fit the bottom of the previous page but
		should be broken before due to the policy constraint of the
		next/next paragraph.
	</font></p>

<p border=1 style='page-break-inside: avoid'>
	<font size=+1 color=green>
		This paragraph <b>avoids page break inside</b>. Policies of the previous and
		next paragraph avoiding respectively after and before policies such this
		group of three paragraphes is unbreakable.
	</font></p>

<p border=1 style='page-break-inside: avoid; page-break-before: avoid'>
	<font size=+1 color=blue>
		This paragragh <b>avoids both page break before and inside</b> and is relatively
		long.
	</font>
	<br>
	<br>
	<? (for i in (1 .. 100)
			( ?>Some text to fill the paragraph (<?== i ?>). <? )) ?></p><? )

(end_of_html(d))
