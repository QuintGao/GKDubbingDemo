//
//  GKDubbingManager.m
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDubbingManager.h"

@implementation GKDubbingManager

+(void)createDubbingPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:kDubbingPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kDubbingPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

@implementation GKDubbingEffect
@end
