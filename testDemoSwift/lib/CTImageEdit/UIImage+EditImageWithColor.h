//
//  UIImage+EditImageWithColor.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <UIKit/UIKit.h>

#define CTImageEditRGBColor(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]


#define CTImageEditPreviewFrame (CGRect){ 0, 60, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 167 }

@interface UIImage (EditImageWithColor)

- (UIImage*)tintImageWithColor:(UIColor*)tintColor;

+ (UIImage*)createImageWithColor:(UIColor*)color;

+ (UIImage*)imageWithName:(NSString*)str;
@end
