//
//  DetailViewController.h
//  Spark
//
//  Created by DJ Chung on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Idea.h"

@interface DetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *imageCaption;
- (IBAction)addPhotoButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) Idea *idea;
@property (strong, nonatomic) NSString* localIdeaObjectID;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
- (IBAction)commentButton:(UIButton *)sender;

@end
