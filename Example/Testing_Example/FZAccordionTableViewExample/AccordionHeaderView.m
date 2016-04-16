//
//  AccordionHeaderView.m
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "AccordionHeaderView.h"

@interface AccordionHeaderView()

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AccordionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.deleteButton addTarget:self action:@selector(pressedDeleteButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pressedDeleteButton {
    if (self.pressedDeleteButtonBlock) {
        self.pressedDeleteButtonBlock(self);
    }
}

@end
