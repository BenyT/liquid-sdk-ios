//
//  LQNetworking+NSURLSession.h
//  Liquid
//
//  Created by Miguel M. Almeida on 16/10/15.
//  Copyright © 2015 Liquid. All rights reserved.
//

#import "LQNetworking.h"
#import "LQRequest.h"

@interface LQNetworkingURLSession : LQNetworking

- (void)requestData:(NSData *)data toEndpoint:(NSString *)endpoint usingMethod:(NSString *)method completionHandler:(void(^)(LQQueueStatus queueStatus, NSData *responseData))completionHandler;

@end
