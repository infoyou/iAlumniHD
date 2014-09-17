//
//  VideoListCell.m
//  iAlumniHD
//
//  Created by Adam on 13-1-9.
//
//

#import "VideoListCell.h"
#import "Video.h"
#import "AppManager.h"
#import "UIImage-Extensions.h"

#define FONT_SIZE       12.0f
#define ICON_X          10.0f
#define ICON_Y          10.0f
#define ICON_W          80.0f
#define ICON_H          80.0f
#define TITLE_X         ICON_X + ICON_W + MARGIN
#define TITLE_Y         10.0f
#define TITLE_W         290.f
#define DATE_Y          55.f
#define DATE_H          20.f
#define PLAY_W          36.f
#define PLAY_H          36.f
#define MARK_IMG_H      16.f

@interface VideoListCell()
@property (nonatomic, copy) NSString *imageUrl;
@end

@implementation VideoListCell
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize timeLabel;
@synthesize markImageView;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
{
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier
         imageDisplayerDelegate:imageDisplayerDelegate
                            MOC:MOC];
    
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    markImageView = [[UIImageView alloc] init];
    imageView = [[UIImageView alloc] init];
}

- (void)dealloc
{
    RELEASE_OBJ(titleLabel);
    RELEASE_OBJ(dateLabel);
    RELEASE_OBJ(timeLabel);
    RELEASE_OBJ(markImageView);
    RELEASE_OBJ(imageView);
    
    [super dealloc];
}

- (void)drawVideo:(Video *)video
{
    
    titleLabel.frame = CGRectMake(TITLE_X, TITLE_Y, TITLE_W, 30);
    titleLabel.text = video.videoName;
    
    titleLabel.textColor = COLOR(88, 88, 88);
    titleLabel.numberOfLines = 100;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    titleLabel.font = Arial_FONT(FONT_SIZE);
    [titleLabel setBackgroundColor:TRANSPARENT_COLOR];
    CGSize constrainedSize = CGSizeMake(TITLE_W, CGFLOAT_MAX);
    
    CGSize titleSize = [titleLabel.text sizeWithFont:titleLabel.font
                                   constrainedToSize:constrainedSize
                                       lineBreakMode:UILineBreakModeWordWrap];
    titleLabel.frame = CGRectMake(TITLE_X, TITLE_Y, TITLE_W, titleSize.height);
    
    [self.contentView addSubview:titleLabel];
    
    float cellHeight = titleSize.height + TITLE_Y*2 + DATE_H + MARK_IMG_H;
    if (cellHeight < VIDEO_LIST_CELL_HEIGHT) {
        cellHeight = VIDEO_LIST_CELL_HEIGHT;
    }
    
    dateLabel.frame = CGRectMake(TITLE_X, cellHeight - MARGIN*2 - MARK_IMG_H - DATE_H, 100.f, DATE_H);
    dateLabel.text = video.createDate;
    dateLabel.textColor = COLOR(93, 93, 93);
    dateLabel.font = FONT(FONT_SIZE);
    [dateLabel setBackgroundColor:TRANSPARENT_COLOR];
    [self.contentView addSubview:dateLabel];
    
    timeLabel.frame = CGRectMake(/*255.f*/175.f, dateLabel.frame.origin.y, 60.f, DATE_H);
    timeLabel.text = video.duration;
    timeLabel.textColor = COLOR(98, 98, 98);
    timeLabel.font = ITALIC_FONT(FONT_SIZE);
    [timeLabel setBackgroundColor:TRANSPARENT_COLOR];
    [self.contentView addSubview:timeLabel];
    
    [self drawPopularity:[video.popularity floatValue] cellHeight:cellHeight];
    
    imageView.frame = CGRectMake(ICON_X, ICON_Y, ICON_W, ICON_H);
    [self.contentView addSubview:imageView];
    self.imageUrl = video.imageUrl;
    
    imageView.image = [[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(ICON_W, ICON_H)];
    
    if (video.imageUrl && video.imageUrl.length > 0) {
        [self fetchImage:[NSMutableArray arrayWithObject:video.imageUrl] forceNew:NO];
    }
}

#pragma mark - ImageFetcherDelegate methods

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    
    if ([self currentUrlMatchCell:url]) {
        [imageView.layer addAnimation:[self imageTransition] forKey:nil];
        
        imageView.image = [image imageByScalingToSize:CGSizeMake(ICON_W, ICON_H)];
    }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    
    if ([self currentUrlMatchCell:url]) {
        imageView.image = [image imageByScalingToSize:CGSizeMake(ICON_W, ICON_H)];
    }
}


- (void)drawPopularity:(float)popular cellHeight:(float)cellHeight
{
    if (popular > 4.5f) {
        markImageView.image = [UIImage imageNamed:@"star5.png"];
    } else if (popular > 4.f) {
        markImageView.image = [UIImage imageNamed:@"star4.5.png"];
    } else if (popular > 3.5f) {
        markImageView.image = [UIImage imageNamed:@"star4.png"];
    } else if (popular > 3.f) {
        markImageView.image = [UIImage imageNamed:@"star3.5.png"];
    } else if (popular > 2.f) {
        markImageView.image = [UIImage imageNamed:@"star3.png"];
    } else if (popular > 1.f) {
        markImageView.image = [UIImage imageNamed:@"star2.png"];
    } else if (popular > 0.5f) {
        markImageView.image = [UIImage imageNamed:@"star1.png"];
    } else if (popular > 0.f) {
        markImageView.image = [UIImage imageNamed:@"star0.5.png"];
    } else {
        markImageView.image = [UIImage imageNamed:@"star0.png"];
    }
    
    markImageView.frame = CGRectMake(TITLE_X, cellHeight - MARGIN*2 - 14.f, 80.f, MARK_IMG_H);
    
    [self.contentView addSubview:markImageView];
}

@end
