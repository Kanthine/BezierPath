//
//  MovePointInBezierView.h
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//
// 使某个点在贝塞尔曲线上移动
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovePointInBezierView : UIView

/** X 坐标轴的取值进度
 * 取值范围是 0 < xProgress < 1.0
 */
@property (nonatomic ,assign) float xProgress;

@end

NS_ASSUME_NONNULL_END
