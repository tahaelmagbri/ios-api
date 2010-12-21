//
//  HCFileCache.m
//  HoccerAPI
//
//  Created by Robert Palmer on 24.11.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <YAJLIOS/YAJLIOS.h>
#import "HCFileCache.h"
#import "NSDictionary+CSURLParams.h"
#import "NSString+URLHelper.h"

#define FILECACHE_URI @"http://filecache.sandbox.hoccer.com"
#define FILECACHE_SANDBOX_URI @"http://filecache.hoccer.com"

@implementation HCFileCache

@synthesize delegate;

- (id) initWithApiKey: (NSString *)key secret: (NSString *)secret {
	self = [super init];
	if (self != nil) {
		httpClient = [[HCAuthenticatedHttpClient alloc] initWithURLString:FILECACHE_URI];
		httpClient.apiKey = key;
		httpClient.secret = secret;
		httpClient.target = self;
	}
	
	return self;
}

- (id) initWithApiKey: (NSString *)key secret: (NSString *)secret sandboxed: (BOOL)sandbox {
	self = [super init];
	if (self != nil) {
		if (sandbox) {
			httpClient = [[HCAuthenticatedHttpClient alloc] initWithURLString:FILECACHE_SANDBOX_URI];
		} else {
			httpClient = [[HCAuthenticatedHttpClient alloc] initWithURLString:FILECACHE_URI];
		}
		
		httpClient.apiKey = key;
		httpClient.secret = secret;
		httpClient.target = self;
	}
	
	return self;
}


#pragma mark -
#pragma mark Metods for Sending
- (NSString *)cacheData: (NSData *)data withFilename: (NSString*)filename forTimeInterval: (NSTimeInterval)interval {
	NSDictionary *params = [NSDictionary dictionaryWithObject:[[NSNumber numberWithFloat:interval] stringValue] forKey:@"expires_in"];
	
	NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: attachment; filename=\"%@\"", filename];
	NSDictionary *headers = [NSDictionary dictionaryWithObject:contentDisposition forKey:@"Content-Disposition"]; 
		
	NSString *urlName = [@"/" stringByAppendingString:[NSString stringWithUUID]];
	NSString *uri = [urlName stringByAppendingQuery:[params URLParams]];
		
	return [httpClient requestMethod:@"PUT" URI:uri payload:data header:headers success:@selector(httpConnection:didSendData:)];
}

#pragma mark -
#pragma mark Methods for Fetching
- (NSString *)load: (NSString *)url {
	return [httpClient requestMethod:@"GET" absoluteURL:url payload:nil success:@selector(httpConnection:didReceiveData:)];
}

#pragma mark -
#pragma mark HttpConnection Delegate Methods

- (void)httpConnection: (HttpConnection *)connection didSendData: (NSData *)data {
	if ([delegate respondsToSelector:@selector(fileCache:didUploadFileToURI:)]) {
		NSString *body = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		[delegate fileCache:self didUploadFileToURI:body];
	}
}

- (void)httpConnection:(HttpConnection *)connection didUpdateDownloadPercentage: (NSNumber *)percentage {
	if ([delegate respondsToSelector:@selector(fileCache:didUpdateProgress:forURI:)]) {
		[delegate fileCache:self didUpdateProgress:percentage forURI: connection.uri];
	}
}

- (void)httpConnection:(HttpConnection *)connection didFailWithError: (NSError *)error {
	if ([delegate respondsToSelector:@selector(fileCache:didFailWithError:forURI:)]) {
		[delegate fileCache:self didFailWithError:error forURI:connection.uri];
	}
}

- (void)httpConnection:(HttpConnection *)connection didReceiveData: (NSData *)data {
	if ([delegate respondsToSelector:@selector(fileCache:didReceiveResponse:withDownloadedData:forURI:)]) {
		[delegate fileCache: self didReceiveResponse:connection.response withDownloadedData: data forURI: connection.uri];
	}
}

- (void)cancelTransferWithURI: (NSString *)transferUri {
	[httpClient cancelRequest:transferUri];
}

@end