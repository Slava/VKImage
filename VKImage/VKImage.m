//
//  VKImage.m
//  VKImage
//
//  Created by Vyacheslav Kim on 2/25/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import "VKImage.h"
#import "NSImage+CCDAdditions.h"

@implementation VKImage

- (NSImage *)imageWithTemplate:(VKImageTemplateType)VKImageTemplate withSize:(NSSize)size {
    if (!size.height && !size.width)
        size = [self size];
    switch (VKImageTemplate) {
        case VKImageTemplateAvatar:
            return [self _avatarWithSize:size];
        case VKImageTemplateDocumentIcon:
            return [self _documentIconWithSize:size];
        case VKImageTemplateFramed:
            return [self _framedWithSize:size];
        default:
        {
            NSImage *img = [self copy];
            img.size = size;
            return img;
        }
    }
}

- (NSImage *)_avatarWithSize:(NSSize)size {
    NSRect fullRect = NSZeroRect;
    fullRect.size = size;
    float diameter = MIN(fullRect.size.width, fullRect.size.height) - 5;
    
    NSImage *img = [[NSImage alloc] initWithSize:fullRect.size];
    
    // drawing mask in img
    [img lockFocus];
    {
        
        [[NSColor whiteColor] setFill];
        NSRectFill(fullRect);
        
        //// Color Declarations
        NSColor* fillColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
        NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
        
        //// Abstracted Attributes
        NSRect ovalRect = NSMakeRect((fullRect.size.width - diameter) / 2, (fullRect.size.height - diameter) / 2, diameter, diameter);
        
        
        //// Oval Drawing
        NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: ovalRect];
        [fillColor setFill];
        [ovalPath fill];
        [strokeColor setStroke];
        [ovalPath setLineWidth: 1];
        [ovalPath stroke];
        
    }
    [img unlockFocus];
    
    // create mask
    CGImageRef maskImage = [img CGImageForProposedRect:&fullRect context:nil hints:nil];
    CGImageRef mask = [NSImage createMaskWithImage:maskImage];
    
    // draw targeted image in img
    [img lockFocus];
    {
        [[NSImage scaleImage:self toSize:fullRect.size proportionally:YES] drawCenteredinRect:fullRect operation:NSCompositeCopy fraction:1];
    }
    [img unlockFocus];
    
    
    CGImageRef masked = CGImageCreateWithMask([img CGImageForProposedRect:&fullRect context:nil hints:nil], mask);
    return [[NSImage alloc] initWithCGImage:masked size:size];
}

#define actual(x,X,ax) ((ax)*(x)/(X))

