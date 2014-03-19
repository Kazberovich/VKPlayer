//
//  KSViewController.m
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSViewController.h"
#import "KSURLBuilder.h"

@interface KSViewController ()

@end

@implementation KSViewController

@synthesize indicator = _indicator;
@synthesize webView = _webView;

- (void) dealloc
{
    [_indicator release];
    [_webView release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];    
    NSLog(@"%@", [KSURLBuilder getAuthorizeURL]);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[KSURLBuilder getAuthorizeURL]]];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest, %@", [request description]);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.indicator startAnimating];
    NSLog(@"");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError, %@", [error description]);
    [self.indicator stopAnimating];
}

@end
