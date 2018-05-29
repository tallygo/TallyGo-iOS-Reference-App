//
//  ReportDriverMotionViewController.m
//  Reference App
//
//  Created by David Deller on 5/29/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ReportDriverMotionViewController.h"

@import MapKit;

@interface ReportDriverMotionViewController ()

@property (nonatomic, weak) IBOutlet UILabel *serverURLLabel;

@property (nonatomic, strong, nullable) TGTurnByTurnViewController *turnByTurnViewController;

// Put these inside your @interface
@property (nonatomic, nullable) NSDate *collectBeginTime;
@property (nonatomic, nonnull) NSMutableArray<TGPoint *> *collectedLocations;

@end

@implementation ReportDriverMotionViewController

// Put these inside your @implementation
// You can change these configuration values to suit your needs.
static NSString *const reportMotionURL = @"http://localhost:3200/drivers/motion";
static NSString *const reportMotionMethod = @"POST";
static NSTimeInterval const collectInterval = 30;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectedLocations = NSMutableArray.new;
    
    NSURL *URL = [NSURL URLWithString:reportMotionURL];
    self.serverURLLabel.text = [NSString stringWithFormat:@"%@://%@:%@", URL.scheme, URL.host, URL.port];
}

- (IBAction)go:(id)sender {
    [self startTurnByTurn];
}

- (void)startTurnByTurn {
    TallyGo.simulatedCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    
    // Get these coordinates from your app, these are just a sample
    CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(34.011441, -118.494932); // Santa Monica Pier
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.origin = origin;
    config.destination = destination;
    config.commencementSpeech = @"Let's go!";
    config.proceedToRouteSpeech = @"Please proceed to the route.";
    config.arrivalSpeech = @"You have arrived.";
    
    // If you’d rather skip the preview and jump straight into directions, you can do that:
    TGTurnByTurnViewController *viewController = [TGTurnByTurnViewController createWithConfiguration:config];
    [self presentViewController:viewController animated:YES completion:nil];
    
    self.turnByTurnViewController = viewController;
    [self setupReporting];
}

- (void)setupReporting {
    [NSNotificationCenter.defaultCenter addObserverForName:TGTelemetryCurrentPointChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        TGPoint *newPoint = notification.userInfo[TGTelemetryUserInfoToPoint];
        if (newPoint == nil) {
            return;
        }
        
        [self collectLocation:newPoint];
    }];
}

- (void)collectLocation:(nonnull TGPoint *)point {
    if (self.collectBeginTime == nil) {
        self.collectBeginTime = NSDate.date;
        
    } else if ([NSDate.date timeIntervalSinceDate:self.collectBeginTime] >= collectInterval) {
        [self reportMotion];
        self.collectedLocations = NSMutableArray.new;
        self.collectBeginTime = NSDate.date;
    }
    
    [self.collectedLocations addObject:point];
}

- (void)reportMotion {
    NSMutableArray<NSArray<NSNumber *> *> *serializedPoints = NSMutableArray.new;
    for (TGPoint *location in self.collectedLocations) {
        NSArray<NSNumber *> *coordinateArray = @[@(location.coordinate.latitude), @(location.coordinate.longitude)];
        
        [serializedPoints addObject:coordinateArray];
    }
    
    NSDictionary *requestData = @{
        @"id": NSUUID.UUID.UUIDString,
        @"points": [NSArray arrayWithArray:serializedPoints],
        @"timeInterval": @(collectInterval),
    };
    
    // Configure the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reportMotionURL]];
    request.HTTPMethod = reportMotionMethod;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSError *error = nil;
    NSData *encodedData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    if (encodedData != nil) {
        request.HTTPBody = encodedData;

    } else {
        @throw error;
    }
    
    // Send the request
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error != nil) {
            NSLog(@"Error reporting driver motion: %@", error.userInfo);
            [self handleError:error viewController:self.turnByTurnViewController];

        } else {
            // Optionally, you can do something with the successful response here.
        }
    }];
    [task resume];
}

@end
