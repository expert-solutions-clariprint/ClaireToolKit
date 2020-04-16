
// Image Class
xlImage <: import()

// Font Class
xlFont <: import()

(c_interface(xlImage,"gdImagePtr "))
(c_interface(xlFont,"gdFontPtr "))

// Called to create images. Invoke gdImageCreate with the x and y dimensions of the desired image.
[imageCreate(x:integer, y:integer) : xlImage
-> function!(gdImageCreate)]

// Called to load images from JPEG format files
[imageCreateFromPng(f:string) : xlImage
->	externC("FILE * fd = fopen(f,\"r\")"),
	externC("gdImageCreateFromPng(fd)",xlImage)]

// Called to load images from PNG format files
[imageCreateFromJpeg(f:string) : xlImage
->	externC("FILE * fd = fopen(f,\"r\")"),
	externC("gdImageCreateFromJpeg(fd)",xlImage)]

;[imageCreateFromWBMP(f:string) : xlImage
;->	externC("FILE * fd = fopen(f,\"r\")"),
;	externC("gdImageCreateFromWBMP(fd)",xlImage)]

// Used to free the memory associated with an image
[imageDestroy(im:xlImage) : void -> function!(gdImageDestroy)]


// Sets a pixel to a particular color index
[imageSetPixel(im:xlImage,  x:integer, y:integer, color:integer) : void
-> function!(gdImageSetPixel)]

// Get color index of a pixel
[imageGetPixel(im:xlImage,  x:integer, y:integer) : integer
-> function!(gdImageGetPixel)]

//

// Draw a line 
[imageLine(im:xlImage,  x1:integer, y1:integer,x2:integer, y2:integer, color:integer) : void
-> function!(gdImageLine)]

// draw a dashed line
[imageDashedLine(im:xlImage,  x1:integer, y1:integer,x2:integer, y2:integer, color:integer) : void
-> function!(gdImageDashedLine)]

// draw a rectangle
[imageRectangle(im:xlImage, x1:integer, y1:integer, x2:integer, y2:integer, color:integer) : void
-> function!(gdImageRectangle)]

// draw a filled rectangle
[imageFilledRectangle(im:xlImage, x1:integer, y1:integer, x2:integer, y2:integer, color:integer) : void
-> function!(gdImageFilledRectangle)]


// draw a filled rectangle
[imageFilledSmoothRectangle(im:xlImage, x1:integer, y1:integer, x2:integer, y2:integer, color:integer,backcolor:integer) : void
->	let red := imageRed(im,color),
		blue := imageBlue(im,color),
		green := imageGreen(im,color),
		bred := imageRed(im,backcolor),
		bblue := imageBlue(im,backcolor),
		bgreen := imageGreen(im,backcolor),
		darkcontrast := imageColorResolve(im,(red ) / 3, (blue ) / 3, (bgreen ) / 3),
//		darkcontrast2 := imageColorResolve(im,(2 * red ) / 3, (2 * blue ) / 3, (2 * bgreen ) / 3),
		lightcontrast := imageColorResolve(im,(red + bred) / 2, (blue + bblue) / 2, (bgreen + green) / 2)
	in (imageFilledRectangle(im,x1 + 1, y1 + 1, x2 - 1 , y2 - 1,color),
		imageLine(im,x1,y1,x2,y1,lightcontrast),
		imageLine(im,x1,y1,x1,y2,lightcontrast),

//		imageLine(im,x1 + 1,y2 - 1,x2 - 1,y2 - 1,darkcontrast),
//		imageLine(im,x2 - 1 ,y1 + 1,x2 - 1,y2 - 1,darkcontrast),
		
		imageLine(im,x1,y2,x2,y2,darkcontrast),
		imageLine(im,x2,y1,x2,y2,darkcontrast))]



// Returns (1) if the specified point is within the bounds of the image
[imageBoundsSafe(im:xlImage, x1:integer, y1:integer) : integer
-> function!(gdImageBoundsSafe)]



//--------------------------------------------------------------------------------
// FONT
//-------------------------------------------------------------------------------

// Return a giant font "gdFontGiant" 
[xlFontGiant() : xlFont -> externC("gdFontGiant",xlFont)]
// Return a large font "gdFontLarge" 
[xlFontLarge() : xlFont -> externC("gdFontLarge",xlFont)]
// Return a small font "gdFontSmall" 
[xlFontSmall() : xlFont -> externC("gdFontSmall",xlFont)]
// Return a tiny font "gdFontTiny" 
[xlFontTiny() : xlFont -> externC("gdFontTiny",xlFont)]

// return width of a font
[width(self:xlFont) : integer 
-> externC("self->w",integer)]

// return height of a font
[height(self:xlFont) : integer 
-> externC("self->h",integer)]

