//
//  BeaconMonitor.m
//  iBeaconPNFDemo
//
//  Created by Jain R on 11/7/14.
//
//

#import "BeaconMonitor.h"
#import "BackgroundTaskManager.h"
#import "DCDefines.h"

@interface BeaconMonitor ()

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion2;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion3;

@property (nonatomic, strong) ESTBeacon* nearestBeacon;
@property (nonatomic, strong) NSTimer* stimulantTimer; // This timer has the app doesn't suspend.

@end

@implementation BeaconMonitor {
    CLProximity _determinedProximity;
}

+ (BeaconMonitor *)sharedBeaconMonitor {
    static BeaconMonitor *_beaconMonitor;
    
    @synchronized(self) {
        if (_beaconMonitor == nil) {
            _beaconMonitor = [[BeaconMonitor alloc] init];
        }
    }
    return _beaconMonitor;
}

- (id)init {
    if (self==[super init]) {
        
        // register method that be called when the app receive UIApplicationDidEnterBackgroundNotification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

-(void)applicationEnterBackground{
    BackgroundTaskManager* bgTaskMgr = [BackgroundTaskManager sharedBackgroundTaskManager];
    [bgTaskMgr beginNewBackgroundTask];
}

- (void)startBeaconMonitoringWith:(NSUUID *)beaconProximityUUID regionID:(NSString *)beaconRegionID determinedProximity:(CLProximity)determinedProximity {
    self.beaconManager = [[ESTBeaconManager alloc] init];
    _beaconManager.delegate = self;
    
    // request permission to get location for iOS 8
    if([_beaconManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_beaconManager requestAlwaysAuthorization];
    }
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:beaconProximityUUID identifier:beaconRegionID];
//    _beaconRegion.notifyEntryStateOnDisplay = YES;
//    _beaconRegion.notifyOnEntry = YES; // default
//    _beaconRegion.notifyOnExit = YES; // default
    
    _determinedProximity = determinedProximity;
    
    [_beaconManager startMonitoringForRegion:_beaconRegion];
//    [_beaconManager requestStateForRegion:_beaconRegion];
//    [self startBeaconRanging];
    
//    NSUUID *jaalee1 = [[NSUUID alloc] initWithUUIDString:@"30783138-3041-47C8-9837-E7B5634DF524"];
//    self.beaconRegion2 = [[ESTBeaconRegion alloc] initWithProximityUUID:jaalee1 identifier:@"Whiteley1"];
//    [_beaconManager startMonitoringForRegion:self.beaconRegion2];
//    
//    NSUUID *jaalee2 = [[NSUUID alloc] initWithUUIDString:@"383321C2-A33A-21C8-9837-E7B5634DF524"];
//    self.beaconRegion3 = [[ESTBeaconRegion alloc] initWithProximityUUID:jaalee2 identifier:@"Whiteley2"];
//    [_beaconManager startMonitoringForRegion:self.beaconRegion3];

    
}

- (void)startBeaconRangingWith:(NSUUID *)beaconProximityUUID regionID:(NSString *)beaconRegionID determinedProximity:(CLProximity)determinedProximity {
    
//    if (beaconProximityUUID == nil)
//        self.beaconRegion = nil;
//    else
//        self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:beaconProximityUUID identifier:beaconRegionID];
//
//    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];

}

- (void)restartBeaconRanging {
    [self stopBeaconRanging];
    [self startBeaconRanging];
}

- (void)stopBeaconMonitoring {
    [self stopBeaconRanging];
    [_beaconManager stopMonitoringForRegion:_beaconRegion];
    self.beaconManager = nil;
    self.beaconRegion = nil;
    self.beaconRegion2 = nil;
    self.beaconRegion3 = nil;
}

- (void)startBeaconRanging {
    if (self.isRanging) {
        return;
    }
    
    self.isRanging = YES;
    
    self.nearestBeacon = nil;
    
    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];
    
    if (self.stimulantTimer) {
        [self.stimulantTimer invalidate];
        self.stimulantTimer = nil;
    }
    self.stimulantTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(wakeUp) userInfo:nil repeats:YES];
}

