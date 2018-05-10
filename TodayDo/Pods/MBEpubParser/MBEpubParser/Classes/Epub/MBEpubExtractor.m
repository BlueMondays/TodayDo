//
//  MBEpubExtractor.m
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//

#import "MBEpubExtractor.h"
#import "MBEpubContentModel.h"
#import "SSZipArchive.h"
#import "VTPG_Common.h"


/**
 압축 관련
 */
@interface MBEpubExtractor (Private)
- (void) __doneExtracting:(NSNumber *)didSucceed;
@end

@implementation MBEpubExtractor (Private)

/**
 epub 파일을 unzip하여 다운로드를 성공하였는지 여부에 따라 결과를 처리합니다.
 */
- (void) __doneExtracting:(NSNumber *)didSucceed {
	if (didSucceed.boolValue) {
		[self.delegate epubExtractorDidFinishExtracting:self];
	}
	
	else {
		NSError *error = [NSError errorWithDomain:kMBEpubKitErrorDomain
											 code:1
										 userInfo:@{NSLocalizedDescriptionKey: @"Could not extract ebup file."}];
		[self.delegate epubExtractor:self didFailWithError:error];
	}
}
@end


@implementation MBEpubExtractor

@synthesize delegate;

- (instancetype) initWithEpubURL:(NSURL *)epubURL andDestinationURL:(NSURL *)destinationURL {
	self = [super init];
	if (self) {
		__epubURL = epubURL;
		__destinationURL = destinationURL;
		
		__extractingQueue = [[NSOperationQueue alloc] init];
		__extractingQueue.maxConcurrentOperationCount = 1;
	}
	return self;
}


/**
 Epub 파일을 다운로드하여 unzip 하여 저장합니다.
 */
- (BOOL) start:(BOOL)asynchronous {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(epubExtractorDidStartExtracting:)]) {
			[self.delegate epubExtractorDidStartExtracting:self];
		}
		
		if (asynchronous) {
			__block BOOL didSucceed;
			
			[__extractingQueue addOperationWithBlock:^{
				didSucceed = [SSZipArchive unzipFileAtPath:__epubURL.path toDestination:__destinationURL.path];
			}];
			
			[__extractingQueue addOperationWithBlock:^{
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					[self performSelector:@selector(__doneExtracting:) withObject:@(didSucceed) afterDelay:.0f];
				}];
			}];
			
			return YES;
		}
		
		else {
			BOOL didSucceed = [SSZipArchive unzipFileAtPath:__epubURL.path toDestination:__destinationURL.path];
			[self __doneExtracting:@(didSucceed)];
			return YES;
		}
	}
	return NO;
}

- (void) cancel {
	[__extractingQueue cancelAllOperations];
	if ([self.delegate respondsToSelector:@selector(epubExtractorDidCancelExtraction:)]) {
		[self.delegate epubExtractorDidCancelExtraction:self];
	}
}

@end
