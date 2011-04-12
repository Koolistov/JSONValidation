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
    KVJSONValidatorErrorGeneral,
    KVJSONValidatorErrorInvalidType,
    KVJSONValidatorErrorMissingProperty,
    KVJSONValidatorErrorNonConformingProperty,
    KVJSONValidatorErrorMissingItem,
    KVJSONValidatorErrorNonConformingItem,
    KVJSONValidatorErrorTooFewItems,
    KVJSONValidatorErrorTooManyItems,
    KVJSONValidatorErrorNotUniqueItems,
    KVJSONValidatorErrorPatternMismatch,
    KVJSONValidatorErrorTooShortString,
    KVJSONValidatorErrorTooLongString,
    KVJSONValidatorErrorNotEnumeratedString,
    KVJSONValidatorErrorTooSmallNumber,
    KVJSONValidatorErrorTooBigNumber
} KVJSONValidatorError;

@interface KVJSONValidator : NSObject {
    
}

- (BOOL)validateJSONSchema:(NSDictionary *)schema error:(NSError **)error;
- (BOOL)validateJSONValue:(id)value withSchema:(NSDictionary *)schema error:(NSError **)error;

@end

@interface NSObject (JSONValidation)

- (BOOL)kv_validateWithJSONSchema:(NSDictionary *)schema error:(NSError **)error;

@end