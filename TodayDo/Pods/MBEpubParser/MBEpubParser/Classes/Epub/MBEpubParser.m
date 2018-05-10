//
//  MBEpubParser.m
//  MBEpubKit
//
//  Created by Kwon Gu Hyuk on 2015. 3. 12..
//  Copyright (c) 2015년 kineo2k@gmail.com. All rights reserved.
//

#import "MBEpubParser.h"
#import "VTPG_Common.h"
#import "XMLReader.h"

#define kMimeTypeEpub @"application/epub+zip"
#define kMimeTypeiBooks @"application/x-ibooks+zip"

@interface MBEpubParser (Private)
- (BOOL) __isValidNode:(DDXMLElement *)node;
- (NSArray *) __subNavPoint:(NSDictionary *)info withDepth:(NSInteger)depth;
@end

@implementation MBEpubParser (Private)
- (BOOL) __isValidNode:(DDXMLElement *)node {
	return node.kind != DDXMLCommentKind;
}

- (NSArray *) __subNavPoint:(NSDictionary *)info withDepth:(NSInteger)depth {
	NSString *title = [info valueForKeyPath:@"navLabel.text.textValue"];
	if (title == nil)
		title = @"제목없음";
	
	NSString *content = [info valueForKeyPath:@"content.src"];
	@try {
		if ([content rangeOfString:@"#"].length > 0) {
			content = [content substringToIndex:[content rangeOfString:@"html"].location + 4];
		}
	} @catch (NSException *exception) {
		return @[];
	}
	
	NSMutableArray *navPoint = [NSMutableArray array];
	NSMutableDictionary *item = [NSMutableDictionary dictionary];
	[item setObject:title forKey:@"title"];
	[item setObject:content forKey:@"content"];
	[item setObject:@(depth) forKey:@"depth"];
	[navPoint addObject:item];
	
	NSValue *value = [info valueForKeyPath:@"navPoint"];
	if (value != nil) {
		if ([value isKindOfClass:[NSDictionary class]]) {
			[navPoint addObjectsFromArray:[self __subNavPoint:(NSDictionary *) value withDepth:depth+1]];
		} else {
			NSArray *navPointList = (NSArray *) value;
			for (NSDictionary *np in navPointList) {
				[navPoint addObjectsFromArray:[self __subNavPoint:np  withDepth:depth+1]];
			}
		}
	}
	
	return navPoint;
}
@end


@implementation MBEpubParser

- (MBEpubKitBookType) bookTypeForBaseURL:(NSURL *)baseURL {
	NSError *error = nil;
	MBEpubKitBookType bookType = MBEpubKitBookTypeUnknown;
	
	NSURL *mimetypeURL = [baseURL URLByAppendingPathComponent:@"mimetype"];
	NSString *mimetype = [[NSString alloc] initWithContentsOfURL:mimetypeURL encoding:NSASCIIStringEncoding error:&error];
	
	if (error) {
		return bookType;
	}
	
	NSRange mimeRange = [mimetype rangeOfString:kMimeTypeEpub];
	
	if (mimeRange.location == 0 && mimeRange.length == 20) {
		bookType = MBEpubKitBookTypeEpub2;
	} else if ([mimetype isEqualToString:kMimeTypeiBooks]) {
		bookType = MBEpubKitBookTypeiBook;
	}
	
	return bookType;
}


- (MBEpubKitBookEncryption) contentEncryptionForBaseURL:(NSURL *)baseURL {
	NSURL *containerURL = [[baseURL URLByAppendingPathComponent:@"META-INF"] URLByAppendingPathComponent:@"sinf.xml"];
	NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&error];
	//content = [MBEpubParser stringByStrippingXMLComments:content];
	DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
	
	if (error) {
		return MBEpubKitBookEnryptionNone;
	}
	
	NSArray *sinfNodes = [document.rootElement nodesForXPath:@"//fairplay:sinf" error:&error];
	if (sinfNodes == nil || sinfNodes.count == 0) {
		return MBEpubKitBookEnryptionNone;
	} else {
		return MBEpubKitBookEnryptionFairplay;
	}
}


