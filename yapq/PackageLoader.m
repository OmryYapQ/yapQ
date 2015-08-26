//
//  PackageLoader.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageLoader.h"

@implementation PackageLoader

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark -
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(id)initWithPackage:(Package *)package {
    if (self = [super init]) {
        self.package = package;
        [self createFilePath];
        [self setStatus:PLS_LOAD_WAITING];
        //_currentStatus = PLS_LOAD_WAITING;
        observers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSString *)messageForCurrentState {
    switch (_currentStatus) {
        case PLS_LOAD_STARTED :
        case PLS_LOAD_ERROR:
        case PLS_LOAD_FINISHED:
            return @"DOWNLOADING";
        case PLS_UNZIP_STARTED:
        case PLS_UNZIP_ERROR:
        case PLS_UNZIP_FINISHED:
        case PLS_PARSING_STARTED:
        case PLS_PARSING_ERROR:
        case PLS_PARSING_FINISHED:
            return @"INSTALLING";
        case PLS_LOAD_WAITING:
            return @"WAITING";
    }
    return @"WAITING";
}

-(BOOL)isEnoughSpaceForLoading {
    double freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    NSLog(@"%lf",freeSpace);
    if ((self.package.size+(self.package.size*0.1)+_contentLength) < (freeSpace-(10+1024+1024))) {
        return YES;
    }
    return NO;
}

-(void)createFilePath {
    if (_package) {
        _filePath = [TMP stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%li%@",TEMP_ZIP_NAME,(long)_package.packageId,TEMP_EXT]];
        _extractedFilePath = [TMP stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%li",TEMP_ZIP_NAME,(long)_package.packageId]];
    }
    else {
        _filePath = [TMP stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",TEMP_ZIP_NAME,TEMP_EXT]];
        _extractedFilePath = [TMP stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",TEMP_ZIP_NAME]];
    }
    NSLog(@"%@",_filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self removePackageZip];
    [fileManager createFileAtPath:_filePath contents:nil attributes:nil];
    [fileManager createDirectoryAtPath:_extractedFilePath withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)loadPackage {
    if (!_filePath) {
        [self createFilePath];
    }
    __weak PackageLoader *weakPl = self;
    [WebServices varifyPurchaseWithPackage:_package
                              purchaseCode:_package.packageCardCode
                                 userToken:[[Settings sharedSettings] getLoginToken]
                        andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *responseDictionary) {
        PackageLoader *strongPl = weakPl;
        if (status == WS_OK) {
            NSString *hash = [responseDictionary valueForKey:HASH_KEY];
            if (!hash) {
                [self setStatus:PLS_LOAD_ERROR];
                [_delegate loadError:strongPl];
            }
            else {
                [self loadAfterVarifyWithHash:hash];
            }
        }
        else if (status == WS_ERROR) {
            [self setStatus:PLS_LOAD_ERROR];
            [_delegate loadError:strongPl];
        }
    }];
    
}

-(void)loadAfterVarifyWithHash:(NSString *)hash{
    __weak PackageLoader *weakPl = self;
    [WebServices getOfflinePackageLink:_package.packageId withUserHash:hash andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *responseDictionary) {
        [NSThread sleepForTimeInterval:1];
        PackageLoader *strongPl = weakPl;
        if (status == WS_OK) {
            [Utilities UITaskInSeparatedBlock:^{
                [strongPl loadPackageFromUrl:[responseDictionary valueForKey:PACKAGE_ZIP_URL]];
                //[self loadPackageToDB];
            }];
        }
        else {
            [self setStatus:PLS_LOAD_ERROR];
            [_delegate loadError:strongPl];
        }
    }];
}

-(void)loadPackageFromUrl:(NSString *)url {
    _package.packageLink = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_package.packageLink] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self setStatus:PLS_LOAD_STARTED];
    [_delegate loadStarted:self]; // Delegate start download
    [connection start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(void)unzipPackage {
    
    [self setStatus:PLS_UNZIP_STARTED];
    [_delegate unzipStarted:self];
    ZipFile *unzipFile = nil;
    @try {
        @autoreleasepool {
            const int BUFFER_SIZE = 4096;
             unzipFile = [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeUnzip];
            NSArray *info = [unzipFile listFileInZipInfos];
            [unzipFile goToFirstFileInZip];
            NSMutableData *data = [[NSMutableData alloc] initWithLength:BUFFER_SIZE];
            float progress = MAX_UNZIP_VALUE_PERCENT/info.count;
            for (FileInZipInfo *f in info) {
                @autoreleasepool {
                    NSString *fileName = f.name;
                    ZipReadStream *read = [unzipFile readCurrentFileInZip];
                    NSLog(@"%@ => %li",f.name,(unsigned long)f.length);
                    do {
                        [data setLength:BUFFER_SIZE];
                        NSUInteger bytes = [read readDataWithBuffer:data];
                        if (bytes > 0) {
                            [data setLength:bytes];
                            NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:[_extractedFilePath stringByAppendingPathComponent:fileName]];
                            if (file) {
                                [file seekToEndOfFile];
                                [file writeData:data];
                                [file closeFile];
                            }
                            else {
                                [data writeToFile:[_extractedFilePath stringByAppendingPathComponent:fileName] atomically:NO];
                            }
                        }
                        else if ([fileName rangeOfString:@"/"].location != NSNotFound) {
                            [self createFolderHierarchy:fileName];
                            break;
                        }
                        else
                            break;
                    }
                    while (YES);
                    
                    [read finishedReading];
                    [unzipFile goToNextFileInZip];
                }
                [self updateProgressValueWithValue:progress];
                
            }
            //[self updateProgressValueWithValue:MAX_UNZIP_VALUE_PERCENT];
            [self setStatus:PLS_UNZIP_FINISHED];
            [_delegate unzipFinished:self];
            [self moveImagesToDocumentDir];
        }
    }
    @catch (ZipException *exception) {
        [self setStatus:PLS_UNZIP_ERROR];
        [_delegate unzipError:self];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_UNZIP_PACKAGE_ERROR,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
    @finally {
        if (unzipFile) {
            [unzipFile close];
        }
    }
    
}

-(void)createFolderHierarchy:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[_extractedFilePath stringByAppendingPathComponent:path]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
}

-(void)moveImagesToDocumentDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *tempImg = [_extractedFilePath stringByAppendingPathComponent:IMG_DIR_NAME];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:tempImg error:nil];
    NSString *docPath = [self imagePath];
    [fileManager createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    for (NSString *f in files) {
        [fileManager moveItemAtPath:[tempImg stringByAppendingPathComponent:f] toPath:[docPath stringByAppendingPathComponent:f] error:nil];
    }
}

-(void)loadPackageToDB {
    
    [self setStatus:PLS_PARSING_STARTED];
    [_delegate parsingStarted:self];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:[_extractedFilePath stringByAppendingPathComponent:DATA_FILE_NAME] options:NSDataReadingMapped|NSDataReadingUncached error:&error];
    //NSString *json = [NSString stringWithContentsOfFile:[_extractedFilePath stringByAppendingPathComponent:DATA_FILE_NAME]
    //                                           encoding:NSUTF8StringEncoding
    //                                              error:&error];
    if (error || jsonData == nil) {
        _error = error;
        NSLog(@"%@",error);
        _currentStatus = PLS_PARSING_ERROR;
        [_delegate parsingError:self];
        return;
    }
    @try {
        //SBJsonParser *parser = [[SBJsonParser alloc] init];
        JSONDecoder* decoder = [[JSONDecoder alloc]
                                initWithParseOptions:JKParseOptionNone];
        NSArray *jsonArr = [decoder objectWithData:jsonData];//[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];//[parser objectWithData:jsonData];
        float progress = MAX_PARSING_VALUE_PERCENT/jsonArr.count;
        NSString *imgDir = [self imagePath];
        
        _package.numberOfPlaces = (int)jsonArr.count;
        [DBCoreDataHelper insertPackage:_package forLanguage:_package.packageLang];
        Place *p = [[Place alloc] init];
        for (int i=0;i<jsonArr.count;i++) {
            @autoreleasepool {
                NSDictionary *pd = [jsonArr objectAtIndex:i];
                p = [PlaceFactoryUtils createPlace:p withJsonDictionary:pd];
                //Place *p = [PlaceFactoryUtils createPlaceWithJsonDictionary:pd];
                if (p.img_url) {
                    NSLog(@"%@",p.img_url);
                    p.img_url = [NSString stringWithFormat:@"%@",[imgDir stringByAppendingPathComponent:p.img_url]];
                }
                //[_package addPlace:p];
                [DBCoreDataHelper insertPlace:p forPackageWithId:_package.packageId andLanguage:_package.packageLang];
                [p dispose];
                [self updateProgressValueWithValue:progress];
            }
        }
        //YAJLParser *parser = [[YAJLParser alloc] initWithParserOptions:YAJLParserOptionsAllowComments];
        //parser.delegate = self;
        //[parser parse:jsonData];
        //[parser release];
        
        [self setStatus:PLS_PARSING_FINISHED];
        [self updateProgressValueWithValue:MAX_PARSING_VALUE_PERCENT];
        [_delegate parsingFinished:self];
        //[self cleanAll];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.debugDescription);
        NSLog(@"%@",exception.description);
        [self setStatus:PLS_PARSING_ERROR];
        [_delegate parsingError:self];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_PARSING_OR_SAVE_TO_DB_ERROR,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

-(void)parserDidStartArray:(YAJLParser *)parser {
    
}

-(void)parserDidEndArray:(YAJLParser *)parser {
    
}

-(NSString *)imagePath {
    NSString *packageNameMd5 = [Utilities md5:_package.packageName];
    NSString *path = [[[Utilities applicationDocumentsDirectory] path] stringByAppendingPathComponent:packageNameMd5];
    return path;
}

-(void)removePackageZip {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (_filePath != nil && [fileManager fileExistsAtPath:_filePath]) {
        [fileManager removeItemAtPath:_filePath error:nil];
    }
    //[self removeExtractedZip];
}

-(void)removeExtractedZip {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (_extractedFilePath != nil && [fileManager fileExistsAtPath:_extractedFilePath]) {
        [fileManager removeItemAtPath:_extractedFilePath error:nil];
    }
}

-(void)cleanAll {
    [self removePackageZip];
    [self removeExtractedZip];
    [observers removeAllObjects];
    _loadingProgres = 0;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Key-Value observer
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)updateProgressValueWithValue:(float)value {
    _loadingProgres += value;
    @try {
        NSObject *o = [observers valueForKey:kDownloadProgressObserver];
        [o observeValueForKeyPath:kDownloadProgressObserver
                         ofObject:self
                           change:@{NSKeyValueChangeNewKey: [NSNumber numberWithFloat:_loadingProgres]}
                          context:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_LOADING_PROGRESS_OBSERVER,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

-(void)setStatus:(PLStatus)status {
    _currentStatus = status;
    @try {
        NSObject *o = [observers valueForKey:KPackageLoaderStatus];
        [o observeValueForKeyPath:KPackageLoaderStatus
                         ofObject:self
                           change:@{NSKeyValueChangeNewKey: [NSNumber numberWithFloat:_currentStatus]}
                          context:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_LOADIGN_STATUS_OBSERVER,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [observers setObject:observer forKey:keyPath];
}

-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [observers removeObserver:observer forKeyPath:keyPath];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"%@",error);
    _error = error;
    [self setStatus:PLS_LOAD_ERROR];
    [_delegate loadError:self]; // Delegate error while download
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *urlRep = (NSHTTPURLResponse *)response;
        NSLog(@"%@",response);
        _contentLength = [[[urlRep allHeaderFields] valueForKey:@"Content-Length"] longLongValue];
        NSLog(@"%@",[[urlRep allHeaderFields] valueForKey:@"Content-Length"]);
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
    [file seekToEndOfFile];
    [file writeData:data];
    [file closeFile];
    
    float loaderd = (MAX_LOAD_VALUE_PERCENT*data.length)/_contentLength;
    [self updateProgressValueWithValue:loaderd];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    long long fileSize = [[fileManager attributesOfItemAtPath:_filePath error:&error] fileSize];
    if (fileSize == _contentLength && error == nil) {
        [self setStatus:PLS_LOAD_FINISHED];
        [_delegate loadFinished:self];
        NSLog(@"%@",[[Utilities applicationDocumentsDirectory] path]);
    }
    else {
        _error = error;
        [self setStatus:PLS_LOAD_ERROR];
        [_delegate loadError:self];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLSessionDownloadDelegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/** NOT IN USE */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
}

@end
