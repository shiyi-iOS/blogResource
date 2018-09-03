---
title: iOS WKWebView基本使用总结
date: 2018-06-11 10:10:21
tags: [WKWebView]
categories: [技术]
password:
photos:
---

## UIWebView废弃，迁移WKWebView

> WWDC 2018中 ，在安全方面，Session上来就宣布了一件重量级的大事，UIWebView正式被官方宣布废弃，建议开发者迁移适配到WKWebView。
> 
> 在XCode9中UIWebView还是 NS_CLASS_AVAILABLE_IOS(2_0)，而我们从最新的Xcode10再看UIWebView就已经是这个样子了

`UIKIT_EXTERN API_DEPRECATED("No longer supported; please adopt WKWebView.", ios(2.0, 12.0)) API_PROHIBITED(tvos, macos) 
@interface UIWebView : UIView <NSCoding, UIScrollViewDelegate>`

> WKWebView从诞生之初相比UIWebView有太多的优势，无论是内存泄露还是网页性能，并且WKWebView可以同时支持macOS与iOS。由于WKWebView的独特设计，网页运行在独立的进程，如果网页遇到Crash，不会影响App的正常运行。
> 
>但是WKWebView不支持JSContext，不支持NSURLProtocol，Cookie管理蛋疼等问题确实给让不少开发者不想丢弃UIWebView，但最后通牒来了还是准备着手替换吧。

下面的一些方法均是看了许多大神的博客后总结到一起的，自己并未一一验证，后续发现错误会去纠正。


## WKWebView的特点


- 性能高，稳定性好，占用的内存比较小，
- 支持JS交互
- 支持HTML5 新特性
- 可以添加进度条（然并卵，不好用，还是习惯第三方的）。
- 支持内建手势，
- 据说高达60fps的刷新频率（不卡）


## 初始化WKWebView

#### 一、先导入头文件 `#import <WebKit/WebKit.h>`

#### 二、WKWebView创建

``` objectivec

	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityDynamic;
    config.allowsInlineMediaPlayback = YES;
    WKPreferences *preferences = [WKPreferences new];
    //是否支持JavaScript
    preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //开了支持滑动返回
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

```

- WKWebViewConfiguration 用于配置WKWebView的一些属性
- WKPreferences 用于配置WKWebView视图的一些属性
- 加上`<WKNavigationDelegate, WKUIDelegate>`两个代理


#### 三、WKNavigationDelegate代理事件

``` objectivec

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"页面开始加载时调用");
}
// 当内容开始返回时调用 内容开始到达主帧时被调用（即将完成）
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"当内容开始返回时调用");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {//这里修改导航栏的标题，动态改变
    self.title = webView.title;
    NSLog(@"页面加载完成之后调用");   
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
//    NSLog(@"webView==%@",webView);
//    NSLog(@"navigationResponse==%@",navigationResponse);
    
    WKNavigationResponsePolicy actionPolicy = WKNavigationResponsePolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
    
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    self.title = webView.title;
    
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    
    if (navigationAction.navigationType == WKNavigationTypeBackForward) {//判断是返回类型
        
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮 这里可以监听左滑返回事件，仿微信添加关闭按钮。
//        self.navigationItem.leftBarButtonItems = @[self.backBtn, self.closeBtn];
        
        //可以在这里找到指定的历史页面做跳转
        //        if (webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
        //            DLog(@"%@",webView.backForwardList.backList);
        //            DLog(@"%@",webView.backForwardList.currentItem);
        //            WKBackForwardListItem * item = webView.backForwardList.currentItem;          //得到现在加载的list
        //            for (WKBackForwardListItem * backItem in webView.backForwardList.backList) { //循环遍历，得到你想退出到
        //                //添加判断条件
        //                [webView goToBackForwardListItem:[webView.backForwardList.backList firstObject]];
        //            }
        //        }
    }
    
    NSLog(@"webView.backForwardList.backList.count==%lu",(unsigned long)webView.backForwardList.backList.count);
    
    if (webView.backForwardList.backList.count > 0) {
        self.navigationItem.leftBarButtonItems = @[self.backBtn, self.closeBtn];
    }else {
        self.navigationItem.leftBarButtonItems = nil;
    }
    
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

//MARK: 以下为不常用的

// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求之后再执行");
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面加载失败时调用");
}

//在提交的主帧中发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"在提交的主帧中发生错误时调用");
}

//当webView需要响应身份验证时调用(如需验证服务器证书)
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable   credential))completionHandler {
//    NSLog(@"当webView需要响应身份验证时调用(如需验证服务器证书)");
//    completionHandler(nil,nil);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
    }
}

//当webView的web内容进程被终止时调用。(iOS 9.0之后)
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    NSLog(@"当webView的web内容进程被终止时调用。(iOS 9.0之后)");
}

```

#### 四、WKUIDelegate代理事件,主要实现与js的交互

