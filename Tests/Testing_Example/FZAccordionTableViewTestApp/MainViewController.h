//
//  FirstViewController.h
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZAccordionTableView.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) id <FZAccordionTableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *sections;

- (void)connectTableView;

@end
