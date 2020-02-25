//
//  ViewController.m
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//




#import "ViewController.h"
#import "API.h"
#import "MGCacheManager.h"

@interface ViewController ()

@property (nonatomic) IBOutlet UIButton *repeatRequestButton;
@property (nonatomic) IBOutlet UILabel *noneCachedRequestTimeLabel;
@property (nonatomic) IBOutlet UILabel *cachedRequestTimeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)repeatRequestButtonAction:(id)sender {
    [MGCacheManager deleteCachedFileForFileNameKey:@"posts" fromDirectoryName:nil];

	__weak __typeof(self)weakSelf = self;
	
	[self testRequest:^(NSTimeInterval executionTime) {
		weakSelf.noneCachedRequestTimeLabel.text = @(executionTime).stringValue;
		[self testRequest:^(NSTimeInterval executionTime) {
			weakSelf.cachedRequestTimeLabel.text = @(executionTime).stringValue;
		}];
	}];
}

- (void)testRequest:(void (^)(NSTimeInterval executionTime))success {
	NSDate *methodStart = [NSDate date];	
	[API getPosts:^(id JSON){
		NSDate *methodFinish = [NSDate date];
		NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
		NSLog(@"Complete Time : %f",executionTime);
		success(executionTime);
	}];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
