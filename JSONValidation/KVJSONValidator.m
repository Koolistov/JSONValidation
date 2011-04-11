//
//  KVJSONValidator.m
//  JSONValidation
//
//  Created by Johan Kool on 10-04-2011.
//  Copyright 2011 Koolistov. All rights reserved.
//

#import "KVJSONValidator.h"

NSString * const KVJSONValidatorDomain = @"KVJSONValidatorDomain";

@interface KVJSONValidator ()

- (BOOL)checkValue:(id)aValue isInstanceOfType:(id)type error:(NSError **)error;
- (BOOL)checkValue:(NSDictionary *)aValue containsConformingProperties:(NSDictionary *)properties error:(NSError **)error;

@end

@implementation KVJSONValidator

- (BOOL)validateJSONValue:(id)aJSONValue withSchema:(NSDictionary *)aJSONSchema error:(NSError **)error {
    // Check if schema is valid?!
    
    // Check value type
    id type = [aJSONSchema objectForKey:@"type"];
    if (![self checkValue:aJSONValue isInstanceOfType:type error:error]) {
        return NO;
    }
    
    // Check properties
    if ([aJSONValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *properties = [aJSONValue objectForKey:@"properties"];
        if (![self checkValue:aJSONValue containsConformingProperties:properties error:error]) {
            return NO;
        }
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

- (BOOL)checkValue:(NSDictionary *)aValue containsConformingProperties:(NSDictionary *)properties error:(NSError **)error {
    if (!properties) {
        return YES;
    }
    
    // NSArray *propertiesInValue = [aValue allKeys];
    NSArray *propertiesInSchema = [aValue allKeys];
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

@end
