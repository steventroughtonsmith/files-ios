//
//  FileProvider.m
//  FilesDocumentProviderFileProvider
//
//  Created by Steven Troughton-Smith on 11/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "FileProvider.h"
#import <UIKit/UIKit.h>

@interface FileProvider ()

@end

@implementation FileProvider

- (NSFileCoordinator *)fileCoordinator {
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    [fileCoordinator setPurposeIdentifier:[self providerIdentifier]];
    return fileCoordinator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.fileCoordinator coordinateWritingItemAtURL:[self documentStorageURL] options:0 error:nil byAccessor:^(NSURL *newURL) {
            // ensure the documentStorageURL actually exists
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&error];
        }];
    }
    return self;
}

- (void)providePlaceholderAtURL:(NSURL *)url completionHandler:(void (^)(NSError *error))completionHandler {
    // Should call + writePlaceholderAtURL:withMetadata:error: with the placeholder URL, then call the completion handler with the error if applicable.
    NSString *fileName = [url lastPathComponent];
	
	NSURL *tempURL = [self.documentStorageURL URLByAppendingPathComponent:fileName];
	NSURL *redirectedURL = [NSURL URLWithString:[NSString stringWithContentsOfURL:tempURL encoding:NSUTF8StringEncoding error:nil]];
    
    NSURL *placeholderURL = [NSFileProviderExtension placeholderURLForURL:redirectedURL];
	
	NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self.documentStorageURL URLByAppendingPathComponent:fileName] path] error:nil];
	
	unsigned long long fileSize = [attribs fileSize];

    NSDictionary* metadata = @{ NSURLFileSizeKey : @(fileSize)};
    [NSFileProviderExtension writePlaceholderAtURL:placeholderURL withMetadata:metadata error:NULL];
    
    if (completionHandler) {
        completionHandler(nil);
    }
}

- (void)startProvidingItemAtURL:(NSURL *)url completionHandler:(void (^)(NSError *))completionHandler {
    // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
    NSError *fileError = nil;
	
	NSURL *redirectedURL = [NSURL URLWithString:[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil]];
	NSData *fileData = [NSData dataWithContentsOfURL:redirectedURL];
    
    [fileData writeToURL:url options:0 error:&fileError];
    
    if (completionHandler) {
        completionHandler(nil);
    }
}


- (void)itemChangedAtURL:(NSURL *)url {
    // Called at some point after the file has changed; the provider may then trigger an upload
    
    // TODO: mark file at <url> as needing an update in the model; kick off update process
    NSLog(@"Item changed at URL %@", url);
}

- (void)stopProvidingItemAtURL:(NSURL *)url {
    // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
    // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    [self providePlaceholderAtURL:url completionHandler:^(NSError * __nullable error) {
        // TODO: handle any error, do any necessary cleanup
    }];
}

@end
