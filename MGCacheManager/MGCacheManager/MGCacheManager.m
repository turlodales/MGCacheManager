//
//  MGMGCacheManager.m
//  MGMGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#import "MGCacheManager.h"

@implementation MGCacheManager
#define CACHE_DIRECTORY_NAME @"cache"
#define SECS_CLEAN_CACHE 10

/**
 *  create cache cleaning background thread
 */
+(void)initializeExpiredCachesCleanerTimer {
    [MGCacheManager cleanExpiredCaches];
    [NSTimer scheduledTimerWithTimeInterval:60*SECS_CLEAN_CACHE target:self selector:@selector(cleanExpiredCaches) userInfo:nil repeats:YES];
}

/**
 *  Check if Cachable endpoints list contains the target endpoint
 *
 *  @param endPoint = Target Path ( without website url )
 *
 *  @return Bool
 */
+(BOOL)endPointsContainsEndPoint:(NSString *)endPoint {
    
    [MGCacheManager createDirectoryForCaches];
    
    for (int i = 0; i <= 9 ; i++) {
        endPoint = [endPoint stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%i",i] withString:@""];
    }
    
    NSArray * endPointsWithCachePeriod = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"endPointsToCache" ofType:@"plist"]];
    [MGCacheManager MGNSLOG:@"endpointWoNumbers : %@",endPoint];
    
    for (int i = 0; i < [endPointsWithCachePeriod count]; i++) {

        if ([endPoint myStringContains:[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0]]) {
            return YES;
        }
    }
    
    return NO;
}

/**
 *  Validate existance of the target patch cache file
 *
 *  @param endPoint Target Path
 *
 *  @return Bool
 */
+(BOOL)validateEndPointCacheFileExistanceForEndPoint:(NSString *)endPoint{
    
    endPoint = [MGCacheManager endPoint:endPoint];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]];
    
    [MGCacheManager MGNSLOG:@"Path : %@",path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]){
        
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
        
        NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+60*[MGCacheManager findExpirationPeriodOfEndPoint:[endPoint stringByReplacingOccurrencesOfString:@"_" withString:@"/"]]];
        
        [MGCacheManager MGNSLOG:@"expirateionDate : %@\nNow : %@",expirationDate,[NSDate dateWithTimeIntervalSinceNow:0]];
        
        if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
            
            NSError *error;
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                
                !success ? [MGCacheManager MGNSLOG:@"Error removing file at path: %@", error.localizedDescription] : [MGCacheManager MGNSLOG:@"File Expired"];
            }
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

/**
 *  Check expiration date of the cached target path file
 *
 *  @param endPoint target path ( without URL )
 *
 *  @return expiration time
 */
+(int)findExpirationPeriodOfEndPoint:(NSString *)endPoint {
    
    for (int i = 0; i <= 9 ; i++) {
        endPoint = [endPoint stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%i",i] withString:@""];
    }
    
    NSArray * endPointsWithCachePeriod = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"endPointsToCache" ofType:@"plist"]];
    
    for (int i = 0; i < [endPointsWithCachePeriod count]; i++) {
        
        if ([[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0] myStringContains:endPoint]) {
            
            return [[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:1] intValue];
        }
    }
    
    return -1;
}

/**
 *  save target path to cache
 *
 *  @param response api response
 *  @param endPoint for target path
 *
 *  @return cached response
 */
+(id)saveAndReturnEndPointResponse:(id)response
                          endPoint:(NSString *)endPoint
{
    
    if (response) {
        endPoint = [MGCacheManager endPoint:endPoint];
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString * path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        [jsonData writeToFile:path atomically:YES];
        
        [MGCacheManager MGNSLOG:@"saveAndReturnEndPointResponse : %@",response];
        return [MGCacheManager loadDataFromCacheForEndPoint:endPoint];
    }
    else
        return response;
}

/**
 *  load target path data from cache
 *
 *  @param endPoint target path
 *
 *  @return content of cached endpoint data
 */
+(id)loadDataFromCacheForEndPoint:(NSString *)endPoint  {
    endPoint = [MGCacheManager endPoint:endPoint];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSData *myJSON = [[NSData alloc] initWithContentsOfFile:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]]];
    
    [MGCacheManager MGNSLOG:@"documentsPath : %@",[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]]];
    NSError *error;
    
    NSMutableDictionary * jsonFileContent = [[NSJSONSerialization JSONObjectWithData:myJSON
                                                                             options: NSJSONReadingMutableContainers
                                                                               error:&error] mutableCopy];
    [MGCacheManager MGNSLOG:@"jsonData : %@",jsonFileContent];
    return jsonFileContent;
    
}

/**
 *  create directory to save cache
 */
+(void)createDirectoryForCaches {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderName = [documentsPath stringByAppendingPathComponent:CACHE_DIRECTORY_NAME];
    if (![fileManager fileExistsAtPath:folderName]) {
        [fileManager createDirectoryAtPath:folderName withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

/**
 *  remove path slashs from target path
 *
 *  @param endPoint target path
 *
 *  @return new formed target path
 */
+(NSString *)endPoint:(NSString *)endPoint {
    return [endPoint stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

/**
 *  clean expired cached files
 */
+(void)cleanExpiredCaches {
    
    NSArray * endPointsWithCachePeriod = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"endPointsToCache" ofType:@"plist"]];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,CACHE_DIRECTORY_NAME]  error:nil];
    
    
    for (int i = 0; i < [endPointsWithCachePeriod count]; i++) {
        
        for (int x = 0; x < [filePathsArray count]; x++) {
            [MGCacheManager MGNSLOG:@"endPointsWithCachePeriod : %@",[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0]];
            [MGCacheManager MGNSLOG:@"filePathsArray : %@",[[filePathsArray objectAtIndex:x] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
            
            if ([[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0] myStringContains:[[[filePathsArray objectAtIndex:x] stringByReplacingOccurrencesOfString:@"_" withString:@"/"] stringByDeletingLastPathComponent]]) {
                
                
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString * path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,[filePathsArray objectAtIndex:x]]];
                
                [MGCacheManager MGNSLOG:@"Path : %@",path];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if ([fileManager fileExistsAtPath:path]){
                    
                    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                    NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
                    
                    NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+60*[MGCacheManager findExpirationPeriodOfEndPoint:[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0]]];
                    
                    [MGCacheManager MGNSLOG:@"expirateionDate : %@\nNow : %@",expirationDate,[NSDate dateWithTimeIntervalSinceNow:0]];
                    
                    if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
                        
                        NSError *error;
                        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
                            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                            
                            !success ? [MGCacheManager MGNSLOG:@"Error removing file at path: %@", error.localizedDescription] : [MGCacheManager MGNSLOG:@"File Deleted"];
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}

/**
 *  NSLog only during debugging mode
 *
 *  @param format parameters
 */
+(void)MGNSLOG:(NSString *)format, ...{
#ifndef NDEBUG
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"%@",msg);
#endif
}

@end


@implementation NSString (Contains)

/**
 *  check if text contains other text
 *
 *  @param string comparable text
 *
 *  @return bool
 */
- (BOOL)myStringContains:(NSString*)string {
    NSRange range = [self rangeOfString:string];
    return range.length != 0;
}

@end