- (NSImage *)_documentIconWithSize:(NSSize)size {
    NSRect fullRect = NSZeroRect;
    fullRect.size = size;
    float width = size.width;
    float height = size.height;
    width = height = MIN(width, height);
    
    NSImage *canvas = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [canvas lockFocus];
    {
        NSRect canvasRect = NSZeroRect;
        canvasRect.size = canvas.size;
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 8;
        shadow.shadowColor = RGBA(40, 40, 40, 0.6);
        shadow.shadowOffset = NSSizeFromString(@"0 0 0 0");
        
        
        [NSGraphicsContext saveGraphicsState];{
            // set light shadow around icon
            [shadow set];
            
            // Draw base
            [[NSImage scaleImage:[[NSBundle mainBundle] imageForResource:@"document_icon_base"] toSize:[canvas size] proportionally:YES] drawCenteredinRect:canvasRect operation:NSCompositeSourceOver fraction:1];
            
        }[NSGraphicsContext restoreGraphicsState];
        
        
        // Draw scaled image
        [[NSImage scaleImage:self toSize:NSMakeSize(actual(284, 512, width), actual(350, 512, height)) proportionally:YES] drawAtPoint:NSMakePoint(actual(123, 512, width), actual(122, 512, height)) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
        
        // Draw top
        [[NSImage scaleImage:[[NSBundle mainBundle] imageForResource:@"document_icon_top"] toSize:[canvas size] proportionally:YES] drawCenteredinRect:canvasRect operation:NSCompositeSourceAtop fraction:1];
    }
    [canvas unlockFocus];
    

    return canvas;
}

- (NSImage *)_framedWithSize:(NSSize)size {
    // margin for frame
    float margin = 4;
    float marginForShadow = 5;
    // radius of frame corners
    float frameRadius = 2;
    
    // rectangle of whole view
    NSRect fullRect;
    fullRect = NSZeroRect;
    fullRect.size = size;
    float coef = MIN(size.height / self.size.height,
                     size.width / self.size.width);
    fullRect.size = self.size;
    fullRect.size.height *= coef;
    fullRect.size.width *= coef;
    
    NSImage *img = [[NSImage alloc] initWithSize:fullRect.size];
    [img lockFocus];
    {
        
        float cornerSize = 0.2 * (fullRect.size.height + fullRect.size.width) / 2;
        
        // rectangle in corner for background effect
        NSRect cornerBgRect = NSMakeRect(0, 0, cornerSize + 3, cornerSize + 3);
        [[NSColor colorWithPatternImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yellow_paper" ofType:@"jpg"]]] setFill];
        NSRectFill(cornerBgRect);
        
        // rectangle for frame which is margined
        NSRect frameRect = fullRect;
        frameRect.size.height -= margin * 2 + marginForShadow;
        frameRect.size.width -= margin * 2 + marginForShadow;
        frameRect.origin.x += margin;
        frameRect.origin.y += margin;
        
        // width of frame should be 5% of ave(height, width) of picture
        float frameSize = 0.05 * (frameRect.size.height + frameRect.size.width) / 2;
        
        // draw frame with small radius corners
        NSBezierPath *framePath = [NSBezierPath bezierPathWithRoundedRect:frameRect xRadius:frameRadius yRadius:frameRadius];
        
        // we need shadow on both frame and picture
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor:RGBA(40, 40, 40, 0.7)];
        [shadow setShadowOffset:NSMakeSize(3.1, -3.1)];
        [shadow setShadowBlurRadius:5];
        
        [NSGraphicsContext saveGraphicsState];
        [shadow set];
        
        // draw frame
        [[NSColor whiteColor] setFill];
        [framePath fill];
        [NSGraphicsContext restoreGraphicsState];
        
        // rectangle of actual picture
        NSRect pictureRect = frameRect;
        pictureRect.size.height -= frameSize * 2;
        pictureRect.size.width -= frameSize * 2;
        pictureRect.origin.x += frameSize;
        pictureRect.origin.y += frameSize;
        
        // draw picture in frame with shadow and gray stroke
        NSBezierPath *picturePath = [NSBezierPath bezierPathWithRoundedRect:pictureRect xRadius:frameRadius yRadius:frameRadius];
        [RGB(240, 240, 240) set];
        [picturePath stroke];
        
        [NSGraphicsContext saveGraphicsState];
        [shadow setShadowOffset:NSZeroSize];
        [shadow set];
        [self drawInRect:pictureRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1 respectFlipped:YES hints:nil];
        [NSGraphicsContext restoreGraphicsState];
        
        // draw corner
        [self drawCornerWithSideLength:cornerSize];
    }
    [img unlockFocus];
    return img;
}

- (void)drawCornerWithSideLength:(CGFloat)sideLength {
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* primeCorner = [NSColor colorWithCalibratedRed: 0.897 green: 0.785 blue: 0.292 alpha: 1];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 0.941 green: 0.727 blue: 0 alpha: 0.5];
    
    
    //// Shadow Declarations
    NSShadow* shadowCorner = [[NSShadow alloc] init];
    [shadowCorner setShadowColor: shadowColor2];
    [shadowCorner setShadowOffset: NSMakeSize(3.1, -3.1)];
    [shadowCorner setShadowBlurRadius: 5];
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: RGBA(0,0,0,0.5)];
    [shadow setShadowOffset: NSMakeSize(3.1, -3.1)];
    [shadow setShadowBlurRadius: 30];
    
    //// cornerPath Drawing
    NSBezierPath* cornerPathPath = [NSBezierPath bezierPath];
    [cornerPathPath moveToPoint: NSMakePoint(0, 0)];
    [cornerPathPath lineToPoint: NSMakePoint(0, sideLength)];
    [cornerPathPath lineToPoint: NSMakePoint(sideLength, 0)];
    [cornerPathPath lineToPoint: NSMakePoint(0, 0)];
    [cornerPathPath closePath];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    CGContextBeginTransparencyLayer(context, NULL);
    [cornerPathPath addClip];
    [[NSColor colorWithPatternImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yellow_paper" ofType:@"jpg"]]] setFill];
    [cornerPathPath fill];
    CGContextEndTransparencyLayer(context);
    
    ////// cornerPath Inner Shadow
    NSRect cornerPathBorderRect = NSInsetRect([cornerPathPath bounds], -shadowCorner.shadowBlurRadius, -shadowCorner.shadowBlurRadius);
    cornerPathBorderRect = NSOffsetRect(cornerPathBorderRect, -shadowCorner.shadowOffset.width, shadowCorner.shadowOffset.height);
    cornerPathBorderRect = NSInsetRect(NSUnionRect(cornerPathBorderRect, [cornerPathPath bounds]), -1, -1);
    
    NSBezierPath* cornerPathNegativePath = [NSBezierPath bezierPathWithRect: cornerPathBorderRect];
    [cornerPathNegativePath appendBezierPath: cornerPathPath];
    [cornerPathNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* shadowCornerWithOffset = [shadowCorner copy];
        CGFloat xOffset = shadowCornerWithOffset.shadowOffset.width + round(cornerPathBorderRect.size.width);
        CGFloat yOffset = shadowCornerWithOffset.shadowOffset.height;
        shadowCornerWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [shadowCornerWithOffset set];
        [[NSColor grayColor] setFill];
        [cornerPathPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(cornerPathBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: cornerPathNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [primeCorner setStroke];
    [cornerPathPath setLineWidth: 0.5];
    [cornerPathPath stroke];
}

@end
