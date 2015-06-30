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

+(void)initializeExpiredCachesCleanerTimer {
    [MGCacheManager cleanExpiredCaches];
    [NSTimer scheduledTimerWithTimeInterval:60*SECS_CLEAN_CACHE target:self selector:@selector(cleanExpiredCaches) userInfo:nil repeats:YES];
}

+(BOOL)endPointsContainsEndPoint:(NSString *)endPoint {
    
    [MGCacheManager createDirectoryForCaches];
    
    for (int i = 0; i <= 9 ; i++) {
        endPoint = [endPoint stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%i",i] withString:@""];
    }
    
    NSArray * endPointsWithCachePeriod = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"endPointsToCache" ofType:@"plist"]];
    NSLog(@"endpointWoNumbers : %@",endPoint);
    for (int i = 0; i < [endPointsWithCachePeriod count]; i++) {

        if ([[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0] myStringContains:endPoint]) {
            NSLog(@"endpoint Found\n %@",endPoint);
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)validateEndPointCacheFileExistanceForEndPoint:(NSString *)endPoint{
    
    endPoint = [MGCacheManager endPoint:endPoint];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString * path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]];
    
    NSLog(@"Path : %@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]){
        
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
        
        NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+60*[MGCacheManager findExpirationPeriodOfEndPoint:[endPoint stringByReplacingOccurrencesOfString:@"_" withString:@"/"]]];
        
        NSLog(@"expirateionDate : %@\nNow : %@",expirationDate,[NSDate dateWithTimeIntervalSinceNow:0]);
        
        if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
            
            NSError *error;
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                
                !success ? NSLog(@"Error removing file at path: %@", error.localizedDescription) : NSLog(@"File Expired");
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
        
        NSLog(@"saveAndReturnEndPointResponse : %@",response);
        return [MGCacheManager loadDataFromCacheForEndPoint:endPoint];
    }
    else
        return response;
}

+(id)loadDataFromCacheForEndPoint:(NSString *)endPoint  {
    endPoint = [MGCacheManager endPoint:endPoint];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSData *myJSON = [[NSData alloc] initWithContentsOfFile:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]]];
    
    NSLog(@"documentsPath : %@",[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,endPoint]]);
    NSError *error;
    
    NSMutableDictionary * jsonFileContent = [[NSJSONSerialization JSONObjectWithData:myJSON
                                                                             options: NSJSONReadingMutableContainers
                                                                               error:&error] mutableCopy];
    NSLog(@"jsonData : %@",jsonFileContent);
    return jsonFileContent;
    
}

+(void)createDirectoryForCaches {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderName = [documentsPath stringByAppendingPathComponent:CACHE_DIRECTORY_NAME];
    if (![fileManager fileExistsAtPath:folderName]) {
        [fileManager createDirectoryAtPath:folderName withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

+(NSString *)endPoint:(NSString *)endPoint {
    return [endPoint stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

+(void)cleanExpiredCaches {
    
    NSArray * endPointsWithCachePeriod = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"endPointsToCache" ofType:@"plist"]];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,CACHE_DIRECTORY_NAME]  error:nil];
    
    
    for (int i = 0; i < [endPointsWithCachePeriod count]; i++) {
        
        for (int x = 0; x < [filePathsArray count]; x++) {
            NSLog(@"endPointsWithCachePeriod : %@",[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0]);
            NSLog(@"filePathsArray : %@",[[filePathsArray objectAtIndex:x] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]);
            
            if ([[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0] myStringContains:[[[filePathsArray objectAtIndex:x] stringByReplacingOccurrencesOfString:@"_" withString:@"/"] stringByDeletingLastPathComponent]]) {
                
                
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString * path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,[filePathsArray objectAtIndex:x]]];
                
                NSLog(@"Path : %@",path);
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if ([fileManager fileExistsAtPath:path]){
                    
                    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                    NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
                    
                    NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+60*[MGCacheManager findExpirationPeriodOfEndPoint:[[endPointsWithCachePeriod objectAtIndex:i] objectAtIndex:0]]];
                    
                    NSLog(@"expirateionDate : %@\nNow : %@",expirationDate,[NSDate dateWithTimeIntervalSinceNow:0]);
                    
                    if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
                        
                        NSError *error;
                        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
                            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                            
                            !success ? NSLog(@"Error removing file at path: %@", error.localizedDescription) : NSLog(@"File Deleted");
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}

@end


@implementation NSString (Contains)

- (BOOL)myStringContains:(NSString*)string {
    NSRange range = [self rangeOfString:string];
    return range.length != 0;
}

@end