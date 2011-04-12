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
- (BOOL)checkObject:(NSDictionary *)value containsConformingPatternProperties:(NSDictionary *)patternProperties error:(NSError **)error;
- (BOOL)checkObject:(NSDictionary *)value containsConformingAdditionalProperties:(id)booleanOrSchema error:(NSError **)error;

#pragma mark - Array 
- (BOOL)checkArray:(NSArray *)value containsConformingItems:(id)schemaOrSchemas error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value containsConformingAdditionalItems:(id)booleanOrSchemaOrSchemas error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasMinItems:(int)minItems error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasMaxItems:(int)maxItems error:(NSError **)error;
- (BOOL)checkArray:(NSArray *)value hasUniqueItems:(BOOL)uniqueItems error:(NSError **)error;

#pragma mark - String
- (BOOL)checkString:(NSString *)value matchesPattern:(NSString *)pattern error:(NSError **)error;
- (BOOL)checkString:(NSString *)value hasMinLength:(int)minLength error:(NSError **)error;
- (BOOL)checkString:(NSString *)value hasMaxLength:(int)maxLength error:(NSError **)error;
- (BOOL)checkString:(NSString *)value isInEnum:(NSArray *)enumeration error:(NSError **)error;
- (BOOL)checkString:(NSString *)value conformsToFormat:(NSString *)format error:(NSError **)error;

#pragma mark - Number
- (BOOL)checkNumber:(NSNumber *)value hasMinimum:(NSNumber *)minimum exclusive:(BOOL)exclusive error:(NSError **)error;
- (BOOL)checkNumber:(NSNumber *)value hasMaximum:(NSNumber *)maximum exclusive:(BOOL)exclusive error:(NSError **)error;
- (BOOL)checkNumber:(NSNumber *)value conformsToFormat:(NSString *)format error:(NSError **)error;
- (BOOL)checkNumber:(NSNumber *)value isDivisibleBy:(NSNumber *)divider error:(NSError **)error;

@end

@implementation KVJSONValidator

