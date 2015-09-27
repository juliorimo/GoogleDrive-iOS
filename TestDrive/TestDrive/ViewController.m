//
//  ViewController.m
//  TestDrive
//
//  Created by Julio Rivas on 10/9/15.
//  Copyright (c) 2015 LuaLabs. All rights reserved.
//

#import "ViewController.h"

#import "GoogleDriveManager.h"
#import "GoogleDriveActivity.h"

@implementation ViewController
{
    BOOL _firstInTime;
}

@synthesize output = _output;

// When the view loads, create necessary subviews, and initialize the Drive API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstInTime = YES;
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    [[GoogleDriveManager sharedInstance] signoutGoogleDrive];
}

// When the view appears, ensure that the Drive API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    
    if(_firstInTime)
    {
        _firstInTime = NO;
        
        //ActivityViewController
        NSString *string = @"lol";
        NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];
        
        GoogleDriveActivity *activity = [[GoogleDriveActivity alloc] init];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL] applicationActivities:@[activity]];
        
        [self presentViewController:activityViewController
                           animated:YES
                         completion:^{}];
    }
}

- (void)fetchFiles
{
    self.output.text = @"Getting files...";
    
    [[GoogleDriveManager sharedInstance] fetchFilesWithCompletionBlock:^(BOOL success, NSArray *files, NSError *error) {
        
        if(success)
        {
            NSLog(@"%@",files);
            
            NSMutableString *filesString = [[NSMutableString alloc] init];
            if (files.count > 0) {
                [filesString appendString:@"Files:\n"];
                for (GTLDriveFile *file in files) {
                    [filesString appendFormat:@"%@ (%@)\n", file.title, file.identifier];
                }
            } else {
                [filesString appendString:@"No files found."];
            }
            self.output.text = filesString;
            
        }
        else
        {
            NSLog(@"%@",error);
            
            [self showAlert:@"Error" message:error.localizedDescription];
        }
    }];
}

- (void)postFile
{
    //Create Asset into PDF
    
    
    //Save
    [[GoogleDriveManager sharedInstance] postFile:@"Title" andContent:@"LOLOLOLOL" withCompletionBlock:^(BOOL success, NSError *error) {
        
        if(success)
        {
            NSLog(@"success!!!");
        }
        else
        {
            NSLog(@"%@",error);
        }
    }];
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}


@end
