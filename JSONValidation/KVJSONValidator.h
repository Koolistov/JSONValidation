//
//  KVJSONValidator.h
//  JSONValidation
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const KVJSONValidatorDomain;

typedef enum {
    KVJSONValidatorErrorInvalidType,
    KVJSONValidatorErrorMissingProperty
} KVJSONValidatorError;

@interface KVJSONValidator : NSObject {
    
}

- (BOOL)validateJSONValue:(id)JSONValue withSchema:(NSDictionary *)JSONSchema error:(NSError **)error;

@end
