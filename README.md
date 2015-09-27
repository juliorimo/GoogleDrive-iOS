# GoogleDrive-iOS
Example of application using Google Drive API as a UIActivity into UIActivityViewController.

## Integration

If you want to use this manager, you just need to include into your project these files:
- GoogleDriveManager.h
- GoogleDriveManager.m
- GoogleDriveActivity.h
- GoogleDriveActivity.m
- Drive_Icon.png

Also include this pods into your Podfile:

````
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

pod 'Google-API-Client/Drive', '~> 1.0'
````

## Using

### Ading the new activity in a UIActivityViewController

````
//ActivityViewController
NSString *string = @"lol";
NSURL *URL = [NSURL URLWithString:@"http://www.google.com"];

GoogleDriveActivity *activity = [[GoogleDriveActivity alloc] init];
UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[string, URL] applicationActivities:@[activity]];

[self presentViewController:activityViewController
                   animated:YES
                 completion:^{}];

````

### Fetching files from your drive

````
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
````
  
### Create new file in your Drive account

````
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
````

### Logount your Drive account

````  
[[GoogleDriveManager sharedInstance] signoutGoogleDrive];
````
