//
//  ViewController.m
//  CMakePlus
//
//  Created by Alex on 2/20/15.
//  Copyright (c) 2015 Alex Peterson. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString * const kCMakeFileKey = @"CMAKEFILE_CONTENTS";
static NSString * const kLastPathKey = @"CMAKEFILE_LASTPATH";

@interface ViewController() <NSTextViewDelegate, NSFileManagerDelegate>

@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *projectName;
@property (unsafe_unretained) IBOutlet NSTextView *cmakefileTextView;
@property (weak) IBOutlet NSPathControl *projectFolder;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *createButton;

@property (strong) NSTask *task;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *cmakefile = [NSUserDefaults.standardUserDefaults objectForKey:kCMakeFileKey];
    if (cmakefile) {
        [self.cmakefileTextView setString:cmakefile];
    }
    
    NSURL *lastPath = [NSUserDefaults.standardUserDefaults URLForKey:kLastPathKey];
    if (lastPath) {
        [self.projectFolder setURL:lastPath];
    }

    self.cmakefileTextView.delegate = self;
    self.progressIndicator.hidden = YES;
    self.projectName.stringValue = @"test";
    self.status.stringValue = @"";
    
    NSFileManager.defaultManager.delegate = self;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self.projectName becomeFirstResponder];
}

- (IBAction)create:(id)sender {
    if (self.projectName.stringValue &&
        self.projectName.stringValue.length &&
        self.projectFolder.URL &&
        self.cmakefileTextView.string &&
        self.cmakefileTextView.string.length) {
        
        [NSUserDefaults.standardUserDefaults setURL:self.projectFolder.URL forKey:kLastPathKey];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(taskQueue, ^{
            @try {
                self.createButton.enabled = NO;
                self.progressIndicator.hidden = NO;
                [self.progressIndicator startAnimation:self];

                [self copyCMakeFiles];

                // download the file
                self.task = NSTask.new;
                [self.task setCurrentDirectoryPath:self.projectFolder.URL.path];
                
                // @TODO find/install/prepackage cmake
                [self.task setLaunchPath:@"/usr/local/bin/cmake"];
                
                // for debugging try these alternatives
//                [self.task setArguments:@[@"--help",@"--debug-output", @"-G=\"Xcode\""]];
//                [self.task setArguments:@[@"--debug-output", @"-G",@"Xcode"]];
                
                [self.task setArguments:@[@"-G",@"Xcode"]];
                [self.task launch];
                [self.task waitUntilExit];
            }
            @catch (NSException *exception) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.status.stringValue = exception.description;
                });
                
                NSLog(@"Problem Running Task: %@", [exception description]);
            }
            @finally {
                [self.progressIndicator stopAnimation:self];
                self.progressIndicator.hidden = YES;
                self.createButton.enabled = YES;
            }
        });
    }
}

- (void)textDidChange:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults]
     setObject:self.cmakefileTextView.string
     forKey:kCMakeFileKey];
}

#pragma mark - NSFileManagerDelegate

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    // overwriting files is OK
    return error.code == NSFileWriteFileExistsError;
}

#pragma mark - Private

- (void)copyCMakeFiles {
    // @TODO OSX version
    NSString *cmakePath = [NSBundle.mainBundle pathForResource:@"CMakeLists" ofType:@"txt" inDirectory:@"iOS"];
    if (cmakePath) {
        NSError *error = nil;
        [NSFileManager.defaultManager copyItemAtPath:cmakePath toPath:[self.projectFolder.URL.path stringByAppendingString:@"/CMakeLists.txt"] error:&error];
        if (error) {
            NSLog(@"Failed to copy CMakeLists.txt file from %@ to %@ : %@",cmakePath, self.projectFolder.URL.path, error.description);
        }
        
    }
    
    NSString *sourcePath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"iOS/sources"];
    if (sourcePath) {
        NSError *error = nil;
        [NSFileManager.defaultManager copyItemAtPath:sourcePath toPath:[self.projectFolder.URL.path stringByAppendingString:@"/sources"] error:&error];
        if (error) {
            NSLog(@"Failed to copy CMakeLists.txt file from %@ to %@ : %@",sourcePath, self.projectFolder.URL.path, error.description);
        }
    }
}

@end
