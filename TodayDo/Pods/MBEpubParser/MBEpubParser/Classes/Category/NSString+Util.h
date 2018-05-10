//
//  NSString+Util.h
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 12..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//




@interface NSString (Util)

- (NSString *) trim;
- (NSString *) reverseString;

- (NSString *) urlEncode;
- (NSString *) urlEncodeWithEncoding:(NSStringEncoding)encoding;
- (NSString *) urlDecode;
- (NSString *) urlDecodeWithEncoding:(NSStringEncoding)encoding;
- (NSString *) base64Decode;
- (NSString *) base64Encode;
- (NSString *) md5;
- (NSString *) stringCleanedForXML;
- (NSString *) stringByStrippingHTML;
- (NSString *) onlyNumberString;
- (NSString *) toCanonicalString;

- (BOOL) isValidEmail;

//+ (NSString *) uuid;
//+ (NSString *) uuidWithoutHyphen;
+ (NSString *) dateStringWithFormat:(NSString *)format;
+ (NSString *) dateString:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *) platformString;
+ (NSString *) fileSizeFormat:(CGFloat)fileSize;
+ (NSString *) minimalPlatformString;
- (NSString *) phoneNumberFormatString;
+ (NSString *) toNumberStringWithComma:(long long int)number;
+ (BOOL) str:(NSString *)str inMatches:(NSArray *)matches;
+ (BOOL) str:(NSString *)str notInMatches:(NSArray *)matches;

@end
