//
//  TGThresholdImageUnitFilter.m
//  TGThresholdImageUnit
//
//  Copyright (c) 2011 Toby Griffin

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "TGThresholdImageUnitFilter.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation TGThresholdImageUnitFilter

static CIKernel *_TGThresholdImageUnitFilterKernel = nil;

- (id)init {
    if(!_TGThresholdImageUnitFilterKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"TGThresholdImageUnitFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"TGThresholdImageUnitFilterKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
		_TGThresholdImageUnitFilterKernel = kernels[0];
    }
    return [super init];
}

- (CGRect)regionOf:(int)sampler  destRect:(CGRect)rect  userInfo:(NSNumber *)radius {
    return CGRectInset(rect, -[radius floatValue], 0);
}

- (NSDictionary *)customAttributes {
    NSNumber *min = [NSNumber numberWithDouble:0.0];
    NSNumber *max = [NSNumber numberWithDouble:1.0];
    return @{
         @"threshold": @{
             kCIAttributeMin: min,
             kCIAttributeMax: max,
             kCIAttributeSliderMin: min,
             kCIAttributeSliderMax: max,
             kCIAttributeDefault: [NSNumber numberWithDouble:0.8],
             kCIAttributeIdentity: min,
             kCIAttributeType: kCIAttributeTypeDistance
             }
         };
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage {
	CISampler *src = [CISampler samplerWithImage: inputImage];
	return [self apply: _TGThresholdImageUnitFilterKernel, src, inputThreshold,
        kCIApplyOptionDefinition, [src definition], nil];
}

@end
