//
//  FZAccordionTableViewTestHelpers.h
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"

@interface FZAccordionTableViewTestHelpers : NSObject

+ (MainViewController *)setupMainViewController;
+ (void)tearDownMainViewController;

+ (void)waitForHeaderViewInSection:(NSInteger)section tableView:(FZAccordionTableView *)tableView;

@end
