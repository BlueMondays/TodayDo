//
//  CLImageUtil.m
//  MrblueIphoneApp
//
//  Created by Gu HyukKwon on 2015. 3. 3..
//  Copyright (c) 2015년 Mrblue. All rights reserved.
//

#import "CLImageUtil.h"

#define degreeToRadian(x) (M_PI * (x) / 180.0f)



@implementation CLImageUtil

+ (UIImage*) resizeImage:(UIImage*)image scaledToMinSize:(CGSize)minSize {
    
	int newWidth = 0;
	int newHeight = 0;
	int minWidth = minSize.width;
	int minHeight = minSize.height;
	double scale = 0;
	
	if (image.size.width <= image.size.height) {
		scale = minWidth / image.size.width;
	} else {
		scale = minHeight / image.size.height;
	}
	
	newWidth = image.size.width * scale;
	newHeight = image.size.height * scale;
	if (newWidth < minWidth) newWidth = minWidth;
	if (newHeight < minHeight) newHeight = minHeight;
	
	return [self resizeImage:image scaledToSize:CGSizeMake(newWidth, newHeight)];
}

+ (UIImage*) resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

+ (UIImage *) cropImage:(UIImage *)image toRect:(CGRect)cropRect {
    
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
	UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return cropImage;
}

+ (UIImage *) cropImageToCenter:(UIImage *)image {
    
	int w = image.size.width;
	int h = image.size.height;
	int x = 0;
	int y = 0;
	if (w <= h) {
		y = (image.size.height - image.size.width) / 2;
		h = w;
	} else {
		x = (image.size.width - image.size.height) / 2;
		w = h;
	}
	
	return [CLImageUtil cropImage:image toRect:CGRectMake(x, y, w, h)];
}

+ (UIImage *) rotateImage:(UIImage *)image withAngle:(NSInteger)angle {
    
	CGSize size = image.size;
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextRotateCTM(ctx, degreeToRadian(angle));
	CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), image.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
