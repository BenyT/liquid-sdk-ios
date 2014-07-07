//
//  LQUser.m
//  Liquid
//
//  Created by Liquid Data Intelligence, S.A. (lqd.io) on 09/01/14.
//  Copyright (c) 2014 Liquid Data Intelligence, S.A. All rights reserved.
//

#import "LQDevice.h"
#import "LQUser.h"
#import "LQDefaults.h"
#import "NSString+LQString.h"

@implementation LQUser

#pragma mark - Initializer

-(id)initWithIdentifier:(NSString *)identifier attributes:(NSDictionary *)attributes {
    self = [super init];
    if(self) {
        _identifier = identifier;
        _attributes = attributes;
        if (identifier == nil) {
            _identifier = [LQUser generateRandomUserIdentifier];
            _autoIdentified = @YES;
        } else {
            _identifier = identifier;
            _autoIdentified = @NO;
        }
        if(_attributes == nil)
            _attributes = [NSDictionary new];
    }
    return self;
}

#pragma mark - JSON

-(NSDictionary *)jsonDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary addEntriesFromDictionary:_attributes];
    [dictionary setObject:_identifier forKey:@"unique_id"];
    [dictionary setObject:_autoIdentified forKey:@"auto_identified"];
    return dictionary;
}

#pragma mark - Attributes

-(void)setAttribute:(id<NSCoding>)attribute forKey:(NSString *)key {
    if (![LQUser assertAttributeType:attribute andKey:key]) return;

    NSMutableDictionary *mutableAttributes = [_attributes mutableCopy];
    [mutableAttributes setObject:attribute forKey:key];
    _attributes = mutableAttributes;
}

-(id)attributeForKey:(NSString *)key {
    return [_attributes objectForKey:key];
}

+ (NSString *)generateRandomUserIdentifier {
    return [NSString generateRandomUUIDAppendingTimestamp:YES];
}

- (BOOL)isAutoIdentified {
    return [self.autoIdentified isEqual:@YES];
}

#pragma mark - Archive to/from disk

+ (LQUser *)loadFromDiskForToken:(NSString *)apiToken {
    LQUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] lastUserFileForToken:apiToken]];
    if (user) {
        LQLog(kLQLogLevelData, @"<Liquid> Loaded User %@ %@ from disk, for token %@", user.identifier, ([user.autoIdentified boolValue] ? @" (auto identified)" : @"(manually identified)"), apiToken);
    }
    return user;
}

+ (BOOL)destroyLastUserForToken:(NSString *)apiToken {
    BOOL status = [[NSFileManager defaultManager] removeItemAtPath:[LQUser lastUserFileForToken:apiToken] error:NULL];
    LQLog(kLQLogLevelInfoVerbose, @"<Liquid> Destroyed cached User, for token %@", apiToken);
    return status;
}

+ (BOOL)destroyLastUserForAllTokens {
    BOOL status = false;
    for (NSString *path in [LQUser filesInDirectory:[LQUser liquidDirectory]]) {
        status &= [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    LQLog(kLQLogLevelInfoVerbose, @"<Liquid> Destroyed cached Last Users");
    return status;
}

- (BOOL)saveToDiskForToken:(NSString *)apiToken {
    LQLog(kLQLogLevelData, @"<Liquid> Saving User %@ %@ to disk, for token %@", self.identifier, ([self.autoIdentified boolValue] ? @" (auto identified)" : @"(manually identified)"), apiToken);
    return [NSKeyedArchiver archiveRootObject:self toFile:[LQUser lastUserFileForToken:apiToken]];
}

+ (NSString*)lastUserFileForToken:(NSString *)apiToken {
    NSString *liquidDirectory = [LQUser liquidDirectory];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:liquidDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:liquidDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    NSString *md5apiToken = [NSString md5ofString:apiToken];
    NSString *liquidFile = [liquidDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.last_user", md5apiToken]];
    LQLog(kLQLogLevelPaths,@"<Liquid> File location %@", liquidFile);
    return liquidFile;
}

+ (NSString *)liquidDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kLQDirectory];
}

+ (NSArray *)filesInDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    return files;
}

#pragma mark - NSCoding & NSCopying

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _attributes = [aDecoder decodeObjectForKey:@"attributes"];
        _autoIdentified = [aDecoder decodeObjectForKey:@"autoIdentified"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_attributes forKey:@"attributes"];
    [aCoder encodeObject:_autoIdentified forKey:@"autoIdentified"];
}

- (id)copyWithZone:(NSZone *)zone {
    LQUser *user = [[[self class] allocWithZone:zone] init];
    user->_identifier = [_identifier copyWithZone:zone];
    user->_attributes = [_attributes copyWithZone:zone];
    user->_autoIdentified = [_autoIdentified copyWithZone:zone];
    return user;
}

@end
