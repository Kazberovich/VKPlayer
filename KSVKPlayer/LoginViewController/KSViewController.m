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
#import "KSPlayerViewController.h"

#define kLoginRedirectURL @"https://login.vk.com/"

@interface KSViewController ()

@end

@implementation KSViewController

@synthesize indicator = _indicator;
@synthesize webView = _webView;

- (void)dealloc
{
    [_indicator release];
    [_webView release];
    _webView.delegate = nil;
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kAccessToken] != nil || [[defaults objectForKey:kAccessToken] length] > 0 )
    {
        KSAccessToken *token = [[KSAccessToken alloc] init];
        
        [token setUserID:[defaults objectForKey:kUserID]];
        [token setToken:[defaults objectForKey:kAccessToken]];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        KSPlayerViewController *playerViewController = (KSPlayerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"player"];
        playerViewController.token = token;
        [token release];
        [self.navigationController pushViewController:playerViewController animated:YES];
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[KSURLBuilder getAuthorizeURL]]];
        _webView.delegate = self;
        
        [self clearCookieForURL:request.URL];
        [self clearCookieForURL:[NSURL URLWithString:kLoginRedirectURL]];
        
        [self.webView loadRequest:request];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest, %@", [request description]);
    
    if ([[[request URL] absoluteString] rangeOfString:kAccessToken].location == NSNotFound)
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
                    if([key isEqualToString:kAccessToken])
                    {
                        token.token = [values lastObject];
                    }
                    else if ([key isEqualToString:kExpirationDate])
                    {
                        NSTimeInterval interval = [[values lastObject] doubleValue];
                        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    }
                    else if ([key isEqualToString:kUserID])
                    {
                        token.userID = [values lastObject];
                    }
                }
            }
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:token.token forKey:kAccessToken];
        [defaults setObject:token.userID forKey:kUserID];
        [defaults synchronize];
        
        NSLog(@"%@  %@  %@", token.userID, token.token, token.expirationDate);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        KSPlayerViewController *playerViewController = (KSPlayerViewController *)[storyboard instantiateViewControllerWithIdentifier:@"player"];
        playerViewController.token = token;
        [self.navigationController pushViewController:playerViewController animated:YES];
        
        [token release];
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError, %@", [error description]);
    [self.indicator stopAnimating];
}

- (void)clearCookieForURL:(NSURL *)url
{
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *oauthCookies = [cookies cookiesForURL:url];
    
    for (NSHTTPCookie *cookie in oauthCookies)
    {
        [cookies deleteCookie:cookie];
    }
}
@end
