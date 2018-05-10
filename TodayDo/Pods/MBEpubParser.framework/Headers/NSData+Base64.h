//
//  NSData+Base64.h
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 12..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//



@interface NSData (Base64)

- (id) initWithBase64EncodedString:(NSString *)string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger)lineLength;

@end
