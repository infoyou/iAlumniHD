//
//  SearchAlumniViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class WXWGradientButton;
@class ClassGroup;
@class Industry;
@class UserCountry;
@class UserListViewController;

@interface SearchAlumniViewController : RootViewController <UITextFieldDelegate> {
    
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
    
@private
    
    UITextField *_nameField;
    UITextField *_companyField;
    UITextField *_companyAddressField;
    UILabel *_classTitleLabel;
    
    WXWGradientButton *_classSelectBtn;
    WXWGradientButton *_genderSelectBtn;
    WXWGradientButton *_countrySelectBtn;
    WXWGradientButton *_industrySelectBtn;
    
    UIView *_shieldView;
    
    UIPopoverController *_popoverView;
    
    BOOL _currentMovedup;
    BOOL _manualHideKeyboard;
    UIBezierPath *_shadowPath;
    
    CGFloat _animatedDistance;
    
    // query criteria
    NSString *_selectedGender;
    UserCountry *_selectedCountry;
    ClassGroup *_selectedClass;
    Industry *_selectedIndustry;
    
    NSMutableArray *classFliters;
}

@property (retain, nonatomic) NSMutableArray *classFliters;
@property(nonatomic,retain) NSMutableArray *_TableCellShowValArray;
@property(nonatomic,retain) NSMutableArray *_TableCellSaveValArray;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
