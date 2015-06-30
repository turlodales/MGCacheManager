//
//  ViewController.m
//  MGCacheManager
//
//  Created by Mortgy on 20/05/15.
//  Copyright (c) 2015 mortgy. All rights reserved.
//




#import "ViewController.h"
#import "API.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDate *methodStart = [NSDate date];
    NSLog(@"Request Time : %f",[methodStart timeIntervalSinceDate:methodStart]);
    
    [API getPosts:^(id JSON){
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"JSON Complete Time : %f",executionTime);
        NSLog(@"Posts JSON : %@",JSON);
        
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
