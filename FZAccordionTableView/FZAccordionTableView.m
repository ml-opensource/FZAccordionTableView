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
#pragma mark - FZAccordionTableViewSection
#pragma mark -

@interface FZAccordionTableViewSection : NSObject
@property (nonatomic, getter=isOpen) BOOL open;
@property (nonatomic) NSInteger numberOfRows;
@end

@implementation FZAccordionTableViewSection
- (instancetype)initWithNumberOfRows:(NSInteger)numberOfRows {
    if (self = [super init]) {
        _numberOfRows = numberOfRows;
    }
    return self;
}
@end

#pragma mark -
#pragma mark - FZAccordionTableViewHeaderView
#pragma mark -

@protocol FZAccordionTableViewHeaderViewDelegate;

@interface FZAccordionTableViewHeaderView()

//@property (nonatomic) NSInteger section;
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
#pragma mark - FZAccordionTableView
#pragma mark - 

@interface FZAccordionTableView() <UITableViewDataSource, UITableViewDelegate, FZAccordionTableViewHeaderViewDelegate>

@property id<UITableViewDelegate, FZAccordionTableViewDelegate> subclassDelegate;
@property id<UITableViewDataSource> subclassDataSource;

//@property (strong, nonatomic) NSMutableSet *openedSections;
//@property (strong, nonatomic) NSMutableDictionary *numOfRowsForSection;
@property (strong, nonatomic) NSMutableArray <FZAccordionTableViewSection *> *sections; // <FZAccordionTableViewSection *>

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
//    _openedSections = [[NSMutableSet alloc] init];
//    _numOfRowsForSection = [NSMutab
    _sections = [NSMutableArray new];
    _allowMultipleSectionsOpen = NO;
    _enableAnimationFix = NO;
    _keepOneSectionOpen = NO;
}

#pragma mark - Helper methods -

- (BOOL)isSectionOpen:(NSInteger)section {
    return [self.sections[section] isOpen];
}

- (BOOL)isAlwaysOpenedSection:(NSInteger)section {
    return [self.sectionsAlwaysOpen containsObject:@(section)];
}

- (void)addOpenedSection:(NSInteger)section { // KRIS TODO: Rename this to markSectionOpen
    [self.sections[section] setOpen:YES];
}

- (void)removeOpenedSection:(NSInteger)section {
    [self.sections[section] setOpen:NO];
}

- (NSArray *)getIndexPathsForSection:(NSInteger)section {
    
    NSInteger numOfRows =  [self.sections[section] numberOfRows];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int row = 0; row < numOfRows; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    
    return indexPaths;
}

- (void)toggleSection:(NSInteger)section {
    
    FZAccordionTableViewHeaderView *headerView = (FZAccordionTableViewHeaderView *)[self headerViewForSection:section];
    [self tappedHeaderView:headerView];
}

- (NSInteger)sectionForHeaderView:(UITableViewHeaderFooterView *)headerView {
    
    NSInteger section = NSNotFound;
    NSInteger minSection = 0;
    NSInteger maxSection = self.numberOfSections;
    
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
        }
        else {
            maxSection = middleSection-1;
        }
    }
    
    return section;
}

#pragma mark - UITableView Overrides -

- (void)setDelegate:(id<UITableViewDelegate, FZAccordionTableViewDelegate>)delegate {
    self.subclassDelegate = delegate;
    super.delegate = self;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    self.subclassDataSource = dataSource;
    super.dataSource = self;
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
        [self.sections removeObjectAtIndex:section];
        // KRIS TODO: If the removed section is one that needs ot be oepned, we need to open the next section.
        // OR Refactor sections open to just be a delegate call "canOpen Section
//        [self.openedSections removeObject:@(section)];
    }];
    [super deleteSections:sections withRowAnimation:animation];
}

#pragma mark - Forwarding handling -

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
    
//    if (_sectionsAlwaysOpen != nil) {
//        for (NSNumber *alwaysOpenedSection in _sectionsAlwaysOpen) {
//            [self addOpenedSection:alwaysOpenedSection.integerValue];
//        }
//    }
}