- (void)stopBeaconRanging {
    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
    
    [[BackgroundTaskManager sharedBackgroundTaskManager] endAllBackgroundTasks];
    
    if (self.stimulantTimer) {
        [self.stimulantTimer invalidate];
        self.stimulantTimer = nil;
    }
    self.nearestBeacon = nil;
    
    self.isRanging = NO;
}

- (void)startBeaconDiscovering {
    if (self.isRanging) {
        return;
    }
    
    self.isRanging = YES;
    
    self.nearestBeacon = nil;
    
    //    [_beaconManager startRangingBeaconsInRegion:_beaconRegion];
    [_beaconManager startEstimoteBeaconsDiscoveryForRegion:_beaconRegion];
    
    if (self.stimulantTimer) {
        [self.stimulantTimer invalidate];
        self.stimulantTimer = nil;
    }
    self.stimulantTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(wakeUp) userInfo:nil repeats:YES];
}

- (void)stopBeaconDiscovering {
//    [_beaconManager stopRangingBeaconsInRegion:_beaconRegion];
    [_beaconManager stopEstimoteBeaconDiscovery];
    
    [[BackgroundTaskManager sharedBackgroundTaskManager] endAllBackgroundTasks];
    
    if (self.stimulantTimer) {
        [self.stimulantTimer invalidate];
        self.stimulantTimer = nil;
    }
    self.nearestBeacon = nil;
    
    self.isRanging = NO;
}

- (void)wakeUp {
    
    if (self.isForegroundMode == NO) {
        BackgroundTaskManager* bgTaskMgr = [BackgroundTaskManager sharedBackgroundTaskManager];
        [bgTaskMgr beginNewBackgroundTask];
    }
}

- (BOOL)isForegroundMode {
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    return state == UIApplicationStateActive;
    
}

- (void) setupAppLocalSettings
{
    [self.delegate setupAppLocalSettings];
   
}
#pragma mark <ESTBeaconManagerDelegate>

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   [userDefaults setObject:@"0" forKey:WHITELEY_LOCATION_ENABLE];

    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"Authorized Always");
