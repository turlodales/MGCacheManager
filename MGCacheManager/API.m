//
//  API.m
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#define kAPIURL @"http://jsonplaceholder.typicode.com/"

#import "API.h"
#import "MGCacheManager.h"
#import "AFNetworking.h"

@implementation API

//Get Movies
+ (void)getPosts:(void (^)(id JSON))complete
{
    [API sendGetPayload:nil toPath:@"posts" withLoadingMessage:nil complete:^(id JSON){
        
        if(complete != nil) complete(JSON);
        
    }];
}

#pragma mark - API - HTTP Calls
+ (void)sendGetPayload:(NSDictionary *)parameters
                toPath:(NSString *)path
    withLoadingMessage:(NSString *)loadingMessage
              complete:(void (^)(id JSON))complete{
    
    BOOL cachableButFileNotFound = NO;
    if ([MGCacheManager endPointsContainsEndPoint:path]) {
        NSLog(@"YES Contains path");
        if ([MGCacheManager validateEndPointCacheFileExistanceForEndPoint:path]) {
            NSLog(@"YES Fild Found");
            
            complete([MGCacheManager loadDataFromCacheForEndPoint:path]);
            return;
        }
        else
        {
            cachableButFileNotFound = YES;
        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    [manager GET:[NSString stringWithFormat:@"%@%@",kAPIURL,path] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         if(complete != nil)
         {
             if (cachableButFileNotFound) {
                 
                 if(complete != nil) complete([MGCacheManager saveAndReturnEndPointResponse:responseObject endPoint:path]);
                 
             }
             else
             {
                 if(complete != nil) complete(responseObject);
             }
         }
         
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
         [params setValue:[NSString stringWithFormat:@"%ld",(long)[operation.response statusCode]] forKey:@"responseCode"];
         if(complete != nil) complete(params);
         
     }];
}

@end