[width(self:string,font:xlFont) : integer 
-> length(self) * width(font)]

[height(self:string,font:xlFont) : integer 
-> height(font)]



// Draw a char
[imageChar(im:xlImage, f:xlFont, x:integer, y:integer, c:char, color:integer) : void
-> externC("gdImageChar(im,f,x,y,c->ascii,color)")]

// Draw a char at +90°
[imageCharUp(im:xlImage, f:xlFont, x:integer, y:integer, c:char, color:integer) : void
-> externC("gdImageCharUp(im,f,x,y,c->ascii,color)")]


// Draw a string 
[imageString(im:xlImage,f:xlFont, x:integer, y:integer, s:string, color:integer) : void
-> externC(" gdImageString(im,f,x,y,(unsigned char *) s,color)")]

// draw a center string
[imageStringCenter(im:xlImage,f:xlFont, x:integer, y:integer, s:string, color:integer) : void
-> 	x :- (width(s,f) / 2),
	y :- (height(f) / 2),
	imageString(im,f, x, y, s, color)]


// Draw a string at +90°
[imageStringUP(im:xlImage,f:xlFont, x:integer, y:integer, s:string, color:integer) : void
-> externC(" gdImageStringUp(im,f,x,y,(unsigned char *) s,color)")]

// draw a center string at +90°
[imageStringUPCenter(im:xlImage,f:xlFont, x:integer, y:integer, s:string, color:integer) : void
-> 	y :+ (width(s,f) / 2),
	x :- (height(f) / 2),
	imageStringUP(im,f, x, y, s, color)]



;void gdImageString16(gdImagePtr im, gdFontPtr f, int x, int y, unsigned short *s, int color);
;void gdImageStringUp16(gdImagePtr im, gdFontPtr f, int x, int y, unsigned short *s, int color);

// a verifier
;char *gdImageStringFT(gdImage *im, int *brect, int fg, char *fontlist,
;                double ptsize, double angle, int x, int y, char *string);



// imageColorAllocate finds the first available color index in the image specified, 
// sets its RGB values to those requested (255 is the maximum for each),
//  and returns the index of the new color table entry. 
// When creating a new image, the first time you invoke this function,
//  you are setting the background color for that image. 
[imageColorAllocate( im:xlImage, r:integer, g:integer, b:integer) : integer
-> function!(gdImageColorAllocate)]

// imageColorClosest searches the colors which have been defined thus far in the image 
// specified and returns the index of the color with RGB values closest 
// to those of the request. 
// (Closeness is determined by Euclidian distance, which is used to determine the distance in
// three-dimensional color space between colors.) 
[imageColorClosest( im:xlImage, r:integer, g:integer, b:integer) : integer
-> function!(gdImageColorClosest)]

// imageColorExact searches the colors which have been defined thus far 
// in the image specified and returns the index of the first color with RGB values 
// which exactly match those of the request. 
// If no allocated color matches the request precisely, 
// imageColorExact returns -1. 
// See imageColorClosest for a way to find the color closest to the color requested.
[imageColorExact( im:xlImage, r:integer, g:integer, b:integer) : integer
-> function!(gdImageColorExact)]

//imageColorResolve searches the colors which have been defined thus far 
// in the image specified and returns the index of the first color with RGB values
// which exactly match those of the request.
// If no allocated color matches the request precisely, 
// then imageColorResolve tries to allocate the exact color.
// If there is no space left in the color table then imageColorResolve returns the closest color (as in gdImageColorClosest). 
// This function always returns an index of a color. 
[imageColorResolve( im:xlImage, r:integer, g:integer, b:integer) : integer
-> function!(gdImageColorResolve)]

//imageColorDeallocate marks the specified color as being available for reuse.
// It does not attempt to determine whether the color index is still in use in the image.
// After a call to this function, the next call to imageColorDeallocate for the same image 
// will set new RGB values for that color index,
//  changing the color of any pixels which have that index as a result.
//  If multiple calls to imageColorDeallocate are made consecutively,
// the lowest-numbered index among them will be reused by the next imageColorDeallocate call. 
[imageColorDeallocate( im:xlImage, color:integer) : void
-> function!(gdImageColorDeallocate)]

// imageColorTransparent sets the transparent color index for the specified image 
// to the specified index. 
// To indicate that there should be no transparent color, 
// invoke imageColorTransparent with a color index of -1. 
// Note that JPEG images do not support transparency, so this setting has no effect when writing JPEG images. 
[imageColorTransparent( im:xlImage, color:integer) : void
-> function!(gdImageColorTransparent)]

// Copies a palette from one image to another, 
// attempting to match the colors in the target image to the colors in the source palette. 
[imagePaletteCopy( dst:xlImage, src:xlImage) : void
-> function!(gdImagePaletteCopy)]


