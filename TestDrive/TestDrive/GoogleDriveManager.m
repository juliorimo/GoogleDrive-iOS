#import "GoogleDriveManager.h"
#import "GTMOAuth2ViewControllerTouch.h"

static NSString *const kKeychainItemName = @"Trov-Hackathon-Drive";
static NSString *const kClientId = @"507530603503-qdnv6hncch20rb47ovakn375e1avestl.apps.googleusercontent.com";
static NSString *const kClientSecret = @"9zXfEE9fTQhPwPbgcOnBqk7R";

@interface GoogleDriveManager()
@property (nonatomic, strong) GTLServiceDrive *driveService;
@property (nonatomic, strong) GTLDriveFile *driveFile;
@end

@implementation GoogleDriveManager
{
    GoogleDriveManagerStatus _loginBlock;
    GoogleDriveManagerFiles _fetchBlock;
    GoogleDriveManagerStatus _postBlock;
}

#pragma mark - Init

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initGoogleDriveManager
{
    // Initialize the Drive API service & load existing credentials from the keychain if available.
    self.driveService = [[GTLServiceDrive alloc] init];
    
    // Check for authorization.
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                          clientID:kClientId
                                                                                      clientSecret:kClientSecret];

    if ([auth canAuthorize]) {
        [[self driveService] setAuthorizer:auth];
    }
}

#pragma mark - Login

- (void)signoutGoogleDrive
{
    // Sign out
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [[self driveService] setAuthorizer:nil];
}

- (void)loginGoogleDriveWithCompletionBlock:(GoogleDriveManagerStatus)completionBlock
{
    if (!self.driveService.authorizer.canAuthorize)
    {
        _loginBlock = completionBlock;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootViewController = window.rootViewController;
        [rootViewController presentViewController:[self createAuthController] animated:YES completion:nil];
    }
    else
    {
        completionBlock(YES, nil);
    }
}

// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:kGTLAuthScopeDriveFile
                      clientID:kClientId
                      clientSecret:kClientSecret
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    
    if (error != nil)
    {
        //Authentication Error
        self.driveService.authorizer = nil;
        _loginBlock(NO, error);
    }
    else
    {
        self.driveService.authorizer = authResult;
        [viewController dismissViewControllerAnimated:YES completion:^{
            
            _loginBlock(YES, error);
            
        }];
    }
}

#pragma mark - Fetching

// Construct a query to get names and IDs of 10 files using the Google Drive API.
- (void)fetchFiles {

    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.maxResults = 10;
    [self.driveService executeQuery:query
                           delegate:self
                  didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Process the response and display output.
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLDriveFileList *)files
                          error:(NSError *)error {
    if (error == nil) {
        
        NSArray *fetchedFiles = (files && files.items) ? files.items : nil;
        
        _fetchBlock(YES, fetchedFiles, error);
        
    } else {
        
        _fetchBlock(NO, nil, error);        
    }
}

- (void)fetchFilesWithCompletionBlock:(GoogleDriveManagerFiles)completionBlock
{
    if(!self.driveService)
    {
        [self initGoogleDriveManager];
    }
    
    
    [self loginGoogleDriveWithCompletionBlock:^(BOOL success, NSError *error) {
       
        if(success)
        {
            _fetchBlock = completionBlock;
            
            [self fetchFiles];
        }
        else
        {
            completionBlock(NO, nil, error);
        }
    }];
}

#pragma mark - Posting

- (void)postFileWithTitle:(NSString *)title andContent:(NSString *)content
{
    NSData *fileContent = [content dataUsingEncoding:NSUTF8StringEncoding];
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:fileContent MIMEType:@"text/plain"];
    self.driveFile = [GTLDriveFile object];
    self.driveFile.title = title;
    GTLQueryDrive *query = nil;
    
    // This is a new file, instantiate an insert query.
    query = [GTLQueryDrive queryForFilesInsertWithObject:self.driveFile
                                        uploadParameters:uploadParameters];
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *updatedFile,
                                                              NSError *error) {
        if (error == nil)
        {
            self.driveFile = updatedFile;
            
            _postBlock(YES, error);
        }
        else
        {
            NSLog(@"An error occurred: %@", error);
            
            _postBlock(NO, error);
        }
    }];
}

- (void)postFile:(NSString *)title andContent:(NSString *)content withCompletionBlock:(GoogleDriveManagerStatus)completionBlock
{
    if(!self.driveService)
    {
        [self initGoogleDriveManager];
    }
    
    [self loginGoogleDriveWithCompletionBlock:^(BOOL success, NSError *error) {
        
        if(success)
        {
            _postBlock = completionBlock;
            
            [self postFileWithTitle:title andContent:content];
        }
        else
        {
            completionBlock(NO, error);
        }
    }];
}

- (void)updateFile:(GTLDriveFile *)file withTitle:(NSString *)title andContent:(NSString *)content withCompletionBlock:(GoogleDriveManagerStatus)completionBlock
{
    if(!self.driveService)
    {
        [self initGoogleDriveManager];
    }
    
    
}


@end
