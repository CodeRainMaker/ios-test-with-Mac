//
//  TSYDefine.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#ifndef TSYDefine_h
#define TSYDefine_h

#ifdef DEBUG
# define T_Log(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define T_Log(...);
#endif

#endif /* TSYDefine_h */