// Create a png image file
[imagePngFile(im:xlImage,out:string) : void
-> 	externC("FILE * f = fopen(out,\"wb\")"),
	externC("if (f) gdImagePng(im, f)"), 
	externC("if (f) fclose(f)")]

// send the PNG image to specified port
[imagePngPort(im:xlImage, out:port) : void -> function!(gdImagePngPort)]
[imageJpegPort(im:xlImage, out:port, qual:integer) : void -> function!(gdImageJpegPort)]


// send the PNG image to stdout
[imagePngStdOut(im:xlImage) : void
->	imagePngPort(im,cout())]

// send the PNG image to specified port
/*
[imagePngPort(im:xlImage, out:port) : void
-> function!(gdImagePngPort)]
*/
//
;[imageWBMPFile(im:xlImage,out:string,fg:integer) : void
;-> 	externC("FILE * f = fopen(out,\"wb\")"),
;	externC("if (f) gdImageWBMP(im,fg, f)"), 
;	externC("if (f) fclose(f)")]
;
;[imageWBMPStdOut(im:xlImage,fg:integer) : void
;-> externC("gdImageWBMP(im,fg, stdout)")]

// create un jpeg file with specified quality (1 .. 95)
[imageJpegFile(im:xlImage,out:string, quality:integer) : void
-> 	externC("FILE * f = fopen(out,\"wb\")"),
	externC("if (f) gdImageJpeg(im,f,quality)"), 
	externC("if (f) fclose(f)")]

// [imageJpegStdOut(im:xlImage,quality:integer) : void
// -> externC("gdImageJpeg(im,stdout,quality)")]

// create un jpeg stream to stdout with specified quality (1 .. 95)
[imageJpegStdOut(im:xlImage,quality:integer) : void
-> externC("\n#ifdef CLPC\nint m = _setmode(_fileno(stdout),_O_BINARY);\n#endif\n"),
	imageJpegPort(im,stdout,quality),
	externC("\n#ifdef CLPC\n_setmode(_fileno(stdout),m);\n#endif\n")]
	


//


// imageArc is used to draw a partial ellipse centered at the given point,
// with the specified width and height in pixels.
// The arc begins at the position in degrees specified by s and ends at the position specified by e.
// The arc is drawn in the color specified by the last argument.
// A circle can be drawn by beginning from 0 degrees and ending at 360 degrees,
// with width and height being equal. e must be greater than s.
// Values greater than 360 are interpreted modulo 360. 
[imageArc(im:xlImage, cx:integer, cy:integer, w:integer, h:integer, s:integer, e:integer, color:integer) : void
-> function!(gdImageArc)]

//imageFillToBorder floods a portion of the image with the specified color, 
// beginning at the specified point and stopping at the specified border color. 
//For a way of flooding an area defined by the color of the starting point, see imageFill. 
[imageFillToBorder(im:xlImage, x:integer, y:integer, border:integer, color:integer) : void
-> function!(gdImageFillToBorder)]

// imageFill floods a portion of the image with the specified color,
// beginning at the specified point and flooding the surrounding region of the same color as the starting point. 
// For a way of flooding a region defined by a specific border color rather than by its interior color, see imageFillToBorder. 
[imageFill(im:xlImage, x:integer, y:integer, color:integer) : void
-> function!(gdImageFill)]

// gdImageCopy is used to copy a rectangular portion of one image to another image.
// (For a way of stretching or shrinking the image in the process, see imageCopyResized.) 
[imageCopy(dst:xlImage,src:xlImage, dstX:integer, dstY:integer,srcX:integer, srcY:integer, w:integer, h:integer) : void
-> function!(gdImageCopy)]

// imageCopyMerge is almost identical to imageCopy, 
// except that it 'merges' the two images by an amount specified in the last parameter. 
// If the last parameter is 100, then it will function identically to imageCopy 
// - the source image replaces the pixels in the destination. 
[imageCopyMerge(dst:xlImage,src:xlImage, dstX:integer, dstY:integer,srcX:integer, srcY:integer, w:integer, h:integer, pct:integer) : void
-> function!(gdImageCopyMerge)]

// imageCopyMergeGray is almost identical to imageCopyMerge, 
// except that when merging images it preserves the hue of the source 
// by converting the destination pixels to grey scale before the copy operation. 
[imageCopyMergeGray(dst:xlImage,src:xlImage, dstX:integer, dstY:integer,srcX:integer, srcY:integer, w:integer, h:integer, pct:integer) : void
-> function!(gdImageCopyMergeGray)]

