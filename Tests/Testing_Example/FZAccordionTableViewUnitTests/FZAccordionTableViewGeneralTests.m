//
//  FZAccordionTableViewUnitTests.m
//  FZAccordionTableViewUnitTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FZAccordionTableViewTestBase.h"
#include <stdlib.h>

@interface FZAccordionTableViewSectionInfo : NSObject
@property (nonatomic, getter=isOpen) BOOL open;
@property (nonatomic) NSInteger numberOfRows;
@end

@interface FZAccordionTableView(Private)

@property (strong, nonatomic) NSMutableArray <FZAccordionTableViewSectionInfo *> *sectionInfos;

@end

@interface FZAccordionTableViewGeneralTests : FZAccordionTableViewTestBase

@end

@implementation FZAccordionTableViewGeneralTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    [self.mainViewController connectTableView];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Method 'isSectionOpen' Tests -

- (void)testClosedSections {
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        [self waitForHeaderViewInSection:i];
        
        XCTAssert(![self.tableView isSectionOpen:i], @"All sections should be initially closed.");
    }
}

#pragma mark - Metohod 'toggleSection' Tests -

- (void)testSectionToggling {
    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.keepOneSectionOpen = NO;
    
    // First, open all of the sections
    for (NSInteger i = 0; i < [self.tableView numberOfSections]-1;  i++) {
        [self waitForHeaderViewInSection:i];
        [self.tableView toggleSection:i];
        
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    
    // Second, close all of the section
    for (NSInteger i = 0; i < [self.tableView numberOfSections]-1; i++) {
        [self waitForHeaderViewInSection:i];
        [self.tableView toggleSection:i];
        
        XCTAssert(![self.tableView isSectionOpen:i], @"Section %d should be closed.", (int)i);
    }
}

#pragma mark - Property 'allowMultipleSectionsOpen' Tests -

- (void)testAllowMultipleSectionsOpenAsTrue {
    self.tableView.allowMultipleSectionsOpen = YES;
    
    [self waitForHeaderViewInSection:0];
    [self.tableView toggleSection:0];
    
    [self waitForHeaderViewInSection:1];
    [self.tableView toggleSection:1];
    
    XCTAssert([self.tableView isSectionOpen:0] && [self.tableView isSectionOpen:1], @"Both sections should be open.");
}

- (void)testAllowMultipleSectionsOpenAsFalse {
    self.tableView.allowMultipleSectionsOpen = NO;
    
    [self waitForHeaderViewInSection:0];
    [self.tableView toggleSection:0];
    
    [self waitForHeaderViewInSection:1];
    [self.tableView toggleSection:1];
    
    XCTAssert(![self.tableView isSectionOpen:0] && [self.tableView isSectionOpen:1], @"Section 0 should be closed when Section 1 was being forced to be open.");
}

#pragma mark - Deletion Tests -

- (void)testDeletingRowWithOpenSection {
    
    NSInteger section = 0;
    
    // Open the section
    [self waitForHeaderViewInSection:section];
    [self.tableView toggleSection:section];
    XCTAssert([self.tableView isSectionOpen:section], @"Section %d should be open.", (int)section);
    
    // Make sure initial conditions hold
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView.", (int)section);
    
    // "Delete" in the user data source
    NSInteger numberOfRows = [self.mainViewController.sections[section] integerValue];
    self.mainViewController.sections[section] = @(numberOfRows-1);
    
    XCTAssert([self.mainViewController.sections[section] integerValue] != [self.tableView.sectionInfos[section] numberOfRows], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
    
    // Delete in the tableView
    @try {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    @catch(NSException *exception) {
        // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
    }
    
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView.", (int)section);
}

//- (void)testDeletingRowWithClosedSection {
//    
//    NSInteger section = 0;
//    
//    XCTAssert(![self.tableView isSectionOpen:section], @"Section %d should be closed.", (int)section);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
//    
//    NSInteger numberOfRows = [self.mainViewController.sections[section] integerValue];
//    self.mainViewController.sections[section] = @(numberOfRows-1);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] != [self.tableView.numOfRowsForSection[@(section)] integerValue], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
//    
//    // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
//    @try {
//        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
//    }
//    @catch(NSException *exception) { }
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection' after deletion.", (int)section);
//}

@end
