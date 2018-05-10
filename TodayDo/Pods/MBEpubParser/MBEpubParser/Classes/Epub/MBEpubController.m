//
//  MBEpubController.m
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//

#import "MBEpubController.h"
#import "MBEpubContentModel.h"
#import "VTPG_Common.h"
#import "CLFileUtil.h"
#import "CLContentSafer.h"

@interface MBEpubController (Private)
- (void) __javascriptInjection;
- (void) __encryptContents;
- (void) __cssExceptionHandling;
@end

@implementation MBEpubController (Private)
- (void) __javascriptInjection {
    
    [self __cssExceptionHandling];
    
	// CSS
	NSString *cssName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"mrblue":@"mrblue-iPad";
	NSString *path = [[NSBundle mainBundle] pathForResource:cssName ofType:@"css"];
	NSString *cssCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
	// mrblue
	path = [[NSBundle mainBundle] pathForResource:@"mrblue" ofType:@"js"];
	NSString *jquery = @"<script type=\"text/javascript\" src=\"jquery-2.1.3.min.js\"></script>";
	NSString *fastclick = @"<script type=\"text/javascript\" src=\"fastclick.min.js\"></script>";
	NSString *rangy = @"<script type=\"text/javascript\" src=\"rangy.min.js\"></script>";
	NSString *jsCode = [NSString stringWithFormat:@"%@%@%@%@", jquery, fastclick, rangy,
						[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
	
	
	NSString *chapterPath = nil;
	NSMutableString *html = nil;
	
	for (NSInteger i = 0; i < [self.contentModel.spine count]; i++) {
		chapterPath = [[__epubContentBaseURL path] stringByAppendingPathComponent:
					   [self.contentModel.manifest valueForKey:[self.contentModel.spine objectAtIndex:i]]];
		html = [[NSMutableString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:chapterPath]] encoding:NSUTF8StringEncoding];
		
		if ([[html trim] isEqualToString:@""]) {
			continue;
		}
		
		// <title/> 을 <title></title>로 치환
		[html replaceOccurrencesOfString:@"<title/>" withString:@"<title></title>" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
		
		// CSS 삽입
		if ([html rangeOfString:@"</head>"].length > 0) {
			[html insertString:cssCode
					   atIndex:[html rangeOfString:@"</head>"].location];
		} else {
			// head가 없네;;
			[html insertString:[NSString stringWithFormat:@"<head>\n%@\n</head>\n", cssCode]
					   atIndex:[html rangeOfString:@"<body>"].location];
		}
		
		// JavaScript 삽입
		if ([html rangeOfString:@"</body>"].length > 0) {
			[html insertString:jsCode
					   atIndex:[html rangeOfString:@"</body>"].location];
		} else {
			// body도 없다;;
			[html appendFormat:@"%@</body></html>", jsCode];
		}
		
		// Injection한 html을 저장
		[html writeToFile:chapterPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		// Injection된 파일들을 복사
		NSString *chapterDirPath = [[chapterPath stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
		NSString *srcPath = nil;
		NSString *dstPath = nil;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			srcPath = [[NSBundle mainBundle] pathForResource:cssName ofType:@"css"];
			dstPath = [chapterDirPath stringByAppendingString:[cssName stringByAppendingString:@"css"]];
		} else {
			srcPath = [[NSBundle mainBundle] pathForResource:cssName ofType:@"css"];
			dstPath = [chapterDirPath stringByAppendingString:[cssName stringByAppendingString:@"css"]];
		}
		
		if (![CLFileUtil fileExistsAtPath:dstPath]) {
			[CLFileUtil copyFileAtPath:srcPath toPath:dstPath];
		}
		
		srcPath = [[NSBundle mainBundle] pathForResource:@"mrblue" ofType:@"js"];
		dstPath = [chapterDirPath stringByAppendingString:@"mrblue.js"];
		if (![CLFileUtil fileExistsAtPath:dstPath]) {
			[CLFileUtil copyFileAtPath:srcPath toPath:dstPath];
		}
		
		srcPath = [[NSBundle mainBundle] pathForResource:@"jquery-2.1.3.min" ofType:@"js"];
		dstPath = [chapterDirPath stringByAppendingString:@"jquery-2.1.3.min.js"];
		if (![CLFileUtil fileExistsAtPath:dstPath]) {
			[CLFileUtil copyFileAtPath:srcPath toPath:dstPath];
		}
		
		srcPath = [[NSBundle mainBundle] pathForResource:@"fastclick.min" ofType:@"js"];
		dstPath = [chapterDirPath stringByAppendingString:@"fastclick.min.js"];
		if (![CLFileUtil fileExistsAtPath:dstPath]) {
			[CLFileUtil copyFileAtPath:srcPath toPath:dstPath];
		}
		
		srcPath = [[NSBundle mainBundle] pathForResource:@"rangy.min" ofType:@"js"];
		dstPath = [chapterDirPath stringByAppendingString:@"rangy.min.js"];
		if (![CLFileUtil fileExistsAtPath:dstPath]) {
			[CLFileUtil copyFileAtPath:srcPath toPath:dstPath];
		}
	}
}

// 
- (void) __cssExceptionHandling {
    
    // CSS 예외처리
    // step 1. css 파일 찾기
    // content.opf 파일에서 style 파일 찾기
    BOOL fileExist = NO;
    NSString *contentPath = [[__epubContentBaseURL path] stringByAppendingPathComponent:@"content.opf"];
    fileExist = [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
    
    // 모든 style 파일경로를 저장해 둔다
    NSMutableArray<NSString*> *cssPathArrays = [[NSMutableArray alloc] init];
    
    if(fileExist) {
        NSMutableString *contentHtml = [[NSMutableString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:contentPath]] encoding:NSUTF8StringEncoding];
        NSArray<NSString*> *htmlPartsArrays = [contentHtml componentsSeparatedByString:@">"];
        
        //Ex) <item href="Styles/style.css" id="style.css" media-type="text/css" />
        for (NSString* htmlParts in htmlPartsArrays) {
            
            NSRange range = [htmlParts rangeOfString:@"text/css"];
            
            // css 타입일 경우
            if(range.location != NSNotFound) {
                
                NSRange pathRange = [htmlParts rangeOfString:@"href=\""];
                
                // css 파일의 경로를 잘라준다.
                if(pathRange.location != NSNotFound) {
                    NSRange subRange = NSMakeRange(pathRange.location + pathRange.length, htmlParts.length - pathRange.location - pathRange.length);
                    NSString *subString = [htmlParts substringWithRange:subRange];
                    NSRange subRange2 = [subString rangeOfString:@"\""];
                    NSString *cssPath = [subString substringWithRange:NSMakeRange(0, subRange2.location)];
                    
                    // 자른 경로를 배열에 저장
                    [cssPathArrays addObject:cssPath];
                }
            }
        }
    }
    
    // step 2. css 예외 처리 옵션 적용
    for (NSString* cssPath in cssPathArrays) {
        
        NSString *cssChapterPath = [[__epubContentBaseURL path] stringByAppendingPathComponent:cssPath];
        fileExist = [[NSFileManager defaultManager] fileExistsAtPath:cssChapterPath];
        
        if(fileExist) {
            // css 파일 불러오기.
            NSMutableString *css = [[NSMutableString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:cssChapterPath]] encoding:NSUTF8StringEncoding];
            
            // css 파일 내용 수정.
            // case 1. margin과 padding값을 고려하지 않고 width, height가 설정 되어 있는 경우 페이지 짤림현상이 발생하여 수정.
            
            // css 텍스트를 블럭 단위로 나눈다.
            NSArray<NSString*> *cssPartsArrays = [css componentsSeparatedByString:@"}"];
            for (NSString *cssParts in cssPartsArrays) {
                NSRange htmlRange = [cssParts rangeOfString:@"html"];
                NSRange bodyRange = [cssParts rangeOfString:@"body"];
                
                NSMutableString *newCssParts = [NSMutableString stringWithFormat:@"%@", cssParts];
                
                // html, body 가 있을경우.
                if(htmlRange.location != NSNotFound && bodyRange.location != NSNotFound) {
                    
                    // width 또는 height가 100% 일 경우 값을 제거한다. // TODO : 100% 이외의 경우도 고려해야함.
                    NSArray<NSString*> *replacementArrays = [[NSArray alloc] initWithObjects:@"width: 100%;", @"width:100%;", @"height: 100%;", @"height:100%;", nil];
                    for (NSString* replacementString in replacementArrays) {
                        NSRange replaceRange = [newCssParts rangeOfString:replacementString];
                        if(replaceRange.location != NSNotFound) {
                            [newCssParts replaceCharactersInRange:replaceRange withString:@""];
                        }
                    }
                }
                
                // 수정된 부분을 전체 css에 반영한다.
                NSRange editRange = [css rangeOfString:cssParts];
                if(editRange.location != NSNotFound) {
                    [css replaceCharactersInRange:editRange withString:newCssParts];
                }
            }
            
            
            // case 2. 띄워쓰기 안된 장문의 문장에서 줄바꿈이 되지 않아 다른 페이지를 침범하는 경우가 발생하여 수정.
            [css insertString:@"html, body {word-break: break-all;}\n" atIndex:0];
            
            // css 파일 저장.
            NSError *error = nil;
            NSData *cssData = [css dataUsingEncoding:NSUTF8StringEncoding];
            [cssData writeToFile:cssChapterPath options:NSDataWritingAtomic error:&error];
            NSLog(@"Write returned error: %@", [error localizedDescription]);
        }
        
    }
}

- (void) __encryptContents {
	// 암호화
	NSString *chapterPath = nil;
	NSMutableDictionary *encryptFileCache = [NSMutableDictionary dictionary]; // spine 값이 잘못 들어간 파일들도 있다. 파일명을 캐시하여 두번 암호화되지 않도록 처리하자.
	
	for (NSInteger i = 0; i < [self.contentModel.spine count]; i++) {
		chapterPath = [[__epubContentBaseURL path] stringByAppendingPathComponent:
					   [self.contentModel.manifest valueForKey:[self.contentModel.spine objectAtIndex:i]]];
		
		if ([encryptFileCache objectForKey:chapterPath] == nil) {
			[encryptFileCache setObject:chapterPath forKey:chapterPath];
			
			// 파일명을 임시로 변경
			[CLFileUtil moveFileAtPath:chapterPath toPath:[chapterPath stringByAppendingFormat:@"_tmp"]];
			
			// 암호화
			NSData *data = [[NSData alloc] initWithContentsOfFile:[chapterPath stringByAppendingFormat:@"_tmp"]];
			[CLContentSafer encryptData:data withSavePath:chapterPath];
			
			// 임시 파일 삭제
			[CLFileUtil removeFileAtPath:[chapterPath stringByAppendingFormat:@"_tmp"]];
		}
	}
	
	// epub 파일 암호화 (업데이트 등 패치를 할경우를 대비하여 원본 epub 파일을 삭제하지 않고 남겨둔다)
	NSString *epubPath = [__epubURL path];
	[CLFileUtil moveFileAtPath:epubPath toPath:[epubPath stringByAppendingFormat:@"_tmp"]];
	NSData *data = [[NSData alloc] initWithContentsOfFile:[epubPath stringByAppendingFormat:@"_tmp"]];
	[CLContentSafer encryptData:data withSavePath:epubPath];
	[CLFileUtil removeFileAtPath:[epubPath stringByAppendingFormat:@"_tmp"]];
	[CLFileUtil addDoNotBackupAttributeToDirectoryAtPath:epubPath];
}
@end


@implementation MBEpubController

@synthesize contentModel;
@synthesize delegate;
@synthesize userInfo = __userInfo;

- (instancetype) initWithEpubPath:(NSString *)epubPath andExtractPath:(NSString *)extractPath {
	self = [super init];
	if (self) {
		__epubURL = [NSURL fileURLWithPath:epubPath];
		__extractURL = [NSURL fileURLWithPath:extractPath];
	}
	return self;
}

- (void)openAsynchronous:(BOOL)asynchronous {
	__extractor = [[MBEpubExtractor alloc] initWithEpubURL:__epubURL andDestinationURL:__extractURL];
	__extractor.delegate = self;
	[__extractor start:asynchronous];
}

#pragma mark -
#pragma mark MBEpubExtractorDelegate Methods


/**
 epub 파일을 성공적으로 다운로드 한 경우 처리
 */
- (void) epubExtractorDidFinishExtracting:(MBEpubExtractor *)epubExtractor {
	__parser = [MBEpubParser new];
	NSURL *rootFile = [__parser rootFileForBaseURL:__extractURL];
	
	if (!rootFile) {
		NSError *error = [NSError errorWithDomain:kMBEpubKitErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"No root file"}];
		[self.delegate epubController:self didFailWithError:error];
		return;
	}
	
	__epubContentBaseURL = [rootFile URLByDeletingLastPathComponent];
	
	// content.opf
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:&error];
	content = [MBEpubParser stringByStrippingXMLComments:content];
	DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
	if (document) {
		self.contentModel = [MBEpubContentModel new];
		self.contentModel.bookType = [__parser bookTypeForBaseURL:__extractURL];
		self.contentModel.bookEncryption = [__parser contentEncryptionForBaseURL:__extractURL];
		self.contentModel.metaData = [__parser metaDataFromDocument:document];
		self.contentModel.coverPath = [__parser coverPathComponentFromDocument:document];
		self.contentModel.contentRootPath = [__epubContentBaseURL lastPathComponent];
		
		if (!self.contentModel.metaData) {
			NSError *error = [NSError errorWithDomain:kMBEpubKitErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"No meta data found"}];
			[self.delegate epubController:self didFailWithError:error];
		} else {
			self.contentModel.manifest = [__parser manifestFromDocument:document];
			
			NSMutableArray *spine = [NSMutableArray arrayWithArray:[__parser spineFromDocument:document]];
			NSString *chapterPath = nil;
			BOOL isDirectory;
			
			for (NSString *item in [spine copy]) {
				chapterPath = [[__epubContentBaseURL path] stringByAppendingPathComponent:[self.contentModel.manifest valueForKey:item]];
				if ([[NSFileManager defaultManager] fileExistsAtPath:chapterPath isDirectory:&isDirectory])
					if (isDirectory)
						[spine removeObject:item];
			}
			self.contentModel.spine = spine;
		}
	} else {
		NSError *error = [NSError errorWithDomain:kMBEpubKitErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"No document found"}];
		[self.delegate epubController:self didFailWithError:error];
	}
	
	// toc.ncx
	if (self.contentModel) {
		NSString *ncx = [self.contentModel.manifest objectForKey: @"ncx"];
		NSURL *toc = nil;
		@try {
			toc = [__epubContentBaseURL URLByAppendingPathComponent:ncx];
		} @catch (NSException *exception) {
		}
		
		self.contentModel.navPoint = [__parser navPointFromDocument:toc];
	}
	
	if (self.delegate) {
		// epub 뷰어용 JavaScript & CSS 인젝션
		[self __javascriptInjection];
		
		// 컨텐츠 암호화
		[self __encryptContents];
		
		// iCloud 백업이 안되도록 설정
		[CLFileUtil addDoNotBackupAttributeToDirectoryAtPath:[__extractURL path]];
		
		[self.delegate epubController:self didOpenEpub:self.contentModel];
	}
}

- (void) epubExtractor:(MBEpubExtractor *)epubExtractor didFailWithError:(NSError *)error {
	[self.delegate epubController:self didFailWithError:error];
}

- (void) epubExtractorDidStartExtracting:(MBEpubExtractor *)epubExtractor {
}

- (void) epubExtractorDidCancelExtraction:(MBEpubExtractor *)epubExtractor {
}

@end
