//
//  WXWAsyncConnectorFacade.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWAsyncConnectorFacade.h"
#import "AppManager.h"
#import "Club.h"

@implementation WXWAsyncConnectorFacade

#pragma mark - fetch host
- (void)fetchHost:(NSString *)url {
    // not show alert message avoid the warning be displayed in startup view
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - user
- (void)verifyUser:(NSString *)url showAlertMsg:(BOOL)showAlertMsg {
    [self asyncGet:url showAlertMsg:showAlertMsg];
}

- (void)fetchUserProfile:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

- (void)fetchUserInfoFromLinkedin:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

- (void)confirmBindLinkedin:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load image
- (void)fetchImage:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - hot news
- (void)fetchNews:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load comment
- (void)fetchComments:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - like action
- (void)likeItem:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - check in action
- (void)checkin:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - favorite action
- (void)favoriteItem:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - upload post

- (NSMutableData *)assembleContentData:(NSDictionary *)dic
                                 photo:(UIImage *)photo
                          originalData:(NSMutableData *)originalData {
    NSString *param = [CommonUtils convertParaToHttpBodyStr:dic];
    
    if (nil != photo) {
        // format the pic as parameter
		param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\r\n", IALUMNIHD_FORM_BOUNDARY]];
		param = [param stringByAppendingString:@"Content-Disposition:form-data; name=\"attach\"; filename=\"pic.jpg\"; Content-Type:application/octet-stream\r\n\r\n"];
    }
    
    [originalData appendData:[param dataUsingEncoding:NSUTF8StringEncoding
                                 allowLossyConversion:YES]];
    
    if (nil != photo) {
        // add pic data into parameter
		NSData *jpgPic = UIImageJPEGRepresentation(photo, 0.8);
		[originalData appendData:jpgPic];
    }
    
    // append footer
	NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", IALUMNIHD_FORM_BOUNDARY];
	[originalData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:YES]];
    
    
    NSLog(@"params: %@", [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] autorelease]);
    return originalData;
}

- (void)uploadItem:(NSString*)url dic:(NSDictionary *)dic photo:(UIImage *)photo {
    
    NSMutableData *contentData = [NSMutableData data];
    
    [self post:url
          data:[self assembleContentData:dic
                                   photo:photo
                            originalData:contentData]];
}

- (void)uploadItem:(NSDictionary *)dic photo:(UIImage *)photo {
    
    NSMutableData *contentData = [NSMutableData data];
    
    [self post:[CommonUtils assembleUrl:nil]
          data:[self assembleContentData:dic
                                   photo:photo
                            originalData:contentData]];
    
}

- (void)uploadItem:(NSDictionary *)dic photo:(UIImage *)photo snsType:(DomainType)snsType {
    
    NSMutableData *contentData = [NSMutableData data];
    
    [self post:[CommonUtils assembleurlWithType:LINKEDIN_DOMAIN_TY]
          data:[self assembleContentData:dic
                                   photo:photo
                            originalData:contentData]];
}

