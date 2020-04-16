

// Return a new image from an +90 (+PI/2) rotation of im
[imageRotate90+(im:xlImage) : xlImage 
-> let 	width := imageSX(im),
		height := imageSY(im),
		width-1 := width - 1,
		height-1 := height - 1,
		newIm := imageCreate(height,width)
	in (
		for i in (0 .. imageColorsTotal(im))
			imageColorAllocate(newIm,
								imageRed(im,i),
								imageGreen(im,i),
								imageBlue(im,i)),
		
		for x in (0 .. width-1)
			for y in (0 .. height-1)
				let color 	:= imageGetPixel(im,x,y)
				in (if (color > 0) imageSetPixel(newIm,y,width-1 - x ,color)),
				
		newIm)]



// Return a new image from an -90 (-PI/2) rotation of im
[imageRotate90-(im:xlImage) : xlImage 
-> let 	width := imageSX(im),
		height := imageSY(im),
		width-1 := width - 1,
		height-1 := height - 1,
		newIm := imageCreate(height,width)
	in (
		for i in (0 .. imageColorsTotal(im))
			imageColorAllocate(newIm,
								imageRed(im,i),
								imageGreen(im,i),
								imageBlue(im,i)),
		
		for x in (0 .. width-1)
			for y in (0 .. height-1)
				let color 	:= imageGetPixel(im,x,y)
				in (if (color > 0) imageSetPixel(newIm,height-1 - y, x ,color)),
				
		newIm)]



// Return a new image from an vertical flip of im
[imageVFlip(im:xlImage) : xlImage 
-> let 	width := imageSX(im),
		height := imageSY(im),
		width-1 := width - 1,
		height-1 := height - 1,
		newIm := imageCreate(width,height)
	in (
		for i in (0 .. imageColorsTotal(im))
			imageColorAllocate(newIm,
								imageRed(im,i),
								imageGreen(im,i),
								imageBlue(im,i)),
		
		for x in (0 .. width-1)
			for y in (0 .. height-1)
				let color 	:= imageGetPixel(im,x,y)
				in (if (color > 0) imageSetPixel(newIm,x, height-1 - y,color)),
				
		newIm)]


// Return a new image from an horizontal flip of im
[imageHFlip(im:xlImage) : xlImage 
-> let 	width := imageSX(im),
		height := imageSY(im),
		width-1 := width - 1,
		height-1 := height - 1,
		newIm := imageCreate(width,height)
	in (
		for i in (0 .. imageColorsTotal(im))
			imageColorAllocate(newIm,
								imageRed(im,i),
								imageGreen(im,i),
								imageBlue(im,i)),
		
		for x in (0 .. width-1)
			for y in (0 .. height-1)
				let color 	:= imageGetPixel(im,x,y)
				in (if (color > 0) imageSetPixel(newIm,width-1 - x,y,color)),
				
		newIm)]

