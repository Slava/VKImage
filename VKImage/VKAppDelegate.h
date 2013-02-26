//
//  VKAppDelegate.h
//  VKImage
//
//  Created by Vyacheslav Kim on 2/25/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VKAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *imageViewOne;
@property (weak) IBOutlet NSImageView *imageViewTwo;
@property (weak) IBOutlet NSImageView *imageViewThree;
@property (weak) IBOutlet NSImageView *imageViewFour;

@end