- (void)sendPost:(NSString *)content
         groupId:(NSString *)groupId
          tagIds:(NSString *)tagIds
         placeId:(NSString *)placeId
       placeName:(NSString *)placeName
          cityId:(long long)cityId
           photo:(UIImage *)photo {
    
    NSDictionary *dic = nil;
    if ([AppManager instance].latitude == 0 && [AppManager instance].longitude == 0) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               @"submit_post", @"action",
               PLATFORM, @"plat",
               [AppManager instance].sessionId, @"session",
               VERSION, @"version",
               [AppManager instance].personId, @"user_id",
               groupId, @"group_id",
               content, @"text",
               LLINT_TO_STRING([AppManager instance].cityId), @"city_id",
               @"0", @"is_suggest",
               SELF_CLASS_TYPE, @"locationType",
               [AppManager instance].currentLanguageDesc, @"lang",
               tagIds, @"tag_ids",
               nil];
        
    } else {
        
        if (nil != placeId && placeId.length > 0 && nil != placeName && placeName.length > 0) {
            // user selects a specified nearby place
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"submit_post", @"action",
                   PLATFORM, @"plat",
                   [AppManager instance].sessionId, @"session",
                   VERSION, @"version",
                   [AppManager instance].userId, @"user_id",
                   groupId, @"group_id",
                   LLINT_TO_STRING([AppManager instance].cityId), @"city_id",
                   @"0", @"is_suggest",
                   SELF_CLASS_TYPE, @"locationType",
                   [AppManager instance].currentLanguageDesc, @"lang",
                   tagIds, @"tag_ids",
                   content, @"text",
                   placeId, @"place_id",
                   placeName, @"place_address",
                   DOUBLE_TO_STRING([AppManager instance].latitude), @"lat",
                   DOUBLE_TO_STRING([AppManager instance].longitude), @"long",
                   nil];
            
        } else {
            // although location detected, user does not select a specified nearby place
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"submit_post", @"action",
                   PLATFORM, @"plat",
                   [AppManager instance].sessionId, @"session",
                   VERSION, @"version",
                   [AppManager instance].userId, @"user_id",
                   groupId, @"group_id",
                   LLINT_TO_STRING([AppManager instance].cityId), @"city_id",
                   @"0", @"is_suggest",
                   SELF_CLASS_TYPE, @"locationType",
                   [AppManager instance].currentLanguageDesc, @"lang",
                   tagIds, @"tag_ids",
                   content, @"text",
                   nil];
        }
        
    }
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - upload post
- (void)sendPost:(NSString *)content
           photo:(UIImage *)photo
          hasSms:(NSString *)hasSms
{
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"submit_post", @"action",
                         PLATFORM, @"plat",
                         @"", @"type_id",
                         @"", @"item_id",
                         hasSms, @"is_sms_inform",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].personId, @"user_id",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].userType, @"user_type",
                         [AppManager instance].clubId, @"host_id",
                         [AppManager instance].hostTypeValue, @"host_type",
                         content, @"message",
                         @"", @"latitude",
                         @"", @"longitude",
                         //                         DOUBLE_TO_STRING([AppManager instance].latitude), @"latitude",
                         //                         DOUBLE_TO_STRING([AppManager instance].longitude), @"longitude",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

- (void)sendEventDiscuss:(NSString *)content
                   photo:(UIImage *)photo
                  hasSMS:(NSString *)hasSMS
                 eventId:(NSString *)eventId {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"submit_post", @"action",
                         PLATFORM, @"plat",
                         [NSString stringWithFormat:@"%d", EVENT_DISCUSS_POST_TY], @"type_id",
                         eventId, @"item_id",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         hasSMS, @"is_sms_inform",
                         [AppManager instance].personId, @"user_id",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].userType, @"user_type",
                         content, @"message",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

- (void)sendChat:(NSString *)content{
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         content, @"ReqContent",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, CHART_SUBMIT_URL] dic:dic photo:nil];
}

#pragma mark - upload share
- (void)sendPost:(NSString *)content
          tagIds:(NSString *)tagIds
       placeName:(NSString *)placeName
           photo:(UIImage *)photo
        postType:(PostType)postType
         groupId:(NSString *)groupId
{
    
    NSDictionary *dic = nil;
    
    if ([AppManager instance].latitude == 0 && [AppManager instance].longitude == 0) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:
               @"submit_post", @"action",
               PLATFORM, @"plat",
               groupId, @"item_id",
               groupId, @"host_id",
               tagIds, @"tag_ids",
               INT_TO_STRING(postType), @"type_id",
               [AppManager instance].sessionId, @"session",
               VERSION, @"version",
               [AppManager instance].personId, @"user_id",
               [AppManager instance].username, @"user_name",
               [AppManager instance].userType, @"user_type",
               content, @"message",
               nil];
        
    } else {
        
        if (placeName.length > 0) {
            
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"submit_post", @"action",
                   PLATFORM, @"plat",
                   groupId, @"item_id",
                   groupId, @"host_id",
                   placeName, @"place",
                   tagIds, @"tag_ids",
                   INT_TO_STRING(postType), @"type_id",
                   [AppManager instance].sessionId, @"session",
                   VERSION, @"version",
                   [AppManager instance].personId, @"user_id",
                   [AppManager instance].username, @"user_name",
                   [AppManager instance].userType, @"user_type",
                   content, @"message",
                   DOUBLE_TO_STRING([AppManager instance].latitude), @"latitude",
                   DOUBLE_TO_STRING([AppManager instance].longitude), @"longitude",
                   nil];
        } else {
            
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"submit_post", @"action",
                   PLATFORM, @"plat",
                   groupId, @"item_id",
                   groupId, @"host_id",
                   tagIds, @"tag_ids",
                   INT_TO_STRING(postType), @"type_id",
                   [AppManager instance].sessionId, @"session",
                   VERSION, @"version",
                   [AppManager instance].personId, @"user_id",
                   [AppManager instance].username, @"user_name",
                   [AppManager instance].userType, @"user_type",
                   content, @"message",
                   nil];
        }
    }
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",
                      [AppManager instance].hostUrl,
                      POST_URL]
                 dic:dic
               photo:photo];
}

