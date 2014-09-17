//
//  UserProfileCell.m
//  iAlumniHD
//
//  Created by Adam on 12-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserProfileCell.h"

#define IMG_WIDTH     80.0f
#define IMG_HEIGHT    107.0f

@interface UserProfileCell()
@property (nonatomic, copy) NSString *url;
@end

@implementation UserProfileCell
@synthesize url = _url;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _photoView = [[UIImageView alloc] init];
        _photoView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _photoView.layer.shadowOffset = CGSizeMake(0, 1.0f);
        _photoView.layer.cornerRadius = 6.0f;
        _photoView.layer.masksToBounds = YES;
//        _photoView.backgroundColor = TRANSPARENT_COLOR;    
        [self.contentView addSubview:_photoView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = TRANSPARENT_COLOR;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = BOLD_FONT(15);
        _nameLabel.shadowColor = [UIColor blackColor];
        _nameLabel.shadowOffset = CGSizeMake(0, 1.0f);
        _nameLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(_photoView);
    RELEASE_OBJ(_nameLabel);
    
    [super dealloc];
}

- (void)drawProfile:(NSString *)name imgUrl:(NSString *)imgUrl {
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, VERTICAL_MENU_WIDTH, PROFILE_CELL_HEIGHT);
    
    CGFloat center_x = self.bounds.size.width/2;
    _photoView.frame = CGRectMake(center_x - IMG_WIDTH/2, MARGIN, IMG_WIDTH, IMG_HEIGHT);
    
    if (nil == _photoView.image) {
        
        if (imgUrl && [imgUrl length] > 0) {
            NSString *mUrl = [CommonUtils geneUrl:imgUrl itemType:IMAGE_TY];    
            
            UIImage *image = [[AppManager instance].imageCache getImage:mUrl];
            if (image) {
                _photoView.image = image;
            } else {
                _photoView.image = nil;
                
                WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:mUrl
                                                                        contentType:IMAGE_TY];
                
                [connector asyncGet:mUrl showAlertMsg:NO];
            }
            self.url = mUrl;
        } else {
            _photoView.image = [UIImage imageNamed:@"userDefault.png"];
        }
    }
    
    if (name) {
        CGSize size = [name sizeWithFont:_nameLabel.font
                       constrainedToSize:CGSizeMake(VERTICAL_MENU_WIDTH-4, 40) 
                           lineBreakMode:UILineBreakModeTailTruncation];
        
        _nameLabel.frame = CGRectMake(center_x - size.width/2, 
                                      self.bounds.size.height - MARGIN - size.height, size.width, size.height);
        _nameLabel.text = name;
        _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    _photoView.image = nil;
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType {
    
    if (url && url.length > 0) {
        UIImage *image = [UIImage imageWithData:result];
        
        if (image) {
            [[AppManager instance].imageCache saveImageIntoCache:url image:image];
        }
        
        if ([url isEqualToString:self.url]) {
            _photoView.image = image;
        }
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
}

@end
