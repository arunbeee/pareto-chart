//
//  NSString+Rotated.m
//  ParetoChart
//
//  Created by Arun Balakrishnan on 05/02/14.
//  Copyright (c) 2014 Arun Balakrishnan. All rights reserved.
//

#import "NSString+Rotated.h"

@implementation NSString (Rotated)

-(void)  drawWithBasePoint:(CGPoint)basePoint
                  andAngle:(CGFloat)angle
                   andFont:(UIFont *)font{
    CGSize  textSize    =   [self   sizeWithFont:font];
    
    CGContextRef    context =   UIGraphicsGetCurrentContext();
    CGAffineTransform   t   =   CGAffineTransformMakeTranslation(basePoint.x, basePoint.y);
    CGAffineTransform   r   =   CGAffineTransformMakeRotation(angle);
    
    
    CGContextConcatCTM(context, t);
    CGContextConcatCTM(context, r);
    
    [self   drawAtPoint:CGPointMake(-1 * textSize.width / 2, -1 * textSize.height / 2)
               withFont:font];
    
    CGContextConcatCTM(context, CGAffineTransformInvert(r));
    CGContextConcatCTM(context, CGAffineTransformInvert(t));
}


@end
