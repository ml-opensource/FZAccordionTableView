//
//  FZAccordionTableViewTestBase.h
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/26/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FZAccordionTableViewTestHelpers.h"

@interface FZAccordionTableViewTestBase : XCTestCase

@property (strong, nonatomic) MainViewController *mainViewController;
@property (weak, nonatomic) FZAccordionTableView *tableView;

- (void)waitForHeaderViewInSection:(NSInteger)section;

@end
