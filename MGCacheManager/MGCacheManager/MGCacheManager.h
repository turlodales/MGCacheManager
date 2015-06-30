//
//  MGCacheManager.h
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGCacheManager : NSObject

+(BOOL)endPointsContainsEndPoint:(NSString *)endPoint;

+(BOOL)validateEndPointCacheFileExistanceForEndPoint:(NSString *)endPoint;

+(id)saveAndReturnEndPointResponse:(id)response
                          endPoint:(NSString *)endPoint;

+(id)loadDataFromCacheForEndPoint:(NSString *)endPoint;

+(void)createDirectoryForCaches;

+(int)findExpirationPeriodOfEndPoint:(NSString *)endPoint;

+(void)initializeExpiredCachesCleanerTimer;

@end

@interface NSString (Contains)

- (BOOL)myStringContains:(NSString*)string;

@end