``` objectivec

//显示一个JS的Alert（与JS交互） 在JS端调用alert函数时，会触发此代理方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    NSLog(@"弹窗alert====message==%@==frame==%@",message,frame);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alert addAction:a2];

    [self presentViewController:alert animated:YES completion:nil];
    
//    completionHandler();

}

//弹出一个输入框（与JS交互的）JS端调用prompt函数时，会触发此方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    NSLog(@"弹窗输入框==prompt==%@==defaultText==%@==frame==%@",prompt,defaultText,frame);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //这里必须执行不然页面会加载不出来
        completionHandler(@"");
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",[alert.textFields firstObject].text);
        completionHandler([alert.textFields firstObject].text);
    }];
    [alert addAction:a1];
    [alert addAction:a2];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"textField.text==%@",textField.text);
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}

//显示一个确认框（JS的） JS端调用confirm函数时，会触发此方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    NSLog(@"弹窗确认框==message==%@==frame==%@",message,frame);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

```

#### 五、JS调用OC方法

- 在JS中调用方法为：

` window.webkit.messageHandlers.方法名.postMessage(参数); `

- 在OC中：

``` objectivec

    //设置addScriptMessageHandler与name.并且设置<WKScriptMessageHandler>协议与协议方法
    [[_webView configuration].userContentController addScriptMessageHandler:self name:@"takePicturesByNative"];

	//在dealloc方法中需要释放掉
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"takePicturesByNative"];


```

- 在WKScriptMessageHandler中：

``` objectivec

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"takePicturesByNative"]) {
        [self takePicturesByNativeWithBody:message.body];
    }
}
- (void)takePicturesByNativeWithBody:(NSString *)body {
    NSLog(@"调用了takePicturesByNative方法");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:body preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:a1];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

```

在使用上述方法中发现，`addScriptMessageHandler:self`中发生了循环引用，造成webview不会被释放掉，故经测试有以下两种解决方案：


**1.新建个WeakScriptMessageDelegate类**

	
``` objectivec

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WeakScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic, assign) id<WKScriptMessageHandler> scriptDelegate;

+ (instancetype)scriptWithDelegate:(id<WKScriptMessageHandler>)delegate;

@end

```

``` objectivec

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

+ (instancetype)scriptWithDelegate:(id<WKScriptMessageHandler>)delegate {
    return [[WeakScriptMessageDelegate alloc]initWithDelegate:delegate];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

```

	设置addScriptMessageHandler方法更换为：
	
``` objectivec

[[_webView configuration].userContentController addScriptMessageHandler:[WeakScriptMessageDelegate scriptWithDelegate:self] name:@"takePicturesByNative"];

```

**2.不在初始化时添加ScriptMessageHandler， 而是和Notificenter/KVC一个思路**


``` objectivec

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"takePicturesByNative"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"takePicturesByNative"];

}

```

#### 六、OC调用JS方法

``` objectivec

    //设置JS
//    NSString *inputValueJS = @"document.getElementsByName('input')[0].attributes['value'].value";
//    NSString *inputValueJS = @"shareCallback()";
    NSString *inputValueJS = @"js代码";

    //执行JS
    [webView evaluateJavaScript:inputValueJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"value: %@ error: %@", response, error);
    }];

```

#### 七、给webview添加请求头

``` objectivec

    NSString *urlString = @"https://www.baidu.com/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"123" forHTTPHeaderField:@"token"];
    [self.webView loadRequest:request];

```

``` objectivec

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;

    //同步HTTPHeaderFields里的参数
    
    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
    //我们项目使用的token同步的，cookie的话类似
    if (requestHeaders[@"token"]) {
        decisionHandler(actionPolicy);//允许跳转
    }else {
        //这里添加请求头，把需要的都添加进来
        [mutableRequest setValue:@"123" forHTTPHeaderField:@"token"];
        
        [webView loadRequest:mutableRequest];
        decisionHandler(actionPolicy);//允许跳转
    }
    
}

```

> **注：**在UIWeb里边是直接用的request 但是在这里需要写上navigationAction.出来的request

#### 八、WKWebView加载不受信任的https

**解决方法：**在plist文件中设置Allow Arbitrary Loads in Web Content 置为 YES,并实现wkwebView下面的代理方法,就可解决 

``` objectivec

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{  
      
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {  
          
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];  
          
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);  
          
    }  
}  

```

#### 九、监听WKWebView的进度条和标题


``` objectivec

    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    //需要注意的是销毁的时候一定要移除监控
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];

```

``` objectivec

@property (nonatomic, weak) CALayer *progressLayer;

    UIView *progress = [[UIView alloc]init];
    progress.frame = CGRectMake(0, 0, KScreenWidth, 3);
    progress.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:progress];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor greenColor].CGColor;
    [progress.layer addSublayer:layer];
    self.progressLayer = layer;

```

