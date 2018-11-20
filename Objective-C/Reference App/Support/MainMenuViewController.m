//
//  MainMenuViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Clean up by resetting any settings from examples back to defaults
    TGDrivingSimulator.sharedDrivingSimulator.enabled = NO;
}

@end
