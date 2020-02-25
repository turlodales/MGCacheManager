
//
//  CacheManager.m
//  Tasit
//
//  Created by Mortgy on 06/02/15.
//  Copyright (c) 2015 mortgy.com. All rights reserved.
//

#import "MGCacheManager.h"

#define DOCUMENTS_DIRECTORY_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define CACHE_DIRECTORY_NAME @"cache"
#define CACHE_SALT_KEY @"mgCacheSalt-"

#define MGCACHE_MINUTE_IN_SECONDS 60

#pragma mark - functions

extern BOOL isNull(id value)
{
	if (!value) return YES;
	if ([value isKindOfClass:[NSNull class]]) return YES;
	
	return NO;
}

@implementation MGCacheManager

+ (BOOL)validateCachedFileExistanceForKey:(NSString *)fileNameKey {
	
	fileNameKey = [NSString stringWithFormat:@"%@%@", CACHE_SALT_KEY, fileNameKey];
	
	NSString * path = [DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME,fileNameKey]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:path]) {
		
		NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
		NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+MGCACHE_MINUTE_IN_SECONDS*[self findExpirationPeriodOfKey:fileNameKey]];
		
		if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
			
			[self deleteCachedFileForFileNameKey:fileNameKey fromDirectoryName:nil];
			
			return NO;
		}
		else {
			return YES;
		}
	}
	
	return NO;
}

+ (NSUInteger)findExpirationPeriodOfKey:(NSString *)key {
	NSNumber *cachePeriod = [[NSUserDefaults standardUserDefaults] valueForKey:key];
	if (cachePeriod) {
		return [cachePeriod intValue];
	}
	return -1;
}

+(void)asyncSaveAndReturnKeyResponse:(id)response
								 key:(NSString *)key
                       directoryName:(NSString *)directoryName
						 cachePeriod:(NSNumber *)cachePeriod{
	
	dispatch_queue_t apiQueue = dispatch_queue_create("ApiQueue",NULL);
	dispatch_async(apiQueue, ^{
		[self saveAndReturnKeyResponse:response key:key directoryName:directoryName cachePeriod:cachePeriod];
	});
}

