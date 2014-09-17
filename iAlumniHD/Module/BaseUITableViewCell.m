//
//  BaseUITableViewCell.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"

@interface BaseUITableViewCell()
@property (nonatomic, retain) NSMutableArray *labelsContainer;
@end

@implementation BaseUITableViewCell
@synthesize imageUrls = _imageUrls;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize labelsContainer = _labelsContainer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageDisplayerDelegate = imageDisplayerDelegate;
        _MOC = MOC;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC {
    
    self = [self initWithStyle:style
               reuseIdentifier:reuseIdentifier
        imageDisplayerDelegate:imageDisplayerDelegate
                           MOC:MOC];
    if (self) {
        _connectionTriggerHolderDelegate = connectionTriggerHolderDelegate;
        self.errorMsgDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {

    if (self.imageUrls) {
        for (NSString *url in self.imageUrls) {
            [[[AppManager instance] imageCache] clearCallerFromCache:url];
        }
        
        self.imageUrls = nil;
    }
    
    self.errorMsgDic = nil;
    self.labelsContainer = nil;
    
    [super dealloc];
}

- (void)setCellStyle:(CGFloat)cellHeight
{
    // Back ground
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bgView.backgroundColor = CELL_COLOR;
    self.backgroundView = bgView;
    
    // topSeparator
    UIView *topSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, 0.8f)] autorelease];
    topSeparator.backgroundColor = CELL_TOP_COLOR; // COLOR(172, 172, 172);
    [self.contentView addSubview:topSeparator];
    
    // bottomSeparator
    UIView *bottomSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, cellHeight - 0.8f, LIST_WIDTH, 0.8f)] autorelease];
    bottomSeparator.backgroundColor = CELL_BOTTOM_COLOR; // COLOR(175, 175, 175);
    [self.contentView addSubview:bottomSeparator];
    
    // Selected Style
    self.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, cellHeight)] autorelease];
    self.selectedBackgroundView.backgroundColor = CELL_SELECTED_COLOR;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Select Content Color Change
    self.contentView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 1.0f);
    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)].CGPath;
}

- (void)requestConnection:(NSString *)url
               connFacade:(WXWAsyncConnectorFacade *)connFacade
         connectionAction:(SEL)connectionAction {
    if (_connectionTriggerHolderDelegate) {
        [_connectionTriggerHolderDelegate registerRequestUrl:url connFacade:connFacade];
    }
    
    [connFacade performSelector:connectionAction withObject:url];
}

#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType {
  WXWAsyncConnectorFacade *connector = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                 interactionContentType:contentType] autorelease];
  
  if (_connectionTriggerHolderDelegate) {
    [_connectionTriggerHolderDelegate registerRequestUrl:url
                                              connFacade:connector];
  }
  return connector;
}


#pragma mark - WXWConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    if (url && url.length > 0) {
        [self.errorMsgDic removeObjectForKey:url];
    }
}

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url {
    if (url && url.length > 0) {
        [self.errorMsgDic setObject:message forKey:url];
    }
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
    
}

#pragma mark - ImageFetcherDelegate
- (void)imageFetchStarted:(NSString *)url {}
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {}
- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {}
- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {}

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew {
    
    if (imageUrls.count == 0) {
        return;
    }
    
    self.imageUrls = imageUrls;
    
    for (NSString *url in imageUrls) {
        // register image url, when the displayer (view controller) be pop up from view controller stack, if
        // image still being loaded, the process could be cancelled
        [_imageDisplayerDelegate registerImageUrl:url];
        [[[AppManager instance] imageCache] fetchImage:url caller:self forceNew:forceNew];
    }
}

- (CATransition *)imageTransition {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    return imageFadein;
}

- (BOOL)currentUrlMatchCell:(NSString *)url {
    // if the image of current url need be displayed in current cell, then return YES; otherwise return NO;
    if (url && url.length > 0 && self.imageUrls) {
        return [self.imageUrls containsObject:url];
    } else {
        return NO;
    }
    
}

- (void)removeLabelShadowForHighlight:(UILabel **)label {
    (*label).shadowOffset = CGSizeMake(0, 0);
    (*label).shadowColor = TRANSPARENT_COLOR;
}

- (void)addLabelShadowForHighlight:(UILabel **)label {
    (*label).shadowOffset = CGSizeMake(0, 1.0f);
    (*label).shadowColor = [UIColor whiteColor];
}

- (void)hideLabelShadow {
    
}

- (void)showLabelShadow {
    
}

- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor {
    
    WXWLabel *label = [[WXWLabel alloc] initWithFrame:frame
                                          textColor:textColor
                                        shadowColor:shadowColor];
    
    if (nil == self.labelsContainer) {
        self.labelsContainer = [NSMutableArray array];
    }
    [self.labelsContainer addObject:label];
    return label;
}

#pragma mark - remove shadow of labels when selected or highlighted

- (void)applyLabelsShadow:(BOOL)needShadow {
    for (WXWLabel *label in self.labelsContainer) {
        if (label.noShadow) {
            label.shadowColor = nil;
        } else {
            label.shadowColor = needShadow ? [UIColor whiteColor] : nil;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

    [super setHighlighted:highlighted animated:animated];
    [self applyLabelsShadow:!highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    [self applyLabelsShadow:!selected];
}

#pragma mark - draw out bottom shadow
- (void)drawOutBottomShadow:(CGFloat)height {
    
    CGRect rect;
    if (height > 0 ) {
        rect = CGRectMake(self.bounds.origin.x + MARGIN * 7,
                          self.bounds.origin.y + MARGIN,
                          LIST_WIDTH - MARGIN * 14,
                          height - MARGIN);
    } else {
        rect = CGRectMake(self.bounds.origin.x + MARGIN * 7,
                          self.bounds.origin.y + MARGIN,
                          LIST_WIDTH - MARGIN * 14,
                          self.bounds.size.height - MARGIN);
    }
    
    
    CGSize cornerRadii = CGSizeMake(GROUP_STYLE_CELL_CORNER_RADIUS, GROUP_STYLE_CELL_CORNER_RADIUS);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:cornerRadii];
    
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.layer.shadowOpacity = 0.9f;
    self.layer.masksToBounds = NO;
    
}

@end
