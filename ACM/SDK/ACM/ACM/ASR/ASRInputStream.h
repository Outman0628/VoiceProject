//
//  ASRInputStream.h
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ASRInputStream_h
#define ASRInputStream_h

#import <Foundation/Foundation.h>
#import "AudioStreamMgr.h"
#import "AsrManager.h"

@interface ASRInputStream : NSInputStream

-(void) pushCaptureData:(unsigned char *)data bytesLength:(int)bytesLength;

@end


#endif /* ASRInputStream_h */
