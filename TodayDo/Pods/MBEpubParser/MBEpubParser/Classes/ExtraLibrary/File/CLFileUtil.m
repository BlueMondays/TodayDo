//
//  CLFileUtil.m
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 5..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import "CLFileUtil.h"
#include <sys/xattr.h>

@implementation CLFileUtil

+ (void) saveData:(NSData *)data toFilePath:(NSString *)filePath {

	if (data && filePath) {
		NSUInteger index = [filePath rangeOfString:@"/" options:NSBackwardsSearch].location;
		NSString *directory = [filePath substringToIndex:index];
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
//            LOG_NS(@"File create failed: %@", error);
            NSLog(@"File create failed: %@", error);
		}
		
		[data writeToFile:filePath atomically:YES];
	}
}

+ (void) saveData:(NSData *)data toFilePath:(NSString *)filePath iCloudBackupEnable:(BOOL)enable {
    
	if (data && filePath) {
		NSUInteger index = [filePath rangeOfString:@"/" options:NSBackwardsSearch].location;
		NSString *directory = [filePath substringToIndex:index];
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
//            LOG_NS(@"File create failed: %@", error);
            NSLog(@"File create failed: %@", error);
		}
		
		[data writeToFile:filePath atomically:YES];
		
		if (!enable) {
			[CLFileUtil addDoNotBackupAttributeToItemAtPath:filePath];
		}
	}
}

+ (void) removeFileAtPath:(NSString *)filePath {
    
	if (filePath && [CLFileUtil fileExistsAtPath:filePath]) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm removeItemAtPath:filePath error:&error]) {
//            LOG_NS(@"File remove failed: %@", error);
            NSLog(@"File remove failed: %@", error);
		}
	}
}

+ (void) removeFileAtUrl:(NSURL *)atUrl {
    
	if (atUrl && [CLFileUtil fileExistsAtPath:[atUrl path]]) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm removeItemAtURL:atUrl error:&error]) {
//            LOG_NS(@"File remove failed: %@", error);
            NSLog(@"File remove failed: %@", error);
		}
	}
}

+ (void) copyFileAtPath:(NSString *)atPath toPath:(NSString *)toPath {
    
	if (atPath && toPath) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:atPath]) {
			NSError *error = nil;
			if (![fm copyItemAtPath:atPath toPath:toPath error:&error]) {
//                LOG_NS(@"File copy failed: %@", error);
                NSLog(@"File copy failed: %@", error);
			}
		}
	}
}

+ (void) copyFileAtUrl:(NSURL *)atUrl toUrl:(NSURL *)toUrl {
    
	if (atUrl && toUrl) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:[atUrl path]]) {
			NSError *error = nil;
			if (![fm copyItemAtURL:atUrl toURL:toUrl error:&error]) {
//                LOG_NS(@"File copy failed: %@", error);
                NSLog(@"File copy failed: %@", error);
			}
		}
	}
}

+ (void) moveFileAtPath:(NSString *)atPath toPath:(NSString *)toPath {
    
	if (atPath && toPath) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:atPath]) {
			NSError *error = nil;
			if (![fm moveItemAtPath:atPath toPath:toPath error:&error]) {
//                LOG_NS(@"File move failed: %@", error);
                NSLog(@"File move failed: %@", error);
			}
		}
	}
}

+ (BOOL) fileExistsAtPath:(NSString *)filePath {
    
	NSFileManager *fm = [NSFileManager defaultManager];
	return [fm fileExistsAtPath:filePath];
}

+ (NSInteger) fileSizeAtPath:(NSString *)filePath {
    
	if (filePath) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:filePath]) {
			NSDictionary *attributes = [fm attributesOfItemAtPath:filePath error:nil];
			if ([attributes objectForKey:NSFileSize]) {
				return [[attributes objectForKey:NSFileSize] intValue];
			}
		}
	}
	
	return 0;
}

+ (NSUInteger) sizeAtPath:(NSURL *)directoryUrl {
    
	NSUInteger result = 0;
	NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
						   NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
	
	NSArray *array = [[NSFileManager defaultManager]
					  contentsOfDirectoryAtURL:directoryUrl
					  includingPropertiesForKeys:properties
					  options:(NSDirectoryEnumerationSkipsHiddenFiles)
					  error:nil];
	
	for (NSURL *fileSystemItem in array) {
		BOOL directory = NO;
		[[NSFileManager defaultManager] fileExistsAtPath:[fileSystemItem path] isDirectory:&directory];
		if (!directory) {
			result += [[[[NSFileManager defaultManager] attributesOfItemAtPath:[fileSystemItem path] error:nil] objectForKey:NSFileSize] unsignedIntegerValue];
		}
		else {
			result += [CLFileUtil sizeAtPath:fileSystemItem];
		}
	}
	
	return result;
}

+ (NSMutableDictionary *) propertyListWithFilePath:(NSString *)filePath {
    
	NSData *fileData = [NSData dataWithContentsOfFile:filePath];
	
	NSError *error = nil;
	NSPropertyListFormat format;
	NSMutableDictionary *propertyList = [NSPropertyListSerialization propertyListWithData:fileData
																				  options:NSPropertyListMutableContainersAndLeaves
																				   format:&format
																					error:&error];
	return propertyList;
}

+ (BOOL) addDoNotBackupAttributeToItemAtPath:(NSString *)path {
    
	return [CLFileUtil addDoNotBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
}

+ (BOOL) addDoNotBackupAttributeToItemAtURL:(NSURL *)url {
	NSError *error = nil;
	BOOL success = [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
	if (!success) {
//        LOG_NS(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
	}
	
	return success;
}

+ (void) addDoNotBackupAttributeToDirectoryAtPath:(NSString *)path {
    
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir;
	BOOL exists = [fm fileExistsAtPath:path isDirectory:&isDir];
	if (!exists || !isDir)
		return;

	NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
	NSString *file = nil;
	NSString *filePath = nil;
	while (file = [enumerator nextObject]) {
		filePath = [NSString stringWithFormat:@"%@/%@", path, file];
		[fm fileExistsAtPath:filePath isDirectory:&isDir];
		if (isDir) {
			[CLFileUtil addDoNotBackupAttributeToDirectoryAtPath:file];
		} else {
			[CLFileUtil addDoNotBackupAttributeToItemAtPath:filePath];
		}
	}
}

+ (void) createDirectoryAtPath:(NSString *)dirPath {
    
	if (dirPath) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		if (![fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
//            LOG_NS(@"File create failed: %@", error);
            NSLog(@"File create failed: %@", error);
		}
	}
}

@end
