//
//  Vec3.h
//  Motion Analysis
//
//  Created by Kevin Loken on 11-09-13.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vec3 : NSObject
{
    double x;
    double y;
    double z;
}

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;

-(id)initWithX:(double)x Y:(double)y Z:(double)z;

-(Vec3*)cross:(Vec3*)rhs;
-(double)dot:(Vec3*)rhs;

@end
