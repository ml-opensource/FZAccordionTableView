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

@property (nonatomic) NSInteger section;
@property (nonatomic, weak) id <FZAccordionTableViewHeaderViewDelegate> delegate;

@end

@protocol FZAccordionTableViewHeaderViewDelegate <NSObject>
- (void)headerView:(FZAccordionTableViewHeaderView *)sectionHeaderView didSelectHeaderInSection:(NSInteger)section;
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
    [self.delegate headerView:self didSelectHeaderInSection:self.section];
}

@end

#pragma mark -
#pragma mark - FZAccordionTableView
#pragma mark - 

@interface FZAccordionTableView() <UITableViewDataSource, UITableViewDelegate, FZAccordionTableViewHeaderViewDelegate>

@property id<UITableViewDelegate, FZAccordionTableViewDelegate> subclassDelegate;
@property id<UITableViewDataSource> subclassDataSource;

@property (strong, nonatomic) NSMutableSet *openedSections;
@property (strong, nonatomic) NSMutableDictionary *numOfRowsForSection;

@end

@implementation FZAccordionTableView

#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self initializeVars];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

- (id)init {
    if (self = [super init]) {
        [self initializeVars];
    }
    return self;
}

- (void)initializeVars {
    _openedSections = [[NSMutableSet alloc] init];
    _numOfRowsForSection = [NSMutableDictionary dictionary];
    _allowMultipleSectionsOpen = NO;
    _enableAnimationFix = NO;
    _keepOneSectionOpen = NO;
}

#pragma mark - Helper methods -

- (BOOL)isSectionOpen:(NSInteger)section {
    return [self.openedSections containsObject:@(section)];
}

- (BOOL)isAlwaysOpenedSection:(NSInteger)section {
    return [self.sectionsAlwaysOpen containsObject:@(section)];
}

- (void)addOpenedSection:(NSInteger)section {
    [self.openedSections addObject:@(section)];
}

- (void)removeOpenedSection:(NSInteger)section {
    [self.openedSections removeObject:@(section)];
}

- (NSArray *)getIndexPathsForSection:(NSInteger)section {
    
    NSInteger numOfRows =  [self.numOfRowsForSection[@(section)] integerValue];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int row = 0; row < numOfRows; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    
    return indexPaths;
}

- (void)toggleSection:(NSInteger)section {
    
    FZAccordionTableViewHeaderView *headerView = (FZAccordionTableViewHeaderView *)[self headerViewForSection:section];
    
    [self headerView:headerView didSelectHeaderInSection:section];
}

#pragma mark - Handle message forwarding -

- (void)setDelegate:(id<UITableViewDelegate, FZAccordionTableViewDelegate>)delegate {
    self.subclassDelegate = delegate;
    super.delegate = self;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    self.subclassDataSource = dataSource;
    super.dataSource = self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.subclassDataSource respondsToSelector:aSelector]) {
        return self.subclassDataSource;
    }
    else if ([self.subclassDelegate respondsToSelector:aSelector]) {
        return self.subclassDelegate;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.subclassDelegate respondsToSelector:aSelector] || [self.subclassDataSource respondsToSelector:aSelector];
}

#pragma mark - Override Setters -

- (void)setSectionsAlwaysOpen:(NSSet *)alwaysOpenedSections {
    _sectionsAlwaysOpen = alwaysOpenedSections;
    
    if (_sectionsAlwaysOpen != nil) {
        for (NSNumber *alwaysOpenedSection in _sectionsAlwaysOpen) {
            [self addOpenedSection:alwaysOpenedSection.integerValue];
        }
    }
}

- (void)setInitialOpenSections:(NSSet *)initialOpenedSections {
    _initialOpenSections = initialOpenedSections;
    
    if (_initialOpenSections != nil) {
        for (NSNumber *section in _initialOpenSections) {
            [self addOpenedSection:section.integerValue];
        }
    }
}

#pragma mark - FZAccordionTableViewHeaderViewDelegate -

- (void)headerView:(FZAccordionTableViewHeaderView *)sectionHeaderView didSelectHeaderInSection:(NSInteger)section {
    
    // Do not interact with sections that are always opened
    if ([self isAlwaysOpenedSection:section]) {
        return;
    }
    
    // Keep at least one section open
    if (self.keepOneSectionOpen) {
        NSInteger countOfOpenSections = self.openedSections.count;
        
        if (self.sectionsAlwaysOpen.count > 0) { // Subtract 'sectionsAlwaysOpen' from 'openedSections'
            NSMutableSet *openedSectionsCopy = [self.openedSections mutableCopy];
            [openedSectionsCopy minusSet:self.sectionsAlwaysOpen];
            countOfOpenSections = openedSectionsCopy.count;
        }
        
        if (countOfOpenSections == 1 && [self isSectionOpen:section]) {
            return;
        }
    }
    
    BOOL openSection = [self isSectionOpen:section];
    
    // Create an array of index paths that will be inserted/removed
    NSArray *indexPathsToModify = [self getIndexPathsForSection:section];
    
    [self beginUpdates];
    
    // Insert/remove rows to simulate opening/closing of a header
    if (!openSection) {
        [self openSection:section withHeaderView:sectionHeaderView andIndexPaths:indexPathsToModify];
    }
    else { // The section is currently open
        [self closeSection:section withHeaderView:sectionHeaderView andIndexPaths:indexPathsToModify];
    }
    
    // Auto-collapse the rest of the opened sections
    if (!self.allowMultipleSectionsOpen && !openSection) {
        [self autoCollapseAllSectionsExceptSection:section];
    }
    
    [self endUpdates];
}

