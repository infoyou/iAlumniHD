//
//  VideoViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-1-21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RootViewController.h"

@interface VideoViewController : RootViewController{
    
}

-(id)initWithURL:(NSString *)videoUrl;

@end
