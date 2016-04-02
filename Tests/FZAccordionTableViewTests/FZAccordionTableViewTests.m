//
//  FZAccordionTableViewTests.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 6/14/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FZAccordionTableViewSimulator.h"
#import "FZAccordionTableView+Internals.h"

@interface FZAccordionTableViewTests : XCTestCase

@property (strong, nonatomic) FZAccordionTableViewSimulator *tableViewSimulator;

@end

@implementation FZAccordionTableViewTests

#pragma mark - Setup -

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.tableViewSimulator = [FZAccordionTableViewSimulator new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.tableViewSimulator = nil;
}

#pragma mark - Method 'isSectionOpen' Tests -

- (void)testClosedSections {
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        XCTAssert(![self.tableViewSimulator.tableView isSectionOpen:i], @"All sections should be initially closed.");
    }
}

#pragma mark - Metohod 'toggleSection' Tests -

- (void)testSectionToggling {
    self.tableViewSimulator.tableView.allowMultipleSectionsOpen = YES;
    self.tableViewSimulator.tableView.keepOneSectionOpen = NO;
    // First, open all of the sections
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
        XCTAssert([self.tableViewSimulator.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    // Second, close all of the section
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
        XCTAssert(![self.tableViewSimulator.tableView isSectionOpen:i], @"Section %d should be closed.", (int)i);
    }
}

#pragma mark - Property 'allowMultipleSectionsOpen' Tests -

- (void)testAllowMultipleSectionsOpenAsTrue {
    self.tableViewSimulator.tableView.allowMultipleSectionsOpen = YES;
    [self.tableViewSimulator.tableView toggleSection:0];
    [self.tableViewSimulator.tableView toggleSection:1];
    XCTAssert([self.tableViewSimulator.tableView isSectionOpen:0] && [self.tableViewSimulator.tableView isSectionOpen:1], @"Both sections should be open.");
}

- (void)testAllowMultipleSectionsOpenAsFalse {
    self.tableViewSimulator.tableView.allowMultipleSectionsOpen = NO;
    [self.tableViewSimulator.tableView toggleSection:0];
    [self.tableViewSimulator.tableView toggleSection:1];
    XCTAssert(![self.tableViewSimulator.tableView isSectionOpen:0] && [self.tableViewSimulator.tableView isSectionOpen:1], @"Section 0 should be closed when Section 1 was being forced to be open.");
}

#pragma mark - Property 'keepOneSectionOpen' Tests -

- (void)testKeepOneSectionOpenAsTrue {
    self.tableViewSimulator.tableView.allowMultipleSectionsOpen = YES;
    self.tableViewSimulator.tableView.keepOneSectionOpen = YES;
    // First, open all of the sections
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
    }
    // Second, close all of the section
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
    }
    // Check if at least one section is open
    BOOL isOneSectionOpen = NO;
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        if ([self.tableViewSimulator.tableView isSectionOpen:i]) {
            isOneSectionOpen = YES;
        }
    }
    XCTAssert(isOneSectionOpen, @"At least one section must be open when the 'keepOneSectionOpen' property is set as TRUE.");
}

- (void)testKeepOneSectionOpenAsFalse {
    self.tableViewSimulator.tableView.allowMultipleSectionsOpen = YES;
    self.tableViewSimulator.tableView.keepOneSectionOpen = NO;
    // First, open all of the sections
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
    }
    // Second, close all of the section
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
    }
    // Check if at least one section is open
    BOOL isOneSectionOpen = NO;
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        if ([self.tableViewSimulator.tableView isSectionOpen:i]) {
            isOneSectionOpen = YES;
        }
    }
    XCTAssert(!isOneSectionOpen, @"All sections should be closed when 'keepOneSectionOpen' is set as FASLE.");
}

#pragma mark - Property 'initialOpenSections' Tests -

- (void)testInitialOpenSections {
    NSMutableArray *initialOpenSections = [NSMutableArray new];
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [initialOpenSections addObject:@(i)];
    }
    self.tableViewSimulator.tableView.initialOpenSections = [NSSet setWithArray:initialOpenSections];
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        XCTAssert([self.tableViewSimulator.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
}

#pragma mark - Property 'sectionsAlwaysOpen' Tests -

- (void)testSectionsAlwaysOpen {
    NSMutableArray *sectionsAlwaysOpen = [NSMutableArray new];
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [sectionsAlwaysOpen addObject:@(i)];
    }
    self.tableViewSimulator.tableView.sectionsAlwaysOpen = [NSSet setWithArray:sectionsAlwaysOpen];
    // Test that no matter which way you toggle the section, the section remains open.
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
        XCTAssert([self.tableViewSimulator.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.tableViewSimulator.tableView toggleSection:i];
        XCTAssert([self.tableViewSimulator.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
}

#pragma mark - Deletion Tests -

- (void)testDeletingRowWithOpenSection {
    
    NSInteger section = 0;
    
    [self.tableViewSimulator.tableView toggleSection:section];
    XCTAssert([self.tableViewSimulator.tableView isSectionOpen:section], @"Section %d should be open.", (int)section);
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] == [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
    
    NSInteger numberOfRows = [self.tableViewSimulator.sections[section] integerValue];
    self.tableViewSimulator.sections[section] = @(numberOfRows-1);
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] != [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
    
    // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
    @try {
        [self.tableViewSimulator.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    @catch(NSException *exception) { }
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] == [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection' after deletion.", (int)section);
}

- (void)testDeletingRowWithClosedSection {
    
    NSInteger section = 0;
    
    XCTAssert(![self.tableViewSimulator.tableView isSectionOpen:section], @"Section %d should be closed.", (int)section);
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] == [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
    
    NSInteger numberOfRows = [self.tableViewSimulator.sections[section] integerValue];
    self.tableViewSimulator.sections[section] = @(numberOfRows-1);
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] != [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
    
    // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
    @try {
        [self.tableViewSimulator.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    @catch(NSException *exception) { }
    
    XCTAssert([self.tableViewSimulator.sections[section] integerValue] == [self.tableViewSimulator.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection' after deletion.", (int)section);
}

@end
