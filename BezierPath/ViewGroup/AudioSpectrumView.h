//
//  AudioSpectrumView.h
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//
// 音谱

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 条形
 */
@interface AudioSpectrumStripView : UIScrollView

/** 获取此刻的音量
 */
@property (nonatomic ,copy) CGFloat (^itemLevelBlock)(void);

/** 重置该音谱
 * @param duration 音乐总时长
 */
- (void)resertSpectrumWithDuration:(CGFloat)duration;
- (void)startSpectrum;
- (void)stopSpectrum;

@end



///波形
@interface AudioSpectrumWaveView : UIScrollView

@property (nonatomic ,copy) void (^itemLevelCallback)(void);
@property (nonatomic ,assign) CGFloat level;

- (void)startSpectrum;
- (void)stopSpectrum;
@end


NS_ASSUME_NONNULL_END
