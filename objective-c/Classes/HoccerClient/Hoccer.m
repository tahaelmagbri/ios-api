//
//  Hoccer.m
//  HoccerAPI
//
//  Created by Robert Palmer on 08.09.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "Hoccer.h"
#import "LocationController.h"
#import "HocLocation.h"
#import "HttpClient.h"
#import "NSString+SBJSON.h"

#define HOCCER_CLIENT_URI @"hoccerClientUri" 


@interface Hoccer ()

- (void)updateEnvironment;
- (void)didFailWithError: (NSError *)error;

- (NSDictionary *)userInfoForNoReceiver;
- (NSDictionary *)userInfoForNoSender;

@end

@implementation Hoccer
@synthesize delegate;
@synthesize environmentController;
@synthesize isRegistered;

- (id) init {
	self = [super init];
	if (self != nil) {
		environmentController = [[LocationController alloc] init];
		environmentController.delegate = self;

		httpClient = [[HttpClient alloc] initWithURLString:@"http://192.168.2.139:9292"];
		httpClient.target = self;

		uri = [[NSUserDefaults standardUserDefaults] stringForKey:HOCCER_CLIENT_URI];
		if (!uri) {
			[httpClient postURI:@"/clients" payload:nil success:@selector(httpConnection:didReceiveInfo:)];
		} else {
			[self updateEnvironment];
		}
	}
	
	return self;
}

- (void)send: (NSData *)data withMode: (NSString *)mode {
	if (!isRegistered) {
		[self didFailWithError:nil];
	}
	
	NSString *actionString = [@"/action" stringByAppendingPathComponent:mode];
	[httpClient postURI:[uri stringByAppendingPathComponent: actionString] 
				payload:data
				success:@selector(httpConnection:didSendData:)];	
}

- (void)receiveWithMode: (NSString *)mode {
	if (!isRegistered) {
		[self didFailWithError:nil];
	}
	
	NSString *actionString = [@"/action" stringByAppendingPathComponent:mode];
	[httpClient getURI:[uri stringByAppendingPathComponent: actionString] 
			   success:@selector(httpConnection:didReceiveData:)];	
}

- (void)disconnect {
	if (!isRegistered) {
		[self didFailWithError:nil];
	}
	
	[httpClient deleteURI:[uri stringByAppendingPathComponent:@"/environment"]
				  success:@selector(httpClientDidDelete:)];
}


#pragma mark -
#pragma mark Error Handling 

- (void)httpConneciton:(HttpConnection *)connection didFailWithError: (NSError *)error {
	[self didFailWithError:error];
}

- (void)didFailWithError: (NSError *)error {
	if ([delegate respondsToSelector:@selector(hoccer:didFailWithError:)]) {
		[delegate hoccer:self didFailWithError:error];
	}
}

#pragma mark -
#pragma mark LocationController Delegate Methods

- (void)locationControllerDidUpdateLocation: (LocationController *)controller {
	[self updateEnvironment];
}

#pragma mark -
#pragma mark HttpClient Response Methods 
- (void)httpConnection: (HttpConnection *)aConncetion didReceiveInfo: (NSData *)receivedData {
	
	NSString *string = [[[NSString alloc] initWithData: receivedData
											  encoding:NSUTF8StringEncoding] autorelease];
	
	NSDictionary *info = [string JSONValue];
	uri = [[info objectForKey:@"uri"] copy];
	
	[[NSUserDefaults standardUserDefaults] setObject:uri forKey:HOCCER_CLIENT_URI];
	
	[self updateEnvironment];
};

- (void)httpConnection: (HttpConnection *)aConnection didUpdateEnvironment: (NSData *)receivedData {
	if (isRegistered) {
		return;
	}
	
	isRegistered = YES;
	if ([delegate respondsToSelector:@selector(hoccerDidRegister:)]) {
		[delegate hoccerDidRegister:self];
	}
}

- (void)httpConnection: (HttpConnection *)connection didSendData: (NSData *)data {
	
	if ([connection.response statusCode] == 204 ) {
		NSError *error = [NSError errorWithDomain:HoccerError code:HoccerNoReceiverError userInfo:[self userInfoForNoReceiver]];
		[self didFailWithError:error];
		return;
	}
	
	if ([delegate respondsToSelector:@selector(hoccerDidSendData:)]) {
		[delegate hoccerDidSendData: self];
	}
}

- (void)httpConnection: (HttpConnection *)connection didReceiveData: (NSData *)data {

	if ([connection.response statusCode] == 204 ) {
		NSError *error = [NSError errorWithDomain:HoccerError code:HoccerNoSenderError userInfo:[self userInfoForNoSender]];
		[self didFailWithError:error];
		return;
	}

	if ([delegate respondsToSelector:@selector(hoccer:didReceiveData:)]) {
		[delegate hoccer: self didReceiveData: data];
	}

}

- (void)httpClientDidDelete: (NSData *)receivedData {
	NSLog(@"deleted resource");
}

#pragma mark -
#pragma mark Private Methods

- (NSDictionary *)userInfoForNoReceiver {

	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"Could not establish connection", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
		
	return [userInfo autorelease];
}

- (NSDictionary *)userInfoForNoSender {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"Could not establish connection", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];	
}

- (void)updateEnvironment {	
	if (uri == nil) {
		return;
	}
	
	[httpClient putURI:[uri stringByAppendingPathComponent:@"/environment"]
			   payload:[[environmentController.location JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] 
			   success:@selector(httpConnection:didUpdateEnvironment:)];
}


- (void)dealloc {
	[httpClient cancelAllRequest];
	[httpClient release];
	[environmentController release];
    [super dealloc];
}


@end
