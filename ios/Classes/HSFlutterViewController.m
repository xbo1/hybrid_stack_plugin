//
//  HSFlutterViewController.m
//  hybrid_stack_plugin
//
//  Created by bob on 2019/3/9.
//

#import "HSFlutterViewController.h"
#import "HSRouter.h"
#import "HybridStackPlugin.h"

@interface HSFlutterViewController ()
@property (nonatomic, strong) FlutterViewController* flutterViewController;
@end

@implementation HSFlutterViewController
- (instancetype)initWithFlutter:(FlutterViewController*)flutterViewController {
    self = [super init];
    if (self) {
        self.flutterViewController = flutterViewController;
    }
    return self;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    #ifdef DEBUG
    self.view.backgroundColor = [UIColor whiteColor];
    #endif
}

- (BOOL)isFlutterAttatched
{
    return _flutterViewController.view.superview == self.view;
}

- (void)attachFlutter{
    if ([self isFlutterAttatched]) {
        return;
    }
    [_flutterViewController willMoveToParentViewController:nil];
    [_flutterViewController removeFromParentViewController];
    [_flutterViewController didMoveToParentViewController:nil];
    
    [_flutterViewController willMoveToParentViewController:self];
    _flutterViewController.view.frame = self.view.bounds;
    [self.view addSubview: _flutterViewController.view];
    [self addChildViewController:_flutterViewController];
    [_flutterViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = TRUE;
    
    [self attachFlutter];
    [super viewWillAppear:animated];
}

//- (void)viewDidAppear:(BOOL)animated{
//    [self attachFlutter];
//    [super viewDidAppear:animated];
//}

- (void)dealloc{
    if (_flutterViewController != nil) {
        _flutterViewController = nil;
    }
}

//- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
//    return YES;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
