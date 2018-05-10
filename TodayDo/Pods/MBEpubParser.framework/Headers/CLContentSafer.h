//
//  CLContentSafer.h
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 12..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 NSData 관련 이미지 암호화 복구화<br>
 */
@interface CLContentSafer : NSObject

+ (void) encryptData:(NSData *)data withSavePath:(NSString *)path;
+ (NSData *) decryptFileAtPath:(NSString *)path;

@end
