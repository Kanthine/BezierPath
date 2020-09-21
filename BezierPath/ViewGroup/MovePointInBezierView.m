//
//  MovePointInBezierView.m
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//

#import "MovePointInBezierView.h"

/** 获取三阶贝塞尔曲线方程上的某一点
 *
 * float t 指定的x坐标比例，取值范围是 0 ~ 1 之间
 * CGPoint startPoint 起始点
 * CGPoint controlPoint1 控制点1
 * CGPoint controlPoint2 控制点2
 * CGPoint endPoint 结束点
 * 返回值：返回指定x坐标的贝塞尔曲线上的某一点
 */
CGPoint getCubicBezierPathThePoint(const float t,const CGPoint startPoint,const CGPoint controlPoint1,const CGPoint controlPoint2,const CGPoint endPoint){
    CGPoint point = CGPointZero;
    float temp = 1 - t;
    point.x = startPoint.x * temp * temp * temp + 3 * controlPoint1.x * t * temp * temp + 3 * controlPoint2.x * t * t * temp + endPoint.x * t * t * t;
    point.y = startPoint.y * temp * temp * temp + 3 * controlPoint1.y * t * temp * temp + 3 * controlPoint2.y * t * t * temp + endPoint.y * t * t * t;
    return point;
}


/** 二分法求取 t 值
 *
 * float x 指定的x坐标
 * CGPoint startPoint 起始点
 * CGPoint controlPoint1 控制点1
 * CGPoint controlPoint2 控制点2
 * CGPoint endPoint 结束点
 * 返回值：返回指定x坐标的贝塞尔曲线方程的 t 值
 */
CGFloat get_t_value_By_binarySort(const float x,const CGPoint startPoint,const CGPoint controlPoint1,const CGPoint controlPoint2,const CGPoint endPoint){
    float a = 0.0 , b = 1.0;
    float xa = getCubicBezierPathThePoint(a, startPoint, controlPoint1, controlPoint2, endPoint).x;
    float xb = getCubicBezierPathThePoint(b, startPoint, controlPoint1, controlPoint2, endPoint).x;
    float xt = getCubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x;
    //x 的取值误差范围在 0.1
    while (fabsf(x - xt) > 0.1) {
        if (x < xt && x > xa){
            b = (b + a) / 2.0;
            xb = xt;
            xt = getCubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x;
        } else if (x > xt && x < xb) {
            a = (b + a) / 2.0;
            xa = xt;
            xt = getCubicBezierPathThePoint((b + a) / 2.0, startPoint, controlPoint1, controlPoint2, endPoint).x;
        } else {
            break;
        }
    }
    return (b + a) / 2.0;
}


@implementation MovePointInBezierView

- (instancetype)init{
    return [self initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), CGRectGetWidth(UIScreen.mainScreen.bounds) * 57 / 75.0 )];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        _xProgress = 0.6;
        self.backgroundColor = [UIColor colorWithRed:104/255.0 green:129/255.0 blue:239/255.0 alpha:0.76];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGPoint startPoint = CGPointMake(0, 470 / 570.0 * CGRectGetHeight(rect));
    CGPoint controlPoint1 = CGPointMake(300 / 750.0 * CGRectGetWidth(rect),200 / 570.0 * CGRectGetHeight(rect));
    CGPoint controlPoint2 = CGPointMake(500 / 750.0 * CGRectGetWidth(rect), 600 / 570.0 * CGRectGetHeight(rect));
    CGPoint endPoint = CGPointMake(CGRectGetWidth(rect), 190 / 570.0 * CGRectGetHeight(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    /****** 贝塞尔曲线及填充渐变色 ****/
    CGFloat locations[] = {0.0, 1.0};
    NSArray *colors = @[(__bridge id) [UIColor colorWithRed:70/255.0 green:95/255.0 blue:251/255.0 alpha:0.1].CGColor, (__bridge id) [UIColor colorWithRed:70/255.0 green:95/255.0 blue:251/255.0 alpha:1].CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -3, CGRectGetHeight(rect));
    CGPathAddLineToPoint(path, NULL, -3, startPoint.y);
    CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x + 3, endPoint.y);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(rect) + 3, CGRectGetHeight(rect));
    CGPathCloseSubpath(path);
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor.CGColor);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect)), CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMaxY(pathRect)), 0);
    CGColorSpaceRelease(colorSpace);
    CGPathRelease(path);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextStrokePath(context);
    
    
    if (_xProgress > 0 && _xProgress < 1){
        CGFloat t = get_t_value_By_binarySort(_xProgress * CGRectGetWidth(rect), startPoint, controlPoint1, controlPoint2, endPoint);
        CGPoint point = getCubicBezierPathThePoint(t, startPoint, controlPoint1, controlPoint2, endPoint);
        
        /****** 当前所在位置点 ****/
        UIImage *pointImage = [UIImage imageNamed:@"Image1"];
        CGRect pointImageFrame = CGRectMake(point.x - pointImage.size.width / 2.0, point.y - pointImage.size.height/2.0, pointImage.size.width, pointImage.size.height);
        [pointImage drawInRect:pointImageFrame];
        CGContextSetLineWidth(context,1.0f);
        CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.26].CGColor);
        CGFloat lengths[] = {4,2};
        CGContextSetLineDash(context,0, lengths,2);
        CGContextMoveToPoint(context,point.x,point.y);
        CGContextAddLineToPoint(context,point.x,CGRectGetHeight(rect));
        CGContextStrokePath(context);
        
        /****** 当前所在位置文字显示 ****/
        UIImage *textImage = [UIImage imageNamed:@"Image"];
        CGRect imageFrame = CGRectMake(point.x - textImage.size.width / 2.0, point.y - textImage.size.height - 6, textImage.size.width, textImage.size.height);
        [textImage drawInRect:imageFrame];
        NSString *progress = [NSString stringWithFormat:@"%.0f",_xProgress * 100];
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithRed:64/255.0 green:88/255.0 blue:237/255.0 alpha:1]};
        CGSize textSize = [progress boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        [progress drawAtPoint:CGPointMake(point.x - textSize.width / 2.0, imageFrame.origin.y + 8) withAttributes:attributes];
    }

    /*************** X 坐标刻度 ******************/
    NSArray<NSString *> *array = @[@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90"];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        CGPoint textPoint = CGPointMake((idx + 1) * (CGRectGetWidth(rect) / (array.count + 1)), CGRectGetHeight(rect) - 20);
        [obj drawAtPoint:CGPointMake(textPoint.x - 4, textPoint.y) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8],NSForegroundColorAttributeName:[UIColor.whiteColor colorWithAlphaComponent:0.43]}];

        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, [UIColor.whiteColor colorWithAlphaComponent:0.5].CGColor);
        CGContextMoveToPoint(context, textPoint.x, CGRectGetHeight(rect) - 4);
        CGContextAddLineToPoint(context, textPoint.x,CGRectGetHeight(rect));
        CGContextStrokePath(context);
    }];
}

///拖动曲线上的点
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;//获取触摸对象
    CGPoint point = [touch locationInView:self];
    self.xProgress = point.x / CGRectGetWidth(self.bounds);
}

- (void)setXProgress:(float)xProgress{
    _xProgress = xProgress;
    if (_xProgress > 0 && _xProgress < 1){
        [self setNeedsDisplay];
    }
}

@end

