//
//  JSONValidationTests.m
//  JSONValidationTests
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//

#import "JSONValidationTests.h"

#import "JSON.h"
#import "KVJSONValidator.h"

@implementation JSONValidationTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
    validator = [[KVJSONValidator alloc] init];
}

- (void)tearDown {
    // Tear-down code here.
    [validator release], validator = nil;
    [super tearDown];
}

- (void)testType {
    NSError *error;
    BOOL valid = NO;
    
    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\" : \"object\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'object.' (error: %@)", error);

    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\" : \"number\"}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected type not to be 'number.' (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);

    valid = [validator validateJSONValue:@"test" withSchema:[@"{\"type\" : \"string\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'string.' (error: %@)", error);

    valid = [validator validateJSONValue:[@"[\"test 1\",\"test 2\"]" JSONValue] withSchema:[@"{\"type\" : \"array\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'array.' (error: %@)", error);

    valid = [validator validateJSONValue:[NSNull null] withSchema:[@"{\"type\" : \"null\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'null.' (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"[\"test 1\",\"test 2\"]" JSONValue] withSchema:[@"{\"type\" : \"any\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'any.' (error: %@)", error);
}

- (void)testRequired {
    NSError *error;
    BOOL valid = NO;
    
    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"string\",\"required\":true}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected property 'test.' (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test2\":{\"type\":\"string\",\"required\":true}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected property 'test2.' (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
}

@end
