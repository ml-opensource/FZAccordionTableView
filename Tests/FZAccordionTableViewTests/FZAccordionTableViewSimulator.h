//
//  FZAccordionTableViewSimulator.h
//  FZAccordionTableViewTests
//
//  Created by Krisjanis Gaidis on 6/14/15.
//
//

#import <Foundation/Foundation.h>
#import "FZAccordionTableView.h"

static const NSInteger kAccordionSimulatorNumberOfSections = 5;
static const NSInteger kAccordionSimulatorNumberOfRows = 5;

@interface FZAccordionTableViewSimulator : NSObject

@property (strong, nonatomic, readonly) NSMutableArray <NSNumber *> *sections;
@property (strong, nonatomic, readonly) FZAccordionTableView *tableView;
@property (weak, nonatomic) id<FZAccordionTableViewDelegate> delegate;

@end
