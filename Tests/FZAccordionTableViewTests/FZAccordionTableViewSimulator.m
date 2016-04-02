//
//  FZAccordionTableViewSimulator.m
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 6/14/15.
//
//

#import "FZAccordionTableViewSimulator.h"

static NSString *const kTableViewCellReuseIdentifier = @"TableViewCellReuseIdentifier";
static NSString *const kTableViewHeaderViewReuseIdentifier = @"TableViewHeaderViewReuseIdentifier";

@interface FZAccordionTableViewSimulator() <UITableViewDelegate, UITableViewDataSource, FZAccordionTableViewDelegate>

@property (strong, nonatomic, readwrite) FZAccordionTableView *tableView;

@end

@implementation FZAccordionTableViewSimulator

#pragma mark - Lifecycle -

- (instancetype)init {
    if (self = [super init]) {
        _tableView = [FZAccordionTableView new];
        _sections = [NSMutableArray new];
        [self setupData];
        [self setupTableView];
    }
    return self;
}

- (void)setupData {
    for (NSInteger i = 0; i < kAccordionSimulatorNumberOfSections; i++) {
        [self.sections addObject:@(kAccordionSimulatorNumberOfRows)];
    }
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellReuseIdentifier];
    [self.tableView registerClass:[FZAccordionTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kTableViewHeaderViewReuseIdentifier];
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource> / <UITableViewDelegate> -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifier forIndexPath:indexPath];;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewHeaderViewReuseIdentifier];
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

@end
