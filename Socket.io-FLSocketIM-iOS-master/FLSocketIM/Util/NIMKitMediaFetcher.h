//
//  NIMKitMediaFetcher.h
//  NIMKit
//
//  Created by chris on 2016/11/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
//#import "TOImageTypeModel.h"

typedef void(^NIMKitLibraryFetchResult)(NSArray *images, NSArray *imageModel,  NSString *path, PHAssetMediaType type);

typedef void(^NIMKitCameraFetchResult)(NSString *path, UIImage *image);

@interface NIMKitMediaFetcher : NSObject

@property (nonatomic,assign) NSInteger limit;

@property (nonatomic,strong) NSArray   *mediaTypes; //kUTTypeMovie,kUTTypeImage

/// Default is NO, if set YES, user can picking gif image.
/// 默认为NO，如果设置为YES,用户可以选择gif图片
@property (nonatomic, assign) BOOL allowPickingGif;

/// Default is YES, if set NO, the picker don't dismiss itself.
/// 默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property(nonatomic, assign) BOOL autoDismiss;

- (void)fetchPhotoFromLibrary:(NIMKitLibraryFetchResult)result;

- (void)fetchMediaFromCamera:(NIMKitCameraFetchResult)result;

//新增 选择视频的方法
- (void)fetchVideoMediaFromCamera:(NIMKitCameraFetchResult)result;
- (void)fetchVideoMediaFromLibrary:(NIMKitLibraryFetchResult)result;


@end
