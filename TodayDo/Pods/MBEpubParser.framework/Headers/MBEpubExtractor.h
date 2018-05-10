//
//  MBEpubExtractor.h
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//



@protocol MBEpubExtractorDelegate;

@interface MBEpubExtractor : NSObject {
@private
	NSURL *__epubURL;
	NSURL *__destinationURL;
	NSOperationQueue *__extractingQueue;
}

@property (nonatomic, weak) id<MBEpubExtractorDelegate> delegate;

- (instancetype) initWithEpubURL:(NSURL *)epubURL andDestinationURL:(NSURL *)destinationURL;

- (BOOL) start:(BOOL)asynchronous;
- (void) cancel;

@end


@protocol MBEpubExtractorDelegate <NSObject>

@required
- (void) epubExtractorDidFinishExtracting:(MBEpubExtractor *)epubExtractor;
- (void) epubExtractor:(MBEpubExtractor *)epubExtractor didFailWithError:(NSError *)error;

@optional
- (void) epubExtractorDidStartExtracting:(MBEpubExtractor *)epubExtractor;
- (void) epubExtractorDidCancelExtraction:(MBEpubExtractor *)epubExtractor;

@end
