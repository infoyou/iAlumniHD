#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class ChatListViewController;

@interface ChatFaceViewController : RootViewController <UITableViewDataSource,UITableViewDelegate> {
    
    UIScrollView              *_faceScrollView;
	NSMutableArray            *_phraseArray;
	ChatListViewController   *_chatViewController;
}

@property (nonatomic, retain) UIScrollView              *faceScrollView;
@property (nonatomic, retain) NSMutableArray            *phraseArray;
@property (nonatomic, retain) ChatListViewController   *chatViewController;

- (id)initWithObject:(ChatListViewController*)aChatViewController;
- (void)dismissMyselfAction:(id)sender;
- (void)showEmojiView;

@end
