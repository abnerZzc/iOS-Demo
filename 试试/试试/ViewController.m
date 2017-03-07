//
//  ViewController.m
//  试试
//
//  Created by user on 2017/3/2.
//  Copyright © 2017年 user. All rights reserved.
//

#import "ViewController.h"
#define SCREENVIEWWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENVIEWHEIGHT [UIScreen mainScreen].bounds.size.height
typedef enum
{
    fullScreen,
    minScreen,
}VideoState;
typedef enum
{
    left,
    right,
    other,
}Direction;
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *bottom;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (assign, nonatomic)VideoState state;
@property (assign, nonatomic)Direction direction;
@property (strong,nonatomic)UITapGestureRecognizer *tap;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // 手势添加
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panClick:)];
    [_bottom addGestureRecognizer:pan];
    
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
    
    _state = fullScreen;
}
#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.text = [NSString stringWithFormat:@"第%ld个cell",(long)indexPath.row];
    }
    
    return cell;
}

#pragma mark - 拖动手势
- (void)panClick:(UIPanGestureRecognizer *) recognizer  {

    //拖动的距离
    CGPoint translation = [recognizer translationInView:_bottom];
    
    //最小的宽度
    CGFloat minWidth = SCREENVIEWWIDTH * 3 / 7.0;
    
    //初始化高度
    CGFloat originalHeight = 200;
    
    //比例大小
    CGFloat scale1;
    
    //最小宽度的x位置
     NSInteger x = SCREENVIEWWIDTH-minWidth;
    
    switch (_state) {
        case fullScreen:
            scale1 = (1 - translation.y/(SCREENVIEWHEIGHT-20));
            _direction = other;
            break;
        case minScreen:
            scale1 = (0.3- translation.y/(SCREENVIEWHEIGHT-20));
            //最小屏状态下 判断左右方向
            if(abs((int)(translation.x))<abs((int)(translation.y)))
                _direction = other;
            else
            {
                if((x + translation.x)/x>1)
                    _direction = left;
                else
                    _direction = right;
            }
            break;
    }
    
   if(recognizer.state == UIGestureRecognizerStateChanged ||recognizer.state == UIGestureRecognizerStateBegan ){
   
        //是否在满屏和最小状态范围内
        if(scale1*_bottom.frame.size.width>=minWidth&&scale1*_bottom.frame.size.width<=SCREENVIEWWIDTH&& _direction == other)
        {
            [_bottom removeGestureRecognizer:_tap];
           self.view.alpha = 1;
            _tableview.alpha = 1- (minWidth)/_videoView.frame.size.width;
            _videoView.transform = CGAffineTransformMakeScale(scale1, scale1);
            _videoView.frame = CGRectMake(0, originalHeight-_videoView.frame.size.height, _videoView.frame.size.width, _videoView.frame.size.height);
            CGFloat y =_tableview.frame.size.height/(originalHeight-minWidth/SCREENVIEWWIDTH*originalHeight)*(originalHeight-_videoView.frame.size.height);
            
            _bottom.frame = CGRectMake(SCREENVIEWWIDTH-_videoView.frame.size.width,y,_bottom.frame.size.width,_bottom.frame.size.height);
        }
       //左滑右滑
       if(_state == minScreen&&_direction != other)
       {
         
           CGRect rect = _bottom.frame;
           rect.origin.x = x + translation.x;
           
           _bottom.alpha = (x + translation.x)/x>1?1-(x + translation.x)/SCREENVIEWWIDTH:(x + translation.x)/x;
           _bottom.frame = rect;
       }
    }
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        //最终位置偏向全屏，则全屏状态；偏向最小化，则最小化状态
        if(_videoView.frame.size.width<(minWidth+SCREENVIEWWIDTH)/2.0)
        {
            _tableview.alpha = 0;
            if(_bottom.alpha > 0.1)
            {
            [UIView animateWithDuration:.3 animations:^{
                _bottom.alpha = 1;
                _videoView.transform = CGAffineTransformMakeScale(minWidth/SCREENVIEWWIDTH, minWidth/SCREENVIEWWIDTH);
                _videoView.frame = CGRectMake(0, originalHeight-minWidth/SCREENVIEWWIDTH*originalHeight, _videoView.frame.size.width, _videoView.frame.size.height);
                _bottom.frame = CGRectMake(SCREENVIEWWIDTH-_videoView.frame.size.width,_tableview.frame.size.height,_bottom.frame.size.width,_bottom.frame.size.height);
                
                _state = minScreen;
                 }];
            }else
                [_bottom removeFromSuperview];
            [_bottom addGestureRecognizer:_tap];
           
        }else{
            [UIView animateWithDuration:.3 animations:^{
            _tableview.alpha = 1;
            _videoView.transform = CGAffineTransformMakeScale(1, 1);
            _videoView.frame = CGRectMake(0, 0, _videoView.frame.size.width, _videoView.frame.size.height);
             _bottom.frame = CGRectMake(0,0,_bottom.frame.size.width,_bottom.frame.size.height);
            _state = fullScreen;
             }];
        }
    }

}
-(void)tapClicked:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:.3 animations:^{
        _tableview.alpha = 1;
        _videoView.transform = CGAffineTransformMakeScale(1, 1);
        _videoView.frame = CGRectMake(0, 0, _videoView.frame.size.width, _videoView.frame.size.height);
        _bottom.frame = CGRectMake(0,0,_bottom.frame.size.width,_bottom.frame.size.height);
        _state = fullScreen;
    }];
    
}
@end
