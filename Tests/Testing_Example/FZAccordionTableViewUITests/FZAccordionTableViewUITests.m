//
//  FZAccordionTableViewUITests.m
//  FZAccordionTableViewUITests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainViewController.h"

@interface FZAccordionTableViewUITests : XCTestCase

@end

@implementation FZAccordionTableViewUITests

#pragma mark - Helpers -

- (MainViewController *)mainViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    MainViewController *mainViewController = (MainViewController *)[storyboard instantiateInitialViewController];
    
    
    [[UIApplication sharedApplication] keyWindow].rootViewController = mainViewController;
    
    [mainViewController view];

    
    
    if (![mainViewController isKindOfClass:[MainViewController class]]) {
        XCTAssert(NO, @"The view controller to test on is not correctly extracted. Aborting all tests.");
        abort();
    }
    
    return mainViewController;
}

- (FZAccordionTableView *)tableView {
    FZAccordionTableView *tableView = [self mainViewController].tableView;
    XCTAssertNotNil(tableView);
    return tableView;
}

#pragma mark - Setup -

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
