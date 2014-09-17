//
//  ProjectSurveyViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-11.
//
//

#import "QuestionViewController.h"

@class Event;

@interface ProjectSurveyViewController : QuestionViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;

@end
