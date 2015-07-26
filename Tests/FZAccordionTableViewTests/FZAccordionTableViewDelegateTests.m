//
//  FZAccordionTableViewDelegateTests.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 6/14/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FZAccordionTableViewSimulator.h"

@interface FZAccordionTableViewDelegateTests : XCTestCase <FZAccordionTableViewDelegate>

@property (strong, nonatomic) FZAccordionTableViewSimulator *tableViewSimulator;

@property (nonatomic) BOOL willOpenSectionCalled;
@property (nonatomic) BOOL didOpenSectionCalled;
@property (nonatomic) BOOL willCloseSectionCalled;
@property (nonatomic) BOOL didCloseSectionCalled;

@end

@implementation FZAccordionTableViewDelegateTests

#pragma mark - Setup -

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.tableViewSimulator = [FZAccordionTableViewSimulator new];
    self.tableViewSimulator.delegate = self;
    self.willOpenSectionCalled = NO;
    self.didOpenSectionCalled = NO;
    self.willCloseSectionCalled = NO;
    self.didCloseSectionCalled = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.tableViewSimulator = nil;
}

#pragma mark - Tests -

- (void)testOpening {
    [self.tableViewSimulator.tableView toggleSection:0];
    XCTAssert(self.willOpenSectionCalled, @"On opening of a section, 'willOpenSection: must be called");
    // NOTE: 'didOpenSection' test needs to be written differently
}

- (void)testClosing {
    // First open
    [self.tableViewSimulator.tableView toggleSection:0];
    // Now, close
    [self.tableViewSimulator.tableView toggleSection:0];
    XCTAssert(self.willCloseSectionCalled, @"On closing of a section, 'willCloseSection: must be called");
    // NOTE: 'didCloseSection' test needs to be written differently
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.willOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.didOpenSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.willCloseSectionCalled = YES;
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.didCloseSectionCalled = YES;
}

@end
