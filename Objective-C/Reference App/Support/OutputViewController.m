//
//  OutputViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "OutputViewController.h"

@import TallyGoKit;
@import MapKit;

@interface OutputViewController ()

@property (nonatomic, weak) IBOutlet UITextView *outputView;

@end

@implementation OutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.outputView.layer.borderWidth = 0.5;
    self.outputView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
    self.outputView.layer.cornerRadius = 4;
}

#pragma mark -

- (void)handleOutput:(id)output {
    if ([output isKindOfClass:NSValue.class] && CLLocationCoordinate2DIsValid(((NSValue *)output).MKCoordinateValue)) {
        CLLocationCoordinate2D location = ((NSValue *)output).MKCoordinateValue;
        [self printOutput:[NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude]];
        
    } else if ([output isKindOfClass:NSArray.class] && [((NSArray *)output).firstObject isKindOfClass:TGSearchResult.class]) {
        NSArray<TGSearchResult *> *searchResults = output;
        NSMutableString *resultsText = NSMutableString.new;
        for (TGSearchResult *searchResult in searchResults) {
            [resultsText appendString:searchResult.placeAddress];
            [resultsText appendString:@"\n"];
        }
        
        [self printOutput:[NSString stringWithString:resultsText]];
        
    } else if ([output isKindOfClass:TGSearchResult.class]) {
        TGSearchResult *searchResult = output;
        NSString *resultText = searchResult.placeAddress;
        
        [self printOutput:resultText];
        
    } else if ([output isKindOfClass:TGRoute.class]) {
        TGRoute *route = output;
        NSMutableString *routeText = NSMutableString.new;
        for (TGRouteSegment *segment in route.segments) {
            for (TGPoint *point in segment.points) {
                if (point.turn == nil) {
                    continue;
                }
                
                NSString *pointText = [NSString stringWithFormat:@"%@ on %@\n", point.turn.direction, point.turn.street.name];
                [routeText appendString:pointText];
            }
        }
        
        [self printOutput:[NSString stringWithString:routeText]];
        
    } else {
        [self handleErrorWithTitle:@"Unable to handle output format" message:nil viewController:nil];
    }
}

- (void)clearOutput {
    self.outputView.text = @"";
}

- (void)printOutput:(NSString *)output {
    if (output != nil) {
        self.outputView.text = output;
    } else {
        [self clearOutput];
    }
}

@end
