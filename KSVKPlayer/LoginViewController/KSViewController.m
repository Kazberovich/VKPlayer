//
//  KSViewController.m
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSViewController.h"
#import "KSURLBuilder.h"
#import <AFHTTPRequestOperation.h>
#import "KSAccessToken.h"

@interface KSViewController ()

@end

@implementation KSViewController

@synthesize indicator = _indicator;
@synthesize webView = _webView;

- (void) dealloc
{
    [_indicator release];
    [_webView release];
    _webView.delegate = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];    
    NSLog(@"%@", [KSURLBuilder getAuthorizeURL]);
    
    // clear cookies
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* tmdbCookies = [cookies cookiesForURL:
                            [NSURL URLWithString:[KSURLBuilder getAuthorizeURL]]];
    
    for (NSHTTPCookie* cookie in tmdbCookies) {
        [cookies deleteCookie:cookie];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[KSURLBuilder getAuthorizeURL]]];
    
    _webView.delegate = self;
    
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
    
    if ([[[request URL] absoluteString] rangeOfString:@"access_token"].location == NSNotFound)
    {
        NSLog(@"not authorized");
        return YES;
    } else
    {
        NSLog(@"authorized");
        NSString *query = [[request URL] description];
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if(array.count > 1)
        {
            query = array.lastObject;
        }
        
        KSAccessToken *token = [[KSAccessToken alloc] init];
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs) {
            
            NSArray *values = [pair componentsSeparatedByString:@"="];
            
            if (values.count == 2) {
                NSString *key = [values firstObject];
                {
                    if([key isEqualToString:@"access_token"])
                    {
                        token.token = [values lastObject];
                    }
                    else if ([key isEqualToString:@"expires_in"])
                    {
                        NSTimeInterval interval = [[values lastObject] doubleValue];
                        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    }
                    else if ([key isEqualToString:@"user_id"])
                    {
                        token.userID = [values lastObject];
                    }
                   
                }
            }
        }
        
        NSLog(@"%@  %@  %@", token.userID, token.token, token.expirationDate);
        return YES;
    }
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
