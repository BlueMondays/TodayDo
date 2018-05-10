//
//  CLFileUtil.h
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 5..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//



@interface CLFileUtil : NSObject

+ (void) saveData:(NSData *)data toFilePath:(NSString *)filePath;
+ (void) saveData:(NSData *)data toFilePath:(NSString *)filePath iCloudBackupEnable:(BOOL)enable;
+ (void) removeFileAtPath:(NSString *)filePath;
+ (void) removeFileAtUrl:(NSURL *)atUrl;
+ (void) copyFileAtPath:(NSString *)atPath toPath:(NSString *)toPath;
+ (void) copyFileAtUrl:(NSURL *)atUrl toUrl:(NSURL *)toUrl;
+ (void) moveFileAtPath:(NSString *)atPath toPath:(NSString *)toPath;
+ (BOOL) fileExistsAtPath:(NSString *)filePath;
+ (NSInteger) fileSizeAtPath:(NSString *)filePath;
+ (NSUInteger) sizeAtPath:(NSURL *)directoryUrl;
+ (NSMutableDictionary *) propertyListWithFilePath:(NSString *)filePath;
+ (BOOL) addDoNotBackupAttributeToItemAtPath:(NSString *)path;  //아이클라우드 백업하지 않기 위해서
+ (BOOL) addDoNotBackupAttributeToItemAtURL:(NSURL *)url;       //아이클라우드 백업하지 않기 위해서
+ (void) addDoNotBackupAttributeToDirectoryAtPath:(NSString *)path; //아이클라우드 백업하지 않기 위해서

+ (void) createDirectoryAtPath:(NSString *)dirPath;

@end
