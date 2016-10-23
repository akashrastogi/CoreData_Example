//
//  Person.h
//  CoreData_Example
//
//  Created by HealthOne on 23/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address;


@interface Person : NSManagedObject

@property (nonatomic) int16_t age;
@property (nullable, nonatomic, retain) NSString *first;
@property (nullable, nonatomic, retain) NSString *last;
@property (nullable, nonatomic, retain) NSSet<Address *> *addresses;

@end
