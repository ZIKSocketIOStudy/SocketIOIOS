//
//  YXZIKBaseWKWebViewController.m
//  Mobileyx
//
//  Created by ZIKong on 2017/4/21.
//  Copyright © 2017年 youhui. All rights reserved.
//

#import "YXZIKBaseWKWebViewController.h"
#import <WebKit/WebKit.h>
@interface YXZIKBaseWKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView      *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSString       *urlString;
@property (nonatomic, strong) NSString       *currentURL;
@property (nonatomic, strong) NSString       *iconUrl;
@property (nonatomic, strong) NSDictionary   *payInfoDic;
@property (nonatomic, assign) BOOL           isHaveTitle;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation YXZIKBaseWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout               = UIRectEdgeNone;
    self.view.backgroundColor                 = [UIColor whiteColor];
    self.isHaveTitle = NO;
    if (self.title) {
        self.isHaveTitle = YES;
    }
    [self setupUI];//设置Nav的 返回按钮
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self loadURL];//加载网址显示网页
}


- (void)setupUI {
//    [self.navigationItem setHidesBackButton:YES];
//    UIImage * bkgN = [[UIImage imageNamed:@"icon_return"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//    UIImage * bkgD = [[UIImage imageNamed:@"icon_return"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0, 0, bkgN.size.width, bkgN.size.height);
//    [btn setBackgroundImage:bkgN forState:UIControlStateNormal];
//    [btn setBackgroundImage:bkgD forState:UIControlStateHighlighted];
//    [btn addTarget:self action:@selector(canback) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem * navigationSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    //    navigationSpacer.width = -bkgN.size.width + 12;
//    navigationSpacer.width = 0;
//    
//    UIBarButtonItem * itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.leftBarButtonItems = @[navigationSpacer,itemLeft];
    
    
    
}

#pragma mark -  加载网页(private)
- (void)loadURL {
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.webView loadRequest:request];
    //        if (_failVC) {
    //            [_failVC removeFromParentViewController];
    //            [_failVC.view removeFromSuperview];
    //            _failVC = nil;
    //        }
}

#pragma mark - public methods
- (void)loadWebURLSring:(NSString *)string {
    NSString *touStr = @"http://";
    
    self.urlString = string;
    if ([self.urlString.lowercaseString hasPrefix:@"www."]) {
        self.urlString = [touStr stringByAppendingString:self.urlString];
    }
    NSLog(@"self.url:%@",self.urlString);
}

#pragma mark - delegate
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",message.body);
}

#pragma mark - WKNavigationDelegate

#pragma mark - 页面开始加载时调用
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.progressView.hidden = NO;
    [self.indicator startAnimating];
    self.currentURL = webView.URL.absoluteString;
    
}
#pragma mark - 当内容开始返回时调用
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}

#pragma mark - 页面加载完成之后调用
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSString *JsStr = @"(document.getElementsByTagName(\"img\")[1]).src";
    //    NSString *JsStr = @"document.getElementsByTagName(\"head\")[0].innerHTML";
    
    [webView evaluateJavaScript:JsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if(![response isEqual:[NSNull null]] && response != nil){
            //截获到视频地址了
            NSLog(@"response == %@",response);
            self.iconUrl = response;
            
        }else{
            //没有视频链接
        }
    }];
    [self.indicator stopAnimating];
    [self configCloseNavigationBar];
    
    
    
    
}


#pragma mark -- 页面加载失败时调用
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.indicator stopAnimating];
}

// 类似 UIWebView的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([strRequest containsString:@"itunes.apple.com"]) { //如果是苹果商店链接，直接跳转到appstore
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strRequest]];
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    }
    
    else if([strRequest isEqualToString:@"about:blank"] ) {
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    } else {//截获页面里面的链接点击
        self.urlString = strRequest;
        decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    }
    //需要判断targetFrame是否为nil，如果为空则重新请求
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    //decisionHandler(WKNavigationActionPolicyAllow);
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - WKUIDelegate

// 提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {//获取网页加载进度
        
        if (object == _webView) {
            //NSLog(@"_webView.estimatedProgress:%lf",_webView.estimatedProgress);
            [self.progressView setAlpha:1.0f];
            BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
            [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
            
            // Once complete, fade out UIProgressView
            if(self.webView.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:1.0f animated:YES];
                }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //    if ([keyPath isEqualToString:@"favicon.ico"]) {
    //        if (object == _webView) {
    //            NSLog(@"%@",keyPath);
    //        }
    //    }
    else if ([keyPath isEqualToString:@"title"] && !self.isHaveTitle) //获取网页标题
    {
//        if (object == _webView) {
//            self.title = _webView.title;
//        }
//        else
//        {
//            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//        }
        self.title = @"隐私政策";
    }
}



- (void)configCloseNavigationBar
{
    UIButton * rightBtnLook = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 35)];
    [rightBtnLook setTitle:@"关闭" forState:UIControlStateNormal];
    rightBtnLook.titleLabel.font =[UIFont systemFontOfSize:16];
    [rightBtnLook addTarget:self action:@selector(backpop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightButtonLook = [[UIBarButtonItem alloc]initWithCustomView:rightBtnLook];
    
        _webView.scrollView.bounces = NO;
        self.navigationItem.rightBarButtonItems = @[rightButtonLook];
}

- (void)canback {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else {
        [self backpop];
    }
}

- (void)backpop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareTOFriendCircle
{
    
}

#pragma mark - 懒加载

-(WKWebView *)webView {
    if (_webView == nil) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.preferences                                       = [[WKPreferences alloc] init];
        config.preferences.minimumFontSize                       = 10;
        config.preferences.javaScriptEnabled                     = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // 允许在线播放
        config.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        config.selectionGranularity = YES;
        config.mediaPlaybackRequiresUserAction = YES;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
            config.requiresUserActionForMediaPlayback = YES;
            //允许视频播放
            config.allowsAirPlayForMediaPlayback = YES;
        }
        
        config.processPool                                       = [[WKProcessPool alloc] init];
        //        LoginData *loginData  = [[NTESLoginManager sharedManager] currentLoginData];
        //        NSString *cookieValue = [NSString stringWithFormat:@"document.cookie = 'user_id=%@';",loginData.user_id];
        //        WKUserContentController *userContentController = WKUserContentController.new;
        //        WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookieValue
        //                                                             injectionTime:WKUserScriptInjectionTimeAtDocumentStart
        //                                                          forMainFrameOnly:NO];
        //        [userContentController addUserScript:cookieScript];
        //        config.userContentController = userContentController;
        
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-88) configuration:config];
        [_webView setAllowsBackForwardNavigationGestures:true];
        //        _webView.hasOnlySecureContent = YES;
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        
        //[self addAllScriptMsgHandle];
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [_webView sizeToFit];
        
    }
    return _webView;
}

-(UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor greenColor];
    }
    return _progressView;
}

-(UIActivityIndicatorView *)indicator {
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = _webView.center;
        [_webView addSubview:_indicator];
    }
    return _indicator;
}

-(void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_progressView removeFromSuperview];
    _progressView = nil;
    [_webView setNavigationDelegate:nil];
    [_webView setUIDelegate:nil];
    [_webView removeFromSuperview];
    _webView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

