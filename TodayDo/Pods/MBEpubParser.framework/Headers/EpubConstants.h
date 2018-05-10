//
//  EpubConstants.h
//  EpubObjC
//
//  Created by Hayden Kang on 2018. 2. 9..
//  Copyright © 2018년 Hayden Kang. All rights reserved.
//

#ifndef EpubConstants_h
#define EpubConstants_h


#endif /* EpubConstants_h */

#define isPhoneX                                                [EpubConstants screenSize].height == 812 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define EpubReaderVerticalMargin                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30:100)
#define EpubReaderHorizontalMargin                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 20:90)

#define IPHONE_X_STATUS_BAR_TOP 20
#define IPHONE_X_HOME_INDICATOR_BOTTOM 34
#define IPHONE_X_HOME_INDICATOR_LANDSCAPE_BOTTOM 16
#define IPHONE_X_LANDSCAPE_SPACE 44

@interface EpubConstants : NSObject
+ (CGSize) screenSize;

@end

@implementation EpubConstants

+ (CGSize) screenSize {
    if (IOS_VERSION >= 8) {
        return CGSizeMake([UIScreen mainScreen].nativeBounds.size.width / [UIScreen mainScreen].nativeScale, [UIScreen mainScreen].nativeBounds.size.height / [UIScreen mainScreen].nativeScale);
    }
    
    else {
        return [UIScreen mainScreen].bounds.size;
    }
}

@end
