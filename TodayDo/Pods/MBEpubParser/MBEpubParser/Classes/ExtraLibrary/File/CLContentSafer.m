//
//  CLContentSafer.m
//  MrblueIphoneApp
//
//  Created by kineo2k on 2015. 2. 12..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import "CLContentSafer.h"

#define CHUNK_SIZE 8192
#define BUFFER_SIZE 1024

@interface CLContentSafer (Private)
+ (NSData *) __encryptChunk:(NSData *)data;
+ (NSData *) __decryptChunk:(NSData *)data;
@end

@implementation CLContentSafer (Private)
+ (NSData *) __encryptChunk:(NSData *)data {
	NSMutableData *result = [NSMutableData data];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 5, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 7, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 1, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 3, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 6, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 2, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 4, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 0, BUFFER_SIZE)]];
	
	return result;
}

+ (NSData *) __decryptChunk:(NSData *)data {
	NSMutableData *result = [NSMutableData data];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 7, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 2, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 5, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 3, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 6, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 0, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 4, BUFFER_SIZE)]];
	[result appendData:[data subdataWithRange:NSMakeRange(BUFFER_SIZE * 1, BUFFER_SIZE)]];
	
	return result;
}
@end


@implementation CLContentSafer

+ (void) encryptData:(NSData *)data withSavePath:(NSString *)path {
    
	[[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
	NSFileHandle *fout = [NSFileHandle fileHandleForWritingAtPath:path];
	
	NSData *buffer = nil;
	unsigned long long fileSize = [data length];
	unsigned long long offsetInData = 0;
	
	while (offsetInData < fileSize) {
		if (offsetInData + CHUNK_SIZE > fileSize) {
			buffer = [data subdataWithRange:NSMakeRange((int) offsetInData, (int) (fileSize - offsetInData))];
			offsetInData = fileSize;
			
			[fout writeData:buffer];
		} else {
			buffer = [data subdataWithRange:NSMakeRange((int) offsetInData, CHUNK_SIZE)];
			offsetInData += CHUNK_SIZE;
			
			[fout writeData:[CLContentSafer __encryptChunk:buffer]];
		}
	}
	
	[fout closeFile];
}

+ (NSData *) decryptFileAtPath:(NSString *)path {
    
	NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	NSMutableData *result = [NSMutableData data];
	
	NSData *buffer = nil;
	unsigned long long fileSize = [data length];
	unsigned long long offsetInData = 0;
	
	while (offsetInData < fileSize) {
		if (offsetInData + CHUNK_SIZE > fileSize) {
			buffer = [data subdataWithRange:NSMakeRange((int) offsetInData, (int) (fileSize - offsetInData))];
			offsetInData = fileSize;
			
			[result appendData:buffer];
		} else {
			buffer = [data subdataWithRange:NSMakeRange((int) offsetInData, CHUNK_SIZE)];
			offsetInData += CHUNK_SIZE;
			
			[result appendData:[CLContentSafer __decryptChunk:buffer]];
		}
	}
	
	return result;
}

@end