+(id)saveAndReturnKeyResponse:(id)response
						  key:(NSString *)key
                directoryName:(NSString *)directoryName
				  cachePeriod:(NSNumber *)cachePeriod {
	
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
	key = [NSString stringWithFormat:@"%@%@", CACHE_SALT_KEY, key];
	
	if (cachePeriod) {
		[[NSUserDefaults standardUserDefaults] setValue:cachePeriod forKey:key];
	}
	
	if (data) {
		NSMutableString * path = [[NSMutableString alloc] initWithString:[DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", CACHE_DIRECTORY_NAME]]];
        
        [self createDirectoryForCachesAtPath:path];

        if (directoryName) {
            [path appendString:[NSString stringWithFormat:@"/%@",  directoryName]];
            [self createDirectoryForCachesAtPath:path];
        }
        
        [path appendString:[NSString stringWithFormat:@"/%@",  key]];

		[data writeToFile:path atomically:YES];
	}
	
	return response;
}

+ (id)loadDataFromCacheFileNameKey:(NSString *)fileNameKey fromDirectoryName:(NSString *)directoryName {
	
	if ([self validateCachedFileExistanceForKey:fileNameKey]) {
		fileNameKey = [NSString stringWithFormat:@"%@%@", CACHE_SALT_KEY, fileNameKey];
        
        NSMutableString * path = [[NSMutableString alloc] initWithString:[DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", CACHE_DIRECTORY_NAME]]];
        
        if (directoryName) {
            [path appendString:[NSString stringWithFormat:@"/%@",  directoryName]];
        }
        
        [path appendString:[NSString stringWithFormat:@"/%@",  fileNameKey]];

        
		NSData *data = [[NSData alloc] initWithContentsOfFile:path];
		
		data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		return data;
	} else {
		return nil;
	}
}

+ (void)createDirectoryForCachesAtPath:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
	}
}

+ (NSArray *)filesInFolderName:(NSString *)folderName  {
    NSError  *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableString * rootPath = [[NSMutableString alloc] initWithString:[DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", CACHE_DIRECTORY_NAME, folderName]]];
    [self createDirectoryForCachesAtPath:rootPath];
    BOOL onlyDirectory = YES;
    if ([fileManager fileExistsAtPath:rootPath isDirectory:&onlyDirectory]) {
        NSArray *filesAtPath = [fileManager contentsOfDirectoryAtPath:rootPath error:&error];
        return filesAtPath;
    } else {
        return @[];
    }
}

+ (void)cleanExpiredCaches {
	
	NSArray * expirableCacheKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
	expirableCacheKeys = [self array:expirableCacheKeys select:^BOOL(NSString * object) {
		return ([object containsString:CACHE_SALT_KEY]);
	}];
	
	for (NSString *fileNameKey in expirableCacheKeys) {
		
        NSError  *error;
        NSMutableString * rootPath = [[NSMutableString alloc] initWithString:[DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", CACHE_DIRECTORY_NAME]]];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSArray *filesAtPath = [fileManager contentsOfDirectoryAtPath:rootPath error:&error];

        if ([filesAtPath containsObject:fileNameKey]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",rootPath, fileNameKey];
            NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            NSDate *fileCreationDate = [fileAttribs objectForKey:NSFileCreationDate];
            
            NSDate *expirationDate = [fileCreationDate dateByAddingTimeInterval:+MGCACHE_MINUTE_IN_SECONDS*[self findExpirationPeriodOfKey:fileNameKey]];
                        
            if ([expirationDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedAscending) {
                
                [self deleteCachedFileForFileNameKey:fileNameKey fromDirectoryName:nil];
            }

        } else {
            for (NSString *folderName in filesAtPath) {
                NSString *copyPath = [NSString stringWithFormat:@"%@/%@", rootPath, folderName];
                BOOL onlyDirectory = YES;
                if ([fileManager fileExistsAtPath:copyPath isDirectory:&onlyDirectory]) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", rootPath, folderName, fileNameKey];
                    if ([fileManager fileExistsAtPath:filePath]) {
                        [self deleteCachedFileForFileNameKey:fileNameKey fromDirectoryName:folderName];
                    }
                }
            }
        }
	}
}

+ (void)deleteAllCachesBeforeDate:(NSNumber *)unixDate {
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate.doubleValue];
	NSArray *cacheFiles = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS_DIRECTORY_PATH,CACHE_DIRECTORY_NAME]  error:nil];
	
	for (NSString *fileName in cacheFiles) {
		NSString *path = [DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@",CACHE_DIRECTORY_NAME, fileName]];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if ([fileManager fileExistsAtPath:path]){
			if ([date compare:[NSDate dateWithTimeIntervalSince1970:0]] == NSOrderedAscending) {
				[self deleteCachedFileForFileNameKey:fileName fromDirectoryName:nil];
			}
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:unixDate forKey:@"latestForcedCacheDeletion"];
}

+ (void)deleteCachedFileForFileNameKey:(NSString *)fileNameKey fromDirectoryName:(NSString *)directoryName {
	
    NSMutableString * path = [[NSMutableString alloc] initWithString:[DOCUMENTS_DIRECTORY_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", CACHE_DIRECTORY_NAME]]];
    
    if (directoryName) {
        [path appendString:[NSString stringWithFormat:@"/%@",  directoryName]];
    }
    
    [path appendString:[NSString stringWithFormat:@"/%@",  fileNameKey]];

    NSError *error;
	if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
		BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		!success ? NSLog(@"Error removing file at path: %@", error.localizedDescription) : NSLog(@"File Deleted");
	}
}

+ (NSString*)buildKey:(NSDictionary*)params {
	NSMutableString *key = [NSMutableString new];
	for (NSString *paramKey in params) {
		if (!isNull(params[paramKey])) {
			[key appendString:[NSString stringWithFormat:@"-%@-%@", paramKey, params[paramKey]]];
		}
	}
	
	return [key copy];
}

+ (NSArray *)array:(NSArray *)sourceArray select:(BOOL (^)(id object))block {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:sourceArray.count];
	
	for (id object in sourceArray) {
		if (block(object)) {
			[array addObject:object];
		}
	}
	
	return array;
}

@end
