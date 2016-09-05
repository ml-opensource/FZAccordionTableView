//
//  FZAccordionTableView.m
//  FZAccordionTableView
//
//  Created by Krisjanis Gaidis on 7/31/14.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "FZAccordionTableView.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark - FZAccordionTableViewHeaderView
#pragma mark -

@protocol FZAccordionTableViewHeaderViewDelegate;

@interface FZAccordionTableViewHeaderView()

@property (nonatomic, weak) id <FZAccordionTableViewHeaderViewDelegate> delegate;

@end

@protocol FZAccordionTableViewHeaderViewDelegate <NSObject>
- (void)tappedHeaderView:(FZAccordionTableViewHeaderView *)sectionHeaderView;
@end

@implementation FZAccordionTableViewHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self singleInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self singleInit];
    }
    return self;
}

- (void)singleInit {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedHeaderView:)]];
}

- (void)touchedHeaderView:(UITapGestureRecognizer *)recognizer {
    [self.delegate tappedHeaderView:self];
}

@end

#pragma mark -
#pragma mark - FZAccordionTableViewSectionInfo
#pragma mark -

@interface FZAccordionTableViewSectionInfo : NSObject
@property (nonatomic, getter=isOpen) BOOL open;
@property (nonatomic) NSInteger numberOfRows;
@end

@implementation FZAccordionTableViewSectionInfo
- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows {
    if (self = [super init]) {
        _numberOfRows = numberOfRows;
    }
    return self;
}
@end

#pragma mark -
#pragma mark - FZAccordionTableViewDelegateProxy
#pragma mark -

@interface FZAccordionTableViewDelegateProxy : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak, readonly) FZAccordionTableView *accordionTableView;
- (instancetype)initWithAccordionTableView:(FZAccordionTableView *)accordionTableView;
@end

#pragma mark -
#pragma mark - FZAccordionTableView
#pragma mark - 

@interface FZAccordionTableView() <FZAccordionTableViewHeaderViewDelegate>

@property (nonatomic, strong) FZAccordionTableViewDelegateProxy *delegateProxy;

@property (weak, nonatomic) id<UITableViewDelegate, FZAccordionTableViewDelegate> subclassDelegate;
@property (weak, nonatomic) id<UITableViewDataSource> subclassDataSource;

@property (nonatomic) BOOL numberOfSectionsCalled;
@property (strong, nonatomic) NSMutableSet *mutableInitialOpenSections;
@property (strong, nonatomic) NSMutableArray <FZAccordionTableViewSectionInfo *> *sectionInfos;

@end

@implementation FZAccordionTableView

#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self initializeVars];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeVars];
    }
    return self;
}

- (void)initializeVars {
    _sectionInfos = [NSMutableArray new];
    _numberOfSectionsCalled = NO;
    _allowMultipleSectionsOpen = NO;
    _enableAnimationFix = NO;
    _keepOneSectionOpen = NO;
    _delegateProxy = [[FZAccordionTableViewDelegateProxy alloc] initWithAccordionTableView:self];
}

#pragma mark - Override Setters -

- (void)setInitialOpenSections:(NSSet *)initialOpenedSections {
    NSAssert(self.sectionInfos.count == 0, @"'initialOpenedSections' MUST be set before the tableView has started loading data.");
    _initialOpenSections = initialOpenedSections;
    _mutableInitialOpenSections = [initialOpenedSections mutableCopy];
}

#pragma mark - UITableView Overrides -

