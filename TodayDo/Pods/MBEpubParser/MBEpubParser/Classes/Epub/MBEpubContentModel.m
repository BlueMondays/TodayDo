//
//  MBEpubContentModel.m
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//

#import "MBEpubContentModel.h"

@implementation MBEpubContentModel 

- (void) setContentRootPath:(NSString *)contentRootPath {
	if ([@"extract" isEqualToString:contentRootPath]) {
		_contentRootPath = @"";
	} else {
		_contentRootPath = contentRootPath;
	}
}
@end
