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
@property (nonatomic, strong) NSDictionary* args;
@end

@implementation HSFlutterViewController
- (instancetype)initWithEngineAndArgs:(FlutterEngine*)engine args:(NSDictionary*)args {
    self = [super initWithEngine:engine nibName:nil bundle:nil];
    if (self) {
        self.args = args;
        [self openFlutter];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    #ifdef DEBUG
    self.view.backgroundColor = [UIColor whiteColor];
    #endif
    [[HSRouter sharedInstance] pushFlutterViewController:self];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = TRUE;
    //must call setViewController, or page will not updated
    [[self engine] setViewController:self];
    [super viewWillAppear:animated];
}
//- (void)dealloc{
//    [[HSRouter sharedInstance] popFlutterViewController];
//}

- (void)openFlutter {
    if (self.args != nil) {
        NSString* pageId = [self.args objectForKey:@"pageId"];
        NSDictionary* dict = [self.args objectForKey:@"args"];
        [[HybridStackPlugin sharedInstance] showFlutterPage:pageId args:dict result:nil];
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
