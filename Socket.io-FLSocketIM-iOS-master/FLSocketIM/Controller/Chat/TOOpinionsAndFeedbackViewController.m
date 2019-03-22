//
//  TOOpinionsAndFeedbackViewController.m
//  WenMingShuo
//
//  Created by 121 on 2017/9/7.
//  Copyright © 2017年 Six. All rights reserved.
//

#import "TOOpinionsAndFeedbackViewController.h"
#import "NIMKitMediaFetcher.h"
//#import "YXLookImageViewController.h"
#import "UIActionSheet+NTESBlock.h"
#import "YXPickImageView.h"
#import "TZImagePickerController.h"

#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height //主屏幕的高度

#define Main_Screen_Width  [[UIScreen mainScreen] bounds].size.width  //主屏幕的宽度

@interface TOOpinionsAndFeedbackViewController ()<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *problemInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *textViewPlacehoderLabel;
@property (strong, nonatomic) IBOutlet UITextView *problemTextView;
@property (strong, nonatomic) IBOutlet UILabel *textCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *imgChooseInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *imgCountLabel;
@property (strong, nonatomic) IBOutlet UIView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *imgChooseButton;
@property (strong, nonatomic) IBOutlet UILabel *contactPhoneInfoLabel;
@property (strong, nonatomic) IBOutlet UITextField *contactPhoneTF;

@property (strong, nonatomic) IBOutlet UIView *editView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic)   YXPickImageView *pickImageView;

@property (nonatomic,strong)    NIMKitMediaFetcher *mediaFetcher;

@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *imgUrlArray;
@property (nonatomic, strong) NSMutableArray *buttonArr;

@end

#define Localized(key)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"Localizable"]

@implementation TOOpinionsAndFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
}

- (void)configView
{
    self.title = @"投诉";
    
    self.problemTextView.delegate = self;
    self.contactPhoneTF.delegate = self;
    
    self.submitButton.layer.cornerRadius = 8;
    self.submitButton.layer.masksToBounds = YES;
    
    self.imgChooseButton.frame = CGRectMake(4, self.imgChooseButton.frame.origin.y, 75, 75);
}

#pragma mark -- textViewDelegate
//开始编辑时隐藏lable placehodel
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textViewPlacehoderLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //更新textview 字数
    if (self.problemTextView.text.length >= 200) {
        self.problemTextView.text = [self.problemTextView.text substringToIndex:200];
    }
    self.textCountLabel.text = [NSString stringWithFormat:@"%lu/200",(unsigned long)self.problemTextView.text.length];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.problemTextView.text.length == 0) {
        self.textViewPlacehoderLabel.hidden = NO;
    }
}

#pragma mark -- textFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.editView.frame = CGRectMake(0, -116, Main_Screen_Width, self.editView.height);
    }];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.editView.frame = CGRectMake(0, 88, Main_Screen_Width, self.editView.height);
    }];
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onActionClickChooseImg:(UIButton *)sender
{
    [self.view endEditing:YES];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    imagePickerVc.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *image = photos.firstObject;
            [sender setImage:image forState:UIControlStateNormal];
        }
    };
    [self presentViewController:imagePickerVc animated:YES completion:nil];

    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:Localized(@"选择照片") delegate:nil cancelButtonTitle:Localized(@"取消") destructiveButtonTitle:nil otherButtonTitles:Localized(@"拍照"),Localized(@"从相册"), nil];
//    __weak typeof(self) wself = self;
//
//    [sheet showInView:self.view completionHandler:^(NSInteger index) {
//        if (index == 0) {        //相机
//            wself.mediaFetcher.limit = 4 - wself.imgArray.count;
//            [wself.mediaFetcher fetchMediaFromCamera:^(NSString *path, UIImage *image) {
////                [TOBusinessManager upLoadImageWithImage:image completed:^(int code, NSArray *objc) {
////                    if (code == 1) {
////                        [wself.imgArray addObject:image];
////                        [wself.imgUrlArray addObject:[NSString stringWithFormat:@"%@",objc[0]]];
////                        [wself refresh];
////                    }
////                    else {
////                        [TOShowMessage showOnKeyWindowWithMessage:Localized(@"图片上传失败，请重试") showTime:2];
////                    }
////                }];
//            }];
//        } else if(index == 1) {  //相册
//            wself.mediaFetcher.limit = 4 - wself.imgArray.count;
//            [wself.mediaFetcher fetchPhotoFromLibrary:^(NSArray *images, NSArray *imageModelArray, NSString *path, PHAssetMediaType type){
//                if (images.count) {
//                    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
////                        [TOBusinessManager upLoadImageWithImage:image completed:^(int code, NSArray *objc) {
////                            if (code == 1) {
////                                [wself.imgArray addObject:image];
////                                [wself.imgUrlArray addObject:[NSString stringWithFormat:@"%@",objc[0]]];
////                                [wself refresh];
////                            }
////                            else {
////                                [TOShowMessage showOnKeyWindowWithMessage:Localized(@"图片上传失败，请重试") showTime:2];
////                            }
////                        }];
//                    }];
//                }
//            }];
//        }
//    }];

}

