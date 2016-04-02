//
//  FZAccordionTableView+Internals.h
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 4/2/16.
//
//

#import "FZAccordionTableView.h"

@interface FZAccordionTableView (Internals)

@property (strong, nonatomic) NSMutableSet *openedSections;
@property (strong, nonatomic) NSMutableDictionary *numOfRowsForSection;

@end
