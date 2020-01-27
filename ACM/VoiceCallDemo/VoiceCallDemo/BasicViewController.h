#import <UIKit/UIKit.h>


typedef void (^OKCallback)(BOOL isOK);

@protocol ShowAlertProtocol <NSObject>
- (void)showAlert:(NSString * _Nonnull)message handle:(void(^_Nullable)(UIAlertAction * _Nullable))handle;
- (void)showAlert:(NSString * _Nonnull)message;
- (void)showAlertWidthCancel:(NSString * _Nonnull)message Callback:(OKCallback _Nullable)completionBlock;
@end

@interface BasicViewController : UIViewController <ShowAlertProtocol>

@end