//
// imageCopyResized is used to copy a rectangular portion of one image to another image.
// The X and Y dimensions of the original region and the destination region can vary,
// resulting in stretching or shrinking of the region as appropriate.
// (For a simpler version of this function which does not deal with resizing, see imageCopy.) 
[imageCopyResized(dst:xlImage,src:xlImage,
					dstX:integer, dstY:integer,
					srcX:integer, srcY:integer,
					dstW:integer, dstH:integer,
					srcW:integer, srcH:integer) : void
-> function!(gdImageCopyResized)]



// A "brush" is an image used to draw wide, shaped strokes in another image.
// Just as a paintbrush is not a single point, a brush image need not be a single pixel.
// Any gd image can be used as a brush, and by setting the transparent color index of the brush image with imageColorTransparent,
// a brush of any shape can be created.
// All line-drawing functions, such as imageLine and imagePolygon,
// will use the current brush if the special "color" gdBrushed or gdStyledBrushed is used when calling them. 
[imageSetBrush(im:xlImage, brush:xlImage) : void
-> function!(gdImageSetBrush)]

// A "tile" is an image used to fill an area with a repeated pattern. 
// Any gd image can be used as a tile, and by setting the transparent color index of the tile image with imageColorTransparent, 
// a tile that allows certain parts of the underlying area to shine through can be created. 
// All region-filling functions, such as imageFill and imageFilledPolygon,
// will use the current tile if the special "color" gdTiled is used when calling them. 
[imageSetTile(im:xlImage, tile:xlImage) : void
-> function!(gdImageSetTile)]

;[imageSetStyle(im:xlImage,  int *style, noOfPixels:integer) : void
;-> function!(gdImageSetStyle)]

// imageInterlace is used to determine whether an image should be stored in a linear fashion,
// in which lines will appear on the display from first to last, or in an interlaced fashion, 
// in which the image will "fade in" over several passes.
// By default, images are not interlaced. 
//(When writing JPEG images, interlacing implies generating progressive JPEG files, 
//which are represented as a series of scans of increasing quality. 
// Noninterlaced gd images result in regular [sequential] JPEG data streams.) 
[imageInterlace(im:xlImage, interlaceArg:integer) : void
-> function!(gdImageInterlace)]


;
;
;#define gdImageSX(im) ((im)->sx)
;#define gdImageSY(im) ((im)->sy)
;#define gdImageColorsTotal(im) ((im)->colorsTotal)
;#define gdImageRed(im, c) ((im)->red[(c)])
;#define gdImageGreen(im, c) ((im)->green[(c)])
;#define gdImageBlue(im, c) ((im)->blue[(c)])
;#define gdImageGetTransparent(im) ((im)->transparent)
;#define gdImageGetInterlaced(im) ((im)->interlace)


//
[imageSX(im:xlImage) : integer
-> externC("im->sx",integer)]

[imageSY(im:xlImage) : integer
-> externC("im->sy",integer)]

[imageRed(im:xlImage,color:integer) : integer
-> externC("im->red[color]",integer)]

[imageGreen(im:xlImage,color:integer) : integer
-> externC("im->green[color]",integer)]

[imageBlue(im:xlImage,color:integer) : integer
-> externC("im->blue[color]",integer)]


[imageColorsTotal(im:xlImage) : integer
-> externC("im->colorsTotal",integer)]



/*
gdImageStringResult <: ephemeral_object(
						result:string,
						lower_left_corner_X:integer,
						lower_left_corner_Y:integer,
						lower_right_corner_X:integer,
						lower_right_corner_Y:integer,
						upper_right_corner_X:integer,
						upper_right_corner_Y:integer,
						upper_left_corner_X:integer,
						upper_left_corner_Y:integer)
*/

[imageStringFT(im:xlImage,color:integer,
				fontname:string,ptsize:float,angle:float,
				x:integer,y:integer,str:string) : integer[]
->	let res := "",
		brect := make_array(8,integer,0)
	in ( // externC("int brect[8];"),
		externC("char* r;"),
		externC("r = gdImageStringFT(im,(int*)(brect + 1),color,fontname,ptsize,angle,x,y,str);"),
		if externC("(r ? CTRUE : CFALSE)",boolean)
			error("~A",copy(externC("r",string))),
		brect)]		 

[imageStringFT(fontname:string,ptsize:float,angle:float,
				x:integer,y:integer,str:string) : integer[]
->	let res := "",
		brect := make_array(8,integer,0)
	in ( // externC("int brect[8];"),
		externC("char* r;"),
		externC("r = gdImageStringFT(NULL,(int*)(brect + 1),0,fontname,ptsize,angle,x,y,str);"),
		if externC("(r ? CTRUE : CFALSE)",boolean)
			error("~A",copy(externC("r",string))),
		brect)]



[imageAlphaBlending(im:xlImage,alphaBlendingArg:integer) : void
->	function!(gdImageAlphaBlending)]

