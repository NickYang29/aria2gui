//
//  AppDelegate.h
//  MG
//
//  Created by Tim Debo on 5/19/14.
//
//

#import <Cocoa/Cocoa.h>


@class WindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSUserNotificationCenterDelegate>

@property (retain, nonatomic) WindowController *windowController;

- (IBAction)openPreferences:(id)sender;




@end
