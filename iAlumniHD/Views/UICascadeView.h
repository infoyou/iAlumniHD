//
//  UICascadeView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import <UIKit/UIKit.h>

@protocol UITableCascadeDelegate <NSObject>

-(void)didSelectResult:(int)leftIndex rightStr:(int)rightIndex;

@end

@interface UICascadeView : UIView <UITableViewDataSource, UITableViewDelegate> {
    
    id<UITableCascadeDelegate> _delegate;
    
    UITableView *leftTableView;
    UITableView *rightTableView;
    
    NSMutableArray *clubFliters;

}

@property (nonatomic, retain) NSMutableArray *clubFliters;

- (id)initWithFrame:(CGRect)frame tableCascadeDelegate:(id<UITableCascadeDelegate>)tableCascadeDelegate;

@end
