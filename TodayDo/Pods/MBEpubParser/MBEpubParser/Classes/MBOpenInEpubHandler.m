//
//  MBOpenInEpubHandler.m
//  MrblueIphoneApp
//
//  Created by Kwon Gu Hyuk on 2016. 1. 18..
//  Copyright © 2016년 Mrblue. All rights reserved.
//

#import "MBOpenInEpubHandler.h"
#import "CLFileUtil.h"
#import "NSData+Base64.h"

#define EPUB_FILE_PATH_FORMAT                                    @"%@/Documents/.%@/%@.epub"                            // HomePath, idx, idx
#define EPUB_FILE_EXTRACT_PATH_FORMAT                            @"%@/Documents/.%@/extract"                            // HomePath, idx


static dispatch_once_t pred;
static MBOpenInEpubHandler *uniqueInstance;

@interface MBOpenInEpubHandler (Private)
- (void) __lazyExecute;
@end

@implementation MBOpenInEpubHandler (Private)
- (void) __lazyExecute {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[@"oid"] = __oid;
	dict[@"thumbnail"] = [__oid stringByAppendingString:@".jpg"];
	dict[@"pid"] = __oid;
	dict[@"title"] = @"";
	dict[@"author"] = @"";
	dict[@"volume_no"] = @"";
	dict[@"volume_text"] = @"";
	dict[@"volume_title"] = @"";
	dict[@"unit"] = @"권";
	dict[@"authors"] = @[];
	dict[@"genre"] = @"기타";
	dict[@"section"] = @"E";
	dict[@"exp"] = @"이용기간 제한없음";
	dict[@"start_date"] = [NSString dateStringWithFormat:@"yyyy-MM-dd HH:mm"];
	dict[@"end_date"] = @"9999-12-31 23:59";
	dict[@"flag_hd"] = @"N";
	dict[@"age"] = @"0";
	dict[@"dir"] = @"";
	dict[@"hdd"] = @"";
	dict[@"first_vol"] = @"1";
	dict[@"free_page"] = @"0";
	dict[@"page_convert"] = @"0";
	dict[@"view_direction"] = @"";
	dict[@"is_end"] = @"N";
	dict[@"update_vol"] = @"1";
	dict[@"first_page"] = @"1";
	dict[@"page_sum"] = @"1";
	dict[@"is_local_file"] = @"Y";
//    MBArchiveData *data = [[MBArchiveData alloc] initWithDictionary:dict];
//    [data setAdditionalData:dict];
	
	NSString *epubPath = [NSString stringWithFormat:EPUB_FILE_PATH_FORMAT, NSHomeDirectory(), __oid, __oid];
	NSString *epubExtractPath = [NSString stringWithFormat:EPUB_FILE_EXTRACT_PATH_FORMAT, NSHomeDirectory(), __oid];
	[CLFileUtil createDirectoryAtPath:epubExtractPath];
	[CLFileUtil moveFileAtPath:__inputPath toPath:epubPath];
	[CLFileUtil addDoNotBackupAttributeToItemAtPath:epubPath];
	
    __epubController = [[MBEpubController alloc] initWithEpubPath:epubPath andExtractPath:epubExtractPath];
    [__epubController setDelegate:self];
///    [__epubController setUserInfo:@{ @"MBArchiveData": data }];
    [__epubController setUserInfo:dict];
    [__epubController openAsynchronous:YES];
}
@end


@implementation MBOpenInEpubHandler

- (id)init {
	self = [super init];
	if (self) {
	}
	
	return self;
}

+ (MBOpenInEpubHandler *) epubHandler {
	dispatch_once(&pred, ^{	
		uniqueInstance = [[MBOpenInEpubHandler alloc] init];
	});
	
	return uniqueInstance;
} 

- (void) openIn:(NSURL *)epubURL {
	NSString *path = [[[epubURL absoluteString] urlDecode] substringFromIndex:6];
	if (![CLFileUtil fileExistsAtPath:path])
		return;
	
	__inputPath = path;
	__oid = [NSString dateStringWithFormat:@"yyyyMMddHHmmss"];

	[self performSelector:@selector(__lazyExecute) withObject:nil afterDelay:0.5f];
}

#pragma mark -
#pragma MBEpubControllerDelegate Methods

- (void) epubController:(MBEpubController *)controller didOpenEpub:(MBEpubContentModel *)contentModel {
	//LOG_EXPR(contentModel.manifest);
	//LOG_EXPR(contentModel.spine);
	
//    MBArchiveData *data = (MBArchiveData *) [[controller userInfo] objectForKey:@"MBArchiveData"];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[data saveDirectory] stringByAppendingFormat:@"extract/%@", contentModel.coverPath]];
//    image = [CLImageUtil resizeImage:image scaledToMinSize:CGSizeMake(320, 320)];
//    [CLFileUtil saveData:UIImageJPEGRepresentation(image, 90) toFilePath:[data thumbnailPath] iCloudBackupEnable:NO];
//
//    [data setTitle:contentModel.metaData[@"title"] authror:contentModel.metaData[@"creator"]];
//    data.contentRootPath = contentModel.contentRootPath;
//    data.manifest = contentModel.manifest;
//    data.spine = contentModel.spine;
//    data.navPoint = contentModel.navPoint;
//    [ARCHIVE addArchiveData:data];
//    [ARCHIVE saveData];
	
	__epubController.delegate = nil;
	__epubController = nil;
	
//    PostNoti(NOTI_OPEN_IN_FILE_ADDED);
//    PostNoti(NOTI_HIDE_SIDE_MENU);
	
//    NSDictionary *args = @{ @"MBArchiveData": data };
//    PostNotiWithArgs(NOTI_GO_ARCHIVE, args);
    
    NSDictionary *epubData = [[NSDictionary alloc] initWithObjectsAndKeys:contentModel, @"contentModel", nil];
    [self.delegate openInEpubHandlerDelegate:self didOpenEpub:epubData];
    
    
}

- (void) epubController:(MBEpubController *)controller didFailWithError:(NSError *)error {
//    MBArchiveData *data = (MBArchiveData *) [[controller userInfo] objectForKey:@"MBArchiveData"];
//    [CLFileUtil removeFileAtPath:data.saveDirectory];
	
	__epubController.delegate = nil;
	__epubController = nil;
	
//	ShowAlert([AppDelegate appDelegate].mainNav, @"EPUB 파일을 열 수 없습니다.");
}

- (void) epubController:(MBEpubController *)controller willOpenEpub:(NSURL *)epubURL {
}
 
 
@end
