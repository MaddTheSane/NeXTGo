#import <appkit/Matrix.h>

@interface AutoWidthMatrix:Matrix
{
}

- superviewSizeChanged:(const NXSize *) oldSize;
- sizeToSuperviewWidth;

@end
