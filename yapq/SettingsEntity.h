//
//  SettingsEntity.h
//  yapq
//
//  Created by yapQ Ltd on 6/25/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
// m

#import <Foundation/Foundation.h>

@interface SettingsEntity : NSObject <NSCoding>

@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *entityDescription;
@property id value;

-(NSString *)getStringValue;
-(NSInteger)getIntegerValue;
-(int)getIntValue;
-(double)getDoubleValue;
-(BOOL)getBoolValue;

-(void)setStringValue:(NSString *)value;
-(void)setIntegerValue:(NSInteger)value;
-(void)setIntValue:(int)value;
-(void)setDoubleValue:(double)value;
-(void)setBoolValue:(BOOL)value;

@end
