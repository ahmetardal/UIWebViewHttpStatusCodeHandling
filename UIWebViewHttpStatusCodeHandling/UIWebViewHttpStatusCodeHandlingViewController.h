//
//  UIWebViewHttpStatusCodeHandlingViewController.h
//  UIWebViewHttpStatusCodeHandling
//
//  Created by Ahmet Ardal on 8/18/11.
//  Copyright 2011 SpinningSphere Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewHttpStatusCodeHandlingViewController: UIViewController<UIWebViewDelegate>
{
    UIWebView *webView;
    UITextView *logsTextView;

    NSString *url;
    BOOL _sessionChecked;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UITextView *logsTextView;
@property (nonatomic, retain) NSString *url;

@end
