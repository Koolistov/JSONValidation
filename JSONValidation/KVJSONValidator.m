//
//  KVJSONValidator.m
//  JSONValidation
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

#import "KVJSONValidator.h"

NSString *const KVJSONValidatorDomain = @"KVJSONValidatorDomain";

@interface KVJSONValidator ()

#pragma mark - General 
- (BOOL)checkValue:(id)value isInstanceOfType:(id)typeOrTypes error:(NSError **)error;

#pragma mark - Object 
- (BOOL)checkObject:(NSDictionary *)value containsConformingProperties:(NSDictionary *)properties patternProperties:(NSDictionary *)patternProperties additionalProperties:(id)additionalProperties error:(NSError **)error;

#pragma mark - Array 
- (BOOL)checkArray:(NSArray *)value containsConformingItems:(id)items additionalItems:(id)additionalItems error:(NSError **)error;
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
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)validateJSONValue:(id)value withSchema:(NSDictionary *)schema error:(NSError **)error {
    // Check if schema is valid?!
    NSParameterAssert(value != nil);
#warning Wrong assert
    NSParameterAssert(schema != nil); // Actually, empty schema means always valid, but this is handier for debugging for now

    // Check value type
    id type = [schema objectForKey:@"type"];
    if (type && ![self checkValue:value isInstanceOfType:type error:error]) {
        return NO;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        // Object checks
        NSDictionary *properties = [schema objectForKey:@"properties"];
        NSDictionary *patternProperties = [schema objectForKey:@"patternProperties"];
        NSDictionary *additionalProperties = [schema objectForKey:@"additionalProperties"];
        if ((properties || patternProperties || additionalProperties) && ![self checkObject:value containsConformingProperties:properties patternProperties:patternProperties additionalProperties:additionalProperties error:error]) {
            return NO;
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        // Array checks
        NSDictionary *items = [schema objectForKey:@"items"];
        NSDictionary *additionalItems = [schema objectForKey:@"additionalItems"];
        if ((items || additionalItems) && ![self checkArray:value containsConformingItems:items additionalItems:additionalItems error:error]) {
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
- (BOOL)checkObject:(NSDictionary *)aValue containsConformingProperties:(NSDictionary *)properties patternProperties:(NSDictionary *)patternProperties additionalProperties:(id)additionalProperties error:(NSError **)error {
#warning Method not yet fully implemented
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

#pragma mark - Array 
- (BOOL)checkArray:(NSArray *)value containsConformingItems:(id)items additionalItems:(id)additionalItems error:(NSError **)error {
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkArray:(NSArray *)value hasMinItems:(int)minItems error:(NSError **)error {
    if ([value count] < minItems) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ contains less than %d items.", value, minItems];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooFewItems userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkArray:(NSArray *)value hasMaxItems:(int)maxItems error:(NSError **)error {
    if ([value count] > maxItems) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ contains more than %d items.", value, maxItems];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooManyItems userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkArray:(NSArray *)value hasUniqueItems:(BOOL)uniqueItems error:(NSError **)error {
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}


#pragma mark - String
- (BOOL)checkString:(NSString *)value matchesPattern:(NSString *)pattern error:(NSError **)error {
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkString:(NSString *)value hasMinLength:(int)minLength error:(NSError **)error {
    if ([value length] < minLength) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ is shorter than %d characters.", value, minLength];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooShortString userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkString:(NSString *)value hasMaxLength:(int)maxLength error:(NSError **)error {
    if ([value length] > maxLength) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ is longer than %d characters.", value, maxLength];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorTooLongString userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkString:(NSString *)value isInEnum:(NSArray *)enumeration error:(NSError **)error {
    NSUInteger valueIndex = [enumeration indexOfObject:value];
    if (valueIndex == NSNotFound) {
        if (error != NULL) {
            NSString *errorString = [NSString stringWithFormat:@"Value %@ is not equal to %@.", value, [enumeration componentsJoinedByString:@" or "]];
            *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorNotEnumeratedString userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkString:(NSString *)value conformsToFormat:(NSString *)format error:(NSError **)error {
#warning Method not yet implemented
    NSLog(@"String '%@' may or may not conform to format '%@'", value, format);
    return YES;
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
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}

- (BOOL)checkNumber:(NSNumber *)value isDivisibleBy:(NSNumber *)divider error:(NSError **)error {
#warning Method not yet implemented
    if (error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"Method %s not yet implemented.", __PRETTY_FUNCTION__];
        *error = [NSError errorWithDomain:KVJSONValidatorDomain code:KVJSONValidatorErrorGeneral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil]];
    }
    return NO;
}


@end
