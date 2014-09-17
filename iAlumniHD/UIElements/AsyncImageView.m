//
//  AsyncImageView.m
//  iAlumniHD
//
//  Created by Adam on 12-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"

@implementation AsyncImageView
@synthesize delegate = _delegate;
@synthesize _type;

- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	[connection release];
//    connection = nil;
	[data release]; 
//    data = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)loadImageFromURL:(NSURL*)url {
	if (connection!=nil) { [connection release]; } 
	if (data!=nil) { [data release]; }
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {

	[connection release];
	connection=nil;
	if ([[self subviews] count]>0) {
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	}
    
	UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self addSubview:imageView];
	imageView.frame = self.bounds;
	[imageView setNeedsLayout];
	[self setNeedsLayout];
    
	[data release];
	data = nil;
    
    if (self.delegate) {
        [self.delegate setImage:[self image] aType:_type];
    }
}

- (UIImage*) image {
    
    if ([self subviews] && [[self subviews] count]>0) {
        UIImageView *image = [[self subviews] objectAtIndex:0];
        return [image image];
    }else{
        return nil;
    }
}

@end
