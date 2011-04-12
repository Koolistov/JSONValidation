//
//  JSONValidationTests.h
//  JSONValidationTests
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class KVJSONValidator;

@interface JSONValidationTests : SenTestCase {
@private
    KVJSONValidator *validator;
    NSDictionary *schemaSchema;
}

@end
