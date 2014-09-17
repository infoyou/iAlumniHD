//
//  UpdateUserInfoViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@interface UpdateUserInfoViewController : RootViewController <UITextFieldDelegate> {
    
    UITextField *_emailField;
    UITextField *_mobileField;
    UITextField *_weiboField;
    
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
    
    CGFloat _animatedDistance;
    NSString *userId;
    NSString *mobile;
    NSString *email;

}

@property (nonatomic, retain) NSMutableArray *_TableCellShowValArray;
@property (nonatomic, retain) NSMutableArray *_TableCellSaveValArray;
@property (nonatomic, retain) UITextField *_emailField;
@property (nonatomic, retain) UITextField *_mobileField;
@property (nonatomic, retain) UITextField *_weiboField;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *mobile;
@property (nonatomic, retain) NSString *email;

@end