``` objectivec

#pragma mark - KVO回馈

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] <[change[@"old"] floatValue]) {
            return;
        }
        self.progressLayer.frame = CGRectMake(0, 0, KScreenWidth*[change[@"new"] floatValue], 3);
        if ([change[@"new"]floatValue] == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else if ([keyPath isEqualToString:@"title"]){
        self.title = change[@"new"];
    }
    
}

```

#### 十、解决cookie问题

> 以前UIWebView会自动去NSHTTPCookieStorage中读取cookie，但是WKWebView并不会去读取,因此导致cookie丢失以及一系列问题，解决方式就是在request中手动帮其添加上。

 
``` objectivec

self.webView.UIDelegate = self;
self.webView.navigationDelegate = self;
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.test.com"]];
[request addValue:[self readCurrentCookieWithDomain:@"http://www.test.com/"] forHTTPHeaderField:@"Cookie"];
[self.webView loadRequest:request];

- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }

//删除最后一个“；”
    [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    return cookieString;
}

```

但是这只能解决第一次进入的cookie问题，如果页面内跳转（a标签等）还是取不到cookie，因此还要再加代码。

``` objectivec

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

   //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
@"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";

    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
    NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [webView evaluateJavaScript:JSCookieString completionHandler:nil];

}

```

#### 十一、加载页面后自动关闭的问题

> 问题描述，我加载一web页面后，进行各种操作，比说我充值，什么的，然后想要在充值提出成功后自顶关闭这个web页面回到上一层或者返回到某一个界面，就用下面的方法，一般判断URL 包含的字符串都是后台给定的，在这里只需要判断就好了！

 
``` objectivec

//**WKNavigationDelegate**里面的代理方法（上面有）
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    //获取请求的url路径.
    NSString *requestString = navigationResponse.response.URL.absoluteString;
    WKLog(@"requestString:%@",requestString);
    // 遇到要做出改变的字符串
    NSString *subStr = @"www.baidu.com";
    if ([requestString rangeOfString:subStr].location != NSNotFound) {
        WKLog(@"这个字符串中有subStr");
        //回调的URL中如果含有百度，就直接返回，也就是关闭了webView界面
        [self.navigationController  popViewControllerAnimated:YES];
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);

}

```

#### 十二、清除缓存


``` objectivec
//清除本地缓存
- (void)clearCache {
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/ NSString *bundleId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    /* * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    NSError *error;
    /* 取得目录下所有的文件，取得文件数组*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:webKitFolderInCachesfs error:&error];
    /* 遍历文件组成的数组*/
    for(NSString * fileName in fileList)
    {
        /* 定位每个文件的位置*/
        NSString * path = [[NSBundle bundleWithPath:webKitFolderInCachesfs] pathForResource:fileName ofType:@""];
        /* 将文件转换为NSData类型的数据*/
        NSData * fileData = [NSData dataWithContentsOfFile:path];
        /* 如果FileData的长度大于2，说明FileData不为空*/
        if(fileData.length >2)
        {
            /* 创建两个用于显示文件类型的变量*/
            int char1 =0;
            int char2 =0;
            [fileData getBytes:&char1 range:NSMakeRange(0,1)];
            [fileData getBytes:&char2 range:NSMakeRange(1,1)];
            /* 拼接两个变量*/ NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
            /* 如果该文件前四个字符是6033，说明是Html文件，删除掉本地的缓存*/
            if([numStr isEqualToString:@"6033"])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",webKitFolderInCachesfs,fileName]error:&error]; continue;
                
            }
        }
    }
}

```

``` objectivec

- (void)cleanCacheAndCookie {
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    if (@available(iOS 9.0, *)) {
        
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records)
         {
             for (WKWebsiteDataRecord *record  in records)
             {
                 
                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                           forDataRecords:@[record]
                                                        completionHandler:^
                  {
                      NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                  }];
             }
         }];

    }
    
}

```

``` objectivec

- (void)dealloc {
    
    [_webView stopLoading];
    [_webView setNavigationDelegate:nil];
    [self clearCache];
    [self cleanCacheAndCookie];
    
}


```


附：demo中使用的返回上一页和关闭浏览器的方法

```

#pragma mark - Actions

- (void)backNative {
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
//        self.navigationItem.leftBarButtonItems = @[self.backBtn, self.closeBtn];
    }else {
        [self closeNative];
    }
}

- (void)closeNative {
    
    if (self.webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
        NSLog(@"backList==%@",self.webView.backForwardList.backList);
        NSLog(@"currentItem==%@",self.webView.backForwardList.currentItem);
        
        [self.webView goToBackForwardListItem:[self.webView.backForwardList.backList firstObject]];

//        WKBackForwardListItem * item = self.webView.backForwardList.currentItem;          //得到现在加载的list
//        for (WKBackForwardListItem * backItem in self.webView.backForwardList.backList) { //循环遍历，得到你想退出到
//            //添加判断条件
//            [self.webView goToBackForwardListItem:[self.webView.backForwardList.backList firstObject]];
//        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

```