- (NSURL *) rootFileForBaseURL:(NSURL *)baseURL {
	NSError *error = nil;
	NSURL *containerURL = [[baseURL URLByAppendingPathComponent:@"META-INF"] URLByAppendingPathComponent:@"container.xml"];
	
	NSString *content = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&error];
	content = [MBEpubParser stringByStrippingXMLComments:content];
	DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
	DDXMLElement *root = [document rootElement];
	
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray* objectElements = [root nodesForXPath:@"//default:container/default:rootfiles/default:rootfile" error:&error];
	
	NSUInteger count = 0;
	NSString *value = nil;
	for (DDXMLElement* xmlElement in objectElements) {
		value = [[xmlElement attributeForName:@"full-path"] stringValue];
		count++;
	}
	
	if (count == 1 && value) {
		return [baseURL URLByAppendingPathComponent:value];
	} else if (count == 0) {
		LOG_EXPR(@"no root file found.");
	} else {
		LOG_EXPR(@"there are more than one root files. this is odd.");
	}
	
	return nil;
}


- (NSString *) coverPathComponentFromDocument:(DDXMLDocument *)document {
	NSString *coverPath;
	DDXMLElement *root  = [document rootElement];
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray *metaNodes = [root nodesForXPath:@"//default:item[@properties='cover-image']" error:nil];
	
	if (metaNodes) {
		coverPath = [[metaNodes.lastObject attributeForName:@"href"] stringValue];
	}
	
	if (!coverPath) {
		NSString *coverItemId;
		
		DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
		defaultNamespace.name = @"default";
		metaNodes = [root nodesForXPath:@"//default:meta" error:nil];
		for (DDXMLElement *xmlElement in metaNodes) {
			if ([[xmlElement attributeForName:@"name"].stringValue compare:@"cover" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
				coverItemId = [xmlElement attributeForName:@"content"].stringValue;
			}
		}
		
		if (!coverItemId) {
			return nil;
		} else {
			DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
			defaultNamespace.name = @"default";
			NSArray *itemNodes = [root nodesForXPath:@"//default:item" error:nil];
			
			for (DDXMLElement *itemElement in itemNodes) {
				if ([[itemElement attributeForName:@"id"].stringValue compare:coverItemId options:NSCaseInsensitiveSearch] == NSOrderedSame) {
					coverPath = [itemElement attributeForName:@"href"].stringValue;
				}
			}
			
		}
	}
	
	return coverPath;
}

- (NSDictionary *) metaDataFromDocument:(DDXMLDocument *)document {
	NSMutableDictionary *metaData = [NSMutableDictionary new];
	DDXMLElement *root  = [document rootElement];
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray *metaNodes = [root nodesForXPath:@"//default:package/default:metadata" error:nil];
	
	if (metaNodes.count == 1) {
		DDXMLElement *metaNode = metaNodes[0];
		NSArray *metaElements = metaNode.children;
		
		for (DDXMLElement* xmlElement in metaElements) {            
			@try {
				if ([self __isValidNode:xmlElement]) {
					if (![metaData objectForKey:xmlElement.localName]) {
						metaData[xmlElement.localName] = xmlElement.stringValue;
					} else {
						NSString * attributeString = [[[xmlElement attributes] firstObject] stringValue];
						NSString * metaDataKeyString = [NSString stringWithFormat:@"%@-%@", xmlElement.localName, attributeString];
						metaData[metaDataKeyString] = xmlElement.stringValue;
					}
				}
			} @catch (NSException *exception) {}
		}
	} else {
		return nil;
	}
	
	return metaData;
}


- (NSArray *) spineFromDocument:(DDXMLDocument *)document {
	NSMutableArray *spine = [NSMutableArray new];
	DDXMLElement *root  = [document rootElement];
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray *spineNodes = [root nodesForXPath:@"//default:package/default:spine" error:nil];
	
	if (spineNodes.count == 1) {
		DDXMLElement *spineElement = spineNodes[0];
		NSArray *spineElements = spineElement.children;
		for (DDXMLElement* xmlElement in spineElements) {
			if ([self __isValidNode:xmlElement]) {
				[spine addObject:[[xmlElement attributeForName:@"idref"] stringValue]];
			}
		}
	} else {
		return nil;
	}
	
	return spine;
}


- (NSDictionary *) manifestFromDocument:(DDXMLDocument *)document {
	NSMutableDictionary *manifest = [NSMutableDictionary new];
	DDXMLElement *root  = [document rootElement];
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray *manifestNodes = [root nodesForXPath:@"//default:package/default:manifest" error:nil];
	
	if (manifestNodes.count == 1) {
		NSArray *itemElements = ((DDXMLElement *)manifestNodes[0]).children;
		for (DDXMLElement* xmlElement in itemElements) {
			if ([self __isValidNode:xmlElement] && xmlElement.attributes) {
				NSString *href = [[xmlElement attributeForName:@"href"] stringValue];
				NSString *itemId = [[xmlElement attributeForName:@"id"] stringValue];
				
				if ([href rangeOfString:@"%20"].location != NSNotFound) {
					href = [href urlDecode];
				}
				
				if (itemId && href) {
					if ([href isEqualToString:@"toc.ncx"]) {
						manifest[@"ncx"] = href;
					} else {
						manifest[itemId] = href;
					}
				}
			}
		}
	} else {
		return nil;
	}
	
	return manifest;
}


- (NSArray *) guideFromDocument:(DDXMLDocument *)document {
	NSMutableArray *guide = [NSMutableArray new];
	DDXMLElement *root  = [document rootElement];
	DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
	defaultNamespace.name = @"default";
	NSArray *guideNodes = [root nodesForXPath:@"//default:package/default:guide" error:nil];
	
	if (guideNodes.count == 1) {
		DDXMLElement *guideElement = guideNodes[0];
		NSArray *referenceElements = guideElement.children;
		
		@try {
			for (DDXMLElement* xmlElement in referenceElements) {
				if ([self __isValidNode:xmlElement]) {
					NSString *type = [[xmlElement attributeForName:@"type"] stringValue];
					NSString *href = [[xmlElement attributeForName:@"href"] stringValue];
					NSString *title = [[xmlElement attributeForName:@"title"] stringValue];
					
					NSMutableDictionary *reference = [NSMutableDictionary new];
					if (type) {
						reference[type] = type;
					}
					
					if (href) {
						reference[@"href"] = href;
					}
					
					if (title) {
						reference[@"title"] = title;
					}
					
					[guide addObject:reference];
				}
			}
		}
		@catch (NSException *exception) {
			return guide;
		}
	} else {
		return nil;
	}
	
	return guide;
}

- (NSArray *) navPointFromDocument:(NSURL *)url {
	NSMutableArray *navPoint = [NSMutableArray new];
	if (url == nil)
		return navPoint;
	
	NSString *xml = [NSString  stringWithContentsOfURL:url
											  encoding:NSUTF8StringEncoding
												 error:nil];
	NSDictionary *info = [XMLReader dictionaryForXMLString:xml error:nil];
	if ([[info valueForKeyPath:@"ncx.navMap.navPoint"] isKindOfClass:[NSDictionary class]]) {
		[navPoint addObjectsFromArray:[self __subNavPoint:[info valueForKeyPath:@"ncx.navMap.navPoint"] withDepth:1]];
	} else {
		NSArray *navPointList = [info valueForKeyPath:@"ncx.navMap.navPoint"];
		for (NSDictionary *np in navPointList) {
			[navPoint addObjectsFromArray:[self __subNavPoint:np withDepth:1]];
		}
	}
	
	return navPoint;
}

+ (NSString *) stringByStrippingXMLComments:(NSString *)xml {
	NSRange r;
	NSString *s = [xml copy];
	while ((r = [s rangeOfString:@"<!--[^>]*-->" options:NSRegularExpressionSearch]).location != NSNotFound)
		s = [s stringByReplacingCharactersInRange:r withString:@""];
	return s;
}
@end
