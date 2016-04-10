//
//  FirstViewController.m
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "FirstViewController.h"
#import "FZAccordionTableView.h"
#import "AccordionHeaderView.h"
#include <stdlib.h>

static NSString *const kTableViewCellReuseIdentifier = @"TableViewCellReuseIdentifier";

@interface FirstViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray <NSNumber *> *sections;
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;

@end

@implementation FirstViewController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupTableView];
}

- (void)setupData {
    self.sections = [NSMutableArray new];
    for (NSInteger i = 0; i < 10; i++) {
        [self.sections addObject:@(arc4random_uniform(10))];
    }
}

- (void)setupTableView {
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowMultipleSectionsOpen = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellReuseIdentifier];
//    [self.tableView registerClass:[FZAccordionTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
}

#pragma mark - Action -

- (IBAction)pressedDeleteButton:(UIButton *)sender {
    // Don't use tag in real code
    [self.sections removeObjectAtIndex:sender.tag];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Class Overrides -

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] integerValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDefaultAccordionHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"Cell";
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AccordionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAccordionHeaderViewReuseIdentifier];
    headerView.deleteButton.tag = section; // This is bad code, but works for testing!
    [headerView.deleteButton addTarget:self action:@selector(pressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.sections[indexPath.section] =  @([self.sections[indexPath.section] integerValue] - 1);
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {

}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {

}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {

}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

@end
