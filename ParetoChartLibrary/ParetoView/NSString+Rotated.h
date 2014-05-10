//
//  NSString+Rotated.h
//  ParetoChart
//
//  Created by Arun Balakrishnan on 05/02/14.
//  Copyright (c) 2014 Arun Balakrishnan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Rotated)

-(void)  drawWithBasePoint:(CGPoint)basePoint
                  andAngle:(CGFloat)angle
                   andFont:(UIFont*)font;
@end