- (void)setInitialOpenSections:(NSSet *)initialOpenedSections {
    _initialOpenSections = initialOpenedSections;
    
//    if (_initialOpenSections != nil) {
//        for (NSNumber *section in _initialOpenSections) {
//            [self addOpenedSection:section.integerValue];
//        }
//    }
}

#pragma mark - FZAccordionTableViewHeaderViewDelegate -

- (void)tappedHeaderView:(FZAccordionTableViewHeaderView *)sectionHeaderView {
    NSParameterAssert(sectionHeaderView);
    
    NSInteger section = [self sectionForHeaderView:sectionHeaderView];
    
    // Do not interact with sections that are always opened
    if ([self isAlwaysOpenedSection:section]) {
        return;
    }
    
    // Keep at least one section open
    if (self.keepOneSectionOpen) {
        NSInteger countOfOpenSections = 0;
        
        for (NSInteger i = 0; i < self.numberOfSections; i++) {
            if ([self.sections[i] isOpen]) {
                countOfOpenSections++;
            }
        }
        
//        if (self.sectionsAlwaysOpen.count > 0) { // Subtract 'sectionsAlwaysOpen' from 'openedSections'
//            NSMutableSet *openedSectionsCopy = [self.openedSections mutableCopy];
//            [openedSectionsCopy minusSet:self.sectionsAlwaysOpen];
//            countOfOpenSections = openedSectionsCopy.count;
//        }
        
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
        // If any section is open beneath the one we are trying to open,
        // animate from the bottom
        for (NSInteger i = section-1; i >= 0; i--) {
            if ([self.sections[i] isOpen]) {
                insertAnimation = UITableViewRowAnimationBottom;
            }
        }
    }
    
    // KRIS TODO: Fix
//    if (self.enableAnimationFix) {
//        if (self.openedSections.count > 0 &&
//            (section == self.sections.count-1 || section == self.sections.count-2) &&
//            !self.allowsMultipleSelection) {
//            insertAnimation = UITableViewRowAnimationFade;
//        }
//    }
    
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
    for (NSInteger i = 0; i < self.numberOfSections; i++) {
        FZAccordionTableViewSection *sectionInfo = self.sections[i];
        if (section != i && sectionInfo.isOpen && ![self isAlwaysOpenedSection:i]) {
            [sectionsToClose addObject:@(i)];
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
            if ((sectionToClose.integerValue == self.sections.count - 1 ||
                 sectionToClose.integerValue == self.sections.count - 2) &&
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numOfSections = 1; // Default value for UITableView is 1
    
    if ([self.subclassDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        numOfSections = [self.subclassDataSource numberOfSectionsInTableView:tableView];
    }
    
    // Initialize an empty array filled with @(0)
//    id sections[numOfSections];
//    memset(sections, (int)[NSNumber numberWithInt:0], numOfSections);
//    self.numberOfRowsInSection = [NSMutableArray arrayWithObjects:sections count:numOfSections];
//    self.numberOfRowsInSection = [NSMutableArray arrayWithCapacity:numOfSections];
//    NSMutableArray *newNumberOfRowsInSection = [NSMutableArray arrayWithCapacity:numOfSections];
    
    for (NSInteger i = self.sections.count; i < numOfSections; i++) {
        FZAccordionTableViewSection *section = [[FZAccordionTableViewSection alloc] initWithNumberOfRows:0];
        section.open = NO;
        [self.sections addObject:section];
        // KRIS TO DO: Handle sections always open and initial open sections.
    }
    
    
    // First time
    // it's less
    // it's more
    
    
    // we must maintain the correct size, yet also copy in the left-over elements.
    
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numOfRows = 0;
    
    if ([self.subclassDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        numOfRows = [self.subclassDataSource tableView:tableView numberOfRowsInSection:section];;
    }
    [self.sections[section] setNumberOfRows:numOfRows];
    
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
            headerView.delegate = self;
        }
    }
    
    return headerView;
}

@end
