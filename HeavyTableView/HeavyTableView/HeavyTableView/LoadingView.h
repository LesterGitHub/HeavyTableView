//
//  LoadingView.h
//  HeavyTableView
//
//  Created by leizi on 15/10/15.
//  Copyright © 2015年 leizi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "CAAnimation+CoreRefresh.h"

@interface LoadingView : UIView

 // 进度
@property (nonatomic,assign) CGFloat progress;
 // 是否刷新中
@property (nonatomic,assign,getter=isRefreshing) BOOL refreshing;

@end
