//
//  ESTBeacon+KeyString.m
//  iBeaconPNFDemo
//
//  Created by Jain R on 11/7/14.
//
//

#import "ESTBeacon+KeyString.h"

@implementation ESTBeacon (KeyString)

- (NSString*)keyString {
    return [NSString stringWithFormat:@"beaconkey_%d-%d", self.major.intValue, self.minor.intValue];
}

@end
