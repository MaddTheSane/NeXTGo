#import "AutoWidthMatrix.h"

@implementation AutoWidthMatrix

- superviewSizeChanged:(const NXSize *) oldSize
{
   [self sizeToSuperviewWidth];
   return self;
}

- sizeToSuperviewWidth
{
   /* Matix instance variables used:
      NXSize cellSize
      NXSize intercell
      int numCols */

   NXRect r;			/* superview's frame */
   float newWidth, newHeight;

   if (! [self superview]) return self;
   
   [[self superview] getFrame:&r];

   /* The matrix width will be the same as the superview's width. */

   newWidth = r.size.width;

   /* The matrix height is computed by multiplying the total height of one
      cell (this includes any intercell gap) by the number of rows.

      One intercell gap is subtracted because there is not intercell space
      before the first cell or after the last.  (The other Matrix methods,
      SizeToFit and SizeTo, seem to also follow this rule.) */

   newHeight = numRows * (intercell.height + cellSize.height)
      - intercell.height;

   if (newHeight < 0.0) newHeight = 0.0;

   /* The cell width is computed so that the matrix columns fill up the
      available superview width.  (If the superview width is small and the
      number of columns large, this will result in rather small cells.)

      The formula computes the space available for cells by taking the
      amount of width available, subtracting out the space required for
      intercell gaps, and dividing this between the number of columns.
      (One extra intercell gap is returned to the available space because
      the gaps are between cells, not at the end or beginning of cells.) */

   cellSize.width  = (r.size.width - (intercell.width * numCols)
		      + intercell.width) / numCols;

   [self sizeTo:newWidth :newHeight];
   
   return self;
}
   
@end
