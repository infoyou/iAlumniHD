//
//  VideoListCell.h
//  iAlumniHD
//
//  Created by Adam on 13-1-9.
//
//

#import "BaseUITableViewCell.h"
#import "WXWImageConsumerCell.h"

@class Video;

@interface VideoListCell : WXWImageConsumerCell
{
    UILabel *titleLabel;
    UILabel *dateLabel;
    UILabel *timeLabel;
    
    UIImageView *imageView;
    UIImageView *markImageView;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *markImageView;


- (void)drawVideo:(Video *)video;

@end
