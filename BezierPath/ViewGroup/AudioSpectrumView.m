//
//  AudioSpectrumView.m
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//

#import "AudioSpectrumView.h"

float const AudioSpectrumItemWidth = 5.0;//元素宽度
float const AudioSpectrumItemSpace = 1.0;//元素间隔

@interface AudioSpectrumStripView ()

{
    NSTimeInterval _timeInterval;
    NSInteger _timerIndex;
}

@property (nonatomic, strong) CAReplicatorLayer *contentLayer;
@property (nonatomic, strong) CALayer *currentLayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat height_2_1;

@end


@implementation AudioSpectrumStripView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bounces = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        UIView *view = [[UIView alloc] init];
        view.tag = 10;
        view.backgroundColor = [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:0.5];
        [self addSubview:view];
        
        _currentLayer = CALayer.layer;
        _currentLayer.frame = CGRectMake(0, CGRectGetHeight(frame) / 2.0 - 25, 2, 50);
        _currentLayer.backgroundColor = [UIColor colorWithRed:255/255.0 green:59/255.0 blue:61/255.0 alpha:1.0].CGColor;
        [self.layer addSublayer:_currentLayer];
    }
    return self;
}

#pragma mark - public method

/** 重置该音谱
 * @param duration 音乐总时长
 */
- (void)resertSpectrumWithDuration:(CGFloat)duration{
    CGFloat maxNumber = CGRectGetWidth(self.frame) / (AudioSpectrumItemWidth + AudioSpectrumItemSpace);//view 所能容纳的最大数量
    CGFloat interval = duration / maxNumber;
    _timeInterval = MIN(1, interval);
    _timerIndex = 0;
        
    [_contentLayer removeFromSuperlayer];
    _contentLayer = nil;
    [self.layer addSublayer:self.contentLayer];
    maxNumber = duration / _timeInterval;
    _contentLayer.frame = CGRectMake(0, 0, maxNumber * (AudioSpectrumItemWidth + AudioSpectrumItemSpace), self.height_2_1);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(_contentLayer.frame), CGRectGetHeight(self.frame));
    self.contentOffset = CGPointZero;
    
    _currentLayer.position = CGPointMake(0, self.height_2_1);
    _currentLayer.hidden = YES;
    [self viewWithTag:10].frame = CGRectMake(0, self.height_2_1 - 0.5, CGRectGetWidth(_contentLayer.frame), 0.5);
}

- (void)startSpectrum {
    _currentLayer.hidden = NO;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(timerClick) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    [self timerClick];
}

- (void)stopSpectrum {
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - private method

- (void)timerClick{
    CGFloat lineHeight = [self getItemHeight];
    CAShapeLayer *itemLayer = [self itemLayerWithHeight:lineHeight];
    [self.contentLayer addSublayer:itemLayer];
    _currentLayer.position = CGPointMake(CGRectGetMaxX(itemLayer.frame), self.height_2_1);
    if (CGRectGetMaxX(itemLayer.frame) > CGRectGetWidth(self.frame) ) {
        self.contentOffset = CGPointMake(CGRectGetMaxX(itemLayer.frame) - CGRectGetWidth(self.frame), 0);
    }
    _timerIndex ++;
}

/** 获取当前音频的高度
 * @note level:{0,160}
 */
- (CGFloat)getItemHeight{
    CGFloat level = fabs(self.itemLevelBlock());
    level = MIN(160, fabs(level));
    level = MAX(arc4random() % 50 + 30, level);//随机控制最小值
    CGFloat lineHeight = level / 160.0 * self.height_2_1;//线的高度
    CGFloat remainder = (int)lineHeight % (int)(AudioSpectrumItemWidth + AudioSpectrumItemSpace);//求余数
    if (remainder > (AudioSpectrumItemWidth + AudioSpectrumItemSpace) / 2.0) {
        lineHeight = lineHeight + AudioSpectrumItemWidth + AudioSpectrumItemSpace - remainder - AudioSpectrumItemSpace;;
    }else{
        lineHeight = lineHeight - remainder - AudioSpectrumItemSpace;
    }
    return lineHeight;
}

- (CAShapeLayer *)itemLayerWithHeight:(CGFloat)height{
    CAShapeLayer *itemLine = [CAShapeLayer layer];
    itemLine.frame = CGRectMake((AudioSpectrumItemWidth + AudioSpectrumItemSpace) * _timerIndex, self.height_2_1 - height, AudioSpectrumItemWidth, height);
    itemLine.fillColor     = UIColor.clearColor.CGColor;
    itemLine.strokeColor   = [UIColor colorWithRed:90/255.f green:88/255.f blue:81/255.f alpha:0.7].CGColor;
    itemLine.lineWidth     = AudioSpectrumItemWidth;
    UIBezierPath *middlePath = [UIBezierPath bezierPath];
    [middlePath moveToPoint:CGPointMake(2.5, height)];
    [middlePath addLineToPoint:CGPointMake(2.5, 0.0)];
    itemLine.path = middlePath.CGPath;
    itemLine.lineDashPattern = @[@(AudioSpectrumItemWidth), @(AudioSpectrumItemSpace)];
    return itemLine;
}

- (CAReplicatorLayer *)contentLayer{
    if (_contentLayer == nil) {
        _contentLayer = CAReplicatorLayer.layer;
        _contentLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.height_2_1);
        _contentLayer.backgroundColor = UIColor.clearColor.CGColor;
        _contentLayer.instanceCount = 2;
        _contentLayer.instanceTransform = CATransform3DRotate(CATransform3DMakeTranslation(0, self.height_2_1, 0), M_PI, 1, 0, 0);
        _contentLayer.instanceAlphaOffset -= 0.3;
    }
    return _contentLayer;
}

