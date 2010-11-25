//
//  HCFileCache.h
//  HoccerAPI
//
//  Created by Robert Palmer on 24.11.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpClient.h"
#import "HCAuthenticatedHttpClient.h"

@class HCFileCache;

@protocol HCFileCacheDelegate

- (void)fileCache: (HCFileCache *)fileCache didFailWithError: (NSError *)error;
- (void)fileCache: (HCFileCache *)fileCache didDownloadFile: (NSString *)path;
- (void)fileCache: (HCFileCache *)fileCache didUpdateProgress: (NSNumber *)progress;
- (void)fileCache: (HCFileCache *)fileCache didUploadFile: (NSString *)path;

@end


@interface HCFileCache : NSObject {
	HCAuthenticatedHttpClient *httpClient;
}

- (id) initWithApiKey: (NSString *)key secret: (NSString *)secret;

- (void)cacheData: (NSData *)data forTimeInterval: (NSTimeInterval)interval;
- (void)load: (NSString *)url;
- (void)cancenTransfer: (NSNumber *)transferId;

@end


/*
 
 HCFileCache *cache = [[HCFileCache alloc] initWithApiKey: secret:];
 [cache 
 
*/

