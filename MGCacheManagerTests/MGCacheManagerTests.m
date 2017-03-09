//
//  MGCacheManagerTests.m
//  MGCacheManagerTests
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "API.h"

@interface MGCacheManagerTests : XCTestCase

@end

@implementation MGCacheManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testNoCaching {
    // This is an example of a performance test case.
    [self measureBlock:^{
        XCTestExpectation *completionExpectation = [self expectationWithDescription:@"getPosts"];

        // Put the code you want to measure the time of here.
        [API getPosts:^(id JSON) {
            [completionExpectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:1000.0 handler:nil];

    }];
}

- (void)testCaching {
    // This is an example of a performance test case.
    [self measureBlock:^{
        XCTestExpectation *completionExpectation = [self expectationWithDescription:@"getPostsWithCaches"];

        // Put the code you want to measure the time of here.
        [API getPostsWithCaches:^(id JSON) {
            [completionExpectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:100.0 handler:nil];

    }];
}

@end
