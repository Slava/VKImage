//
//  NSImage+CCDAdditions.h
//  VKImage
//
//  Created by Vyacheslav Kim on 2/25/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define RGB(R,G,B) [NSColor colorWithCalibratedRed:(R)/255. green:(G)/255. blue:(B)/255. alpha:1]
#define RGBA(R,G,B,A) [NSColor colorWithCalibratedRed:(R)/255. green:(G)/255. blue:(B)/255. alpha:(A)]


@interface NSImage (CCDAdditions)

+ (NSImage *)scaleImage:(NSImage *)image toSize:(NSSize)newSize proportionally:(BOOL)prop;
// draws the passed image into the passed rect, centered and scaled appropriately.
// note that this method doesn't know anything about the current focus, so the focus must be locked outside this method
- (void)drawCenteredinRect:(NSRect)inRect operation:(NSCompositingOperation)op fraction:(float)delta;
+ (CGImageRef) createMaskWithImage:(CGImageRef) image;

@end
