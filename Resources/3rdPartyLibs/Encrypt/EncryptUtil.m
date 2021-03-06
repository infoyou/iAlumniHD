//
//  EncryptUtil.m
//  iAlumniHD
//
//  Created by fnicole on 11-11-6.
//  Copyright (c) 2011年 CEIBS. All rights reserved.
//

#import "EncryptUtil.h"

#define ifEncrypt @"YES"

@implementation EncryptUtil

#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

+ (NSData*)TripleDESforNSData:(NSData*)plainData encryptOrDecrypt:(CCOperation)encryptOrDecrypt{
  
  NSString *plainText = [[[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding] autorelease];
  NSString *result = [[self class] TripleDES:plainText encryptOrDecrypt:encryptOrDecrypt];
  return [result dataUsingEncoding:NSUTF8StringEncoding];
}



+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt{
  
  NSString *key = @"abcdefghijklmnopqrstuvwx";
  NSString *vec = @"init Vec";
  
  const void *vplainText;
  size_t plainTextBufferSize;
  
  if (encryptOrDecrypt == kCCDecrypt){
    NSData *EncryptData = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
    plainTextBufferSize = [EncryptData length];
    vplainText = [EncryptData bytes];
  }
  else{
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    plainTextBufferSize = [data length];
    vplainText = (const void *)[data bytes];
  }
  
  CCCryptorStatus ccStatus;
  uint8_t *bufferPtr = NULL;
  size_t bufferPtrSize = 0;
  size_t movedBytes = 0;
  
  bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
  bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
  memset((void *)bufferPtr, 0x0, bufferPtrSize);

  NSString *initVec = vec;
  const void *vkey = (const void *) [key UTF8String];
  const void *vinitVec = (const void *) [initVec UTF8String];
  
  ccStatus = CCCrypt(encryptOrDecrypt,
                     kCCAlgorithm3DES,
                     kCCOptionPKCS7Padding,
                     vkey, //key
                     kCCKeySize3DES,
                     vinitVec, //iv,
                     vplainText,  //plainText,
                     plainTextBufferSize,
                     (void *)bufferPtr,
                     bufferPtrSize,
                     &movedBytes);
  
  NSString *result;
  
  if (encryptOrDecrypt == kCCDecrypt){
    result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr 
                                                            length:(NSUInteger)movedBytes] 
                                    encoding:NSUTF8StringEncoding] 
              autorelease];
  }
  else{
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    result = [GTMBase64 stringByEncodingData:myData];
    
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];//过滤掉+号
                                                                                  //result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];//过滤掉/号
  }
  

  return result;
} 

@end
