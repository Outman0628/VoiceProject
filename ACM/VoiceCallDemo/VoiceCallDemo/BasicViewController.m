#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)showAlert:(NSString * _Nonnull)message handle:(void (^_Nullable)(UIAlertAction * _Nullable))handle {
    [self.view endEditing:true];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlertWidthCancel:(NSString * _Nonnull)message handle:(void (^_Nullable)(UIAlertAction * _Nullable))handle {
    [self.view endEditing:true];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlert:(NSString * _Nonnull)message; {
    [self showAlert:message handle:nil];
}


- (void)showAlertWidthCancel:(NSString * _Nonnull)message Callback:(OKCallback _Nullable)completionBlock {
    [self showAlertWidthCancel:message handle:^(UIAlertAction * _Nullable action) {
        if([action.title isEqualToString:@"OK"])
        {
            completionBlock(true);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = false;
}

@end
