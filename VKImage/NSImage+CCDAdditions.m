//
//  NSImage+CCDAdditions.m
//  VKAvatarImageView
//
//  Created by Vyacheslav Kim on 2/24/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import "NSImage+CCDAdditions.h"

@implementation NSImage (CCDAdditions)

+ (CGImageRef) createMaskWithImage:(CGImageRef) image {
    long maskWidth               = CGImageGetWidth(image);
    long maskHeight              = CGImageGetHeight(image);
    //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    long bytesPerRow             = (maskWidth + 15) & 0xfffffff0;
    long bufferSize              = bytesPerRow * maskHeight;
    
    //  allocate memory for the bits
    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);
    
    //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx            = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                                        maskWidth, maskHeight,
                                                        8, bytesPerRow, colourSpace, kCGImageAlphaNone);
    //  drawing into this context will draw into the dataBuffer.
    CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), image);
    CGContextRelease(ctx);
    
    //  now make a mask from the data.
    CGDataProviderRef dataProvider  = CGDataProviderCreateWithCFData(dataBuffer);
    CGImageRef mask                 = CGImageMaskCreate(maskWidth, maskHeight, 8, 8, bytesPerRow,
                                                        dataProvider, NULL, FALSE);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colourSpace);
    CFRelease(dataBuffer);
    
    return mask;
}

+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)newSize proportionally:(BOOL)prop
{
    if (image) {
        NSImage *copy = [image copy];
		NSSize size = [copy size];
        
		if (prop) {
			float rx, ry, r;
            
            rx = newSize.width / size.width;
            ry = newSize.height / size.height;
            r = rx < ry ? rx : ry;
            size.width *= r;
            size.height *= r;
		} else
			size = newSize;
        
        [copy setScalesWhenResized:YES];
        [copy setSize:size];
        
        return copy;
    }
    return nil; // or 'image' if you prefer.
}
// draws the passed image into the passed rect, centered and scaled appropriately.
// note that this method doesn't know anything about the current focus, so the focus must be locked outside this method
- (void)drawCenteredinRect:(NSRect)inRect operation:(NSCompositingOperation)op fraction:(float)delta
{
    NSRect srcRect = NSZeroRect;
    srcRect.size = [self size];
    
    // create a destination rect scaled to fit inside the frame
    NSRect drawnRect = srcRect;
    if (drawnRect.size.width > inRect.size.width)
    {
        drawnRect.size.height *= inRect.size.width/drawnRect.size.width;
        drawnRect.size.width = inRect.size.width;
    }
    
    if (drawnRect.size.height > inRect.size.height)
    {
        drawnRect.size.width *= inRect.size.height/drawnRect.size.height;
        drawnRect.size.height = inRect.size.height;
    }
    
    drawnRect.origin = inRect.origin;
    
    // center it in the frame
    drawnRect.origin.x += (inRect.size.width - drawnRect.size.width)/2;
    drawnRect.origin.y += (inRect.size.height - drawnRect.size.height)/2;
    
    [self drawInRect:drawnRect fromRect:srcRect operation:op fraction:delta];
}

@end
