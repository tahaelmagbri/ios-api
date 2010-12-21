//  Copyright (C) 2010, Hoccer GmbH Berlin, Germany <www.hoccer.com>
//  
//  These coded instructions, statements, and computer programs contain
//  proprietary information of Linccer GmbH Berlin, and are copy protected
//  by law. They may be used, modified and redistributed under the terms
//  of GNU General Public License referenced below. 
//  
//  Alternative licensing without the obligations of the GPL is
//  available upon request.
//  
//  GPL v3 Licensing:
    
//  This file is part of the "Linccer iOS-API".
    
//  Linccer iOS-API is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
    
//  Linccer iOS-API is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
    
//  You should have received a copy of the GNU General Public License
//  along with Linccer iOS-API. If not, see <http://www.gnu.org/licenses/>.
//
//  LocationController.h
//  Hoccer
//
//  Created by Robert Palmer on 16.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WifiScannerDelegate.h"
#import "HCEnvironmentManagerDelegate.h"

#define kHoccerPerfectLocation 0
#define kHoccerImpreciseLocation 1
#define kHoccerBadLocation 2

@class HCEnvironment;

@interface HCEnvironmentManager : NSObject <CLLocationManagerDelegate, WifiScannerDelegate> {
	@private 
	CLLocationManager *locationManager;

	NSInteger oldHoccability, hoccability;

	NSDate *lastLocationUpdate;
	NSArray *bssids;
		
	id <HCEnvironmentManagerDelegate> delegate;
}

@property (assign) NSInteger hoccability;
@property (readonly) HCEnvironment *environment;
@property (assign) id <HCEnvironmentManagerDelegate> delegate;

- (BOOL)hasLocation;
- (BOOL)hasBSSID;
- (BOOL)hasEnvironment;
- (NSError *)messageForLocationInformation;

@end
