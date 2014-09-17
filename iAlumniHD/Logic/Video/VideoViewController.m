//
//  VideoViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-1-21.
//
//

#import "VideoViewController.h"
#import "MPMoviePlayer.h"
#import "CommonUtils.h"
#import "VideoListViewController.h"

@interface VideoViewController ()
@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSMutableData *connectionData;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,retain) MPMoviePlayer *moviePlayerVC;
@end

@implementation VideoViewController

-(id)initWithURL:(NSString *)videoUrl
{
	self = [super init];
    
	if(self != nil)
	{
		self.url = videoUrl;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self play];
}

- (void)play
{
    
    NSURL *urlpath = nil;
    
    NSLog(@"%f", [CommonUtils currentOSVersion]);

    if ([CommonUtils currentOSVersion] > IOS4 && [CommonUtils currentOSVersion] <= IOS5_1) {
        urlpath = [NSURL URLWithString:self.url];
    } else {
        urlpath = [[NSURL alloc] initWithString:self.url];
    }
    
    self.moviePlayerVC = [[[MPMoviePlayer alloc] initWithContentURL:urlpath] autorelease];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayerVC.moviePlayer];

    if ([CommonUtils currentOSVersion] >= IOS4) {
        
        self.moviePlayerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[APP_DELEGATE foundationRootViewController] presentModalViewController:self.moviePlayerVC animated:YES];
    } else {
        [self presentModalViewController:self.moviePlayerVC animated:YES];
    }
    
    [[self.moviePlayerVC moviePlayer] play];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}

- (void)connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data{
    NSLog(@"Received data");
    [self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /* 下载的数据 */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //获取文件路径
    NSArray *urlArray = [self.url componentsSeparatedByString:@"/"];
    int size = [urlArray count];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[urlArray objectAtIndex:(size-1)]];

    NSLog(@"%@ path = ",path);
    
    if ([self.connectionData writeToFile:path atomically:YES]) {
        NSLog(@"保存成功.");
    } else {
        NSLog(@"保存失败.");
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.connectionData setLength:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
    self.connectionData = nil;
    self.moviePlayerVC = nil;

    [super dealloc];
}

-(void)moviePlayBackDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayerVC.moviePlayer];
    
    [self.moviePlayerVC setWantsFullScreenLayout:NO];
    [self.view removeFromSuperview];
    [AppManager instance].showIndex = VIDEO_MENU_TY;
//    [APP_DELEGATE closeViewStack];
}

@end