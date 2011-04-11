//
//  KVJSONValidator.m
//  JSONValidation
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//

#import "KVJSONValidator.h"

NSString *const KVJSONValidatorDomain = @"KVJSONValidatorDomain";

@interface KVJSONValidator ()

#pragma mark - General 
- (BOOL)checkValue:(id)value isInstanceOfType:(id)typeOrTypes error:(NSError **)error;

#pragma mark - Object 
- (BOOL)checkObject:(NSDictionary *)value containsConformingProperties:(NSDictionary *)properties error:(NSError **)error;

#pragma mark - Array 
- (BOOL)checkArray:(NSArray *)value containsConformingItems:(id)schemaOrSchemas error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasMinItems:(int)minItems error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasMaxItems:(int)maxItems error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasUniqueItems:(BOOL)uniqueItems error:(NSError **)error;

#pragma mark - String
- (BOOL)checkString:(NSString *)value matchesPattern:(NSString *)pattern error:(NSError **)error;
- (BOOL)checkString:(NSString *)value hasMinLength:(int)minLength error:(NSError **)error;
- (BOOL)checkString:(NSString *)value hasMaxLength:(int)maxLength error:(NSError **)error;
- (BOOL)checkString:(NSString *)value isInEnum:(NSArray *)enumeration error:(NSError **)error;

#pragma mark - Number
- (BOOL)checkString:(NSNumber *)value hasMinimum:(NSNumber *)minimum error:(NSError **)error;
- (BOOL)checkString:(NSNumber *)value hasMaximum:(NSNumber *)maximum error:(NSError **)error;
- (BOOL)checkString:(NSNumber *)value hasExclusiveMinimum:(NSNumber *)exclusiveMinimum error:(NSError **)error;
- (BOOL)checkString:(NSNumber *)value hasExclusiveMaximum:(NSNumber *)exclusivemMaximum error:(NSError **)error;

@end

@implementation KVJSONValidator

#pragma mark - General 
- (BOOL)validateJSONValue:(id)value withSchema:(NSDictionary *)schema error:(NSError **)error {
    // Check if schema is valid?!
    NSParameterAssert(value != nil);
    NSParameterAssert(schema != nil); // Actually, empty schema means always valid, but this is handier for debugging for now

    // Check value type
    id type = [schema objectForKey:@"type"];
    if (![self checkValue:value isInstanceOfType:type error:error]) {
        return NO;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        // Object checks
        // Check properties
        NSDictionary *properties = [schema objectForKey:@"properties"];
        if (![self checkObject:value containsConformingProperties:properties error:error]) {
            return NO;
        }
        // Check patternProperties

        // Check additionalProperties
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        // Array checks
        // Check items

        // Check additionalItems

    } else if ([value isKindOfClass:[NSNumber class]]) {
        // Number checks
        
    }
    
    return YES;
}

- (BOOL)checkValue:(id)aValue isInstanceOfType:(id)typeOrTypes error:(NSError **)error {
    NSArray *allowedTypes = nil;

    if ([typeOrTypes isKindOfClass:[NSString class]]) {
        allowedTypes = [NSArray arrayWithObject:typeOrTypes];
    } else if ([typeOrTypes isKindOfClass:[NSArray class]]) {
        allowedTypes = typeOrTypes;
    }
    BOOL foundAllowedType = NO;
    for (NSString *type in allowedTypes) {
        if ([type isEqualToString:@"string"]) {
            if ([aValue isKindOfClass:[NSString class]]) {
                foundAllowedType = YES;
                break;
            }
        } else if ([type isEqualToString:@"array"]) {
            if ([aValue isKindOfClass:[NSArray class]]) {
                foundAllowedType = YES;
                break;
            }
        } else if ([type isEqualToString:@"object"]) {
            if ([aValue isKindOfClass:[NSDictionary class]]) {
                foundAllowedType = YES;
                break;
            }
        } else if ([type isEqualToString:@"number"]) {
            if ([aValue isKindOfClass:[NSNumber class]]) {
                foundAllowedType = YES;
                break;
            }
        } else if ([type isEqualToString:@"boolean"]) {
            if ([aValue isKindOfClass:[NSNumber class]]) {
                double test = [aValue doubleValue];
                if (test == 0 ||  test == 1) {
                    foundAllowedType = YES;
                    break;
                } else {
                    // NSNumber, but not a boolean
                }
            }
        } else if ([type isEqualToString:@"integer"]) {
            if ([aValue isKindOfClass:[NSNumber class]]) {
                double test = [aValue doubleValue];
                double integral;
                double fractional = modf(test, &integral);
                if (fractional == 0.0) {
                    foundAllowedType = YES;
                    break;
                } else {
                    // NSNumber, but not a integer
                }
            }
        } else if ([type isEqualToString:@"null"]) {
            if ([aValue isKindOfClass:[NSNull class]]) {
                foundAllowedType = YES;
                break;
            }
        } else if ([type isEqualToString:@"any"]) {
            foundAllowedType = YES;
        }
    }

    if (!foundAllowedType) {
        if (*error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Expected %@ but found %@.", [allowedTypes componentsJoinedByString:@" or "], NSStringFromClass([aValue class])];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorInvalidType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Object 
- (BOOL)checkObject:(NSDictionary *)aValue containsConformingProperties:(NSDictionary *)properties error:(NSError **)error {
    if (!properties) {
        return YES;
    }
    // NSArray *propertiesInValue = [aValue allKeys];
    NSArray *propertiesInSchema = [properties allKeys];
    for (NSString *propertyInSchema in propertiesInSchema) {
        id valueForProperty = [aValue objectForKey:propertyInSchema];
        if (valueForProperty) {
            if (![self validateJSONValue:valueForProperty withSchema:[properties objectForKey:propertyInSchema] error:error]) {
                return NO;
            }
        } else {
            // Required?
            BOOL required = [[[properties objectForKey:propertyInSchema] objectForKey:@"required"] boolValue];
            if (required) {
                if (*error != NULL) {
                    NSString *errorString = [NSString stringWithFormat:@"Required property '%@' not found.", propertyInSchema];
                    *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorMissingProperty userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
                }
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - String 

@end
