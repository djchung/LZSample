//
//  DetailViewController.m
//  Spark
//
//  Created by DJ Chung on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "TagImageViewController.h"
#import "HudView.h"
#import "CommentsViewController.h"
#import "AddPhotoViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
{
    UIImage *image;
}
@synthesize photoButton = _photoButton;
@synthesize imageView = _imageView;
@synthesize imageCaption = _imageCaption;
@synthesize managedObjectContext;
@synthesize photoID = _photoID;
@synthesize idea = _idea;
@synthesize localIdeaObjectID = _localIdeaObjectID;
@synthesize scrollView = _scrollView;
@synthesize addressLabel = _addressLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showImage:(UIImage *)theImage
{
    self.photoButton.hidden = YES;
    self.imageView.image = theImage;

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(320, 414);
    
    NSLog(@"^^^^^^^^^%@", self.idea.ideaName);
    //TODO: when there is an image, hide the add photo button
    //TODO: Edit button if owner
    
    //load photo from coredata by retrieving photoID
    if (self.idea.photoID != nil) {
        self.photoButton.hidden = YES;
        
        if (![UIImage imageWithContentsOfFile:[self photoPath:self.idea.photoID]]) {
            
            //Show spinner or hud loading view
            [self downloadPhotoFromParse];
        } else if ([UIImage imageWithContentsOfFile:[self photoPath:self.idea.photoID]])
        {
            UIImage *photo = [self photoImage];
            [self showImage:photo];
            NSLog(@"%@", self.idea.photoID);
        }
        
    } else if (!self.idea.photoID)
    {
        NSLog(@"no photo");
        
    }
    
    self.addressLabel.text = self.idea.address;
    
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setImageCaption:nil];
    [self setPhotoButton:nil];
    [self setScrollView:nil];
    [self setAddressLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.imageCaption = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    
}
- (void)showPhotoMenu
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        
        [actionSheet showInView:self.view.window];
    } else {
        [self choosePhotoFromLibrary];
    }
}
- (IBAction)addPhotoButton:(id)sender {
    
    [self showPhotoMenu];
    
}

- (void)choosePhotoFromLibrary {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)photoPath:(NSString *)aPhotoID
{

    return [[self documentsDirectory] stringByAppendingPathComponent:aPhotoID];
}


- (void)downloadPhotoFromParse
{
    //create HUD view
    Hudview *hudview = [Hudview hudInView:self.navigationController.view animated:YES];
    hudview.text = @"Loading...";
    
    dispatch_queue_t downloadPhotoFromParse = dispatch_queue_create("download photo", NULL);
    dispatch_async(downloadPhotoFromParse, ^{
        PFQuery *ideaQuery = [PFQuery queryWithClassName:@"Idea"];
        [ideaQuery whereKey:@"photoID" equalTo:self.idea.photoID];
        NSArray *retrieveIdeaFromParse = [ideaQuery findObjects];
        PFObject *ideaObjectFromParse = [retrieveIdeaFromParse lastObject];
        PFFile *ideaPhotoFileFromParse = [ideaObjectFromParse objectForKey:@"ideaPhoto"];
        NSData *ideaPhotoData = [ideaPhotoFileFromParse getData];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            if (![ideaPhotoData writeToFile:[self photoPath:self.idea.photoID] options:NSDataWritingAtomic error:&error])
            {
                NSLog(@"Error writing to file: %@", error);
                
            }else {
                [self showImage:[UIImage imageWithContentsOfFile:[self photoPath:self.idea.photoID]]];
                self.navigationController.view.userInteractionEnabled = YES;
                [hudview removeFromSuperview];
            }
            
        });
    });
    dispatch_release(downloadPhotoFromParse);
}
- (UIImage *)photoImage
{

    return [UIImage imageWithContentsOfFile:[self photoPath:self.idea.photoID]];
    
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    self.photoID = (__bridge NSString *)newUniqueIDString;
    self.idea.photoID = self.photoID;
    
    
    CFRelease(newUniqueID);
    CFRelease(newUniqueIDString);
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", error);
        abort();
    }
    
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *data = UIImagePNGRepresentation(image);
    if (![data writeToFile:[self photoPath:self.idea.photoID] options:NSDataWritingAtomic error:&error])
    {
        NSLog(@"Error writing to file: %@", error);
    }
    dispatch_queue_t uploadPhotoToParse = dispatch_queue_create("photo uploader", NULL);
    dispatch_async(uploadPhotoToParse, ^{
        PFFile *imageFile= [PFFile fileWithName:[NSString stringWithFormat:@"%@.png", self.idea.photoID] data:data];
        [imageFile save];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Idea"];
        
        [query whereKey:@"localIdeaObjectID" equalTo:self.localIdeaObjectID];
        NSArray *getCurrentIdea = [query findObjects];
        
        PFObject *currentIdea = [getCurrentIdea lastObject];
        [currentIdea setObject:imageFile forKey:@"ideaPhoto"];
        [currentIdea setObject:self.idea.photoID forKey:@"photoID"];
        
        [currentIdea save];
        NSLog(@"uploading to parse");
    });
    dispatch_release(uploadPhotoToParse);
    
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        
        [self showImage:image];
  
        
    }];
    
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)commentButton:(UIButton *)sender {
    CommentsViewController *cvc = [[CommentsViewController alloc]init];
    cvc.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:cvc animated:YES];
}
@end
