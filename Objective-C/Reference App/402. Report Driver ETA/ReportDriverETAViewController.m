//
//  ReportDriverETAViewController.m
//  Reference App
//
//  Created by David Deller on 5/3/18.
//  Copyright © 2018 TallyGo. All rights reserved.
//

#import "ReportDriverETAViewController.h"

@interface ReportDriverETAViewController ()

@property (nonatomic, weak) IBOutlet UILabel *serverURLLabel;

@property (nonatomic, strong, nullable) TGTurnByTurnViewController *turnByTurnViewController;

// Put these inside your @interface
// Keep track of when and what we last reported.
@property (nonatomic, nullable) NSDate *lastReportedETA;
@property (nonatomic, nullable) NSDate *lastReportedETATime;

@property (nonatomic, nonnull) NSString *temporaryID;

@end

@implementation ReportDriverETAViewController

// Put these inside your @implementation
// You can change these configuration values to suit your needs.
static NSTimeInterval const reportETADeltaTrigger = 60;
static NSTimeInterval const reportETATimeTrigger = (5 * 60);
static NSString *const reportETAURL = @"http://localhost:3200/drivers/eta";
static NSString *const reportETAMethod = @"PUT";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:reportETAURL];
    self.serverURLLabel.text = [NSString stringWithFormat:@"%@://%@:%@", URL.scheme, URL.host, URL.port];
    
    self.temporaryID = NSUUID.UUID.UUIDString;
}

- (IBAction)go:(id)sender {
    [self startTurnByTurn];
}

- (void)startTurnByTurn {
    TGDrivingSimulator.sharedDrivingSimulator.startingCoordinate = CLLocationCoordinate2DMake(34.101558, -118.340944); // Grauman's Chinese Theatre
    TGDrivingSimulator.sharedDrivingSimulator.enabled = YES;
    
    // Get these coordinates from your app, these are just a sample
    TGWaypoint *origin = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.101558, -118.340944)]; // Grauman's Chinese Theatre
    TGWaypoint *destination = [TGWaypoint.alloc initWithCoordinate:CLLocationCoordinate2DMake(34.011441, -118.494932)]; // Santa Monica Pier
    
    // Configure turn-by-turn navigation
    TGTurnByTurnConfiguration *config = [TGTurnByTurnConfiguration new];
    config.showsOriginIcon = NO;
    config.originWaypoint = origin;
    config.destinationWaypoint = destination;
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
        NSDate *newETA = notification.userInfo[TGTelemetryUserInfoETA];
        if (newETA == nil) {
            return;
        }
        
        [self reportETA:newETA];
    }];
}

- (void)reportETA:(nonnull NSDate *)ETA {
    // We should only continue if we haven't reported yet, or if one of our triggers has been satisfied.
    if (self.lastReportedETA != nil &&
        self.lastReportedETATime != nil &&
        fabs([ETA timeIntervalSinceDate:self.lastReportedETA]) <= reportETADeltaTrigger &&
        [NSDate.date timeIntervalSinceDate:self.lastReportedETATime] <= reportETATimeTrigger) {
        
        return;
    }
    
    NSISO8601DateFormatter *formatter = [NSISO8601DateFormatter new];
    formatter.formatOptions = NSISO8601DateFormatWithInternetDateTime;
    
    // Collect the data we want to send
    NSDictionary *requestData = @{
        @"ETA": [formatter stringFromDate:ETA],
    };
    
    // Configure the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reportETAURL]];
    request.HTTPMethod = reportETAMethod;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.temporaryID forHTTPHeaderField:@"X-Temporary-ID"];
    
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
            NSLog(@"Error reporting ETA: %@", error.userInfo);
            
        } else {
            // Optionally, you can do something with the successful response here.
        }
    }];
    [task resume];
    
    // Remember that we did this
    self.lastReportedETA = ETA;
    self.lastReportedETATime = NSDate.date;
}

@end
