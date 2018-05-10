//
//  NSString+Util.m
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 12..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>
#import "NSData+Base64.h"
//#import "KeychainItemWrapper.h"

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

static NSArray *CHO;
static NSArray *JUNG;
static NSArray *JONG;

@implementation NSString (Util)

- (NSString *) trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *) reverseString {
	NSInteger len = [self length];
	NSMutableString *reversedStr = [NSMutableString stringWithCapacity:len];
	
	while (len > 0) {
		[reversedStr appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
	}
	
	return reversedStr;
}

#pragma mark -
#pragma mark 각종 문자열 인코딩/디코딩 메소드

- (NSString *) urlEncode {
	return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *) urlEncodeWithEncoding:(NSStringEncoding)encoding {
	return [self stringByAddingPercentEscapesUsingEncoding:encoding];
}

- (NSString *) urlDecode {
	if (IOS_VERSION >= 9) {
		return [self stringByRemovingPercentEncoding];
	} else {
		return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
}

- (NSString *) urlDecodeWithEncoding:(NSStringEncoding)encoding {
	return [self stringByReplacingPercentEscapesUsingEncoding:encoding];
}

- (NSString *) base64Decode {
	NSData *base64DecodedData = [[NSData allocWithZone:nil] initWithBase64EncodedString:self];
	return [[NSString alloc] initWithData:base64DecodedData encoding:NSUTF8StringEncoding];
}


- (NSString *) base64Encode {
	NSData *base64EncodedData = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [base64EncodedData base64Encoding];
}


- (NSString *) md5 {
	const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (int)strlen(str), result);
	
	NSMutableString *md5Encoded = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for (NSInteger i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[md5Encoded appendFormat:@"%02x",result[i]];
	}
	
	return md5Encoded;
}

- (NSString *) stringCleanedForXML {
	unichar character;
	NSInteger index, len = [self length];
	NSMutableString *cleanedString = [[NSMutableString alloc] init];
	
	for (index = 0; index < len; index++)
	{
		character = [self characterAtIndex:index];
		
		if (character == 0x9 ||
			character == 0xA ||
			character == 0xD ||
			(character >= 0x20 && character <= 0xD7FF) ||
			(character >= 0xE000 && character <= 0xFFFD) ||
			(character >= 0x10000 && character <= 0x10FFFF))
			[cleanedString appendFormat:@"%C", character];
	}
	
	return cleanedString;
}

- (NSString *) stringByStrippingHTML {
	NSString *html = [[NSString alloc] initWithString:self];
	NSRange r;
	while ((r = [html rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		html = [html stringByReplacingCharactersInRange:r withString:@""];
	return html;
}

- (NSString *) onlyNumberString {
	return [[self componentsSeparatedByCharactersInSet:
			 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
			componentsJoinedByString:@""];
}

// 구현 참고 : http://dream.ahboom.net/entry/한글-유니코드-자소-분리-방법
- (NSString *) toCanonicalString {
	if (CHO == nil) {
		CHO = @[@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ"];
		JUNG = @[@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@"ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ"];
		JONG = @[@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",
				 @"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ"];
	}
	
	NSString *canonical = @"";
	for (NSInteger i = 0; i < [self length]; i++) {
		NSInteger code = [self characterAtIndex:i];
		if (code >= 44032 && code <= 55203) { // 한글영역에 대해서만 처리
			NSInteger uniCode = code - 44032; // 한글 시작영역을 제거
			NSInteger choIndex = uniCode/21/28; // 초성
			NSInteger jungIndex = uniCode%(21*28)/28; // 중성
			NSInteger jongIndex = uniCode%28; // 종성
			
			canonical = [NSString stringWithFormat:@"%@%@%@%@",
						 canonical,
						 [CHO objectAtIndex:choIndex],
						 [JUNG objectAtIndex:jungIndex],
						 [JONG objectAtIndex:jongIndex]];
		} else {
			canonical = [NSString stringWithFormat:@"%@%@",
						 canonical, [self substringWithRange:NSMakeRange(i, 1)]];
		}
	}
	
	return canonical;
}

- (BOOL) isValidEmail {
	NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *tester = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex]; 
	return [tester evaluateWithObject:self];
}

/**
+ (NSString *) uuid {

    //키체인에 uuid를 저장하여 유효성을 확보 함.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];

    if (uuid == nil || uuid.length == 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);

        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }

    return uuid;
}

+ (NSString *) uuidWithoutHyphen {
	return [[NSString uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
 */

+ (NSString *) dateStringWithFormat:(NSString *)format {
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
	[dateFormatter setLocale:locale];
	
	[dateFormatter setDateFormat:format];
	NSString *dateString = [dateFormatter stringFromDate:now];
	
	return dateString;
}

+ (NSString *) dateString:(NSDate *)date withFormat:(NSString *)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
	[dateFormatter setLocale:locale];
	
	[dateFormatter setDateFormat:format];
	NSString *dateString = [dateFormatter stringFromDate:date];
	
	return dateString;
}

+ (NSString *) platformString {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	
	if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
	if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
	if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
	if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
	if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
	if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
	if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
	if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
	if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
	if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
	if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
	if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
	if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
	if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
	if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
	if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
	if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
	if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
	
	if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4G)";
	if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5G)";
	if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6G)";
	
	if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
	if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
	if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
	if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
	if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
	if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
	if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
	if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
	if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
	if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
	if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
	if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
	if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
	if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
	if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
	if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
	if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (12.9)";
	if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (12.9)";
	if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro (9.7)";
	if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro (9.7)";
	if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4";
	if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4";
	
	if ([platform isEqualToString:@"i386"])         return @"Simulator";
	if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
	
	return platform;
}

+ (NSString *) fileSizeFormat:(CGFloat)fileSize {
    if (fileSize < 1024) {
        return [NSString stringWithFormat:@"%dB", (int) fileSize];
    } else if (fileSize >= 1024 && fileSize < 1048576) {
        return [NSString stringWithFormat:@"%0.1fKB", fileSize / 1024];
    } else if (fileSize >= 1048576 && fileSize < 1073741824l) {
        return [NSString stringWithFormat:@"%0.1fMB", fileSize / 1048576];
    } else if (fileSize >= 1073741824l && fileSize < 1099511627776l) {
        return [NSString stringWithFormat:@"%0.1fGB", fileSize / 1073741824l];
    } else {
        return [NSString stringWithFormat:@"%0.1fTB", fileSize / 1099511627776l];
    }
}

+ (NSString *) minimalPlatformString {
	NSString *tmp = [NSString platformString];
	NSRange range = [tmp rangeOfString:@" ("];
	if (range.location > -1 && range.length > -1) {
		return [tmp substringWithRange:NSMakeRange(0, (NSUInteger) range.location)];
	}
	return tmp;
}



- (NSString *) phoneNumberFormatString {
	NSInteger length = [self length];
	NSString *phoneNumberFormatString = nil;
	
	if ([self hasPrefix:@"0"]) {
		if (length < 5 || length > 11) {
			phoneNumberFormatString = self;
		} else if (length < 7){
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@",
									   [self substringWithRange:NSMakeRange(0, 3)],
									   [self substringWithRange:NSMakeRange(3, length - 3)]];
		} else if (length < 11){
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@-%@",
									   [self substringWithRange:NSMakeRange(0, 3)],
									   [self substringWithRange:NSMakeRange(3, 3)],
									   [self substringWithRange:NSMakeRange(6, length - 6)]];
		} else {
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@-%@",
									   [self substringWithRange:NSMakeRange(0, 3)],
									   [self substringWithRange:NSMakeRange(3, 4)],
									   [self substringWithRange:NSMakeRange(7, length - 7)]];
		}
	} else {
		if (length < 5 || length > 10) {
			phoneNumberFormatString = self;
		} else if (length < 6){
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@",
									   [self substringWithRange:NSMakeRange(0, 2)],
									   [self substringWithRange:NSMakeRange(2, length - 2)]];
		} else if (length < 10){
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@-%@",
									   [self substringWithRange:NSMakeRange(0, 2)],
									   [self substringWithRange:NSMakeRange(2, 3)],
									   [self substringWithRange:NSMakeRange(5, length - 5)]];
		} else {
			phoneNumberFormatString = [NSString stringWithFormat:@"%@-%@-%@",
									   [self substringWithRange:NSMakeRange(0, 2)],
									   [self substringWithRange:NSMakeRange(2, 4)],
									   [self substringWithRange:NSMakeRange(6, length - 6)]];
		}
	}
	
	return phoneNumberFormatString;
}

+ (NSString *) toNumberStringWithComma:(long long int)number {
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithLongLong:number]];
	
	return formatted;
}

+ (BOOL) str:(NSString *)str inMatches:(NSArray *)matches {
	if (str == nil || matches == nil || [matches count] == 0)
		return NO;
	
	for (NSString *item in matches) {
		if ([str isEqualToString:item])
			return YES;
	}
	
	return NO;
}

+ (BOOL) str:(NSString *)str notInMatches:(NSArray *)matches {
	return ![NSString str:str inMatches:matches];
}
@end