#pragma mark - upload post
- (void)sendPostForGroup:(Club *)group
                 content:(NSString *)content
                   photo:(UIImage *)photo {
        
    NSString *groupId = [NSString stringWithFormat:@"%@", group.clubId];
    
    NSDictionary *dic = @{@"action": @"submit_post",
    @"plat": PLATFORM,
    @"type_id": group.clubType,
    @"item_id": groupId,
    @"session": [AppManager instance].sessionId,
    @"version": VERSION,
    @"user_id": [AppManager instance].personId,
    @"user_name": [AppManager instance].username,
    @"user_type": [AppManager instance].userType,
    @"host_id": groupId,
    @"message": content,
    @"latitude": @"",
    @"longitude": @""};
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
                 dic:dic
               photo:photo];
}

- (void)sendComment:(NSString *)content
     originalItemId:(NSString *)originalItemId
              photo:(UIImage *)photo {
    
    if (nil == originalItemId || [originalItemId length] == 0) {
        return;
    }
    
    NSString *clubId = [AppManager instance].clubId;
    if (nil == clubId) {
        clubId = @"";
    }
    
    NSString *clubType = [AppManager instance].hostTypeValue;
    if (nil == clubType) {
        clubType = @"";
    }
    
    NSDictionary *dic = nil;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           @"submit_post_comment", @"action",
           PLATFORM, @"plat",
           @"", @"type_id",
           originalItemId, @"post_id",
           [AppManager instance].sessionId, @"session",
           VERSION, @"version",
           [AppManager instance].personId, @"user_id",
           [AppManager instance].username, @"user_name",
           [AppManager instance].userType, @"user_type",
           clubId, @"host_id",
           clubType, @"host_type",
           content, @"message",
           DOUBLE_TO_STRING([AppManager instance].latitude), @"latitude",
           DOUBLE_TO_STRING([AppManager instance].longitude), @"longitude",
           nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - modify User Icon
- (void)modifyUserIcon:(UIImage *)photo {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"submit_wap_user_avatar", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].personId, @"person_id",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].userType, @"user_type",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - upload brand, service item, provider comment
- (void)sendServiceItemComment:(NSString *)content
                        itemId:(NSString *)itemId
                       brandId:(NSString *)brandId {
    
    if (nil == itemId || [itemId length] == 0) {
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"service_comment_submit", @"action",
                         PLATFORM, @"plat",
                         VERSION, @"version",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].personId, @"person_id",
                         itemId, @"service_id",
                         brandId, @"channel_id",
                         content, @"message",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         nil];
    [self uploadItem:dic photo:nil];
}

- (void)sendBrandComment:(NSString *)content
                 brandId:(NSString *)brandId {
    
    if (nil == brandId || [brandId length] == 0) {
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"service_comment_submit", @"action",
                         PLATFORM, @"plat",
                         VERSION, @"version",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].personId, @"person_id",
                         brandId, @"channel_id",
                         content, @"message",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         nil];
    [self uploadItem:dic photo:nil];
}

- (void)sendServiceProviderComment:(NSString *)content
                        providerId:(NSString *)providerId {
    
    if (nil == providerId || providerId.length == 0) {
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"service_provider_comment_submit", @"action",
                         PLATFORM, @"plat",
                         @"", @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         providerId, @"service_provider_id",
                         content, @"message",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         nil];
    [self uploadItem:dic photo:nil];
}

#pragma mark - send video comment
- (void)sendVideoComment:(NSString *)content
                 videoId:(NSString *)videoId
{
    if (nil == videoId || [videoId length] == 0) {
        return;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"submit_video_comment", @"action",
                         PLATFORM, @"plat",
                         VERSION, @"version",
                         [AppManager instance].personId, @"user_id",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].userType, @"user_type",
                         [AppManager instance].username, @"user_name",
                         [AppManager instance].personId, @"person_id",
                         videoId, @"video_id",
                         content, @"message",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         nil];

    [self uploadItem:[NSString stringWithFormat:@"%@%@",
                      [AppManager instance].hostUrl,
                      POST_URL]
                 dic:dic
               photo:nil];
}

