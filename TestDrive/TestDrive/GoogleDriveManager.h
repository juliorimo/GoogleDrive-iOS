#import <Foundation/Foundation.h>
#import "GTLDrive.h"

typedef void (^GoogleDriveManagerStatus)(BOOL success, NSError *error);
typedef void (^GoogleDriveManagerFiles)(BOOL success, NSArray *files, NSError *error);

@interface GoogleDriveManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  Public methods
 */

- (void)fetchFilesWithCompletionBlock:(GoogleDriveManagerFiles)completionBlock;
- (void)postFile:(NSString *)title andContent:(NSString *)content withCompletionBlock:(GoogleDriveManagerStatus)completionBlock;

- (void)signoutGoogleDrive;

@end
