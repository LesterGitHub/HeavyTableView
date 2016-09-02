//
//  LoadingView.m
//  HeavyTableView
//
//  Created by leizi on 15/10/15.
//  Copyright © 2015年 leizi. All rights reserved.
//

#import "LoadingView.h"

#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kDegreeToRadian(x) (M_PI/180.0 * (x))


@interface LoadingView()

@property (nonatomic,assign) CGFloat centerX,centerY,radius,startAngle;

@end

@implementation LoadingView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor=rgba(120, 120, 120, .1f).CGColor;
        self.layer.borderWidth=1.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawProgressArc:context rect:rect];
    
    if(!self.refreshing)return;
      [self drawWhiteCircle:context rect:rect];
}

//  绘制一个进度
- (void)drawProgressArc:(CGContextRef)context rect:(CGRect)rect{
    
    //  新建路径
    CGMutablePathRef progressArcPath = CGPathCreateMutable();
    
    CGFloat endAngle = kDegreeToRadian(_progress * 359.99f) + kDegreeToRadian(-90);
    
    //  添加一个环形路径
    CGPathAddArc(progressArcPath, NULL, self.centerX, self.centerY, self.radius, self.startAngle, endAngle, NO);
    
    //  设置路径属性
    //  1.设置颜色
    [[UIColor grayColor] setStroke];
    
    //  2.设置线宽
    CGContextSetLineWidth(context, 2.0f);
    
    //  将路径添加到上下文中
    CGContextAddPath(context, progressArcPath);
    
    //  渲染路劲
    CGContextStrokePath(context);
    
    //  释放路径
    CGPathRelease(progressArcPath);
    
}

//  绘制一个白色的圆环
-(void)drawWhiteCircle:(CGContextRef)context rect:(CGRect)rect{
    
    //新建路径
    CGMutablePathRef grayCirclePath=CGPathCreateMutable();
    
    CGFloat startAngle=kDegreeToRadian(-80);
    CGFloat endAngle=kDegreeToRadian(200);
    
    CGPathAddArc(grayCirclePath, NULL,self.centerX, self.centerY, self.radius, startAngle,endAngle,YES);
    
    //将路径添加到上下文
    CGContextAddPath(context, grayCirclePath);
    
    //路径设置
    //1.颜色
    [[UIColor whiteColor] setStroke];
    //2.线宽
    CGContextSetLineWidth(context, 2.0f);
    
    
    //渲染路径
    CGContextStrokePath(context);
    
    //释放路径
    CGPathRelease(grayCirclePath);
}



-(void)setProgress:(CGFloat)progress{
    
    if(_progress==progress)
        return;
    
    //  异常处理
    if(progress<=0)progress = 0;
    if(progress>=1.0f)progress = 1.0f;
    
    //  记录
    _progress = progress;
    
    //  重绘
    [self setNeedsDisplay];
    
}


-(void)setRefreshing:(BOOL)refreshing{
    
    //记录
    _refreshing=refreshing;
    
    //响应是否刷新中这个状态
    if(refreshing){
        [self refreshWithYes];
    }else{
        [self refreshWithNO];
    }
    
    //重绘
    [self setNeedsDisplay];
}

//  正在刷新中
-(void)refreshWithYes{
    
    //强制进度
    self.progress=1.0f;
    
    //在iconImageV添加动画
    [self.layer addAnimation:[CAAnimation rotaAnim] forKey:@"rotaAnim"];
    
}

//  没有在刷新
-(void)refreshWithNO{
    
    //强制进度
    self.progress=.001f;
    
    [self.layer removeAllAnimations];
}

#pragma mark  get方法区
-(CGFloat)centerX{
    
    if(!_centerX){
        _centerX=self.width *.5f;
    }
    
    return _centerX;
}

-(CGFloat)centerY{
    
    if(!_centerY){
        
        _centerY=self.height *.5f;
    }
    
    return _centerY;
}

-(CGFloat)radius{
    
    if(!_radius){
        _radius=MIN(self.centerX, self.centerY);
    }
    
    return _radius;
}

-(CGFloat)startAngle{
    
    if(!_startAngle){
        _startAngle=kDegreeToRadian(270.0f);
    }
    
    return _startAngle;
}


@end
