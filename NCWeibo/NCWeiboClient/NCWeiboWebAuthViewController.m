//
//  NCWeiboWebAuthViewController.m
//  NCWeibo
//
//  Created by nickcheng on 13-3-31.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCWeiboWebAuthViewController.h"
#import "MBProgressHUD.h"
#import "NCWeiboAuthentication.h"
#import "NCWeiboClientConfig.h"

@interface NCWeiboWebAuthViewController () <UIWebViewDelegate, MBProgressHUDDelegate>
@end

@implementation NCWeiboWebAuthViewController {
  UIWebView *_webView;
  UIBarButtonItem *_cancelButton;
  UIBarButtonItem *_stopButton;
  UIBarButtonItem *_refreshButton;
  MBProgressHUD *_hud;

  NCWeiboAuthentication *_authentication;
  BOOL _closed;
  
  NCWeiboAuthCancellationBlock _authCancellationBlock;
  NCWeiboAuthCompletionBlock _authCompletionBlock;
}

#pragma mark -
#pragma mark Init

-(id)initWithAuthentication:(NCWeiboAuthentication *)authentication andCancellation:(NCWeiboAuthCancellationBlock)cancellation andCompletion:(NCWeiboAuthCompletionBlock)completion {
  //
	if((self = [super init]) == nil) return nil;
  
  // Custom initialization
  _authentication = authentication;
  _authCancellationBlock = cancellation;
  _authCompletionBlock = completion;

  _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
  _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
  _stopButton.style = UIBarButtonItemStylePlain;
  _refreshButton.style = UIBarButtonItemStylePlain;
  
  return self;
}

#pragma mark -
#pragma mark Button Events

- (void)cancel:(id)sender {
  //
  [_hud hideAnimated:YES];
  _closed = YES;
  
  //
  [self dismissViewControllerAnimated:YES completion:^{
    //
    if (_authCancellationBlock)
      _authCancellationBlock(_authentication);
  }];
}

- (void)stop:(id)sender {  
}

- (void)refresh:(id)sender {
  _closed = NO;
  NSURL *url = [NSURL URLWithString:_authentication.authorizeURL];
  NCLogInfo(@"request url: %@", url);
  NSURLRequest *request =[NSURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                      timeoutInterval:60.0f];
  [_webView loadRequest:request];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = NSLocalizedString(@"ncweibo.webauth.loadingmessage", @"加载中...(NCWeibo.WebAuth.LoadingMessage)");
    self.navigationItem.rightBarButtonItem = _stopButton;
    
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view.window];
        [self.view.window addSubview:_hud];
        
        _hud.delegate = self;
        _hud.label.text = NSLocalizedString(@"ncweibo.webauth.loadingmessage", @"加载中...(NCWeibo.WebAuth.LoadingMessage)");
        [_hud showAnimated:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  self.navigationItem.rightBarButtonItem = _refreshButton;
  [_hud hideAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  if (error.code != NSURLErrorCancelled && !_closed) {
    self.title = NSLocalizedString(@"ncweibo.webauth.loadingfailed", @"网页加载失败(NCWeibo.WebAuth.LoadingFailed)");
    self.navigationItem.rightBarButtonItem = _refreshButton;
    _hud.label.text = NSLocalizedString(@"ncweibo.webauth.loadingfailed", @"网页加载失败(NCWeibo.WebAuth.LoadingFailed)");
    [_hud hideAnimated:YES afterDelay:2];
  }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NCLogInfo(@"%@", request.URL.absoluteString);
  NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
  
  if (range.location != NSNotFound) {
    NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
    NCLogInfo(@"code: %@", code);
    
    [_hud hideAnimated:YES];
    _closed = YES;
    [self dismissViewControllerAnimated:YES completion:^{
      //
      _authentication.authorizationCode = code;
      if (_authCompletionBlock)
        _authCompletionBlock(YES, _authentication, nil);
    }];
  }
  
  return YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	hud = nil;
}

#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	// Do any additional setup after loading the view.
  _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  _webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
  | UIViewAutoresizingFlexibleTopMargin
  | UIViewAutoresizingFlexibleRightMargin
  | UIViewAutoresizingFlexibleBottomMargin
  | UIViewAutoresizingFlexibleWidth
  | UIViewAutoresizingFlexibleHeight;
  _webView.delegate = self;
  [self.view addSubview:_webView];
  
  NSString *html = [NSString stringWithFormat:@"<html><body><div align=center>%@</div></body></html>", NSLocalizedString(@"ncweibo.webauth.loadingmessage", @"加载中...(NCWeibo.WebAuth.LoadingMessage)")];
  [_webView loadHTMLString:html baseURL:nil];
  
  self.navigationItem.leftBarButtonItem = _cancelButton;
  self.navigationItem.rightBarButtonItem = _refreshButton;
  
  [self refresh:nil];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
