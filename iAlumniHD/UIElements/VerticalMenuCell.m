//
//  VerticalMenuCell.m
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VerticalMenuCell.h"
#import "GlobalConstants.h"
#import "WXWGradientView.h"

#define INDICATOR_WIDTH         30.0f
#define INDICATOR_HEIGHT        23.0f
#define FONT_SIZE               15.0f

@interface VerticalMenuCell()

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIView *disabledView;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, retain) UIImageView *indicatorView;

@end

@implementation VerticalMenuCell

@synthesize delegate = _delegate;
@synthesize enabled = _enabled;
@synthesize disabledView = _disabledView;
@synthesize indicatorView = _selectedImgView;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
              width:(CGFloat)width {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _enabled = YES;
        _delegate = nil;
        
        _width = width;
        
        self.clipsToBounds = YES;
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, self.bounds.size.height)] autorelease];
        self.selectedBackgroundView.backgroundColor = VERTICAL_MENU_SELECTED_COLOR;
//        [UIColor colorWithWhite:0.0f alpha:0.25f];
        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_WIDTH, INDICATOR_HEIGHT)];
		_selectedImgView.image = [UIImage imageNamed:@"indicator.png"];
		_selectedImgView.hidden = YES;
		[self addSubview:_selectedImgView];
        
        self.textLabel.backgroundColor = TRANSPARENT_COLOR;
        self.textLabel.font = BOLD_FONT(FONT_SIZE);
        self.imageView.backgroundColor = TRANSPARENT_COLOR;
        self.imageView.image = [UIImage imageNamed:@"logout.png"];
    }
    
    return self;
}

- (void)dealloc
{
	if (self.delegate) {
		[self.delegate removeObserver:self forKeyPath:@"controllerEnabled"];
	}
	self.disabledView = nil;
	self.delegate = nil;
	RELEASE_OBJ(_selectedImgView);
    
	[super dealloc];
}

- (void)setDelegate:(id)aDelegate {
    if (_delegate && (nil != aDelegate || [_delegate isEqual:aDelegate])) {
        [_delegate removeObserver:self forKeyPath:@"controllerEnabled"];
    }
    
    _delegate = aDelegate;
    if (_delegate) {
        [_delegate addObserver:self 
                    forKeyPath:@"controllerEnabled" 
                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                       context:nil];	
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (keyPath && [keyPath isEqualToString:@"controllerEnabled"]) {
		BOOL enbl = YES;
		
		id newVal = [change valueForKey:NSKeyValueChangeNewKey];
		if (newVal) {
			enbl = [newVal boolValue];
		}
		self.enabled = enbl;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _width, self.frame.size.height);
	
	CGRect frm = self.imageView.frame;
	self.imageView.frame = CGRectMake(8.f, frm.origin.y, frm.size.width, frm.size.height);
	frm = self.textLabel.frame;
	self.textLabel.frame = CGRectMake(40.f, frm.origin.y, 80, frm.size.height);
    
    _selectedImgView.frame = CGRectMake(0, self.bounds.size.height/2 - INDICATOR_HEIGHT/2, INDICATOR_WIDTH, INDICATOR_HEIGHT);
    
    if (self.selected) {
		self.textLabel.textColor = [UIColor whiteColor];
		self.indicatorView.hidden = NO;
	}	else {
		self.textLabel.textColor = COLOR(188, 188, 188);
		self.indicatorView.hidden = YES;
	}
}

@end
