//
//  TSYNetWatch.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYNetWatch.h"
#import "NSURLSession+TSYSession.h"
#import <objc/runtime.h>

static NSString *OneNetworkFlag = @"OneNetworkFlag";

@interface TSYNetWatch()

@property(nonatomic,strong)NSURLConnection *connectUReq;

@property(nonatomic,strong)NSURLRequest *tsy_request;

@property(nonatomic,strong)NSURLResponse *tsy_response;

@property(nonatomic,strong)NSData *tsy_data;

@end

@implementation TSYNetWatch

+(TSYNetWatch *)intanceStart {
    static  TSYNetWatch   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSYNetWatch alloc] init];
    });
    return manager;
}

//开始监听
- (void)start{
    [NSURLSession startWatch];
    [NSURLProtocol registerClass:[self classForCoder]];
}

//结束监听
- (void)stop {
    [NSURLProtocol unregisterClass:[self classForCoder]];
    [NSURLSession stopWatch];
}

//请求拦截
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *sch = request.URL.scheme;
    if (sch == nil || sch.length == 0) {
        return false;
    }
    
    if ([NSURLProtocol propertyForKey:OneNetworkFlag inRequest:request]) {
        //有标示表示处理过了
        return false;
    }
    
    if ([sch isEqualToString:@"http"] || [sch isEqualToString:@"https"]) {
        return true;
    }
    
    return false;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *req = [request mutableCopy];
    [NSURLProtocol setProperty:[NSNumber numberWithBool:YES] forKey:OneNetworkFlag inRequest:req];
    
    return [request copy];
}

//发送请求
- (void)startLoading {
    NSURLRequest *request = [TSYNetWatch canonicalRequestForRequest:self.request];
    
    self.connectUReq = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    self.tsy_request = self.request;
}

- (void)stopLoading {
    [self.connectUReq cancel];
    
    if (_delegate && [_delegate respondsToSelector:@selector(watchSendInfo:withType:)]) {
        //数据外出
        NSString *urlInfo = [NSString stringWithFormat:@"url = %@ ,method = %@,HeaderFields = %@, httpBody = %@",self.tsy_response.URL ,self.tsy_request.HTTPMethod,self.tsy_request.allHTTPHeaderFields,self.tsy_request.HTTPBody];
        [_delegate watchSendInfo:urlInfo withType:TSY_Msg_Type_Net];
    }
    
}

#pragma mark ###### NSURLConnectiongDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    if (response != nil) {
        self.tsy_response = response;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    self.tsy_data = data;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
