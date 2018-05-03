//
//  InputOutputViewController.h
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "OutputViewController.h"

@interface InputOutputViewController : OutputViewController <UITextFieldDelegate>

- (void)handleInput:(nonnull NSString *)input;

@end
