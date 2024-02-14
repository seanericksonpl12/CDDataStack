//
//  ObjC.m
//  
//
//  Created by Sean Erickson on 2/14/24.
//

#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchNSException:(void (^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    } @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
        return NO;
    }
}

@end
