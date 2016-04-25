//
//  FZAccordionTableViewUnitTests.m
//  FZAccordionTableViewUnitTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainViewController.h"
#include <stdlib.h>

@interface FZAccordionTableViewUnitTests : XCTestCase

@property (nonatomic, strong) MainViewController *mainViewController;

@end

@implementation FZAccordionTableViewUnitTests

#pragma mark - Helpers -

//- (MainViewController *)mainViewController {
//    
////    MainViewController *mainViewController = (MainViewController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
////    if (![mainViewController isKindOfClass:[MainViewController class]]) {
////        XCTFail(@"The view controller to test on is not correctly extracted. Aborting all tests.");
////    }
////    [mainViewController view];
//    
//    
//
//    return mainViewController;
//}

- (FZAccordionTableView *)tableView {
    FZAccordionTableView *tableView = self.mainViewController.tableView;
    XCTAssertNotNil(tableView);
    return tableView;
}
#pragma mark - Setup

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    MainViewController *mainViewController = (MainViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    if (![mainViewController isKindOfClass:[MainViewController class]]) {
        XCTFail(@"The view controller to test on is not correctly extracted. Aborting all tests.");
    }
    [[[UIApplication sharedApplication] delegate] window].rootViewController = mainViewController;
//    [mainViewController view];
    self.mainViewController = mainViewController;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[[UIApplication sharedApplication] delegate] window].rootViewController = nil;
    self.mainViewController = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (void)waitForHeaderViewInSection:(NSInteger)section
{
    NSInteger lastSection = -1;
    NSInteger randomzier = 1;
    while (![[self tableView] headerViewForSection:section]) {
        
        NSLog(@"%@", NSStringFromCGRect([[self tableView] rectForSection:section]));
        
        
        CGRect sectionRect = [[self tableView] rectForSection:section];
        sectionRect.origin.y -= 100;
        sectionRect.size.height += 100;
        [[self tableView] scrollRectToVisible:sectionRect animated:NO];
        
        
        if (lastSection == section) {
            randomzier++;
        }
        else {
            lastSection = section;
            randomzier = 1;
        }
        
        if (randomzier > 2) {
            CGFloat validContentOffSet = self.tableView.contentSize.height - self.tableView.bounds.size.height;
            CGPoint contentOffset = CGPointMake(0, 1 + arc4random_uniform(validContentOffSet)-10);
            
            
//            [[self tableView] setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:NO];
            
            [[self tableView] setContentOffset:CGPointMake(0, contentOffset.y) animated:NO];
            
            randomzier = 1;
        }
        
        lastSection = section;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

#pragma mark - Method 'isSectionOpen' Tests -

- (void)testClosedSections {
    for (NSInteger i = 0; i < [self tableView].numberOfSections; i++) {
        [self waitForHeaderViewInSection:i];
        
        XCTAssert(![[self tableView] isSectionOpen:i], @"All sections should be initially closed.");
    }
}

#pragma mark - Metohod 'toggleSection' Tests -


- (void)testSectionToggling {
    [self tableView].allowMultipleSectionsOpen = YES;
    [self tableView].keepOneSectionOpen = NO;
    
    // First, open all of the sections
    for (NSInteger i = 0; i < [[self tableView] numberOfSections]-1;  i++) {
        [self waitForHeaderViewInSection:i];
        [[self tableView] toggleSection:i];
        
        XCTAssert([[self tableView] isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
    
    // Second, close all of the section
    for (NSInteger i = 0; i < [[self tableView] numberOfSections]-1; i++) {
        [self waitForHeaderViewInSection:i];
        [[self tableView] toggleSection:i];
        
        XCTAssert(![[self tableView] isSectionOpen:i], @"Section %d should be closed.", (int)i);
    }
}

#pragma mark - Property 'allowMultipleSectionsOpen' Tests -

- (void)testAllowMultipleSectionsOpenAsTrue {
    [self tableView].allowMultipleSectionsOpen = YES;
    
    [self waitForHeaderViewInSection:0];
    [[self tableView] toggleSection:0];
    
    [self waitForHeaderViewInSection:1];
    [[self tableView] toggleSection:1];
    
    XCTAssert([[self tableView] isSectionOpen:0] && [[self tableView] isSectionOpen:1], @"Both sections should be open.");
}

- (void)testAllowMultipleSectionsOpenAsFalse {
    [self tableView].allowMultipleSectionsOpen = NO;
    
    [self waitForHeaderViewInSection:0];
    [[self tableView] toggleSection:0];
    
    [self waitForHeaderViewInSection:1];
    [[self tableView] toggleSection:1];
    
    XCTAssert(![[self tableView] isSectionOpen:0] && [[self tableView] isSectionOpen:1], @"Section 0 should be closed when Section 1 was being forced to be open.");
}

#pragma mark - Property 'initialOpenSections' Tests -

- (void)testInitialOpenSections {
    

    
    
    NSMutableArray *initialOpenSections = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        [initialOpenSections addObject:@(i)];
    }
    
    self.tableView.initialOpenSections = [NSSet setWithArray:initialOpenSections];
    
    
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        [self waitForHeaderViewInSection:i];
        
        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
    }
}
//
//#pragma mark - Property 'sectionsAlwaysOpen' Tests -
//
//- (void)testSectionsAlwaysOpen {
//    NSMutableArray *sectionsAlwaysOpen = [NSMutableArray new];
//    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
//        [sectionsAlwaysOpen addObject:@(i)];
//    }
//    self.tableView.sectionsAlwaysOpen = [NSSet setWithArray:sectionsAlwaysOpen];
//    
//    // Test that no matter which way you toggle the section, the section remains open.
//    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
//        [self waitForHeaderViewInSection:i];
//        [self.tableView toggleSection:i];
//        
//        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
//    }
//    
//    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
//        [self waitForHeaderViewInSection:i];
//        [self.tableView toggleSection:i];
//        
//        XCTAssert([self.tableView isSectionOpen:i], @"Section %d should be open.", (int)i);
//    }
//}

//#pragma mark - Deletion Tests -
//
//- (void)testDeletingRowWithOpenSection {
//    
//    NSInteger section = 0;
//    
//    [self.mainViewController.tableView toggleSection:section];
//    XCTAssert([self.mainViewController.tableView isSectionOpen:section], @"Section %d should be open.", (int)section);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
//    
//    NSInteger numberOfRows = [self.mainViewController.sections[section] integerValue];
//    self.mainViewController.sections[section] = @(numberOfRows-1);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] != [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
//    
//    // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
//    @try {
//        [self.mainViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
//    }
//    @catch(NSException *exception) { }
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection' after deletion.", (int)section);
//}
//
//- (void)testDeletingRowWithClosedSection {
//    
//    NSInteger section = 0;
//    
//    XCTAssert(![self.mainViewController.tableView isSectionOpen:section], @"Section %d should be closed.", (int)section);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection'", (int)section);
//    
//    NSInteger numberOfRows = [self.mainViewController.sections[section] integerValue];
//    self.mainViewController.sections[section] = @(numberOfRows-1);
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] != [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"Without calling 'deleteForRows' there should be a difference between data source and what the tableView says.");
//    
//    // Calling 'deleteRowsAtIndexPaths' propogates the necessary methods/changes, but throws an exception that we can just ignore.
//    @try {
//        [self.mainViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numberOfRows-1 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
//    }
//    @catch(NSException *exception) { }
//    
//    XCTAssert([self.mainViewController.sections[section] integerValue] == [self.mainViewController.tableView.numOfRowsForSection[@(section)] integerValue], @"The number of rows in section %d of our data source should match those of the FZAccordionTableView 'numOfRowsForSection' after deletion.", (int)section);
//}

#pragma mark - Duds

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    [self mainViewController];
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
