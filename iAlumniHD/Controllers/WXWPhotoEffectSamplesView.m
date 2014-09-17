//
//  WXWPhotoEffectSamplesView.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWPhotoEffectSamplesView.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonUtils.h"
#import "TextConstants.h"
#import "WXWLabel.h"

#define SAMPLE_SIDE_LENGTH    72.0f

#define GAP_WIDTH             42.5f

@interface WXWPhotoEffectSamplesView()
@property (nonatomic, retain) NSMutableDictionary *effectedPhotos;
@property (nonatomic, retain) NSMutableArray *buttons;
@end


@implementation WXWPhotoEffectSamplesView

@synthesize effectedPhotos = _effectedPhotos;
@synthesize buttons = _buttons;

#pragma mark - user action
- (void)selectEffectedPhoto:(id)sender {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    for (UIButton *btn in self.buttons) {
        btn.layer.borderWidth = 0.0f;
        btn.layer.borderColor = TRANSPARENT_COLOR.CGColor;
    }
    [UIView commitAnimations];
    
    UIButton *clickedButton = (UIButton *)sender;
    clickedButton.layer.borderWidth = MARGIN;
    clickedButton.layer.borderColor = NAVIGATION_BAR_COLOR.CGColor;
    
    if (_target && _action) {
        
        [_target performSelector:_action
                      withObject:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:clickedButton.tag]]];
    }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
      originalImage:(UIImage *)originalImage
             target:(id)target
             action:(SEL)action
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _target = target;
        _action = action;
        
        self.backgroundColor = TRANSPARENT_COLOR;
        
        self.buttons = [NSMutableArray array];
        
        self.effectedPhotos = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [CommonUtils effectedImageWithType:NORMAL_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:NORMAL_PHOTO_TY],
                               
                               [CommonUtils effectedImageWithType:INKWELL_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:INKWELL_PHOTO_TY],
                               
                               [CommonUtils effectedImageWithType:CLASSIC_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:CLASSIC_PHOTO_TY],
                               
                               [CommonUtils effectedImageWithType:COLORINVERT_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:COLORINVERT_PHOTO_TY],
                               
                               [CommonUtils effectedImageWithType:ADAPTIVETHRESHOLD_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:ADAPTIVETHRESHOLD_PHOTO_TY],
                               
                               [CommonUtils effectedImageWithType:BOXBLUR_PHOTO_TY originalImage:originalImage],
                               [NSNumber numberWithInt:BOXBLUR_PHOTO_TY],
                               
                               nil];
        
        _samplesContainer = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.bounds.size.width,
                                                                            EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT)] autorelease];
        _samplesContainer.backgroundColor = TRANSPARENT_COLOR;
        _samplesContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _samplesContainer.canCancelContentTouches = NO;
        _samplesContainer.clipsToBounds = YES;
        _samplesContainer.scrollEnabled = NO;
        // it should be set YES, if there are many effected samples
        _samplesContainer.showsVerticalScrollIndicator = NO;
        _samplesContainer.showsHorizontalScrollIndicator = NO;
        [self addSubview:_samplesContainer];
        
        // i is index and the type identifier
        for (NSInteger i = 0; i < self.effectedPhotos.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.showsTouchWhenHighlighted = YES;
            btn.frame = CGRectMake(i * (SAMPLE_SIDE_LENGTH + GAP_WIDTH) + GAP_WIDTH, MARGIN, SAMPLE_SIDE_LENGTH, SAMPLE_SIDE_LENGTH);
            
            [btn addTarget:self
                    action:@selector(selectEffectedPhoto:)
          forControlEvents:UIControlEventTouchUpInside];
            
            btn.backgroundColor = TRANSPARENT_COLOR;
            btn.layer.cornerRadius = 6.0f;
            btn.layer.masksToBounds = YES;
            
            if (i == 0) {
                btn.layer.borderWidth = MARGIN;
                btn.layer.borderColor = NAVIGATION_BAR_COLOR.CGColor;
            }
            
            UIImage *effectedImage = nil;
            WXWLabel *title = [[[WXWLabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x, EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT - MARGIN * 3, SAMPLE_SIDE_LENGTH, MARGIN * 3)
                                                   textColor:[UIColor whiteColor]
                                                 shadowColor:TRANSPARENT_COLOR] autorelease];
            title.textAlignment = UITextAlignmentCenter;
            title.font = BOLD_FONT(11);
            NSTimeInterval before = [CommonUtils convertToUnixTS:[NSDate date]];
            switch (i) {
                case NORMAL_PHOTO_TY:
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:NORMAL_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSNormalTitle, nil);
                    break;
                    
                case INKWELL_PHOTO_TY:
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:INKWELL_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSInkwellTitle, nil);
                    break;
                    
                case CLASSIC_PHOTO_TY:
                    
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:CLASSIC_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSClassicTitle, nil);
                    break;
                    
                case COLORINVERT_PHOTO_TY:
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:COLORINVERT_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSColorinvertTitle, nil);
                    break;
                    
                case ADAPTIVETHRESHOLD_PHOTO_TY:
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:ADAPTIVETHRESHOLD_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSAdaptivethresholdTitle, nil);
                    break;
                    
                case BOXBLUR_PHOTO_TY:
                    effectedImage = [CommonUtils cutPartImage:[self.effectedPhotos objectForKey:[NSNumber numberWithInt:BOXBLUR_PHOTO_TY]]
                                                        width:SAMPLE_SIDE_LENGTH
                                                       height:SAMPLE_SIDE_LENGTH];
                    title.text = LocaleStringForKey(NSBoxblurTitle, nil);
                    break;
                    
                default:
                    break;
            }
            
            [btn setImage:effectedImage forState:UIControlStateNormal];
            
            [_samplesContainer addSubview:btn];
            [_samplesContainer addSubview:title];
            
            [self.buttons addObject:btn];
            
            NSTimeInterval after = [CommonUtils convertToUnixTS:[NSDate date]];
            
            NSLog(@"time: %f", after - before);
        }
    }
    return self;
}

- (void)dealloc {
    
    self.effectedPhotos = nil;
    self.buttons = nil;
    
    [super dealloc];
}


@end
