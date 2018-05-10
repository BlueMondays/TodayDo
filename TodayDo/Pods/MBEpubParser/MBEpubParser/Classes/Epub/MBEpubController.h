//
//  MBEpubController.h
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//


#import "MBEpubExtractor.h"
#import "MBEpubParser.h"

@class MBEpubContentModel;
@protocol MBEpubControllerDelegate;

@interface MBEpubController : NSObject <MBEpubExtractorDelegate> {
@private
	NSURL *__epubURL;
	NSURL *__extractURL;
	MBEpubExtractor *__extractor;
	MBEpubParser *__parser;
	NSURL *__epubContentBaseURL;
	
	NSDictionary *__userInfo;
}

@property (nonatomic, strong) MBEpubContentModel *contentModel;
@property (nonatomic, weak) id<MBEpubControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *userInfo;

- (instancetype) initWithEpubPath:(NSString *)epubPath andExtractPath:(NSString *)extractPath;

- (void) openAsynchronous:(BOOL)asynchronous;

@end


@protocol MBEpubControllerDelegate <NSObject>

@required
- (void) epubController:(MBEpubController *)controller didOpenEpub:(MBEpubContentModel *)contentModel;
- (void) epubController:(MBEpubController *)controller didFailWithError:(NSError *)error;

@optional
- (void) epubController:(MBEpubController *)controller willOpenEpub:(NSURL *)epubURL;

@end
