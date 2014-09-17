//
//  SurveyViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-2-9.
//
//

#import "BaseListViewController.h"
#import "QuestionViewController.h"

@interface SurveyViewController : QuestionViewController
{
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
