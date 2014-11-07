//
//  MKParallaxManager.m
//  MKParallaxViewDemo
//
//  Created by Morgan Kennedy on 19/07/13.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Copyright (c) 2013 Morgan Kennedy
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MKParallaxManager.h"
#import "MKGyroManager.h"

@interface MKParallaxManager()
/**
 Generates the current Frame based on the front facing angle and sideways tilt
 as well as the frame size
 */
- (CGRect)generateCurrentFrameUsingFrontAngle:(CGFloat)frontAngle SideTile:(CGFloat)sideTilt ViewFrame:(CGRect)viewFrame;

@end

@implementation MKParallaxManager

#pragma mark -
#pragma mark - Lifecycle Methods
+ (MKParallaxManager *)standardParallaxManager
{
    MKParallaxManager *standardParallaxManager = [[MKParallaxManager alloc] init];
    return standardParallaxManager;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [MKGyroManager sharedGyroManager];
        self.zeroPointV = 30.0f ;
        self.maxV = 700.0f ;
        self.minV = 0.0f ;
        self.zeroPointH = 0.0f ;
        self.maxH = 30.0f ;
        self.minH = -30.0f ;
        self.sizePercentPadding = 0.03f ;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Public Methods
- (CGRect)parallexFrameWithViewFrame:(CGRect)viewFrame
{
    CGFloat roll = [[MKGyroManager sharedGyroManager] roll];
    CGFloat pitch = [[MKGyroManager sharedGyroManager] pitch];
    
    CGFloat frontAngle = self.zeroPointV;
    CGFloat sideTilt = self.zeroPointH;
    
    UIViewController *orientationController = [[UIViewController alloc] init];
    
    if (orientationController.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        frontAngle = roll * -1;
        sideTilt = pitch;
    }
    else if (orientationController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        frontAngle = roll;
        sideTilt = pitch * -1;
    }
    else if (orientationController.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        frontAngle = pitch * -1;
        sideTilt = roll * -1;
    }
    else // Portrait Assumption
    {
        frontAngle = pitch;
        sideTilt = roll;
    }
    
    if (frontAngle < 0)
    {
        frontAngle = frontAngle * -1;
    }
    
    if (frontAngle > self.maxV)
    {
        frontAngle = self.maxV;
    }
    else if (frontAngle < self.minV)
    {
        frontAngle = self.minV;
    }
    
    if (sideTilt > self.maxH)
    {
        sideTilt = self.maxH;
    }
    else if (sideTilt < self.minH)
    {
        sideTilt = self.minH;
    }
    
    return [self generateCurrentFrameUsingFrontAngle:frontAngle SideTile:sideTilt ViewFrame:viewFrame];
}

#pragma mark -
#pragma mark - Private Methods
- (CGRect)generateCurrentFrameUsingFrontAngle:(CGFloat)frontAngle SideTile:(CGFloat)sideTilt ViewFrame:(CGRect)viewFrame
{
    CGFloat widthSingleSidePadding = viewFrame.size.width * self.sizePercentPadding;
    CGFloat heightSingleSidePadding = viewFrame.size.height * self.sizePercentPadding;
    
    CGFloat newWidth = viewFrame.size.width + (widthSingleSidePadding * 2);
    CGFloat newHeight = viewFrame.size.height + (heightSingleSidePadding * 2);
    
    CGFloat newX = 0 - widthSingleSidePadding;
    CGFloat newY = 0;
    
    if (sideTilt > self.zeroPointH)
    {
        CGFloat rightTiltPercent = sideTilt / self.maxH;
        CGFloat shiftFromCenter = rightTiltPercent * widthSingleSidePadding;
        newX = newX - shiftFromCenter;
    }
    else if (sideTilt < self.zeroPointH)
    {
        CGFloat leftTiltPercent = sideTilt / self.minH;
        CGFloat shiftFromCenter = leftTiltPercent * widthSingleSidePadding;
        newX = newX + shiftFromCenter;
    }
    
    if (frontAngle > self.zeroPointV)
    {
        CGFloat topTiltPercent = frontAngle / self.maxH;
        CGFloat shiftFromCenter = topTiltPercent * heightSingleSidePadding;
        newY = newY - shiftFromCenter;
    }
    else if (frontAngle < self.zeroPointV)
    {
        CGFloat bottomTiltPercent = frontAngle / self.minH;
        CGFloat shiftFromCenter = bottomTiltPercent * heightSingleSidePadding;
        newY = newY + shiftFromCenter;
    }
    
    return CGRectMake(newX, newY, newWidth, newHeight);
}

@end
