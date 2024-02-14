//
//  Header.h
//  
//
//  Created by Sean Erickson on 2/14/24.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchNSException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