#pragma mark - General 
- (BOOL)validateJSONSchema:(NSDictionary *)schema error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)validateJSONValue:(id)value withSchema:(NSDictionary *)schema error:(NSError **)error {
    // Check if schema is valid?!
    NSParameterAssert(value != nil);
    NSParameterAssert(schema != nil); // Actually, empty schema means always valid, but this is handier for debugging for now

    // Check value type
    id type = [schema objectForKey:@"type"];
    if (type && ![self checkValue:value isInstanceOfType:type error:error]) {
        return NO;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        // Object checks
        NSDictionary *properties = [schema objectForKey:@"properties"];
        if (properties && ![self checkObject:value containsConformingProperties:properties error:error]) {
            return NO;
        }
    
        NSDictionary *patternProperties = [schema objectForKey:@"patternProperties"];
        if (patternProperties && ![self checkObject:value containsConformingPatternProperties:patternProperties error:error]) {
            return NO;
        }
        
        NSDictionary *additionalProperties = [schema objectForKey:@"additionalProperties"];
        if (additionalProperties && ![self checkObject:value containsConformingAdditionalProperties:additionalProperties error:error]) {
            return NO;
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        // Array checks
        NSDictionary *items = [schema objectForKey:@"items"];
        if (items && ![self checkArray:value containsConformingItems:items error:error]) {
            return NO;
        }
        
        NSDictionary *additionalItems = [schema objectForKey:@"additionalItems"];
        if (additionalItems && ![self checkArray:value containsConformingAdditionalItems:additionalItems error:error]) {
            return NO;
        }
        
        NSNumber *minItems = [schema objectForKey:@"minItems"];
        if (minItems && ![self checkArray:value hasMinItems:[minItems intValue] error:error]) {
            return NO;
        }
        
        NSNumber *maxItems = [schema objectForKey:@"maxItems"];
        if (maxItems && ![self checkArray:value hasMaxItems:[maxItems intValue] error:error]) {
            return NO;
        }
        
        NSNumber *uniqueItems = [schema objectForKey:@"uniqueItems"];
        if (uniqueItems && ![self checkArray:value hasUniqueItems:[uniqueItems boolValue] error:error]) {
            return NO;
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        // String checks
        NSString *pattern = [schema objectForKey:@"pattern"];
        if (pattern && ![self checkString:value matchesPattern:pattern error:error]) {
            return NO;
        }
        
        NSNumber *minLength = [schema objectForKey:@"minLength"];
        if (minLength && ![self checkString:value hasMinLength:[minLength intValue] error:error]) {
            return NO;
        }
        
        NSNumber *maxLength = [schema objectForKey:@"maxLength"];
        if (maxLength && ![self checkString:value hasMaxLength:[maxLength intValue] error:error]) {
            return NO;
        }
        
        NSArray *enumeration = [schema objectForKey:@"enum"];
        if (enumeration && ![self checkString:value isInEnum:enumeration error:error]) {
            return NO;
        }
        
        NSString *format = [schema objectForKey:@"format"];
        if (format && ![self checkString:value conformsToFormat:format error:error]) {
            return NO;
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // Number checks
        NSNumber *minimum = [schema objectForKey:@"minimum"];
        NSNumber *exclusiveMinimum = [schema objectForKey:@"exclusiveMinimum"];
        if (minimum && ![self checkNumber:value hasMinimum:minimum exclusive:exclusiveMinimum ? [exclusiveMinimum boolValue] : NO error:error]) {
            return NO;
        }
        
        NSNumber *maximum = [schema objectForKey:@"maximum"];
        NSNumber *exclusiveMaximum = [schema objectForKey:@"exclusiveMaximum"];
        if (maximum && ![self checkNumber:value hasMaximum:maximum exclusive:exclusiveMaximum ? [exclusiveMaximum boolValue] : NO error:error]) {
            return NO;
        }
        
        NSString *format = [schema objectForKey:@"format"];
        if (format && ![self checkNumber:value conformsToFormat:format error:error]) {
            return NO;
        }
        
        NSNumber *divisibleBy = [schema objectForKey:@"divisibleBy"];
        if (divisibleBy && ![self checkNumber:value isDivisibleBy:divisibleBy error:error]) {
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
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Expected %@ but found %@.", [allowedTypes componentsJoinedByString:@" or "], NSStringFromClass([aValue class])];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorInvalidType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Object 
- (BOOL)checkObject:(NSDictionary *)aValue containsConformingProperties:(NSDictionary *)properties error:(NSError **)error {
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
                if (error != NULL) {
                    NSString *errorString = [NSString stringWithFormat:@"Required property '%@' not found.", propertyInSchema];
                    *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorMissingProperty userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
                }
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)checkObject:(NSDictionary *)value containsConformingPatternProperties:(NSDictionary *)patternProperties error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkObject:(NSDictionary *)value containsConformingAdditionalProperties:(id)booleanOrSchema error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

#pragma mark - Array 
- (BOOL)checkArray:(NSArray *)value containsConformingItems:(id)schemaOrSchemas error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkArray:(NSArray *)value containsConformingAdditionalItems:(id)booleanOrSchemaOrSchemas error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkArray:(NSArray *)value hasMinItems:(int)minItems error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkArray:(NSArray *)value hasMaxItems:(int)maxItems error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkArray:(NSArray *)value hasUniqueItems:(BOOL)uniqueItems error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}


#pragma mark - String
- (BOOL)checkString:(NSString *)value matchesPattern:(NSString *)pattern error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkString:(NSString *)value hasMinLength:(int)minLength error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkString:(NSString *)value hasMaxLength:(int)maxLength error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkString:(NSString *)value isInEnum:(NSArray *)enumeration error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkString:(NSString *)value conformsToFormat:(NSString *)format error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}


#pragma mark - Number
- (BOOL)checkNumber:(NSNumber *)value hasMinimum:(NSNumber *)minimum exclusive:(BOOL)exclusive error:(NSError **)error {
    BOOL result;
    if (exclusive) {
        result = ([value compare:minimum] == NSOrderedDescending);
    } else {
        result = (([value compare:minimum] == NSOrderedDescending) || ([value compare:minimum] == NSOrderedSame));
    }
    
    if (!result) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ smaller than %@", value, minimum];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooSmallNumber userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }

    return YES;
}

- (BOOL)checkNumber:(NSNumber *)value hasMaximum:(NSNumber *)maximum exclusive:(BOOL)exclusive error:(NSError **)error {
    BOOL result;
    if (exclusive) {
        result = ([value compare:maximum] == NSOrderedAscending);
    } else {
        result = (([value compare:maximum] == NSOrderedAscending) || ([value compare:maximum] == NSOrderedSame));
    }
    
    if (!result) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ bigger than %@", value, maximum];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooBigNumber userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkNumber:(NSNumber *)value conformsToFormat:(NSString *)format error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkNumber:(NSNumber *)value isDivisibleBy:(NSNumber *)divider error:(NSError **)error {
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}


@end