- (void)setDelegate:(id<UITableViewDelegate, FZAccordionTableViewDelegate>)delegate {
    self.subclassDelegate = delegate;
    super.delegate = self.delegateProxy;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    self.subclassDataSource = dataSource;
    super.dataSource = self.delegateProxy;
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
       FZAccordionTableViewSectionInfo *sectionInfo = [[FZAccordionTableViewSectionInfo alloc] initWithNumberOfRows:0];
        [self.sectionInfos insertObject:sectionInfo atIndex:section];
    }];
    
    [super insertSections:sections withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    
    // Remove section info in reverse order to prevent array from
    // removing the wrong section due to the stacking effect of arrays
    [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
        [self.sectionInfos removeObjectAtIndex:section];
    }];
    
    [super deleteSections:sections withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
#ifdef DEBUG
    for (NSIndexPath *indexPath in indexPaths) {
        NSAssert([self isSectionOpen:indexPath.section], @"Can't insert rows in a closed section: %d.", (int)indexPath.section);
    }
#endif
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

#pragma mark - Public Helper Methods -

- (BOOL)isSectionOpen:(NSInteger)section {
    return [self.sectionInfos[section] isOpen];
}

- (void)toggleSection:(NSInteger)section { 
    FZAccordionTableViewHeaderView *headerView = (FZAccordionTableViewHeaderView *)[self headerViewForSection:section];
    [self toggleSection:section withHeaderView:headerView];
}

- (NSInteger)sectionForHeaderView:(UITableViewHeaderFooterView *)headerView {
    
    NSInteger section = NSNotFound;
    NSInteger minSection = 0;
    NSInteger maxSection = self.numberOfSections-1;
    
    CGRect headerViewFrame = headerView.frame;
    CGRect compareHeaderViewFrame;
    
    while (minSection <= maxSection) {
        NSInteger middleSection = (minSection+maxSection)/2;
        compareHeaderViewFrame = [self rectForHeaderInSection:middleSection];
        if (CGRectEqualToRect(headerViewFrame, compareHeaderViewFrame)) {
            section = middleSection;
            break;
        }
        else if (headerViewFrame.origin.y > compareHeaderViewFrame.origin.y) {
            minSection = middleSection+1;
            section = middleSection; // Occurs when headerView sticks to the top
        }
        else {
            maxSection = middleSection-1;
        }
    }
    
    return section;
}

#pragma mark - Private Utility Helpers -

- (void)markSection:(NSInteger)section open:(BOOL)open {
    [self.sectionInfos[section] setOpen:open];
}

- (NSArray *)getIndexPathsForSection:(NSInteger)section {
    NSInteger numOfRows = [self.sectionInfos[section] numberOfRows];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int row = 0; row < numOfRows; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    return indexPaths;
}

- (BOOL)canInteractWithHeaderAtSection:(NSInteger)section {
    BOOL canInteractWithHeader = YES;
    if ([self.delegate respondsToSelector:@selector(tableView:canInteractWithHeaderAtSection:)]) {
        canInteractWithHeader = [self.subclassDelegate tableView:self canInteractWithHeaderAtSection:section];
    }
    return canInteractWithHeader;
}

#pragma mark - <FZAccordionTableViewHeaderViewDelegate> -

- (void)tappedHeaderView:(FZAccordionTableViewHeaderView *)sectionHeaderView {
    NSParameterAssert(sectionHeaderView);
    
    NSInteger section = [self sectionForHeaderView:sectionHeaderView];
    [self toggleSection:section withHeaderView:sectionHeaderView];
}

- (void)closeAllSectionsExcept:(NSInteger)section {
    // Get all of the sections that we need to close
    NSMutableSet *sectionsToClose = [[NSMutableSet alloc] init];
    for (NSInteger i = 0; i < self.numberOfSections; i++) {
        FZAccordionTableViewSectionInfo *sectionInfo = self.sectionInfos[i];
        if (section != i && sectionInfo.isOpen) {
            [sectionsToClose addObject:@(i)];
        }
    }
    
    // Close the found sections
    for (NSNumber *sectionToClose in sectionsToClose) {
        
        // Change animations based off which sections are closed
        UITableViewRowAnimation closeAnimation = UITableViewRowAnimationTop;
        if (section < sectionToClose.integerValue) {
            closeAnimation = UITableViewRowAnimationBottom;
        }
        if (self.enableAnimationFix) {
            if (!self.allowsMultipleSelection &&
                (sectionToClose.integerValue == self.sectionInfos.count - 1 ||
                 sectionToClose.integerValue == self.sectionInfos.count - 2)) {
                    closeAnimation = UITableViewRowAnimationFade;
                }
        }
        
        [self closeSection:sectionToClose.integerValue withHeaderView:(FZAccordionTableViewHeaderView *)[self headerViewForSection:sectionToClose.integerValue] rowAnimation:closeAnimation];
    }
}

#pragma mark - Open / Closing

- (void)toggleSection:(NSInteger)section withHeaderView:(nullable FZAccordionTableViewHeaderView *)sectionHeaderView {
    if (![self canInteractWithHeaderAtSection:section]) {
        return;
    }
    
    // Keep at least one section open
    if (self.keepOneSectionOpen) {
        NSInteger countOfOpenSections = 0;
        
        for (NSInteger i = 0; i < self.numberOfSections; i++) {
            if ([self.sectionInfos[i] isOpen]) {
                countOfOpenSections++;
            }
        }
        
        if (countOfOpenSections == 1 && [self isSectionOpen:section]) {
            return;
        }
    }
    
    BOOL openSection = [self isSectionOpen:section];
    
    [self beginUpdates];
    
    // Insert/remove rows to simulate opening/closing of a header
    if (!openSection) {
        [self openSection:section withHeaderView:sectionHeaderView];
    }
    else { // The section is currently open
        [self closeSection:section withHeaderView:sectionHeaderView];
    }
    
    // Auto-collapse the rest of the opened sections
    if (!self.allowMultipleSectionsOpen && !openSection) {
        [self closeAllSectionsExcept:section];
    }
    
    [self endUpdates];
}

- (void)openSection:(NSInteger)section withHeaderView:(nullable FZAccordionTableViewHeaderView *)sectionHeaderView {
    if (![self canInteractWithHeaderAtSection:section]) {
        return;
    }
    
    if ([self.subclassDelegate respondsToSelector:@selector(tableView:willOpenSection:withHeader:)]) {
        [self.subclassDelegate tableView:self willOpenSection:section withHeader:sectionHeaderView];
    }
    
    UITableViewRowAnimation insertAnimation = UITableViewRowAnimationTop;
    if (!self.allowMultipleSectionsOpen) {
        // If any section is open beneath the one we are trying to open,
        // animate from the bottom
        for (NSInteger i = section-1; i >= 0; i--) {
            if ([self.sectionInfos[i] isOpen]) {
                insertAnimation = UITableViewRowAnimationBottom;
            }
        }
    }
    
    if (self.enableAnimationFix) {
        if (!self.allowsMultipleSelection &&
            (section == self.numberOfSections-1 || section == self.numberOfSections-2)) {
            insertAnimation = UITableViewRowAnimationFade;
        }
    }
    
    NSArray *indexPathsToModify = [self getIndexPathsForSection:section];
    [self markSection:section open:YES];
    [self beginUpdates];
    [CATransaction setCompletionBlock:^{
        if ([self.subclassDelegate respondsToSelector:@selector(tableView:didOpenSection:withHeader:)]) {
            [self.subclassDelegate tableView:self didOpenSection:section withHeader:sectionHeaderView];
        }
    }];
    [self insertRowsAtIndexPaths:indexPathsToModify withRowAnimation:insertAnimation];
    [self endUpdates];
}

- (void)closeSection:(NSInteger)section withHeaderView:(nullable FZAccordionTableViewHeaderView *)sectionHeaderView {
    [self closeSection:section withHeaderView:sectionHeaderView rowAnimation:UITableViewRowAnimationTop];
}

- (void)closeSection:(NSInteger)section withHeaderView:(nullable FZAccordionTableViewHeaderView *)sectionHeaderView rowAnimation:(UITableViewRowAnimation)rowAnimation {
    if (![self canInteractWithHeaderAtSection:section]) {
        return;
    }
    
    if ([self.subclassDelegate respondsToSelector:@selector(tableView:willCloseSection:withHeader:)]) {
        [self.subclassDelegate tableView:self willCloseSection:section withHeader:sectionHeaderView];
    }
    NSArray *indexPathsToModify = [self getIndexPathsForSection:section];
    [self markSection:section open:NO];
    [self beginUpdates];
    [CATransaction setCompletionBlock: ^{
        if ([self.subclassDelegate respondsToSelector:@selector(tableView:didCloseSection:withHeader:)]) {
            [self.subclassDelegate tableView:self didCloseSection:section withHeader:sectionHeaderView];
        }
    }];
    [self deleteRowsAtIndexPaths:indexPathsToModify withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
}

@end

#pragma mark -
#pragma mark - FZAccordionTableViewDelegateProxy
#pragma mark -

@implementation FZAccordionTableViewDelegateProxy

- (instancetype)initWithAccordionTableView:(FZAccordionTableView *)accordionTableView
{
    if (self = [super init]) {
        _accordionTableView = accordionTableView;
    }
    return self;
}

#pragma mark - Forwarding handling -

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.accordionTableView.subclassDataSource respondsToSelector:aSelector]) {
        return self.accordionTableView.subclassDataSource;
    }
    else if ([self.accordionTableView.subclassDelegate respondsToSelector:aSelector]) {
        return self.accordionTableView.subclassDelegate;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.accordionTableView.subclassDelegate respondsToSelector:aSelector] || [self.accordionTableView.subclassDataSource respondsToSelector:aSelector];
}

