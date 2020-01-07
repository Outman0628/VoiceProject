#import <UIKit/UIKit.h>

@protocol ShowAlertProtocol <NSObject>
- (void)showAlert:(NSString * _Nonnull)message handle:(void(^_Nullable)(UIAlertAction * _Nullable))handle;
- (void)showAlert:(NSString * _Nonnull)message;
@end

@interface BasicViewController : UIViewController <ShowAlertProtocol>

@end
