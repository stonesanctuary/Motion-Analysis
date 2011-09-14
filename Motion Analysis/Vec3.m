//
//  Vec3.m
//  Motion Analysis
//
//  Created by Kevin Loken on 11-09-13.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "Vec3.h"

@implementation Vec3

@synthesize x,y,z;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        x = 0;
        y = 0;
        z = 0;
    }
    
    return self;
}

-(id)initWithX:(double)x_ Y:(double)y_ Z:(double)z_    
{
    self = [super init];
    if ( self != nil ) {
        self.x = x_;
        self.y = y_;
        self.z = z_;
    }
    return self;
}

-(double)dot:(Vec3*)rhs
{
    return x * rhs.x + y * rhs.y + z * rhs.z;
}

-(Vec3*)cross:(Vec3 *)rhs
{
    Vec3* c = [[[Vec3 alloc] init] autorelease];
    c.x = y * rhs.z - z * rhs.y;
    c.y = z * rhs.x - x * rhs.z;
    c.z = x * rhs.y - y * rhs.x;
    
    return c;
}

@end