//            [_beaconManager startMonitoringForRegion:_beaconRegion];
            [_beaconManager requestStateForRegion:_beaconRegion];
            [userDefaults setObject:@"1" forKey:WHITELEY_LOCATION_ENABLE];
            NSString *firstOpen = [userDefaults stringForKey:WHITELEY_FIRST_OPEN];
            if(firstOpen == nil || firstOpen.length == 0)
            {
                [userDefaults setValue:@"1" forKey:WHITELEY_FIRST_OPEN];
                [self.delegate showNotifyBox];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Authorized when in use");
            break;
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"Denied");
            NSString *firstOpen = [userDefaults stringForKey:WHITELEY_FIRST_OPEN];
            if(firstOpen == nil || firstOpen.length == 0)
            {
                [userDefaults setValue:@"1" forKey:WHITELEY_FIRST_OPEN];
                [self.delegate showNotifyBox];
            }
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Not determined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Restricted");
            break;
            
        default:
            break;
    }
    [userDefaults synchronize];
    [self setupAppLocalSettings];
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region {
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region {
    if ( !self.isEasterEgg )
        [self.delegate didExitRegion:[self.nearestBeacon.proximityUUID UUIDString]];
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    
    if (beacons.count == 0) {
        if (self.nearestBeacon) {
            self.nearestBeacon = nil;
        }
    }
    else {
        
        ESTBeacon* beacon = [beacons objectAtIndex:0];
        
        if (beacon != nil) {
            self.nearestBeacon = beacon;
            if ([self.delegate respondsToSelector:@selector(beaconMonitor:didDiscoverNearestBeacon:)]) {
                [self.delegate beaconMonitor:self didDiscoverNearestBeacon:self.nearestBeacon];
            }
            [self stopBeaconDiscovering];

        }
    }
}

#if 0
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    
    // Apply delay time between ranging event
    
    static NSDate* previousTime = nil;
    
    if (previousTime == nil) {
        previousTime = [NSDate date];
        return;
    }

    if (previousTime) {

        // calculate seconds from last check time
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:previousTime toDate:[NSDate date] options:0];
        NSInteger seconds = components.second;
        
        if (seconds < CPBEACON_RANGING_INTERVAL) {
            return;
        }
        
    }
    
    previousTime = [NSDate date];

    if ([region.identifier isEqual:_beaconRegion.identifier]) {
        
        if ([self.delegate respondsToSelector:@selector(beaconMonitor:didRangeBeacons:)]) {
            NSMutableArray* valideBeacons = [NSMutableArray array];
            for (ESTBeacon* beacon in beacons) {
                if (beacon.distance.doubleValue > 0) {
                    [valideBeacons addObject:beacon];
                }
            }
            [self.delegate beaconMonitor:self didRangeBeacons:valideBeacons];
        }
    
        
//#define DEBUG_BEACON
#ifdef DEBUG_BEACON
        // header
        NSString* debugString = [NSString stringWithFormat:@"Detected Beacons %d:\n{\n", beacons.count];
        // body
        for (ESTBeacon* bcon in beacons) {
            NSString* beaconString = [NSString stringWithFormat:@"[\nUUID:%@\nMajor:%d\nMinor:%d\nProximity:%d\nRSSI:%d\nDistance:%fm\nColor:%d\nmac:%@\n]\n"
                                      , ESTIMOTE_PROXIMITY_UUID.UUIDString
                                      , bcon.major.intValue
                                      , bcon.minor.intValue
                                      , bcon.proximity
                                      , bcon.rssi
                                      , bcon.distance.floatValue
                                      , bcon.color
                                      , bcon.macAddress
                                      ];
            
            debugString = [debugString stringByAppendingString:beaconString];
        }
        // footer
        debugString = [debugString stringByAppendingString:@"\n}"];
        NSLog(@"%@", debugString);
#endif
        
        BOOL isChanged = NO;
        
        if (beacons.count == 0) {
            if (self.nearestBeacon) {
                self.nearestBeacon = nil;
                isChanged = YES;
            }
        }
        else {
            ESTBeacon* beacon = [beacons objectAtIndex:0];
            if (beacon.distance.doubleValue > 0) {
                if (self.nearestBeacon == nil || [self.nearestBeacon isEqualToBeacon:beacon] == NO) {
                    self.nearestBeacon = beacon;
                    isChanged = YES;
                }
            }
            else {
                if (self.nearestBeacon) {
                    self.nearestBeacon = nil;
                    isChanged = YES;
                }
            }
        }
        
        if (isChanged) {
            if ([self.delegate respondsToSelector:@selector(beaconMonitor:didDiscoverNearestBeacon:)]) {
                [self.delegate beaconMonitor:self didDiscoverNearestBeacon:self.nearestBeacon];
            }
            //previousTime = nil;
        }
    }
    
    if ( !self.isEasterEgg )
        [self stopBeaconRanging];

}
#endif

- (void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(ESTBeaconRegion *)region {
    if ([region.identifier isEqual:_beaconRegion.identifier]) {
        switch (state) {
            case CLRegionStateInside:
                NSLog(@"Inside State");
//                [self startBeaconRanging];
                [self startBeaconDiscovering];
                break;
            case CLRegionStateOutside:
                NSLog(@"Outside State");
//                [self stopBeaconRanging];
                [self stopBeaconDiscovering];
                break;
            case CLRegionStateUnknown:
                NSLog(@"Unknown State");
                break;
            default:
                break;
        }
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    
}

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    
}

@end
