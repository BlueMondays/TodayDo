//
//  MBOpenInEpubHandler.h
//  MrblueIphoneApp
//
//  Created by Kwon Gu Hyuk on 2016. 1. 18..
//  Copyright © 2016년 Mrblue. All rights reserved.
//


//#import "MBEpubKit.h"
#import "MBEpubController.h"

@protocol MBOpenInEpubHandlerDelegate;

@interface MBOpenInEpubHandler : NSObject <MBEpubControllerDelegate> {
    MBEpubController *__epubController;
    
	NSString *__inputPath;
	NSString *__oid;
}

@property (nonatomic, weak) id<MBOpenInEpubHandlerDelegate> delegate;

+ (MBOpenInEpubHandler *) epubHandler;

- (void) openIn:(NSURL *)epubURL;

@end

@protocol MBOpenInEpubHandlerDelegate<NSObject>
@required
- (void) openInEpubHandlerDelegate:(MBOpenInEpubHandler *)handler didOpenEpub:(NSDictionary*)epubData;

@end
