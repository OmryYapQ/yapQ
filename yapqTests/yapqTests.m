//
//  yapqTests.m
//  yapqTests
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBCoreDataHelper.h"
#import "PackageLoader.h"
#import "Settings.h"

@interface yapqTests : XCTestCase

@end

@implementation yapqTests

- (void)setUp
{
    // [super setUp];
    /*Place *p = [[Place alloc] init];
    p.p_id = -111;
    p.title = @"test";
    p.descr = @"descr";
    p.img_url = @"http://www.google.co.il/imgres?imgurl=&imgrefurl=https%3A%2F%2Fwww.iconfinder.com%2Ficons%2F63118%2Fchecklist_icon&h=0&w=0&sz=1&tbnid=KUAaTOjLzNcWEM&tbnh=204&tbnw=204&zoom=1&docid=obElwLNNAps0pM&ei=nGejUoLyB-Gb0QX3h4HoCA&ved=0CAYQsCUoAg&biw=1440&bih=713";
    [[ServerResponse sharedResponse].places addObject:p];
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    [NSThread detachNewThreadSelector:@selector(mytest) toTarget:self withObject:nil];*/
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    //[[NSNotificationCenter defaultCenter] postNotificationName:LSLocationWasUpdatedNotification object:[LocationSevice sharedService]];
    //[super tearDown];
}

- (void)testExample
{
    /*NSLog(@"Hello");
    YLocation *loc = [YLocation initWithLatitude:TEST_LATITUDE andLongitude:TEST_LONGITUDE];
    NSArray *ar = [DBCoreDataHelper placesForLocation:loc fromRadius:200 toRadius:2500 withMaxRequestRows:10];
    NSLog(@"%@",ar);*/
}

-(void)test3DeleteFromDB {
    //NSLog(@"%@",[DBCoreDataHelper fetchAllPlaces]);
    //[DBCoreDataHelper deletePackageWithId:1 forLanguage:@"fr"];
   // NSLog(@"%@",[DBCoreDataHelper fetchAllPlaces]);
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults removeObjectForKey:GLOBAL_SETTINGS];
    
}

-(void)test2FetchFromDB {
    //[LocationSevice sharedService].currentLatitude = TEST_LATITUDE;
    //[LocationSevice sharedService].currentLongitude = TEST_LONGITUDE;
    NSLog(@"%@",[DBCoreDataHelper getAllPackages]);
    NSLog(@"%@",[DBCoreDataHelper getAllPlaces]);
    NSLog(@"%@",[DBCoreDataHelper getAllPlacesCoord]);
    //NSArray *arr = [DBCoreDataHelper placesForCurrentPlaceWithRadius:2.5];
    //NSLog(@"%@",arr);
}

-(void)test1InsertToDB {
   /* Package *p = [PackageFactoryUtils createPackage];
    p.packageId = 2;
    p.packageDescription = @"bla bla";
    p.packageCity = @"Test City";
    p.packageCountry = @"Test Country";
    p.packageName = @"First test";
    p.packageCardCode = @"TREWQ";
    p.packageExpDate = [NSDate date];
    for (int i=0; i< 3; i++) {
        Place *place = [[Place alloc] init];
        place.p_id = i;//[[NSDate date] timeIntervalSinceReferenceDate];
        place.title = [NSString stringWithFormat:@"%@",[NSDate date]];
        place.dist = 5-i;
        place.descr = @"Bla bla";
        place.img_url = @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Ben-Gurion_University_of_the_Negev_Aerial_View.JPG/300px-Ben-Gurion_University_of_the_Negev_Aerial_View.JPG";
        place.lan = 31.2439;
        place.lon = 34.7936;
        place.code_name = @"No";
        place.audio = @"http://yapp.simplest.co.il/audio/10.mp3";
        [p addPlace:place];
    }
    [DBCoreDataHelper insertPackage:p];*/
}

-(void)fileLoading {
    /*Package *p1 = [PackageFactoryUtils createPackage];
    p1.packageId = 2;
    p1.packageDescription = @"bla bla";
    p1.packageCity = @"Test City 1";
    p1.packageCountry = @"Test Country";
    p1.packageName = @"First test";
    p1.packageCardCode = @"TREWQ";
    p1.packageExpDate = [NSDate date];
    p1.packageLink = @"http://yapq.com/offline/api.php";
    
    PackageLoader *pl = [[PackageLoader alloc] initWithPackage:p1];
    [pl loadPackage];*/
}

-(void)mytest {
    
    
    //[NSThread sleepForTimeInterval:2];
    
}

@end
