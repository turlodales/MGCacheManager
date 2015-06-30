//
//  API.h
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

//Get Movies JSON
+ (void)getPosts:(void (^)(id JSON))complete;

@end
