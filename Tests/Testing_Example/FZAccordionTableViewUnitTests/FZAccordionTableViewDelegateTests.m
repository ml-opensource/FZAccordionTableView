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
}

- (void)tearDown {
    [super tearDown];
    self.mainViewController.delegate = nil;
}

#pragma mark - Tests -

- (void)testOpening {
    [self waitForHeaderViewInSection:0];
    [self.tableView toggleSection:0];
    
    XCTAssert(self.willOpenSectionCalled, @"On opening of a section, 'willOpenSection:' must be called");
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    XCTAssert(self.didOpenSectionCalled, @"On opening of a section, 'didOpenSection:' must be called");
}

- (void)testClosing {
    
    [self waitForHeaderViewInSection:0];
    // First open
    [self.tableView toggleSection:0];
    // Now, close
    [self.tableView toggleSection:0];
    
    XCTAssert(self.willCloseSectionCalled, @"On closing of a section, 'willCloseSection:' must be called");
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
    XCTAssert(self.didCloseSectionCalled, @"On closing of a section, 'didCloseSection:' must be called");
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView * _Nonnull)header {
    XCTAssertNotNil(tableView);
    XCTAssertNotNil(header);
    self.willOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView * _Nonnull)header {
    XCTAssertNotNil(tableView);
    XCTAssertNotNil(header);
    self.didOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView * _Nonnull)header {
    XCTAssertNotNil(tableView);
    XCTAssertNotNil(header);
    self.willCloseSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView * _Nonnull)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView * _Nonnull)header {
    XCTAssertNotNil(tableView);
    XCTAssertNotNil(header);
    self.didCloseSectionCalled = YES;
}

@end
