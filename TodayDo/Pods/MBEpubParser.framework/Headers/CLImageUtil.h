//
//  CLImageUtil.h
//  MrblueIphoneApp
//
//  Created by Gu HyukKwon on 2015. 3. 3..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLImageUtil : NSObject

+ (UIImage *) resizeImage:(UIImage *)image scaledToMinSize:(CGSize)minSize;
+ (UIImage *) resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *) cropImage:(UIImage *)image toRect:(CGRect)cropRect;
+ (UIImage *) cropImageToCenter:(UIImage *)image;
+ (UIImage *) rotateImage:(UIImage *)image withAngle:(NSInteger)angle;

@end
