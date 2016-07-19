//
//  FirstViewController.m
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 6/7/15.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import "MainViewController.h"
#import "AccordionHeaderView.h"
#include <stdlib.h>

static NSString *const kTableViewCellReuseIdentifier = @"TableViewCellReuseIdentifier";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FZAccordionTableViewDelegate>

@end

@implementation MainViewController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupTableView];
    // [self executeTestMethods];
}

- (void)setupData {
    NSInteger numberOfSections = 10 + arc4random_uniform(10);
    self.sections = [NSMutableArray new];
    for (NSInteger i = 0; i < numberOfSections; i++) {
        [self.sections addObject:@(arc4random_uniform(10))];
    }
}

- (void)setupTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellReuseIdentifier];
//    [self.tableView registerClass:[FZAccordionTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
}

/**
 These methods shouldn't be executed while testing.
 */
- (void)executeTestMethods {
    [self connectTableView];
    [self testSettingProperties];
    // [self testAddingSection];
    // [self testDeletingMultipleSectionsAtTheSameTime];
}

- (void)connectTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)testSettingProperties {
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
    //    self.tableView.allowMultipleSectionsOpen = NO;
//        self.tableView.keepOneSectionOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(4), @(6), nil];
}

- (void)testAddingSection {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger section = 100;
        [self.sections insertObject:@(3) atIndex:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    });
}

- (void)testDeletingMultipleSectionsAtTheSameTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
        [indexSet addIndex:0];
        [indexSet addIndex:2];
        
        [self.sections removeObjectAtIndex:2];
        [self.sections removeObjectAtIndex:0];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    });
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
    __weak typeof(self) weakSelf = self;
    headerView.pressedDeleteButtonBlock = ^(AccordionHeaderView *headerView) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSInteger section = [strongSelf.tableView sectionForHeaderView:headerView];
            [strongSelf.sections removeObjectAtIndex:section];
            [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        }
    };
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
    [self.delegate tableView:tableView willOpenSection:section withHeader:header];
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    [self.delegate tableView:tableView didOpenSection:section withHeader:header];
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    [self.delegate tableView:tableView willCloseSection:section withHeader:header];
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    [self.delegate tableView:tableView didCloseSection:section withHeader:header];
}

- (BOOL)tableView:(FZAccordionTableView *)tableView canInteractWithHeaderAtSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:canInteractWithHeaderAtSection:)]) {
        return [self.delegate tableView:tableView canInteractWithHeaderAtSection:section];
    }
    return YES;
}

@end
