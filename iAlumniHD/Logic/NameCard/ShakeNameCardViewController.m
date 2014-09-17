//
//  ShakeNameCardViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import "ShakeNameCardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "NameCardListViewController.h"

#define ICON_SIDE_LENGTH   80.0f
#define ICON_Y             190.0f
#define FONT_SIZE           20

static BOOL checkShakeing(UIAcceleration* last, UIAcceleration* current, double threshold) {
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@interface ShakeNameCardViewController ()
@property(nonatomic, retain) UIAcceleration *lastAcceleration;
@end

@implementation ShakeNameCardViewController
@synthesize lastAcceleration;

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super initWithMOC:MOC frame:CGRectMake(0, 0, SCREEN_WIDTH - VERTICAL_MENU_WIDTH, SCREEN_HEIGHT)];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    self.lastAcceleration = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shakeBg.png"]];
    
    [self initView];
    [self initResource];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self resignFirstResponder];
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    [UIAccelerometer sharedAccelerometer].delegate = self;
    
    [self arrangeAnimation];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - load data

- (void)triggerLocationAndFetch:(id)sender {
    
    if (_processing) {
        return;
    }
    
    _processing = YES;
    
    [self prepareLocationCondition];
}

#pragma mark - init view

- (void)initView {
    
    _leftIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakeNameCardLeft.png"]] autorelease];
    _leftIcon.backgroundColor = TRANSPARENT_COLOR;
    _leftIcon.frame = CGRectMake(self.view.frame.size.width/2.0f - MARGIN * 2 - ICON_SIDE_LENGTH, ICON_Y, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    [self.view addSubview:_leftIcon];
    
    _rightIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakeNameCardRight.png"]] autorelease];
    _rightIcon.backgroundColor = TRANSPARENT_COLOR;
    _rightIcon.frame = CGRectMake(self.view.frame.size.width/2.0f + MARGIN * 2,
                                  ICON_Y, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    [self.view addSubview:_rightIcon];
    
    WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:COLOR(162, 162, 162)
                                              shadowColor:TRANSPARENT_COLOR] autorelease];
    titleLabel.font = BOLD_FONT(19);
    titleLabel.backgroundColor = TRANSPARENT_COLOR;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = LocaleStringForKey(NSShakeNameCardInfoMsg, nil);
    
    CGSize size = [titleLabel.text sizeWithFont:titleLabel.font
                              constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 6, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    titleLabel.frame = CGRectMake(15, 450.f, self.view.frame.size.width - 30, size.height);
    UIGestureRecognizer *shakeTap = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(doShakeTap:)];
    shakeTap.delegate = self;
    [titleLabel addGestureRecognizer:shakeTap];
    [titleLabel setUserInteractionEnabled:YES];
    [self.view addSubview:titleLabel];
}

- (void)arrangeAnimation {
    
    _leftIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0));
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         _leftIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-30));
                         
                     } completion:^(BOOL finished){
                     }];
    
    _rightIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0));
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         
                         _rightIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(30));
                         
                     } completion:^(BOOL finished){
                     }];
    
}

- (void)initResource
{
    
    // Sound
    NSString *shakePath = [[NSBundle mainBundle] pathForResource:@"shake"
                                                          ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL
                                                fileURLWithPath:shakePath], &shakeSoundID);
    
}

#pragma mark - prepare Condition
- (void)prepareLocationCondition
{
    
    [AppManager instance].defaultPlace = @"";
    [AppManager instance].defaultThing = @"";
    
    if (![IPAD_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        
        [AppManager instance].latitude = 0.0;
        [AppManager instance].longitude = 0.0;
        
        [self getCurrentLocationInfoIfNecessary];
    } else {
        [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
        [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
        [self goNameCard];
    }
}

- (void)doShakeTap:(UIGestureRecognizer *)recognizer
{
    AudioServicesPlaySystemSound(shakeSoundID);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    _processing = YES;
    isShakeAction = YES;
    [self prepareLocationCondition];
}

#pragma mark - location result
- (void)locationResult:(int)type{
    NSLog(@"shake type is %d", type);
    
    [WXWUIUtils closeActivityView];
    
    switch (type) {
        case 0:
        {
            [self goNameCard];
        }
            break;
            
        case 1:
        {
            [WXWUIUtils showNotificationOnTopWithMsg:@"定位失败"
                                          msgType:ERROR_TY
                               belowNavigationBar:YES];
            _processing = NO;
            isShakeAction = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if (self.lastAcceleration) {
        
        if (!_processing) {
            if (checkShakeing(self.lastAcceleration, acceleration, 0.3)) {
                /* SHAKE DETECTED. DO HERE WHAT YOU WANT. */
                AudioServicesPlaySystemSound(shakeSoundID);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                _processing = YES;
                isShakeAction = YES;
                [self prepareLocationCondition];
            }
        }
    }
    
    self.lastAcceleration = acceleration;
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)goNameCard
{
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    
    _processing = NO;
    
    NameCardListViewController *nameCardListVC = [[[NameCardListViewController alloc] initWithMOC:_MOC] autorelease];
    nameCardListVC.title = LocaleStringForKey(NSExchangeNameCardTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:nameCardListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
}

@end
