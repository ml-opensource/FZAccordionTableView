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
    
    // Make sure UITableView methods get called / loaded
    [self waitForHeaderViewInSection:0];
    
    // First, open all of the sections
    for (NSInteger i = 0; i < [self.tableView numberOfSections];  i++) {
        [self.tableView toggleSection:i];
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    
    // Second, close all of the section
    for (NSInteger i = 0; i < [self.tableView numberOfSections]; i++) {
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

#pragma mark - Test Adding Rows - 

- (void)testAddingRows {

    NSInteger section = 0;
    NSInteger numberOfRowsToAdd = 33;
    
    // We can only add rows to an open section
    [self waitForHeaderViewInSection:0];
    [self.tableView toggleSection:0];
    
    NSInteger numberOfRowsExisting = [self.mainViewController.sections[section] integerValue];
    
    NSMutableArray *rowsIndexPaths = [NSMutableArray new];
    for (int i = (int)numberOfRowsExisting; i < numberOfRowsToAdd+numberOfRowsExisting; i++) {
        [rowsIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }

    self.mainViewController.sections[section] = @(numberOfRowsExisting + numberOfRowsToAdd);
    [self.tableView insertRowsAtIndexPaths:rowsIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    XCTAssert(numberOfRowsExisting + numberOfRowsToAdd  == [self.tableView.sectionInfos[section] numberOfRows], @"Unequal number of rows in section %d.", (int)section);

}

#pragma mark - Deletion Row Tests -

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

- (void)testDeletingRowWithClosedSection {
    
    NSInteger section = 0;
    
    [self waitForHeaderViewInSection:section];
    XCTAssert(![self.tableView isSectionOpen:section], @"Section %d should be closed.", (int)section);
    
    // Make sure initial conditions hold
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
    
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

#pragma mark - Add Section -

- (void)testAddingSection {
    
    NSInteger section = 0;
    NSInteger numberOfRows = 33;
    
    // Makes sure that sections are loaded.
    [self waitForHeaderViewInSection:section];
    
    NSInteger initialSectionCount = self.mainViewController.sections.count;
    
    // Add data into data source
    [self.mainViewController.sections insertObject:@(numberOfRows) atIndex:0];
    
    // Add to tableview
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The data source section rows should match up.");
    XCTAssert(initialSectionCount+1 == self.tableView.numberOfSections, @"The section counts should match up.");
}

- (void)testAddingSectionWhileOtherSectionsAreOpen {
    
    // First, open all of the sections
    self.tableView.allowMultipleSectionsOpen = YES;
    for (NSInteger i = 0; i < [self.tableView numberOfSections];  i++) {
        [self waitForHeaderViewInSection:i];
        [self.tableView toggleSection:i];
        
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    
    NSInteger section = 1;
    NSInteger numberOfRows = 33;
    NSInteger initialSectionCount = self.mainViewController.sections.count;
    
    // Add data into data source
    [self.mainViewController.sections insertObject:@(numberOfRows) atIndex:section];
    
    // Add to tableview
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The data source section rows should match up.");
    XCTAssert(initialSectionCount+1 == self.tableView.numberOfSections, @"The section counts should match up.");
}

#pragma mark - Delete Section -

- (void)testDeleteClosedSection {
    
    NSInteger section = 0;
    
    // Open the section
    [self waitForHeaderViewInSection:section];
    XCTAssert(![self.tableView isSectionOpen:section], @"Section %d should be closed.", (int)section);
    
    // Remove from data source
    [self.mainViewController.sections removeObjectAtIndex:section];
    
    // Remove from tableview
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The data source section rows should match up.");
    XCTAssert(self.mainViewController.sections.count == self.tableView.numberOfSections, @"The section counts should match up.");
}

- (void)testDeleteOpenSection {
    
    NSInteger section = 0;
    
    // Open the section
    [self waitForHeaderViewInSection:section];
    [self.tableView toggleSection:section];
    XCTAssert([self.tableView isSectionOpen:section], @"Section %d should be open.", (int)section);
    
    // Remove from data source
    [self.mainViewController.sections removeObjectAtIndex:section];
    
    // Remove from tableview
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The data source section rows should match up.");
    XCTAssert(self.mainViewController.sections.count == self.tableView.numberOfSections, @"The section counts should match up.");
}

#pragma mark - Method 'isSectionOpen' Tests -

- (void)testDataSourceMapping {
    for (NSInteger section = 0; section < self.tableView.numberOfSections; section++) {
        [self waitForHeaderViewInSection:section];
        XCTAssert([self.mainViewController.sections[section] integerValue] == [self.tableView.sectionInfos[section] numberOfRows], @"The external data source does not match the internal FZAccordionTableView datasource in section %d.", (int)section);
    }
}

@end
