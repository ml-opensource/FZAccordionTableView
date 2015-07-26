//
//  FZAccordionTableView.h
//  FZAccordionTableViewTest
//
//  Created by Krisjanis Gaidis on 7/31/14.
//  Copyright (c) 2015 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZAccordionTableViewHeaderView : UITableViewHeaderFooterView

/*!
 @desc  The section which this header view is part of.
 */
@property (nonatomic, readonly) NSInteger section;

@end

@interface FZAccordionTableView : UITableView

/*!
 @desc  If set to NO, a max of one section will be open at a time.
 
        If set to YES, any amount of sections can be open at a time.
 
        Use 'sectionsInitiallyOpen' to specify which section should be
        open at the start, otherwise, all sections will be closed at
        the start even if the property is set to YES.
 
        The default value is NO.
 */
@property (nonatomic) BOOL allowMultipleSectionsOpen;

/*!
 @desc  If set to YES, one section will always be open.
 
        If set to NO, all sections can be closed.
 
        Note that this does NOT influence 'sectionsAlwaysOpen.' Also,
        use 'sectionsInitiallyOpen' to specify which section should be 
        open at the start, otherwise, all sections will be closed at 
        the start even if the property is set to YES.
 
        The default value is NO.
 */
@property (nonatomic) BOOL keepOneSectionOpen;

/*!
 @desc  Defines which sections should be open the first time the
        table is shown.
 */
@property (strong, nonatomic) NSSet *initialOpenSections;

/*!
 @desc  Defines which sections will always be open.
        The headers of these sections will not call the
        FZAccordionTableViewDelegate methods.
 */
@property (strong, nonatomic) NSSet *sectionsAlwaysOpen;

/*!
 @desc  Enables the fading of cells for the last two rows of the
        table. The fix can remove some of the animation clunkyness
        that happens at the last table view cells.
    
        The default value is NO.
 */
@property (nonatomic) BOOL enableAnimationFix;

/*!
 @desc  Checks whether the provided section is open.
 
 @param section The section that needs to be checked if it's open.
 
 @returns YES if the section is open, otherwise NO.
 */
- (BOOL)isSectionOpen:(NSInteger)section;

/*!
 @desc  Simulates tapping of the header in the provided section.
 
 @param section The section whose header should be 'tapped.'
 */
- (void)toggleSection:(NSInteger)section;

@end

@protocol FZAccordionTableViewDelegate <NSObject>

@optional

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header;
- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header;

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header;
- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header;

@end