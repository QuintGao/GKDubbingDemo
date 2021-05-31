//
//  GKEffectCollectionViewCell.h
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/4.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDubbingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKEffectCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) GKDubbingEffect   *effect;

@end

NS_ASSUME_NONNULL_END
