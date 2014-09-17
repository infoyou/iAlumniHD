//
//  ECClickableElementDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alumni.h"
#import "Post.h"

@protocol ECClickableElementDelegate <NSObject>

@optional
- (void)openImage:(UIImage *)image;
- (void)openImageUrl:(NSString *)imageUrl;
- (void)openImageUrl:(NSString *)imageUrl imageCaption:(NSString *)imageCaption;
- (void)openUrl:(NSString *)url;
- (void)openProfile:(NSString*)personId userType:(NSString*)userType;
- (void)openTraceMap;
- (void)addComment;
- (void)deletePost:(id)sender;
- (void)doChat:(Alumni *)alumni sender:(id)sender;
- (void)goPostClub:(id)sender;

#pragma mark - post stuff
- (void)sharePostToWeChat:(Post *)post;

#pragma mark - photo in post/Q&A
- (void)editPhoto;
- (void)clearPhoto;

#pragma mark - user list
- (void)openLikers;
- (void)openCheckinAlumnus;

#pragma mark - user profile
- (void)browsePoints;
- (void)browseFavoriteItems;
- (void)browseSentFeeds;
- (void)browseSentAnswers;
- (void)editProfile;
- (void)showBigPhoto:(NSString *)url;

#pragma mark - profile
- (void)addPhoto;
- (void)browseComments;
- (void)browseAlbum;
- (void)updateUsername:(NSString *)username;
- (void)share;
- (void)openKnownAlumnus;
- (void)openFavoritedAlumnus;
- (void)openWithMeConnections;
- (void)addToAddressbook;
- (void)sendDirectMessage;
- (void)changeSaveStatus;

#pragma mark - name card
- (void)showIndustries;

#pragma makr - tap gesture handler
- (void)tapGestureHandler;

#pragma mark - comment
- (void)sendComment:(NSString *)content;
- (void)deleteComment:(long long)commentId;

#pragma mark - arrange sub views
- (void)disableSubViewsOndemand;
- (void)enableSubViewOndemand;

#pragma mark - shake winner
- (void)showWinnersAndAwards;

#pragma mark - close key board
- (void)hideKeyboard;

#pragma mark - chanage avatar
- (void)changeAvatar;

- (void)changeMenuAvatar;

@end
