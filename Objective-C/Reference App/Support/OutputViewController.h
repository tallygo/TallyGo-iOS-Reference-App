//
//  OutputViewController.h
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ExampleViewController.h"

@interface OutputViewController : ExampleViewController

- (void)handleOutput:(nonnull id)output;
- (void)clearOutput;
- (void)printOutput:(nullable NSString *)output;

@end
