//
//  NIMKitPhotoFetcher.m
//  NIMKit
//
//  Created by chris on 2016/11/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NIMKitMediaFetcher.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NIMKitFileLocationHelper.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"
//#import "TOImageTypeModel.h"
//#import "TOFunction.h"
#define Localized(key)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"Localizable"]

#define NIMKit_Dispatch_Sync_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define NIMKit_Dispatch_Async_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface NIMKitMediaPickerController : TZImagePickerController

@end

@interface NIMKitMediaFetcher()<TZImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,copy)   NIMKitLibraryFetchResult libraryResultHandler;

@property (nonatomic,copy)   NIMKitCameraFetchResult  cameraResultHandler;

@property (nonatomic,strong) UIImagePickerController  *imagePicker;

@property (nonatomic,strong) NIMKitMediaPickerController  *assetsPicker;

@end

@implementation NIMKitMediaFetcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        _limit = 9;
    }
    return self;
}

- (void)presentVC:(UIViewController *)picker {
    UIViewController *topRootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    // 循环
    while (topRootViewController.presentedViewController)
    {
        topRootViewController = topRootViewController.presentedViewController;
    }
    // 然后再进行present操作
    [topRootViewController presentViewController:picker animated:YES completion:nil];
}

- (void)fetchPhotoFromLibrary:(NIMKitLibraryFetchResult)result
{
    __weak typeof(self) weakSelf = self;
    [self setUpPhotoLibrary:^(NIMKitMediaPickerController * _Nullable picker) {
        if (picker && weakSelf) {
            picker.allowPickingOriginalPhoto = NO;
//            picker.allowPickingGif           = weakSelf.allowPickingGif;
            picker.autoDismiss               = weakSelf.autoDismiss;
            weakSelf.assetsPicker            = picker;
            weakSelf.libraryResultHandler    = result;
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
            [weakSelf presentVC:picker];
        }else{
            result(nil,nil,nil,PHAssetMediaTypeUnknown);
        }
    }];
}

- (void)fetchMediaFromCamera:(NIMKitCameraFetchResult)result
{
    if ([self initCamera]) {
        self.cameraResultHandler = result;
#if TARGET_IPHONE_SIMULATOR
        NSAssert(0, @"not supported");
#elif TARGET_OS_IPHONE
        self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.imagePicker.videoMaximumDuration = 10;
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.imagePicker animated:YES completion:nil];
        [self presentVC:self.imagePicker];
#endif
    }
}

- (void)fetchVideoMediaFromCamera:(NIMKitCameraFetchResult)result {
    if ([self initCamera]) {
        self.cameraResultHandler = result;
#if TARGET_IPHONE_SIMULATOR
        NSAssert(0, @"not supported");
#elif TARGET_OS_IPHONE
        self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        // 设置最长摄像时间
        self.imagePicker.videoMaximumDuration = 10;
        // 允许用户进行编辑
        self.imagePicker.allowsEditing = YES;
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.imagePicker animated:YES completion:nil];
        [self presentVC:self.imagePicker];
#endif
    }
}

- (void)fetchVideoMediaFromLibrary:(NIMKitLibraryFetchResult)result {
    __weak typeof(self) weakSelf = self;
    [self setUpPhotoLibrary:^(NIMKitMediaPickerController * _Nullable picker) {
        if (picker && weakSelf) {
            picker.allowPickingOriginalPhoto = NO;
//            picker.allowPickingGif           = NO;
            picker.autoDismiss               = YES;
            picker.allowTakePicture  = NO;
            picker.allowPickingImage = NO;
            weakSelf.assetsPicker            = picker;
            weakSelf.libraryResultHandler    = result;
            [weakSelf presentVC:picker];
        }else{
            result(nil,nil,nil,PHAssetMediaTypeUnknown);
        }
    }];
}


