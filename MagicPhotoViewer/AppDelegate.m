//
//  AppDelegate.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ViewController *vc = [ViewController new];
    [self.window setRootViewController:vc];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Lazy initialization

- (UIWindow *)window
{
    if (!_window)
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        _window = [[UIWindow alloc] initWithFrame:rect];
    }
    return _window;
}

@end
