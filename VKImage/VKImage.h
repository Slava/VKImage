//
//  VKImage.h
//  VKImage
//
//  Created by Vyacheslav Kim on 2/25/13.
//  Copyright (c) 2013 Vyacheslav Kim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    VKImageTemplateNone,
    VKImageTemplateAvatar,
    VKImageTemplateFramed,
    VKImageTemplateDocumentIcon
} VKImageTemplateType;

@interface VKImage : NSImage

- (NSImage *)imageWithTemplate:(VKImageTemplateType)VKImageTemplate withSize:(NSSize)size;

@end
