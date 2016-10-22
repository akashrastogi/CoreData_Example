//
//  Person.h
//  CoreData_Example
//
//  Created by HealthOne on 22/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nullable, nonatomic, retain) NSString *first;
@property (nullable, nonatomic, retain) NSString *last;
@property (nonatomic) int16_t age;
@property (nonatomic) NSTimeInterval createdAt;

@end

