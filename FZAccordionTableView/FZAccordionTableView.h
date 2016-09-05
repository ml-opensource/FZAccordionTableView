//
//  FZAccordionTableView.h
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

#import <UIKit/UIKit.h>

@interface FZAccordionTableViewHeaderView : UITableViewHeaderFooterView

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
 
        Use 'sectionsInitiallyOpen' to specify which section should be
        open at the start, otherwise, all sections will be closed at 
        the start even if the property is set to YES.
 
        The default value is NO.
 */
@property (nonatomic) BOOL keepOneSectionOpen;

/*!
 @desc  Defines which sections should be open the first time the
        table is shown.
 
        Must be set before any data is loaded.
 */
@property (strong, nonatomic, nullable) NSSet <NSNumber *> *initialOpenSections;

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

/*!
 @desc  Finds the section of a header view.
 
 @param headerView The header view whose section must be found.
 
 @returns The section of the header view.
 */
- (NSInteger)sectionForHeaderView:(nonnull UITableViewHeaderFooterView *)headerView;

@end

/*!
 `header` can be `nil` in some of the delegate methods if the header
 is not visible.
 */
@protocol FZAccordionTableViewDelegate <NSObject>

@optional

/*!
 @desc  Implement to respond to which sections can be interacted with.
 
        If NO is returned for a section, the section can neither be opened or closed. 
        It stays in it's initial state no matter what.
 
        Use 'initialOpenSections' to mark a section open from the start.
 
        The default return value is YES.
 */
- (BOOL)tableView:(nonnull FZAccordionTableView *)tableView canInteractWithHeaderAtSection:(NSInteger)section;

- (void)tableView:(nonnull FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header;
- (void)tableView:(nonnull FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header;

- (void)tableView:(nonnull FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header;
- (void)tableView:(nonnull FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(nullable UITableViewHeaderFooterView *)header;

@end
