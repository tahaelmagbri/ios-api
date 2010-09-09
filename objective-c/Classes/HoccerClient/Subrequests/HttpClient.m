//
//  HttpClient.m
//  HoccerAPI
//
//  Created by Robert Palmer on 08.09.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "HttpClient.h"

@interface ConnectionContainer : NSObject 
{
	SEL successAction;
	NSMutableData *receivedData;
}

@property (assign) SEL successAction;
@property (readonly) NSMutableData *receivedData;


@end

@implementation ConnectionContainer

@synthesize successAction;
@synthesize receivedData;
 
+ (ConnectionContainer *)containerWithSuccessSelector: (SEL)selector {
	ConnectionContainer *c = [[ConnectionContainer alloc] init];
	c.successAction = selector;
	
	return [c autorelease];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		receivedData = [[NSMutableData alloc] init];
	}
	return self;
}

- (void) dealloc {
	[receivedData release];  
	[super dealloc];
}

@end


@interface HttpClient ()

- (void)requestMathod: (NSString *)method URI: (NSString *)uri payload: (NSData *)payload success: (SEL)success;

@end

@implementation HttpClient

@synthesize target;

- (id)initWithURLString: (NSString *)url {
	self = [super init];
	if (self != nil) {
		baseURL = [url copy];
		
		connections = [[NSMutableDictionary alloc] init];	
	}
	
	return self;	
}

- (void)getURI: (NSString *)uri success: (SEL)success {
	[self requestMathod:@"GET" URI: uri payload:nil success:success];
}

- (void)putURI: (NSString *)uri payload: (NSData *)payload success: (SEL)success {
	[self requestMathod:@"PUT" URI: uri payload:payload success:success];
}

- (void)postURI: (NSString *)uri payload: (NSData *)payload success: (SEL)success {
	return [self requestMathod:@"POST" URI: uri payload:payload success:success];
};

- (void)requestMathod: (NSString *)method URI: (NSString *)uri payload: (NSData *)payload success: (SEL)success {
	NSLog(@"conenction: %@ %@", method, uri);
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, uri]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:method];
	[request setHTTPBody:payload];
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	[connections setObject:[ConnectionContainer containerWithSuccessSelector:success] forKey:[connection description]];
	
	NSLog(@"connections: %@", connections);
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	[[[connections objectForKey:[aConnection description]] receivedData] appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	NSLog(@"error: %@", error);
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"response: %d", [(NSHTTPURLResponse *)response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	ConnectionContainer *container = [connections objectForKey:[aConnection description]];

	if ([target respondsToSelector:container.successAction]) {
		[target performSelector:container.successAction withObject:container.receivedData];
	}

	[connections removeObjectForKey:[aConnection description]];
}

- (void)dealloc {
    [super dealloc];
}


@end
