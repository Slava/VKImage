//
//  VKAppDelegate.m
//  VKImage
//
//  Created by Vyacheslav Kim on 2/25/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import "VKAppDelegate.h"
#import "VKImage.h"

@implementation VKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    VKImage *img;
    NSString *fileName;
    fileName = @"/Library/Desktop Pictures/Beach.jpg";
    
    img = [[VKImage alloc] initWithContentsOfFile:fileName];
    
    _imageViewOne.image = [img imageWithTemplate:VKImageTemplateAvatar withSize:NSZeroSize];
    _imageViewTwo.image = [img imageWithTemplate:VKImageTemplateFramed withSize:NSZeroSize];
    _imageViewThree.image = [img imageWithTemplate:VKImageTemplateDocumentIcon withSize:NSZeroSize];
    _imageViewFour.image = [img imageWithTemplate:VKImageTemplateNone withSize:NSZeroSize];
}

@end
