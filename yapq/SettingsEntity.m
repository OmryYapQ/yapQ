//
//  SettingsEntity.m
//  yapq
//
//  Created by yapQ Ltd on 6/25/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
// m

#import "SettingsEntity.h"

@implementation SettingsEntity

-(NSString *)getStringValue {
    if ([_value isKindOfClass:[NSString class]]) {
        return _value;
    }
    return nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _entityName = [aDecoder decodeObjectForKey:@"entity_name"];
        _entityDescription = [aDecoder decodeObjectForKey:@"entity_description"];
        _value = [aDecoder decodeObjectForKey:@"entity_value"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_entityName forKey:@"entity_name"];
    [aCoder encodeObject:_entityDescription forKey:@"entity_description"];
    [aCoder encodeObject:_value forKey:@"entity_value"];
}

-(NSInteger)getIntegerValue {
    if ([_value isKindOfClass:[NSNumber class]]) {
        return [_value integerValue];
    }
    @throw [NSException exceptionWithName:@"Wrong format" reason:@"_value does not Number" userInfo:nil];
}

-(int)getIntValue {
    if ([_value isKindOfClass:[NSNumber class]]) {
        return [_value intValue];
    }
    @throw [NSException exceptionWithName:@"Wrong format" reason:@"_value does not Number" userInfo:nil];
}

-(double)getDoubleValue {
    if ([_value isKindOfClass:[NSNumber class]]) {
        return [_value doubleValue];
    }
    @throw [NSException exceptionWithName:@"Wrong format" reason:@"_value does not Number" userInfo:nil];
}

-(BOOL)getBoolValue {
    if ([_value isKindOfClass:[NSNumber class]]) {
        return [_value boolValue];
    }
    @throw [NSException exceptionWithName:@"Wrong format" reason:@"_value does not Number" userInfo:nil];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Name: %@, Descr: %@, Value: %@]",_entityName,_entityDescription,_value];
}

-(void)setStringValue:(NSString *)value {
    _value = value;
}

-(void)setIntegerValue:(NSInteger)value {
    _value = [NSNumber numberWithInteger:value];
}

-(void)setIntValue:(int)value {
    _value = [NSNumber numberWithInt:value];
}

-(void)setDoubleValue:(double)value {
    _value = [NSNumber numberWithDouble:value];
}

-(void)setBoolValue:(BOOL)value {
    _value = [NSNumber numberWithBool:value];
}

@end