- (void)setUpPhotoLibrary:(void(^)(NIMKitMediaPickerController * _Nullable picker)) handler
{
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:Localized( @"相册权限受限")
                                           delegate:nil
                                  cancelButtonTitle:Localized(@"确定")
                                  otherButtonTitles:nil] show];
                if(handler) handler(nil);
            }
            if (status == PHAuthorizationStatusAuthorized) {
                NIMKitMediaPickerController *vc = [[NIMKitMediaPickerController alloc] initWithMaxImagesCount:self.limit delegate:weakSelf];
//                vc.allowPickingGif = self.allowPickingGif;
                vc.navigationBar.barTintColor   = [UIColor whiteColor];
                vc.barItemTextColor             = [UIColor blackColor];
                vc.navigationBar.barStyle       = UIBarStyleDefault;
                vc.allowPickingVideo            = [_mediaTypes containsObject:(NSString *)kUTTypeMovie];
                if(handler) handler(vc);
            }
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *inputURL               = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString *outputFileName      = [NIMKitFileLocationHelper genFilenameWithExt:@"mp4"];
            NSString *outputPath          = [NIMKitFileLocationHelper filepathForVideo:outputFileName];
            AVURLAsset *asset             = [AVURLAsset URLAssetWithURL:inputURL options:nil];
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                             presetName:AVAssetExportPresetMediumQuality];
            session.outputURL                   = [NSURL fileURLWithPath:outputPath];
            session.outputFileType              = AVFileTypeMPEG4;// 支持安卓某些机器的视频播放
            session.shouldOptimizeForNetworkUse = YES;
            session.videoComposition            = [self getVideoComposition:asset];  //修正某些播放器不识别视频Rotation的问题
            [session exportAsynchronouslyWithCompletionHandler:^(void)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (session.status == AVAssetExportSessionStatusCompleted)
                     {
                         self.cameraResultHandler(outputPath,nil);
                     }
                     else
                     {
                         self.cameraResultHandler(nil,nil);
                     }
                     self.cameraResultHandler = nil;
                 });
             }];
            
        });
        
    }else{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.cameraResultHandler(nil,image);
        self.cameraResultHandler = nil;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 相册回调
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (isSelectOriginalPhoto)
    {
        [self requestAssets:[assets mutableCopy]];
    }
    else
    {
        NSArray *imageTypeMArray = [self imageModelWithAssets:assets];
        if (self.libraryResultHandler) {
            self.libraryResultHandler(photos,imageTypeMArray,nil,PHAssetMediaTypeImage);
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    //NSLog(@"%@",asset);
    NSArray *imageArray = [NSArray arrayWithObject:animatedImage];
    NSArray *array      = [NSArray arrayWithObject:asset];
    NSArray *assets     = [self imageModelWithAssets:array];
    if (self.libraryResultHandler) {
        self.libraryResultHandler(imageArray,assets,nil,PHAssetMediaTypeImage);
    }
}

- (NSArray *)imageModelWithAssets:(NSArray *)assets {
    
    PHImageRequestOptions *options      = [PHImageRequestOptions new];
    options.resizeMode                  = PHImageRequestOptionsResizeModeFast;
    options.synchronous                 = YES;

    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    NSMutableArray *imageTypeMArray     = [NSMutableArray arrayWithCapacity:9];
    
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [imageManager requestImageDataForAsset:asset
                                       options:options
                                 resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                     //                                     NSLog(@"dataUTI:%@",dataUTI);
                                     //gif 图片
                                     if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                                         //这里获取gif图片的NSData数据
//                                         NSString *imageContent       = [TOFunction contentTypeForImageData:imageData];
//                                         TOImageTypeModel *imageModel = [[TOImageTypeModel alloc] init];
//                                         imageModel.isGif             = YES;
//                                         imageModel.imageType         = ImageTypeGif;
//                                         imageModel.imageTypeString   = imageContent;
//                                         imageModel.imageData         = imageData;
                                         [imageTypeMArray addObject:imageData];
                                     }
                                     else /*if([dataUTI isEqualToString:(__bridge NSString *)kUTTypeJPEG] || [dataUTI isEqualToString:(__bridge NSString *)kUTTypeJPEG2000])*/ {
                                         //其他格式的图片
//                                         NSString *imageContent       = [TOFunction contentTypeForImageData:imageData];
//                                         TOImageTypeModel *imageModel = [[TOImageTypeModel alloc] init];
//                                         imageModel.isGif             = NO;
//                                         imageModel.imageType         = ImageTypeJpg;
//                                         imageModel.imageTypeString   = imageContent;
//                                         imageModel.imageData         = imageData;
                                         [imageTypeMArray addObject:imageData];
                                     }
//                                     else   {
//                                         //其他格式的图片
//                                         NSString *imageContent       = [TOFunction contentTypeForImageData:imageData];
//                                         TOImageTypeModel *imageModel = [[TOImageTypeModel alloc] init];
//                                         imageModel.isGif             = NO;
//                                         imageModel.imageType         = ImageTypePng;
//                                         imageModel.imageTypeString   = imageContent;
//                                         imageModel.imageData         = imageData;
//                                         [imageTypeMArray addObject:imageModel];
//                                         
//                                     }
                                 }];
    }];
    return imageTypeMArray;
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:@[asset]];
    [self requestAssets:items];
}

- (void)requestAssets:(NSMutableArray *)assets
{
    if (!assets.count) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self requestAsset:assets.firstObject handler:^(NSString *path, PHAssetMediaType type) {
        if (weakSelf.libraryResultHandler) {
            weakSelf.libraryResultHandler(nil,nil,path,type);
        }
        NIMKit_Dispatch_Async_Main(^{
            [assets removeObjectAtIndex:0];
            [weakSelf requestAssets:assets];
        })
        
    }];
}

- (void)requestAsset:(PHAsset *)asset handler:(void(^)(NSString *,PHAssetMediaType)) handler
{
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            NSString *path = [(AVURLAsset *)asset URL].relativePath;
            handler(path, PHAssetMediaTypeVideo);
        }];
    }
    if (asset.mediaType == PHAssetMediaTypeImage) {
        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            NSString *path = contentEditingInput.fullSizeImageURL.relativePath;
            handler(path,contentEditingInput.mediaType);
        }];
    }
    
}

#pragma mark - Private

- (void)setMediaTypes:(NSArray *)mediaTypes
{
    _mediaTypes = mediaTypes;
    _imagePicker.mediaTypes = mediaTypes;
    _assetsPicker.allowPickingVideo = [mediaTypes containsObject:(NSString *)kUTTypeMovie];
}

- (AVMutableVideoComposition *)getVideoComposition:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    if(isPortrait_) {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    composition.naturalSize     = videoSize;
    videoComposition.renderSize = videoSize;
    
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}

- (BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = NO;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = NO;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = NO;
        }
    }
    return isPortrait;
}

- (BOOL)initCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:Localized(@"检测不到相机设备")
                                   delegate:nil
                          cancelButtonTitle:Localized(@"确定")
                          otherButtonTitles:nil] show];
        return NO;
    }
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:Localized(@"相机权限受限")
                                   delegate:nil
                          cancelButtonTitle:Localized(@"确定")
                          otherButtonTitles:nil] show];
        return NO;
        
    }
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = self.mediaTypes;
    return YES;
}

- (void)originalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) completion(result,info,isDegraded);
        }
    }];
}


/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
#pragma clang diagnostic pop

@end


@implementation NIMKitMediaPickerController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleDefault;
}

@end
