//
//  ExampleViewController.h
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleViewController : UIViewController

- (void)handleError:(nonnull NSError *)error;
- (void)handleError:(nonnull NSError *)error viewController:(nullable UIViewController *)viewController;
- (void)handleErrorWithTitle:(nonnull NSString *)title message:(nullable NSString *)message viewController:(nullable UIViewController *)viewController;

@end
