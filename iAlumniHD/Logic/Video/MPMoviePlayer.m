//
//  MPMoviePlayer.m
//  iAlumniHD
//
//  Created by Adam on 13-1-21.
//
//

#import "MPMoviePlayer.h"

@implementation MPMoviePlayer

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [super dealloc];
}

@end

