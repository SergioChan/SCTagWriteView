//
//  NSString+Helper.m
//  tataUFO
//
//  Created by Can on 9/19/14.
//  Copyright (c) 2014 tataUFO.com. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)trimWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
