#import "GoogleDriveActivity.h"
#import "GoogleDriveManager.h"

@implementation GoogleDriveActivity
{
    NSString *_file;
}

#pragma mark - Overrides

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
    return @"Drive";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"Drive_Icon"];
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]]) {
            _file = activityItem;
        }
    }
}

- (void)performActivity
{
    // This is where you can do anything you want, and is the whole reason for creating a custom
    // UIActivity

//    [[GoogleDriveManager sharedInstance] fetchFilesWithCompletionBlock:^(BOOL success, NSArray *files, NSError *error) {
//        
//        if(success)
//        {
//            NSLog(@"%@",files);
//        }
//        else
//        {
//            NSLog(@"%@",error);
//        }
//        
//        [self activityDidFinish:YES];
//    }];

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
        
        [self activityDidFinish:YES];
    }];
}

@end
