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
@synthesize noConnectionLabel = _noConnectionLabel;
@synthesize noConnectionView = _noConnectionView;

- (void)dealloc
{
    [_noConnectionView release];
    [_noConnectionLabel release];
    [_indicator release];
    [_webView release];
    _webView.delegate = nil;
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = @"Log in";
    [KSNetworkStatusHelper sharedInstance].delegate = self;
    
    if([KSNetworkStatusHelper isInternetActive])
    {
        [_noConnectionView setHidden:YES];
        [_webView setHidden:NO];
        [_indicator setHidden:NO];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:kAccessToken] != nil || [[defaults objectForKey:kAccessToken] length] > 0 )
        {
            self.navigationItem.title = @"Log out";
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
    else
    {
        [_noConnectionView setHidden:NO];
        [_webView setHidden:YES];
        [_indicator setHidden:YES];
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
        self.navigationItem.title = @"Log out";
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

#pragma mark - NetworkStatusDelegate

- (void)statusWasChanged:(KSNetworkStatusHelper *)helper
{
    [self viewDidAppear:YES];
}

@end
