//
//  UIWebViewHttpStatusCodeHandlingViewController.m
//  UIWebViewHttpStatusCodeHandling
//
//  Created by Ahmet Ardal on 8/18/11.
//  Copyright 2011 SpinningSphere Labs. All rights reserved.
//

#import "UIWebViewHttpStatusCodeHandlingViewController.h"

@interface UIWebViewHttpStatusCodeHandlingViewController(Private)
- (void) log:(NSString *)message;
@end

@implementation UIWebViewHttpStatusCodeHandlingViewController

@synthesize webView, logsTextView, url;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) {
        return self;
    }

    self.url = @"https://plus.google.com/photos/117695031573406098203/albums/5642126738667211649";
    _sessionChecked = NO;

    return self;
}

- (void) dealloc
{
    [self.webView release];
    [self.logsTextView release];
    [self.url release];
    [super dealloc];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma -
#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.logsTextView.font = [UIFont fontWithName:@"Courier-Bold" size:16];
    self.logsTextView.backgroundColor = [UIColor blackColor];
    self.logsTextView.textColor = [UIColor whiteColor];

    [self log:@"start loading request."];

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:req];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma -
#pragma Private Methods

- (void) log:(NSString *)message
{
    NSString *newText = [self.logsTextView.text stringByAppendingFormat:@"> %@\n", message];
    [self.logsTextView setText:newText];
    [self.logsTextView scrollRangeToVisible:NSMakeRange((self.logsTextView.text.length - 2), 1)];
}


#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (BOOL)           webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType
{
    if (_sessionChecked) {
        [self log:@"session already checked."];
        return YES;
    }

    [self log:@"will check session."];

    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    if (conn == nil) {
        NSLog(@"cannot create connection");
    }
    return NO;
}

- (void) webViewDidStartLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"webView:didFailLoadWithError - %@", error);
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"connection:didReceiveResponse");
    [self log:@"received response."];

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        _sessionChecked = YES;

        NSString *newUrl = @"";
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];

        if (status == 403) {
            NSLog(@"not authenticated. http status code: %d", status);
            [self log:[NSString stringWithFormat:@"not authenticated. http status code: %d", status]];
            newUrl = [NSString stringWithFormat:
                      @"https://www.google.com/accounts/ServiceLogin?continue=%@", self.url];
        }
        else {
            NSLog(@"authenticated. http status code: %d", status);
            [self log:[NSString stringWithFormat:@"authenticated. http status code: %d", status]];
            newUrl = self.url;
        }

        // cancel the connection. we got what we want from the response,
        // no need to download the response data.
        [connection cancel];

        // start loading the new request in webView
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:newUrl]];
        [self.webView loadRequest:req];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection:didReceiveData");
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection:didFailWithError - %@", error);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
}

@end
