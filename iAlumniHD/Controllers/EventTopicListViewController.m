//
//  EventTopicListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-9-10.
//
//

#import "EventTopicListViewController.h"
#import "VoteDetailViewController.h"
#import "WXWColorfulButton.h"
#import "EventTopicCell.h"
#import "EventTopic.h"

#define BADGE_SIDE_LENGTH           40.0f

#define SUBMIT_BUTTON_WIDTH         200.0f
#define SUBMIT_BUTTON_HEIGHT        36.0f

@interface EventTopicListViewController ()
@property (nonatomic, retain) EventTopic *currentSelectedTopic;
@end

@implementation EventTopicListViewController

@synthesize currentSelectedTopic = _currentSelectedTopic;

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId
{
    
    self = [super initWithMOC:MOC showCloseButton:NO needRefreshHeaderView:NO needRefreshFooterView:YES];
    
    if (self) {
        
        _eventId = eventId;
        DELETE_OBJS_FROM_MOC(_MOC, @"EventTopic", nil);
    }
    return self;
}

- (void)dealloc {
    
    self.currentSelectedTopic = nil;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"EventTopic", nil);
    
    [super dealloc];
}

#pragma mark - load data

- (void)setPredicate {
    self.entityName = @"EventTopic";
    self.predicate = [NSPredicate predicateWithFormat:@"(eventId == %lld)", _eventId];
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequenceNumber"
                                                                    ascending:YES] autorelease];
    [self.descriptors addObject:sortDescriptor];
    
}

- (void)loadTopics {
    
    NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id>", _eventId];
    
    NSString *url = [CommonUtils geneUrl:param itemType:LOAD_EVENT_TOPICS_TY];
    
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:LOAD_EVENT_TOPICS_TY] autorelease];
    [self.connDic setObject:connFacade forKey:url];
    
    [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)refreshList:(id)sender {
    [self loadTopics];
}

- (void)loadOptions:(EventTopic *)topic {
    NSString *param = [NSString stringWithFormat:@"<pool_id>%@</pool_id><person_id>%@</person_id>", topic.topicId, [AppManager instance].personId];
    
    _currentType = LOAD_EVENT_OPTIONS_TY;
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:_currentType] autorelease];
    [self.connDic setObject:connFacade forKey:url];
    
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods

- (void)initBottomToolbar {
    
    _bottomToolbar = [[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - TOOLBAR_HEIGHT, LIST_WIDTH, TOOLBAR_HEIGHT)] autorelease];
    _bottomToolbar.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
    [self.view addSubview:_bottomToolbar];
    
    ECStandardButton *submitButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake((LIST_WIDTH - SUBMIT_BUTTON_WIDTH)/2.0f, (TOOL_TITLE_HEIGHT - SUBMIT_BUTTON_HEIGHT)/2.0f, SUBMIT_BUTTON_WIDTH, SUBMIT_BUTTON_HEIGHT)
                                                                       target:self
                                                                       action:@selector(refreshList:)
                                                                        title:LocaleStringForKey(NSRefreshTitle, nil)
                                                                    tintColor:COLOR(117, 189, 56)
                                                                    titleFont:BOLD_FONT(20)
                                                                  borderColor:COLOR(113, 127, 62)] autorelease];
    [_bottomToolbar addSubview:submitButton];
    
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,
                                  _tableView.frame.size.width, _tableView.frame.size.height - TOOLBAR_HEIGHT);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self initBottomToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_autoLoaded) {
        [_tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_autoLoaded) {
        [self loadTopics];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)showOptions {
    
    VoteDetailViewController *voteDetailVC = [[[VoteDetailViewController alloc] initWithMOC:_MOC
                                                                                 eventTopic:self.currentSelectedTopic] autorelease];
    voteDetailVC.title = LocaleStringForKey(NSFillVoteTitle, nil);
    [self.navigationController pushViewController:voteDetailVC animated:YES];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case LOAD_EVENT_TOPICS_TY:
            if ([XMLParser parserEventTopics:result
                                     eventId:_eventId
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                [self refreshTable];
                
                _autoLoaded = YES;
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadEventTopicFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
            
        case LOAD_EVENT_OPTIONS_TY:
        {
            if ([XMLParser parserTopicOptions:result
                                        topic:self.currentSelectedTopic
                                          MOC:_MOC
                            connectorDelegate:self
                                          url:url]) {
                
                if (self.currentSelectedTopic.voted.boolValue) {
                    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSVoteRepeatedlyMsg, nil)
                                                  msgType:WARNING_TY
                                       belowNavigationBar:YES];
                } else {
                    [self showOptions];
                }
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadEventOptionFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
  NSString *msg = nil;
  
  switch (contentType) {
    case LOAD_EVENT_TOPICS_TY:
      msg = LocaleStringForKey(NSLoadEventTopicFailedMsg, nil);
      break;
      
    case LOAD_EVENT_OPTIONS_TY:
      msg = LocaleStringForKey(NSLoadEventOptionFailedMsg, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"TopicCell";
    EventTopicCell *cell = (EventTopicCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[EventTopicCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellIdentifier] autorelease];
    }
    
    EventTopic *topic = (EventTopic *)[_fetchedRC objectAtIndexPath:indexPath];
    
    [cell drawCell:topic];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTopic *topic = (EventTopic *)[_fetchedRC objectAtIndexPath:indexPath];
    
    CGFloat leftBaseInfoHeight = MARGIN * 2 + BADGE_SIDE_LENGTH;
    CGSize size = [LocaleStringForKey(NSInProcessTitle, nil) sizeWithFont:BOLD_FONT(13)
                                                        constrainedToSize:CGSizeMake(BADGE_SIDE_LENGTH, BADGE_SIDE_LENGTH)
                                                            lineBreakMode:UILineBreakModeWordWrap];
    leftBaseInfoHeight += MARGIN + size.height;
    leftBaseInfoHeight += MARGIN + size.height;
    leftBaseInfoHeight += MARGIN * 2;
    
    size = [topic.content sizeWithFont:BOLD_FONT(14)
                     constrainedToSize:CGSizeMake(LIST_WIDTH - MARGIN * 4 - MARGIN * 2 - BADGE_SIDE_LENGTH, CGFLOAT_MAX)
                         lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + MARGIN * 4;
    
    if (leftBaseInfoHeight < height) {
        return height;
    } else {
        return leftBaseInfoHeight;
    }
}

- (void)clearOptions:(EventTopic *)topic {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(topicId == %@)", topic.topicId];
    DELETE_OBJS_FROM_MOC(_MOC, @"Option", predicate);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
    
    EventTopic *topic = (EventTopic *)[_fetchedRC objectAtIndexPath:indexPath];
    
    switch (topic.status.intValue) {
        case VOTE_CLOSED_TY:
        {
            [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSVoteInCloseStatusMsg, nil)
                                          msgType:ERROR_TY
                               belowNavigationBar:YES];
            break;
        }
            
        case VOTE_IN_PROCESS_TY:
        {
            if (!topic.voted.boolValue) {
                // if user voted to this topic, then he/she cannot enter the detail option view
                self.currentSelectedTopic = topic;
                
                [self clearOptions:topic];
                
                [self loadOptions:topic];
            } else {        
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSVoteRepeatedlyMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
        }
            
        default:
            break;
    }
}

@end