// 选择图片后布局
- (void)refresh
{
    CGRect frame = self.imgChooseButton.frame;
    
    NSLog(@"%lu",(unsigned long)self.buttonArr.count);
    
    UIButton* sbItem = [[UIButton alloc] initWithFrame:frame];
    sbItem.layer.masksToBounds = YES;
    sbItem.layer.cornerRadius = 2;

    frame.origin.x += frame.size.width + 4;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imgChooseButton.frame = frame;
    }];
    
    UIImage *image = [self.imgArray lastObject];
    [sbItem setImage:image forState:UIControlStateNormal];
    sbItem.tag = self.buttonArr.count;
    
    [sbItem addTarget:self action:@selector(lookPic:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonArr addObject:sbItem];
    [self.imgView addSubview:sbItem];
    int count = (int)self.imgArray.count;
    if (count >= 4)
    {
        self.imgChooseButton.hidden = YES;
        
    } else
    {
        self.imgChooseButton.hidden = NO;
    }
    
    self.imgCountLabel.text = [NSString stringWithFormat:@"%lu/4",(unsigned long)self.imgArray.count];
}

-(void)addPreImg:(UIImage *)img{
    self.imgArray = [[NSMutableArray alloc]init];
    [self.imgArray addObject:img];
    [self refresh];
}

- (void)lookPic:(UIButton *)sender
{
//    int imgCount = (int)sender.tag;
//
//    __weak typeof(self) weakSelf = self;
//
//    UIImage *img = [self.imgArray objectAtIndex:imgCount];
//    YXLookImageViewController *preViewController = [[YXLookImageViewController alloc] init];
//    preViewController.bigImage = img;
//    preViewController.deletePictureBlock = ^(BOOL isDelete){
//        if (isDelete) {
//            [weakSelf.imgArray removeObjectAtIndex:imgCount];
//            [weakSelf.imgUrlArray removeObjectAtIndex:imgCount];
//            UIButton * sbItem = [weakSelf.buttonArr objectAtIndex:imgCount];
//            [sbItem removeFromSuperview];
//            [weakSelf.buttonArr removeObjectAtIndex:imgCount];
//            [UIView animateWithDuration:0.25 animations:^{
//                [weakSelf.buttonArr enumerateObjectsUsingBlock:^(UIButton * button, NSUInteger idx, BOOL *stop) {
//                    [button removeFromSuperview];
//                    weakSelf.imgChooseButton.frame = CGRectMake(4, weakSelf.imgChooseButton.origin.y, 75, 75);
//
//                }];
//                NSArray * array = [NSArray arrayWithArray:weakSelf.imgArray];
//                [weakSelf.imgArray removeAllObjects];
//                [weakSelf.buttonArr removeAllObjects];
//
//                if(array.count > 0)
//                {
//                    for (UIImage * image in array)
//                    {
//                        [weakSelf.imgArray addObject:image];
//                        [weakSelf refresh];
//                    }
//                }
//                else
//                {
//                    self.imgChooseButton.frame = CGRectMake(4, weakSelf.imgChooseButton.origin.y, 75, 75);
//                }
//            }];
//            if (weakSelf.imgArray.count > 4) {
//                weakSelf.imgChooseButton.hidden = YES;
//            } else {
//                weakSelf.imgChooseButton.hidden = NO;
//            }
//            weakSelf.imgCountLabel.text = [NSString stringWithFormat:@"%lu/4",(unsigned long)weakSelf.imgArray.count];
//        }
//    };
//    [self.navigationController pushViewController:preViewController animated:YES];
}

#pragma mark -- 懒
- (NSMutableArray *)imgArray
{
    if (!_imgArray) {
        _imgArray = [NSMutableArray array];
    }
    return _imgArray;
}

- (NSMutableArray *)imgUrlArray
{
    if (!_imgUrlArray) {
        _imgUrlArray = [NSMutableArray array];
    }
    return _imgUrlArray;
}

- (NSMutableArray *)buttonArr
{
    if (!_buttonArr) {
        _buttonArr = [NSMutableArray array];
    }
    return _buttonArr;
}

- (NIMKitMediaFetcher *)mediaFetcher
{
    if (!_mediaFetcher) {
        _mediaFetcher                 = [[NIMKitMediaFetcher alloc] init];
        _mediaFetcher.limit           = 9;
        _mediaFetcher.autoDismiss     = YES;
        _mediaFetcher.allowPickingGif = NO;
        _mediaFetcher.mediaTypes      = @[(NSString *)kUTTypeImage];
    }
    return _mediaFetcher;
}

- (IBAction)onActionSubmit:(UIButton *)sender
{
    if(self.problemTextView.text.length <= 10)
    {
        [self showHint:@"请填写10个字以上的投诉内容"];
    }
    else
    {
        [self showMessage:@"提交中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHud];
            [self showHint:@"投诉成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
