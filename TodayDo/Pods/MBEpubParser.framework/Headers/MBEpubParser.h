//
//  MBEpubParser.h
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//


#import "DDXMLDocument.h"
#import "MBEpubContentModel.h"

@interface MBEpubParser : NSObject {
@private
}

- (MBEpubKitBookType) bookTypeForBaseURL:(NSURL *)baseURL;
- (MBEpubKitBookEncryption) contentEncryptionForBaseURL:(NSURL *)baseURL;
- (NSURL *) rootFileForBaseURL:(NSURL *)baseURL;
- (NSString *) coverPathComponentFromDocument:(DDXMLDocument *)document;
- (NSDictionary *) metaDataFromDocument:(DDXMLDocument *)document;
- (NSArray *) spineFromDocument:(DDXMLDocument *)document;
- (NSDictionary *) manifestFromDocument:(DDXMLDocument *)document;
- (NSArray *) guideFromDocument:(DDXMLDocument *)document;
- (NSArray *) navPointFromDocument:(NSURL *)url;

+ (NSString *) stringByStrippingXMLComments:(NSString *)xml;

@end
