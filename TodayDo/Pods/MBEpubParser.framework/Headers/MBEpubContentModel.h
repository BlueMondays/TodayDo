//
//  MBEpubContentModel.h
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//

/**
 Epub 정의
 
 - MBEpubKitBookTypeUnknown: 정의되지 않음
 - MBEpubKitBookTypeEpub2: Epub2 표준 타입
 - MBEpubKitBookTypeEpub3: Epub3 표준 타입
 - MBEpubKitBookTypeiBook: iBook 타입
 */
typedef NS_ENUM(NSUInteger, MBEpubKitBookType) {
    MBEpubKitBookTypeUnknown,
    MBEpubKitBookTypeEpub2,
    MBEpubKitBookTypeEpub3,
    MBEpubKitBookTypeiBook
};


typedef NS_ENUM(NSUInteger, MBEpubKitBookEncryption) {
    MBEpubKitBookEnryptionNone,
    MBEpubKitBookEnryptionFairplay
};

#define kMBEpubKitErrorDomain @"MBEpubKitErrorDomain"

@interface MBEpubContentModel : NSObject

@property (nonatomic, assign) MBEpubKitBookType bookType;
@property (nonatomic, assign) MBEpubKitBookEncryption bookEncryption;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, strong) NSString *coverPath;
@property (nonatomic, strong) NSDictionary *manifest;
@property (nonatomic, strong) NSArray *spine;   //목차
@property (nonatomic, strong) NSArray *guide;
@property (nonatomic, strong) NSArray *navPoint;
@property (nonatomic, strong) NSString *contentRootPath;

@end