- (void)openSection:(NSInteger)section withHeaderView:(FZAccordionTableViewHeaderView *)sectionHeaderView andIndexPaths:(NSArray *)indexPathsToModify {
    if ([self.subclassDelegate respondsToSelector:@selector(tableView:willOpenSection:withHeader:)]) {
        [self.subclassDelegate tableView:self willOpenSection:section withHeader:sectionHeaderView];
    }
    
    UITableViewRowAnimation insertAnimation = UITableViewRowAnimationTop;
    if (!self.allowMultipleSectionsOpen) {
        for (NSNumber *openSection in self.openedSections) {
            if (openSection.integerValue < section) {
                insertAnimation = UITableViewRowAnimationBottom;
            }
        }
    }
    
    if (self.enableAnimationFix) {
        if (self.openedSections.count > 0 &&
            (section == self.numOfRowsForSection.count-1 || section == self.numOfRowsForSection.count-2) &&
            !self.allowsMultipleSelection) {
            insertAnimation = UITableViewRowAnimationFade;
        }
    }
    
    [self addOpenedSection:section];
    [self beginUpdates];
    [CATransaction setCompletionBlock:^{
        if ([self.subclassDelegate respondsToSelector:@selector(tableView:didOpenSection:withHeader:)]) {
            [self.subclassDelegate tableView:self didOpenSection:section withHeader:sectionHeaderView];
        }
    }];
    [self insertRowsAtIndexPaths:indexPathsToModify withRowAnimation:insertAnimation];
    [self endUpdates];
}

- (void)closeSection:(NSInteger)section withHeaderView:(FZAccordionTableViewHeaderView *)sectionHeaderView andIndexPaths:(NSArray *)indexPathsToModify {
    if ([self.subclassDelegate respondsToSelector:@selector(tableView:willCloseSection:withHeader:)]) {
        [self.subclassDelegate tableView:self willCloseSection:section withHeader:sectionHeaderView];
    }
    
    [self removeOpenedSection:section];
    [self beginUpdates];
    [CATransaction setCompletionBlock: ^{
        if ([self.subclassDelegate respondsToSelector:@selector(tableView:didCloseSection:withHeader:)]) {
            [self.subclassDelegate tableView:self didCloseSection:section withHeader:sectionHeaderView];
        }
    }];
    [self deleteRowsAtIndexPaths:indexPathsToModify withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
}

- (void)autoCollapseAllSectionsExceptSection:(NSInteger)section {
    // Get all of the sections that we need to close
    NSMutableSet *sectionsToClose = [[NSMutableSet alloc] init];
    for (NSNumber *openedSection in self.openedSections) {
        if (openedSection.integerValue != section && ![self isAlwaysOpenedSection:openedSection.integerValue]) {
            [sectionsToClose addObject:openedSection];
        }
    }
    
    // Close the found sections
    for (NSNumber *sectionToClose in sectionsToClose) {
        
        if ([self.subclassDelegate respondsToSelector:@selector(tableView:willCloseSection:withHeader:)]) {
            [self.subclassDelegate tableView:self willCloseSection:sectionToClose.integerValue withHeader:[self headerViewForSection:sectionToClose.integerValue]];
        }
        
        // Change animations based off which sections are closed
        UITableViewRowAnimation closeAnimation = UITableViewRowAnimationTop;
        if (section < sectionToClose.integerValue) {
            closeAnimation = UITableViewRowAnimationBottom;
        }
        if (self.enableAnimationFix) {
            if ((sectionToClose.integerValue == self.numOfRowsForSection.count - 1 ||
                 sectionToClose.integerValue == self.numOfRowsForSection.count - 2) &&
                !self.allowsMultipleSelection) {
                closeAnimation = UITableViewRowAnimationFade;
            }
        }
        
        // Delete the cells for section that is closing
        NSArray *indexPathsToDelete = [self getIndexPathsForSection:sectionToClose.integerValue];
        [self removeOpenedSection:sectionToClose.integerValue];
        
        [self beginUpdates];
        [CATransaction setCompletionBlock:^{
            if ([self.subclassDelegate respondsToSelector:@selector(tableView:didCloseSection:withHeader:)]) {
                [self.subclassDelegate tableView:self didCloseSection:sectionToClose.integerValue withHeader:[self headerViewForSection:sectionToClose.integerValue]];
            }
        }];
        [self deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:closeAnimation];
        [self endUpdates];
    }
}


#pragma mark - <UITableViewDataSource> -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numOfRows = 0;
    
    if ([self.subclassDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        numOfRows = [self.subclassDataSource tableView:tableView numberOfRowsInSection:section];;
    }
    self.numOfRowsForSection[@(section)] = @(numOfRows);
    
    return ([self isSectionOpen:section]) ? numOfRows : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // We implement this purely to satisfy the Xcode UITableViewDataSource warning
    return [self.subclassDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}
 
#pragma mark - <UITableViewDelegate> -

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    FZAccordionTableViewHeaderView *headerView = nil;
    
    if ([self.subclassDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        headerView = (FZAccordionTableViewHeaderView *)[self.subclassDelegate tableView:tableView viewForHeaderInSection:section];
        if ([headerView isKindOfClass:[FZAccordionTableViewHeaderView class]]) {
            headerView.section = section;
            headerView.delegate = self;
        }
    }
    
    return headerView;
}

@end
