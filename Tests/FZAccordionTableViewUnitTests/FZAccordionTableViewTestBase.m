//
//  FZAccordionTableViewTestBase.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/26/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import "FZAccordionTableViewTestBase.h"

@implementation FZAccordionTableViewTestBase

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    self.mainViewController = [FZAccordionTableViewTestHelpers setupMainViewController];
    self.tableView = self.mainViewController.tableView;
    
    XCTAssertNotNil(self.mainViewController);
    XCTAssertNotNil(self.tableView);
    
    [[[UIApplication sharedApplication] delegate] window].layer.speed = 100;
}

- (void)tearDown {
    [FZAccordionTableViewTestHelpers tearDownMainViewController];
    self.mainViewController = nil;
    self.tableView = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (void)waitForHeaderViewInSection:(NSInteger)section
{
    [FZAccordionTableViewTestHelpers waitForHeaderViewInSection:section tableView:self.tableView];
}

@end
