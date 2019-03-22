//
//  YXPickImageView.h
//  Mobileyx
//
//  Created by changle on 2017/2/28.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TakePhotoBlock) ();
typedef void (^ImageShowBlock) (NSInteger tag,UIImage *showImage);

@interface YXPickImageView : UIView

@property (nonatomic, assign) NSInteger  pickImageViewHeight;

@property (nonatomic, copy)   TakePhotoBlock takePhotoBlock;
@property (nonatomic, copy)   ImageShowBlock imageShowBlock;


@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *photosUrlStr;

- (void)addImage:(UIImage *)image;
- (void)addImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString;

- (void)removeImage:(UIImage *)image;
- (void)removeImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString;

@end
