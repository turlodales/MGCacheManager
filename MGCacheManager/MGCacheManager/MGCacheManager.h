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
 *  create cache cleaning background thread, initialize it at AppDelegate
 */
+ (void)initializeExpiredCachesCleaner;

+ (void)asyncSaveAndReturnKeyResponse:(id)response
                                  key:(NSString *)key
                          cachePeriod:(NSNumber *)cachePeriod;

/**
 *  save target key to cache
 *
 *  @param response api response
 *  @param key for request
 *  @param cachePeriod set cache time for data if required
 *
 *  @return cached response
 */
+ (id)saveAndReturnKeyResponse:(id)response
                           key:(NSString *)key
                   cachePeriod:(NSNumber *)cachePeriod;

/**
 *  load data from cache
 *
 *  @param fileNameKey
 *
 *  @return content of cached endpoint data
 */
+ (id)loadDataFromCacheFileNameKey:(NSString *)fileNameKey;

/**
 *  force deleting all caches before a specific date 
 *  ( could be useful to be used through firebase configuration manager
 *
 *  @param unixDate
 *
 */
+ (void)deleteAllCachesBeforeDate:(NSNumber *)unixDate;

/**
 *  clean all caches regardless to any dates
 *
 */
+ (void)cleanExpiredCaches;

/**
 *  generate a buildKey based on parameters sent to endpoint, 
 *  in order to cache various data
 *
 *  @param parameters sent during the HTTP request
 *
 *  @return unique key
 *
 */
+ (NSString*)buildKey:(NSDictionary*)params;

/**
 *  generate a buildKey based on parameters sent to endpoint,
 *  in order to cache various data
 *
 *  @param prefix set a prefix to the request generated key
 *  @param parameters sent during the HTTP request
 *
 *  @return unique key
 *
 */
+ (NSString*)buildKey:(NSString*)prefix params:(NSDictionary*)params;

@end
