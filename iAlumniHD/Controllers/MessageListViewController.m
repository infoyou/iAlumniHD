//
//  MessageListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MessageListViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "MessageCell.h"
#import "CoreDataUtils.h"
#import "Messages.h"
#import "MessageButton.h"
#import "AppManager.h"

@implementation MessageListViewController

- (void)close {
  
  // delete reviewed message
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(reviewed == YES)"];
  DELETE_OBJS_FROM_MOC(_MOC, @"Messages", predicate);
  
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)addBackButton {

  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSCloseTitle, nil) 
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                           action:@selector(close)] autorelease];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction
{
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO 
      needRefreshFooterView:NO
          needGoHome:YES];
  
  if (self) {
    
  }
  
  return self;
}

- (void)setAllMessageBeQuickViewed {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(quickViewed == 0)"];
  NSArray *messages = [CoreDataUtils fetchObjectsFromMOC:_MOC
                                              entityName:@"Messages"
                                               predicate:predicate];
  for (Messages *message in messages) {
    message.quickViewed = [NSNumber numberWithBool:YES];
    message.reviewed = [NSNumber numberWithBool:YES];
  }
  SAVE_MOC(_MOC);
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = CELL_COLOR;
  
  [self addBackButton];
  
  [self refreshTable];
  
  // set the flag, then the audio notification will not be executed again next time if user click it
  [AppManager instance].unreadMessageReceived = NO;
  
  [self setAllMessageBeQuickViewed];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - user action

- (void)openWapForDetail:(Messages *)message {

    if (YES) {
        return;
    }
//  message.reviewed = [NSNumber numberWithBool:YES];
//  SAVE_MOC(_MOC);
  
  NSString *url = [NSString stringWithFormat:@"%@user_id=%@&session=%@&plat=i&version=%@&lang=%@", 
                   message.url, 
                   [AppManager instance].userId,
                   [AppManager instance].sessionId,
                   VERSION,
                   [AppManager instance].currentLanguageDesc];
  
  [CommonUtils openWebView:self.navigationController
                     title:nil
                       url:url
                 backTitle:LocaleStringForKey(NSCloseTitle, nil)
               needRefresh:NO
            needNavigation:NO
      blockViewWhenLoading:YES];
}

- (void)showAwardStatus:(id)sender {
  MessageButton *button = (MessageButton *)sender;
  [self openWapForDetail:button.message];
}

- (void)updateApp:(id)sender {
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URL]];
  
//  MessageButton *button = (MessageButton *)sender;
//  button.message.reviewed = [NSNumber numberWithBool:YES];
//  SAVE_MOC(_MOC);
}

- (void)reviewDetails:(id)sender {
  
  MessageButton *button = (MessageButton *)sender;
  [self openWapForDetail:button.message];  
}

#pragma mark - override methods
- (void)setPredicate {
  self.entityName = @"Messages";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Messages *message = (Messages *)[_fetchedRC objectAtIndexPath:indexPath];

  static NSString *cellIdentifier = @"messageCell";
  MessageCell *cell = (MessageCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:cellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  switch (message.type.intValue) {
    case AWARD_SYS_MSG_TY:
      [cell drawCell:message target:self action:@selector(showAwardStatus:)];
      break;
      
    case UPDATE_AVAILABLE_SYS_MSG_TY:
      [cell drawCell:message target:self action:@selector(updateApp:)];
      break;
      
    default:
      [cell drawCell:message target:self action:@selector(reviewDetails:)];
      break;
  }

  return cell;
}

- (CGFloat)cellHeight:(Messages *)message {
    
  CGSize size = [message.content sizeWithFont:BOLD_FONT(13)
                               constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 6 - 60.0f, CGFLOAT_MAX) 
                                   lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat height = 44.0f;
  if (size.height > height) {
    height = size.height;
  }

  height += MARGIN * 2 + MARGIN * 2;
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Messages *message = (Messages *)[_fetchedRC objectAtIndexPath:indexPath];
  return [self cellHeight:message];
}

@end
