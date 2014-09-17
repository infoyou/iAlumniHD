//
//  UICascadeView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import "UICascadeView.h"
#import "GlobalConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "AppManager.h"
#import "CommonUtils.h"

static int selIndex = 0;

#define FONT_SIZE                   14.0f

typedef enum {
    LEFT_TABLE_TAG = 100,
    RIGHT_TABLE_TAG = 101,
} TableTag;

@interface UICascadeView()
@property (nonatomic, retain) UITableView *leftTableView;
@property (nonatomic, retain) UITableView *rightTableView;
@end

@implementation UICascadeView
@synthesize clubFliters;
@synthesize leftTableView;
@synthesize rightTableView;

- (id)initWithFrame:(CGRect)frame tableCascadeDelegate:(id<UITableCascadeDelegate>)tableCascadeDelegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _delegate = tableCascadeDelegate;
        
        // Initialization code
        self.leftTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2.f, frame.size.height)] autorelease];
        self.leftTableView.dataSource = self;
        self.leftTableView.delegate = self;
        self.leftTableView.tag = LEFT_TABLE_TAG;
        self.leftTableView.backgroundColor = COLOR(242, 242, 242);
        self.leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.leftTableView.scrollEnabled = YES;
        [self addSubview:self.leftTableView];
        
        self.rightTableView = [[[UITableView alloc] initWithFrame:CGRectMake(frame.size.width/2.f, 0, frame.size.width/2.f, frame.size.height)] autorelease];
        self.rightTableView.dataSource = self;
        self.rightTableView.delegate = self;
        self.rightTableView.tag = RIGHT_TABLE_TAG;
        self.rightTableView.backgroundColor = COLOR(213, 213, 213);
        self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.rightTableView.scrollEnabled = YES;
        [self addSubview:self.rightTableView];
        
        self.clubFliters = [[AppManager instance].clubFilterList objectAtIndex:0];
    }
    
    return self;
}

- (void)dealloc {
    
    selIndex = 0;
    
    self.clubFliters = nil;
    self.leftTableView = nil;
    self.rightTableView = nil;
    
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (tableView.tag) {
        case LEFT_TABLE_TAG:
        {
            return [[AppManager instance].supClubFilterList count];
        }
            
        case RIGHT_TABLE_TAG:
        {
            self.clubFliters = [[AppManager instance].clubFilterList objectAtIndex:selIndex];
            return [self.clubFliters count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *tableKeyStr = @"";
    UITableViewCell *tableCell = nil;
    int row = [indexPath row];
    
    switch (tableView.tag) {
        case LEFT_TABLE_TAG:
        {
            tableKeyStr = @"LeftTableCell";
            tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableKeyStr] autorelease];
            
            tableCell.textLabel.text = [[[AppManager instance].supClubFilterList objectAtIndex:row] objectAtIndex:1];
            tableCell.textLabel.font = Arial_FONT(FONT_SIZE+1);
            tableCell.textLabel.highlightedTextColor = [UIColor blackColor];
            
            // select style
            tableCell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, 0, LIST_WIDTH-MARGIN, tableCell.frame.size.height)] autorelease];
            tableCell.selectedBackgroundView.backgroundColor = COLOR(213, 213, 213);
            
            UIButton *leftBut = [UIButton buttonWithType:UIButtonTypeCustom];
            leftBut.backgroundColor = [UIColor whiteColor];
            leftBut.frame = CGRectMake(0, 0, MARGIN, tableCell.frame.size.height);
            [leftBut setBackgroundImage:[CommonUtils createImageWithColor:COLOR(242, 242, 242)] forState:UIControlStateNormal];
            [leftBut setBackgroundImage:[CommonUtils createImageWithColor:COLOR(127, 188, 26)] forState:UIControlStateHighlighted];
            [leftBut setBackgroundColor:TRANSPARENT_COLOR];
            [tableCell.contentView addSubview:leftBut];
            
            // Select Content Color Change
            tableCell.contentView.layer.shadowColor = [UIColor grayColor].CGColor;
            tableCell.contentView.layer.shadowOffset = CGSizeMake(0, 1.0f);
            tableCell.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, tableCell.contentView.bounds.size.width, tableCell.contentView.bounds.size.height)].CGPath;
            
            // separator color
            UIView *topSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, tableCell.contentView.bounds.size.height - 1.6f, LIST_WIDTH, 0.8f)] autorelease];
            topSeparator.backgroundColor = COLOR(224, 224, 224);
            [tableCell.contentView addSubview:topSeparator];
            
            UIView *bottomSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, tableCell.contentView.bounds.size.height - 0.8f, LIST_WIDTH, 0.8f)] autorelease];
            bottomSeparator.backgroundColor = COLOR(247, 247, 247);
            [tableCell.contentView addSubview:bottomSeparator];
            
            break;
        }
            
        case RIGHT_TABLE_TAG:
        {
            tableKeyStr = @"RightTableCell";
            tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableKeyStr] autorelease];
            tableCell.textLabel.text = [[self.clubFliters objectAtIndex:row] objectAtIndex:1];
            tableCell.textLabel.font = Arial_FONT(FONT_SIZE);
            tableCell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, tableCell.frame.size.height)] autorelease];
            tableCell.selectedBackgroundView.backgroundColor = COLOR(213, 213, 213);
            
            break;
        }
            
        default:
            return nil;
    }
    
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = [indexPath row];
    
    switch (tableView.tag) {
        case LEFT_TABLE_TAG:
        {
            selIndex = row;
            self.clubFliters = [[AppManager instance].clubFilterList objectAtIndex:row];
            [self.rightTableView reloadData];
            
            break;
        }
            
        case RIGHT_TABLE_TAG:
        {
            // Go Club list
            [AppManager instance].supClubTypeValue = [[[AppManager instance].supClubFilterList objectAtIndex:selIndex] objectAtIndex:0];
            [AppManager instance].hostTypeValue = [[self.clubFliters objectAtIndex:row] objectAtIndex:0];
            [_delegate didSelectResult:selIndex rightStr:row];
            break;
        }
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews {
    
    NSIndexPath *first=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.leftTableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionBottom];
    
    self.clubFliters = [[AppManager instance].clubFilterList objectAtIndex:0];
}

@end