#pragma mark - check address book contacts join status
- (void)checkABContactsJoinStatus:(NSString *)emails {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"user_exist_check_email", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         emails, @"emails",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         nil];
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - load place
- (void)fetchPlaces:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load country
- (void)fetchCountries:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - fetch current city
- (void)fetchCurrentCity:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load feeds
- (void)fetchFeeds:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load questions
- (void)fetchQuestions:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - delete feed
- (void)deleteFeeds:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - delete comment
- (void)deleteComment:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - delete question
- (void)deleteQuestion:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load liker list
- (void)fetchLikers:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load checked in alumnus
- (void)fetchCheckedinAlumnus:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load sns friends
- (void)fetchSNSFriends:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - invite address book friends
- (void)inviteByAddressbookPhoneNumbers:(NSString *)phoneNumbers {
    NSDictionary *dic = nil;
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"invite_friends", @"action",
           PLATFORM, @"plat",
           VERSION, @"version",
           [AppManager instance].userId, @"user_id",
           phoneNumbers, @"mobile", nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

- (void)inviteByAddressbookEmails:(NSString *)emails {
    NSDictionary *dic = nil;
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"invite_friends", @"action",
           PLATFORM, @"plat",
           VERSION, @"version",
           [AppManager instance].userId, @"user_id",
           emails, @"email", nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

- (void)inviteByAddressbookEmails:(NSString *)emails phoneNumbers:(NSString *)phoneNumbers {
    NSDictionary *dic = nil;
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"invite_friends", @"action",
           PLATFORM, @"plat",
           VERSION, @"version",
           [AppManager instance].userId, @"user_id",
           emails, @"email",
           phoneNumbers, @"mobile", nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - invite linkedin friends
- (void)inviteLinkedinFriends:(NSString *)userIds {
    NSDictionary *dic = nil;
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"user_message", @"action",
           PLATFORM, @"plat",
           VERSION, @"version",
           [AppManager instance].userId, @"user_id",
           userIds, @"linkedinid", nil];
    
    [self uploadItem:dic photo:nil snsType:LINKEDIN_DOMAIN_TY];
}

#pragma mark - update user's nationality
- (void)updateUserNationality:(long long)countryId {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"user_info_update", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         LLINT_TO_STRING(countryId), @"country_id",
                         nil];
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update user's photo
- (void)updateUserPhoto:(UIImage *)photo {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"user_info_update", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - update years of user living China
- (void)updateUserLivingYears:(NSString *)years {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"user_info_update", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         years, @"living_years",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update user's city
- (void)updateUserLivingCity:(long long)cityId {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"user_info_update", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         LLINT_TO_STRING(cityId), @"city_id",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update username
- (void)updateUserUsername:(NSString *)username {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"user_info_update", @"action",
                         PLATFORM, @"plat",
                         [AppManager instance].sessionId, @"session",
                         VERSION, @"version",
                         [AppManager instance].userId, @"user_id",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         username, @"user_name",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - add photo for service item and provider
- (void)addPhotoForServiceItem:(UIImage *)photo
                        itemId:(long long)itemId
                       caption:(NSString *)caption {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"service_photo_submit", @"action",
                         PLATFORM, @"plat",
                         @"", @"session",
                         [AppManager instance].personId, @"person_id",
                         VERSION, @"version",
                         [NSString stringWithFormat:@"%lld", itemId], @"service_id",
                         caption, @"message",
                         [AppManager instance].currentLanguageDesc, @"locale",
                         nil];
    
    [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
                 dic:dic
               photo:photo];
}

- (void)addPhotoForServiceProvider:(UIImage *)photo
                        providerId:(long long)providerId
                           caption:(NSString *)caption {
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"service_provider_photo_submit", @"action",
                         PLATFORM, @"plat",
                         @"", @"session",
                         [AppManager instance].userId, @"user_id",
                         VERSION, @"version",
                         LLINT_TO_STRING(providerId), @"service_provider_id",
                         caption, @"message",
                         [AppManager instance].currentLanguageDesc, @"lang",
                         nil];
    
    [self uploadItem:dic photo:photo];
}

#pragma mark - load nearby groups
- (void)fetchNearbyGroups:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - recommended items for nearby service
- (void)fetchRecommendedItems:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load nearby items
- (void)fetchNearbyItems:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load album photo
- (void)fetchAlbumPhoto:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load user meta data
- (void)fetchUserMetaData:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load nearby item detail
- (void)fetchNearbyItemDetail:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - get & show
- (void)fetchGets:(NSString *)url {
    [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - get whithout alert
- (void)fetchGetsWithoutAlert:(NSString *)url {
    [self asyncGet:url showAlertMsg:NO];
}

@end
