//
//  FZAccordionTableViewInitializationTests.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FZAccordionTableViewTestBase.h"

@interface FZAccordionTableViewInitializationTests : FZAccordionTableViewTestBase

@end

@implementation FZAccordionTableViewInitializationTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Property 'initialOpenSections' Tests -

- (void)testInitialOpenSections {
    
    NSMutableArray *initialOpenSections = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.mainViewController.sections.count/2; i++) {
        [initialOpenSections addObject:@(i)];
    }
    
    self.tableView.initialOpenSections = [NSSet setWithArray:initialOpenSections];
    
    [self.mainViewController connectTableView];
    
    // First half should be open
    for (NSInteger i = 0; i < self.mainViewController.sections.count/2; i++) {
        [self waitForHeaderViewInSection:i];
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    
    // Second half should be open
    for (NSInteger i = self.mainViewController.sections.count/2; i < self.mainViewController.sections.count; i++) {
        [self waitForHeaderViewInSection:i];
        XCTAssert(![self.tableView isSectionOpen:i], @"Section %d should be closed.", (int)i);
    }
}

@end
