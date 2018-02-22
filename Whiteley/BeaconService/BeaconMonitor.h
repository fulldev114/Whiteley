//
//  BeaconMonitor.h
//  iBeaconPNFDemo
//
//  Created by Jain R on 11/7/14.
//
//

#import <Foundation/Foundation.h>
#import "ESTBeaconManager.h"
#import "ESTBeacon+KeyString.h"

@class BeaconMonitor;

@protocol BeaconMonitorDelegate <NSObject>

@optional
- (void)beaconMonitor:(BeaconMonitor*)beaconMonitor didDiscoverNearestBeacon:(ESTBeacon*)nearestBeacon;
- (void)beaconMonitor:(BeaconMonitor*)beaconMonitor didRangeBeacons:(NSArray*)beacons;
- (void)didExitRegion:(NSString*)strUUID;
- (void)setupAppLocalSettings;
- (void)showNotifyBox;
@end

@interface BeaconMonitor : NSObject<ESTBeaconManagerDelegate>

@property (nonatomic, weak) id<BeaconMonitorDelegate> delegate;

@property (nonatomic, assign) BOOL isRanging;
@property (nonatomic, assign) BOOL isEasterEgg;

+ (BeaconMonitor *)sharedBeaconMonitor;

// start beacon monitoring using UUID and region
- (void)startBeaconMonitoringWith:(NSUUID *)beaconProximityUUID regionID:(NSString *)beaconRegionID determinedProximity:(CLProximity)determinedProximity;
- (void)startBeaconRangingWith:(NSUUID *)beaconProximityUUID regionID:(NSString *)beaconRegionID determinedProximity:(CLProximity)determinedProximity;
// stop beacon monitoring
- (void)stopBeaconMonitoring;
- (void)restartBeaconRanging;
- (void)startBeaconRanging;
- (void)stopBeaconRanging;

@end
