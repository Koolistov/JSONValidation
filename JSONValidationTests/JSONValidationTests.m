//
//  JSONValidationTests.m
//  JSONValidationTests
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of 
//    conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list 
//    of conditions and the following disclaimer in the documentation and/or other materials 
//    provided with the distribution.
//  * Neither the name of KOOLISTOV nor the names of its contributors may be used to 
//    endorse or promote products derived from this software without specific prior written 
//    permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
//  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "JSONValidationTests.h"

#import "JSON.h"
#import "KVJSONValidator.h"

@implementation JSONValidationTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
    validator = [[KVJSONValidator alloc] init];
    
    NSError *error;
    // NSString *filePath = [[NSBundle mainBundle] pathForResource:@"schema" ofType:@""];
    NSString *fileContent = [NSString stringWithContentsOfFile:@"/Users/jkool/Developer/JSONValidation/Documentation/schema" usedEncoding:NULL error:&error];
    schemaSchema = [[fileContent JSONValue] retain];
}

- (void)tearDown {
    // Tear-down code here.
    [validator release], validator = nil;
    [schemaSchema release], schemaSchema = nil;
    [super tearDown];
}

- (void)testSchema {
    NSError *error;
    BOOL valid = NO;
 
    valid = [validator validateJSONValue:schemaSchema withSchema:schemaSchema error:&error];
    STAssertTrue(valid, @"Expected valid schema. (error: %@)", error);
    
    NSString *fileContent = [NSString stringWithContentsOfFile:@"/Users/jkool/Developer/JSONValidation/Documentation/hyper-schema" usedEncoding:NULL error:&error];
    STAssertNotNil(fileContent, @"Expected no error. (error: %@)", error);
    NSString *hyperSchema = [fileContent JSONValue];
    STAssertNotNil(hyperSchema, @"Expected text. (error: %@)", error);
    valid = [validator validateJSONValue:hyperSchema withSchema:schemaSchema error:&error];
    STAssertTrue(valid, @"Expected valid hyper schema. (error: %@)", error);
                
}

- (void)testType {
    NSError *error;
    BOOL valid = NO;
    
    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\" : \"object\"}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected type 'object.' (error: %@)", error);

    valid = [validator validateJSONValue:[@"{\"test\":\"test 1\"}" JSONValue] withSchema:[@"{\"type\" : \"number\"}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected type not to be 'number.' (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
    
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

- (void)testNumber {
    NSError *error;
    BOOL valid = NO;
    
    valid = [validator validateJSONValue:[@"{\"test\":0.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected minimum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
    
    valid = [validator validateJSONValue:[@"{\"test\":1.0}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected minimum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":1.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected minimum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":0.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected maximum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":1.0}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected maximum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":1.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected maximum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
    
    valid = [validator validateJSONValue:[@"{\"test\":0.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0,\"exclusiveMinimum\":true}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected minimum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":1.0}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0,\"exclusiveMinimum\":true}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected minimum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
    
    valid = [validator validateJSONValue:[@"{\"test\":1.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"minimum\":1.0,\"exclusiveMinimum\":true}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected minimum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":0.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0,\"exclusiveMaximum\":true}}}" JSONValue] error:&error];
    STAssertTrue(valid, @"Expected maximum (error: %@)", error);
    
    valid = [validator validateJSONValue:[@"{\"test\":1.0}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0,\"exclusiveMaximum\":true}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected maximum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
    
    valid = [validator validateJSONValue:[@"{\"test\":1.5}" JSONValue] withSchema:[@"{\"type\":\"object\",\"properties\":{\"test\":{\"type\":\"number\",\"required\":true,\"maximum\":1.0,\"exclusiveMaximum\":true}}}" JSONValue] error:&error];
    STAssertFalse(valid, @"Expected maximum (error: %@)", error);
    STAssertNotNil(error, @"Expected an error. (error: %@)", error);
    error = nil;
}

@end
