//
//  MGCacheManager.h
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGCacheManager : NSObject

/**
 *  create cache cleaning background thread
 */
+(void)initializeExpiredCachesCleanerTimer;

/**
 *  Check if Cachable endpoints list contains the target endpoint
 *
 *  @param endPoint = Target Path ( without website url )
 *
 *  @return Bool
 */
+(BOOL)endPointsContainsEndPoint:(NSString *)endPoint;

/**
 *  Validate existance of the target patch cache file
 *
 *  @param endPoint Target Path
 *
 *  @return Bool
 */
+(BOOL)validateEndPointCacheFileExistanceForEndPoint:(NSString *)endPoint;

/**
 *  save target path to cache
 *
 *  @param response api response
 *  @param endPoint for target path
 *
 *  @return cached response
 */
+(id)saveAndReturnEndPointResponse:(id)response
                          endPoint:(NSString *)endPoint;

/**
 *  load target path data from cache
 *
 *  @param endPoint target path
 *
 *  @return content of cached endpoint data
 */
+(id)loadDataFromCacheForEndPoint:(NSString *)endPoint;

/**
 *  create directory to save cache
 */
+(void)createDirectoryForCaches;

/**
 *  Check expiration date of the cached target path file
 *
 *  @param endPoint target path ( without URL )
 *
 *  @return expiration time
 */
+(int)findExpirationPeriodOfEndPoint:(NSString *)endPoint;



@end

@interface NSString (Contains)

- (BOOL)myStringContains:(NSString*)string;

@end