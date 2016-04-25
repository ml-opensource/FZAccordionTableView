//
//  FZAccordionTableViewInitializationTests.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FZAccordionTableViewTestHelpers.h"

@interface FZAccordionTableViewInitializationTests : XCTestCase

@property (strong, nonatomic) MainViewController *mainViewController;
@property (weak, nonatomic) FZAccordionTableView *tableView;

@end

@implementation FZAccordionTableViewInitializationTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    self.mainViewController = [FZAccordionTableViewTestHelpers setupMainViewController];
    self.tableView = self.mainViewController.tableView;
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

#pragma mark - Property 'initialOpenSections' Tests -

- (void)testInitialOpenSections {
    
    NSMutableArray *initialOpenSections = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.mainViewController.sections.count; i++) {
        [initialOpenSections addObject:@(i)];
    }
    
    self.tableView.initialOpenSections = [NSSet setWithArray:initialOpenSections];
    
    [self.mainViewController connectTableView];
    
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        [self waitForHeaderViewInSection:i];
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
}

#pragma mark - Property 'sectionsAlwaysOpen' Tests -

- (void)testSectionsAlwaysOpen {
    NSMutableArray *sectionsAlwaysOpen = [NSMutableArray new];
    for (NSInteger i = 0; i < self.mainViewController.sections.count; i++) {
        [sectionsAlwaysOpen addObject:@(i)];
    }
    self.tableView.sectionsAlwaysOpen = [NSSet setWithArray:sectionsAlwaysOpen];
    
    [self.mainViewController connectTableView];
    
    // Test that no matter which way you toggle the section, the section remains open.
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        
        [self waitForHeaderViewInSection:i];
        [self.tableView toggleSection:i];
        
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        
        [self waitForHeaderViewInSection:i];
        [self.tableView toggleSection:i];
        
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
}

@end