- (CGFloat)height_2_1{
    return CGRectGetHeight(self.frame) / 2.0;
}

@end

















@interface AudioSpectrumWaveView ()

{
    CGFloat _lineWidth;//线宽
    CGFloat _lineSpace;//线间距
}

@property (nonatomic, strong) NSMutableArray *levelArray;
@property (nonatomic, strong) NSMutableArray *itemLineLayers;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation AudioSpectrumWaveView

//frame.width = 3.0f * 7 + 4.0 * 5 = 42
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lineWidth = 2.0f;
        _lineSpace = 3.0f;
        [self updateLineLayers];
    }
    return self;
}

#pragma mark - update

- (void)updateLineLayers{
    UIGraphicsBeginImageContext(self.frame.size);
    CGFloat space = (_lineSpace + _lineWidth) * 1.0;
    CGFloat middlePoint = CGRectGetWidth(self.bounds) / 2.0;
    int middleIndex = (int)self.levelArray.count - 1;
    int leftX = middlePoint - space;
    int rightX = middlePoint + space;
    
    for(int i = 0; i < self.levelArray.count; i++) {
        CGFloat lineHeight = [self.levelArray[i] floatValue] / 160.0 * CGRectGetHeight(self.frame);//线的高度
        CGFloat lineTop = (CGRectGetHeight(self.bounds) - lineHeight) / 2.f;
        CGFloat lineBottom = (CGRectGetHeight(self.bounds) + lineHeight) / 2.f;
        
        if (i == 0) {
            UIBezierPath *middlePath = [UIBezierPath bezierPath];
            [middlePath moveToPoint:CGPointMake(middlePoint, lineTop)];
            [middlePath addLineToPoint:CGPointMake(middlePoint, lineBottom)];
            CAShapeLayer *itemLine2 = [self.itemLineLayers objectAtIndex:middleIndex];
            itemLine2.path = [middlePath CGPath];
        }else{
            UIBezierPath *linePathLeft = [UIBezierPath bezierPath];
            [linePathLeft moveToPoint:CGPointMake(leftX, lineTop)];
            [linePathLeft addLineToPoint:CGPointMake(leftX, lineBottom)];
            CAShapeLayer *itemLine2 = [self.itemLineLayers objectAtIndex:middleIndex + i];
            itemLine2.path = [linePathLeft CGPath];
            leftX -= space;
            
            UIBezierPath *linePathRight = [UIBezierPath bezierPath];
            [linePathRight moveToPoint:CGPointMake(rightX, lineTop)];
            [linePathRight addLineToPoint:CGPointMake(rightX, lineBottom)];
            CAShapeLayer *itemLine = [self.itemLineLayers objectAtIndex:middleIndex - i];
            itemLine.path = [linePathRight CGPath];
            rightX += space;
        }
    }
    UIGraphicsEndImageContext();
}

- (void)startSpectrum {
    [self displayLink];
}

- (void)stopSpectrum {
    [_displayLink invalidate];
    _displayLink = nil;
}

#pragma mark - setter and getters

- (void)setLevel:(CGFloat)level {
    level = MIN(160, fabs(level));
    level = MAX(arc4random() % 30 + 50, level);//设置个最小值
    [self.levelArray removeLastObject];
    [self.levelArray insertObject:@(level) atIndex:0];
    [self updateLineLayers];
}

- (NSMutableArray *)levelArray{
    if (_levelArray == nil) {
        _levelArray = [[NSMutableArray alloc]initWithObjects:@(60),@(120),@(90),@(160), nil];
    }
    return _levelArray;
}

- (NSMutableArray *)itemLineLayers{
    if (_itemLineLayers == nil) {
        NSMutableArray *array = [NSMutableArray array];
        for(int i = 0; i < self.levelArray.count * 2.0 - 1; i++) {
            CAShapeLayer *itemLine = [CAShapeLayer layer];
            itemLine.lineCap       = kCALineCapButt;
            itemLine.lineJoin      = kCALineJoinRound;
            itemLine.strokeColor   = UIColor.clearColor.CGColor;
            itemLine.fillColor     = UIColor.clearColor.CGColor;
//            itemLine.strokeColor   = [UIColor colorWithRed:233/255.f green:139/255.f blue:163/255.f alpha:1.0].CGColor;
            itemLine.strokeColor   = UIColor.blueColor.CGColor;
            itemLine.lineWidth     = _lineWidth;
            [self.layer addSublayer:itemLine];
            [array addObject:itemLine];
        }
        _itemLineLayers = array;
    }
    return _itemLineLayers;
}

- (CADisplayLink *)displayLink{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:_itemLevelCallback selector:@selector(invoke)];
        _displayLink.frameInterval = 6.f;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

@end
