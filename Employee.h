//
//  Employee.h
//  CoreData_Example
//
//  Created by HealthOne on 23/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic) int16_t age;
@property (nonatomic) NSTimeInterval createdAt;
@property (nullable, nonatomic, retain) NSString *first;
@property (nullable, nonatomic, retain) NSString *last;

@end

