//
//  FZAccordionTableViewDelegateTests.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/26/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import "FZAccordionTableViewTestBase.h"

@interface FZAccordionTableViewDelegateTests : FZAccordionTableViewTestBase <FZAccordionTableViewDelegate>

@property (nonatomic) BOOL willOpenSectionCalled;
@property (nonatomic) BOOL didOpenSectionCalled;
@property (nonatomic) BOOL willCloseSectionCalled;
@property (nonatomic) BOOL didCloseSectionCalled;
@property (nonatomic) BOOL canInteractWithHeaderAtSection;

@end

@implementation FZAccordionTableViewDelegateTests

#pragma mark - Setup -

- (void)setUp {
    [super setUp];
    [self.mainViewController connectTableView];
    self.mainViewController.delegate = self;
    self.willOpenSectionCalled = NO;
    self.didOpenSectionCalled = NO;
    self.willCloseSectionCalled = NO;
    self.didCloseSectionCalled = NO;
    self.canInteractWithHeaderAtSection = YES;
}

- (void)tearDown {
    [super tearDown];
    self.mainViewController.delegate = nil;
}

#pragma mark - Test Open / Close Delegate Calls -

- (void)testOpening {
    XCTAssert(!self.willOpenSectionCalled);
    XCTAssert(!self.didOpenSectionCalled);
    
    [self waitForHeaderViewInSection:0];
    [self.tableView toggleSection:0];
    
    XCTAssert(self.willOpenSectionCalled, @"On opening of a section, 'willOpenSection:' must be called");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"On opening of a section, 'didOpenSection:' must be called"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.didOpenSectionCalled) {
            [expectation fulfill];
        }
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) { }];
}

- (void)testClosing {
    XCTAssert(!self.willCloseSectionCalled);
    XCTAssert(!self.didCloseSectionCalled);
    
    [self waitForHeaderViewInSection:0];
    // First open
    [self.tableView toggleSection:0];
    // Now, close
    [self.tableView toggleSection:0];
    
    XCTAssert(self.willCloseSectionCalled, @"On closing of a section, 'willCloseSection:' must be called");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"On closing of a section, 'didCloseSection:' must be called"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.didCloseSectionCalled) {
            [expectation fulfill];
        }
    });
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) { }];
}

#pragma mark - Test Interaction Delegate Call -

- (void)testOpeningInteraction
{
    NSInteger section = 0;
    
    // Open section
    [self waitForHeaderViewInSection:section];
    [self.tableView toggleSection:section];
    XCTAssert([self.tableView isSectionOpen:section], @"Section must be open after opening it.");
    
    // Close it
    [self.tableView toggleSection:section];
    
    // Now try opening again
    self.canInteractWithHeaderAtSection = NO;
    [self.tableView toggleSection:section];
    XCTAssert(![self.tableView isSectionOpen:section], @"Section must be still closed after turning off interaction.");
}

- (void)testClosingInteraction
{
    NSInteger section = 0;
    
    // Test if section is closed
    [self waitForHeaderViewInSection:section];
    XCTAssert(![self.tableView isSectionOpen:section], @"Section must be closed at the start");
    
    // Open it
    [self.tableView toggleSection:section];
    XCTAssert([self.tableView isSectionOpen:section], @"Section must be open.");

    // Now try closing
    self.canInteractWithHeaderAtSection = NO;
    [self.tableView toggleSection:section];
    XCTAssert([self.tableView isSectionOpen:section], @"Section must be be open after turning off interaction.");
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView willOpenSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header {
    XCTAssertNotNil(tableView);
    self.willOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView didOpenSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header {
    XCTAssertNotNil(tableView);
    self.didOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView willCloseSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header {
    XCTAssertNotNil(tableView);
    self.willCloseSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView didCloseSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header {
    XCTAssertNotNil(tableView);
    self.didCloseSectionCalled = YES;
}

- (BOOL)tableView:(FZAccordionTableView * _Nonnull)tableView canInteractWithHeaderAtSection:(NSInteger)section
{
    return self.canInteractWithHeaderAtSection;
}

@end
