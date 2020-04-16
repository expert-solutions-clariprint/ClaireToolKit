(print_in_html(d))

( ?><p>the folowing attachment defines an inlined data with a default
		appearance. You may choose a default appearance by setting the
		"appearance" attribute with a value like "Pushpin", "Graph", "Paperclip"
		or "Tag" :</p>

<attachment content=titi.txt appearance=Paperclip name="embeded file" mimetype=text/plain>
	<data>titi</data>
</attachment>

<p>the following attachment defines the three available appearances :
	<ul angle=45>
		<li>normal : the normal appearance<br>la
		<li>down : when the annotation has been selected by a click
		<li>rollover : if not selected, when the cursor is over the annotation
	</ul>
	In order to open the attached file double click the annotation
</p><? )


( ?><attachment content=toto.txt mimetype=text/plain name="embeded file">

	<normal>come on</normal>

	<rollover>click me !</rollover>

	<down bgcolor=#AAAAAA>you did it :)</down>

	<data>toto</data>

</attachment><? )

(end_of_html(d))
