//
//  FZAccordionTableViewTestHelpers.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/24/16.
//  Copyright © 2016 Fuzz. All rights reserved.
//

#import "FZAccordionTableViewTestHelpers.h"

@implementation FZAccordionTableViewTestHelpers

+ (MainViewController *)setupMainViewController {
    MainViewController *mainViewController = (MainViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    if (![mainViewController isKindOfClass:[MainViewController class]]) {
        return nil;
    }
    
    [[[UIApplication sharedApplication] delegate] window].rootViewController = mainViewController;
    [mainViewController view];
    
    return mainViewController;
}

+ (void)tearDownMainViewController {
    [[[UIApplication sharedApplication] delegate] window].rootViewController = nil;
}

+ (void)waitForHeaderViewInSection:(NSInteger)section tableView:(FZAccordionTableView *)tableView {
    NSInteger lastSection = -1;
    
    while (![tableView headerViewForSection:section]) {
        NSLog(@"%@", NSStringFromCGRect([tableView rectForSection:section]));

        if (lastSection == section) {
            CGFloat validContentOffSet = tableView.contentSize.height - tableView.bounds.size.height;
            CGPoint contentOffset = CGPointMake(0, 1 + arc4random_uniform(validContentOffSet)-10);
            //            [tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:NO];
            [tableView setContentOffset:CGPointMake(0, contentOffset.y) animated:NO];
        }
        else {
            CGRect sectionRect = [tableView rectForSection:section];
            sectionRect.origin.y -= 100;
            sectionRect.size.height += 100;
            [tableView scrollRectToVisible:sectionRect animated:NO];
        }
        
        lastSection = section;
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
}


@end