#pragma mark - <UITableViewDataSource> -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.accordionTableView.numberOfSectionsCalled = YES;
    
    NSInteger numOfSections = 1; // Default value for UITableView is 1
    
    if ([self.accordionTableView.subclassDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        numOfSections = [self.accordionTableView.subclassDataSource numberOfSectionsInTableView:tableView];
    }
    
    // Create 'FZAccordionTableViewSectionInfo' objects to represent each section
    for (NSInteger i = self.accordionTableView.sectionInfos.count; i < numOfSections; i++) {
        FZAccordionTableViewSectionInfo *section = [[FZAccordionTableViewSectionInfo alloc] initWithNumberOfRows:0];
        
        // Account for any initial open sections
        if (self.accordionTableView.mutableInitialOpenSections.count > 0 && [self.accordionTableView.mutableInitialOpenSections containsObject:@(i)]) {
            section.open = YES;
            [self.accordionTableView.mutableInitialOpenSections removeObject:@(i)];
        }
        
        [self.accordionTableView.sectionInfos addObject:section];
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.accordionTableView.numberOfSectionsCalled) {
        // There is some potential UITableView bug where
        // 'tableView:numberOfRowsInSection:' gets called before
        // 'numberOfSectionsInTableView' gets called.
        return 0;
    }
    
    NSInteger numOfRows = 0;
    
    if ([self.accordionTableView.subclassDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        numOfRows = [self.accordionTableView.subclassDataSource tableView:tableView numberOfRowsInSection:section];;
    }
    
    [self.accordionTableView.sectionInfos[section] setNumberOfRows:numOfRows];
    
    if (![self.accordionTableView isSectionOpen:section]) {
        numOfRows = 0;
    }
    
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // We implement this purely to satisfy the Xcode UITableViewDataSource warning
    return [self.accordionTableView.subclassDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - <UITableViewDelegate> -

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    FZAccordionTableViewHeaderView *headerView = nil;
    
    if ([self.accordionTableView.subclassDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        headerView = (FZAccordionTableViewHeaderView *)[self.accordionTableView.subclassDelegate tableView:tableView viewForHeaderInSection:section];
        if ([headerView isKindOfClass:[FZAccordionTableViewHeaderView class]]) {
            headerView.delegate = self.accordionTableView;
        }
    }
    
    return headerView;
}

@end
