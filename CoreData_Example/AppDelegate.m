//
//  AppDelegate.m
//  CoreData_Example
//
//  Created by HealthOne on 22/10/16.
//  Copyright © 2016 akash. All rights reserved.
//

#import "AppDelegate.h"
#import "Employee.h"
#import "Person.h"
#import "Address.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self basicCrudOperations];
    
    [self relationshipCrudOperations];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSError *error;
    [[self managedObjectContext]save:&error];
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 It describes the schema that you use in the app. If you have a database background, think of this as the database schema. However, the schema is represented by a collection of objects (also known as entities). In Xcode, the Managed Object Model is defined in a file with the extension .xcdatamodeld. You can use the visual editor to define the entities and their attributes, as well as, relationships.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    NSURL *modeurl = [[NSBundle mainBundle]URLForResource:@"CoreData_Example" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modeurl];
    return _managedObjectModel;
}

/*
 SQLite is the default persistent store in iOS. However, Core Data allows developers to setup multiple stores containing different entities. The Persistent Store Coordinator is the party responsible to manage different persistent object stores and save the objects to the stores. Forget about it you don’t understand what it is. You’ll not interact with Persistent Store Coordinator directly when using Core Data.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [[self  applicationDocumentsDirectory]URLByAppendingPathComponent:@"CoreData_Example.sqlite"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *dictOptions = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES)
                                  };
    NSError *error;
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:dictOptions error:&error];
    if (!store)
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

/*
 Think of it as a “scratch pad” containing objects that interacts with data in persistent store. Its job is to manage objects created and returned using Core Data. Among the components in the Core Data Stack, the Managed Object Context is the one you’ll work with for most of the time. In general, whenever you need to fetch and save objects in persistent store, the context is the first component you’ll talk to.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Basic CRUD operations
- (void)basicCrudOperations
{
    // Create employee object
    Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:[self managedObjectContext]];
    int r = arc4random() % 100;
    employee.first = [NSString stringWithFormat:@"first_%d", r];
    employee.last = [NSString stringWithFormat:@"last_%d", r];
    employee.age = r;
    employee.createdAt = [[NSDate date]timeIntervalSince1970];
    NSError *error;
    if (![[self managedObjectContext] save:&error])
    {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    // Read employees
    error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    NSArray *arrEmployees = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSAssert(NO, @"Error fetching context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    else
    {
        NSLog(@"Available employees As Fault- %@", arrEmployees);
        NSLog(@"All first names- %@", [arrEmployees valueForKey:@"first"]);
        NSLog(@"employees after faulting- %@", arrEmployees);
    }
    
    // Update Record
    error = nil;
    NSFetchRequest *updateRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    int age = 70;// may be different based on available data
    [updateRequest setPredicate:[NSPredicate predicateWithFormat:@"age == %d", age]];
    Employee *oldEmployee = [[[self managedObjectContext]executeFetchRequest:updateRequest error:&error]lastObject];
    if (oldEmployee)
    {
        oldEmployee.first = [NSString stringWithFormat:@"updated first name- %d", r];
        oldEmployee.last = [NSString stringWithFormat:@"updated last name- %d", r];
        error = nil;
        [[self managedObjectContext]save:&error];
    }
    
    // Delete Records
    error = nil;
    NSFetchRequest *deleteRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    age = 90;// may be different based on available data
    [deleteRequest setPredicate:[NSPredicate predicateWithFormat:@"age == %d", age]];
    NSArray *arrDeleteEmployees = [[self managedObjectContext]executeFetchRequest:deleteRequest error:&error];
    for (int i=0; i<arrDeleteEmployees.count; i++)
    {
        Employee *deleteEmployee = [arrDeleteEmployees objectAtIndex:i];
        [[self managedObjectContext]deleteObject:deleteEmployee];
    }
    [[self managedObjectContext]save:&error];
}

#pragma mark - Relationships
- (void)relationshipCrudOperations
{
    int random = arc4random() % 100;
    
    // Create person
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[self managedObjectContext]];
    person.age = random;
    person.first = [NSString stringWithFormat:@"first_%d", random];
    person.last = [NSString stringWithFormat:@"last_%d", random];
    
    // Create Address
    Address *address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:[self managedObjectContext]];
    address.city = [NSString stringWithFormat:@"city_%d", random];
    address.country = [NSString stringWithFormat:@"country_%d", random];
    address.number = [NSString stringWithFormat:@"number_%d", random];
    address.street = [NSString stringWithFormat:@"street_%d", random];
    
    int random2 = arc4random() % 100;
    Address *address2 = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:[self managedObjectContext]];
    address2.city = [NSString stringWithFormat:@"city_%d", random2];
    address2.country = [NSString stringWithFormat:@"country_%d", random2];
    address2.number = [NSString stringWithFormat:@"number_%d", random2];
    address2.street = [NSString stringWithFormat:@"street_%d", random2];
    
    NSSet *setAddress = [NSSet setWithObjects:address, address2, nil];
    
    //     Assign Address set to person
    person.addresses = setAddress;
    
    // Save Person
    NSError *error;
    if (![[self managedObjectContext] save:&error])
    {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    
    // Read Persons
    error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    NSArray *arrpersons = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSAssert(NO, @"Error fetching context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    else
    {
        NSLog(@"Available Persons As Fault- %@", arrpersons);
        NSLog(@"All first names- %@", [arrpersons valueForKey:@"first"]);
        NSLog(@"Persons after faulting- %@", arrpersons);
    }
    
    
    // Update Relationship
    error = nil;
    NSFetchRequest *updateRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    int age = 24;// may be different based on available data
    [updateRequest setPredicate:[NSPredicate predicateWithFormat:@"age == %d", age]];
    Person *oldPerson = [[[self managedObjectContext]executeFetchRequest:updateRequest error:&error]lastObject];
    if (oldPerson)
    {
        NSMutableSet *setAddress = [oldPerson mutableSetValueForKey:@"addresses"];
        [setAddress removeAllObjects];// Remove all addresses
        
        int random3 = arc4random() % 100;
        Address *address3 = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:[self managedObjectContext]];
        address3.city = [NSString stringWithFormat:@"updated_city_%d", random3];
        address3.country = [NSString stringWithFormat:@"updated_country_%d", random3];
        address3.number = [NSString stringWithFormat:@"updated_number_%d", random3];
        address3.street = [NSString stringWithFormat:@"updated_street_%d", random3];
        [setAddress addObject:address3];// add new address
        error = nil;
        [[self managedObjectContext]save:&error];
    }
    
    // Delete relationships
    error = nil;
    NSFetchRequest *delRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    age = 99;// may be different based on available data
    [delRequest setPredicate:[NSPredicate predicateWithFormat:@"age == %d", age]];
    Person *delPerson = [[[self managedObjectContext]executeFetchRequest:delRequest error:&error]lastObject];
    if (delPerson)
    {
        delPerson.addresses = nil;
        [[self managedObjectContext]save:&error];
    }
    
    
    // Delete Person, In this example we are using 'cascade' delete rules so when we delete person object it will also delete addresses those are only associated with this Person object
    error = nil;
    NSFetchRequest *deleteRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    age = 39;// may be different based on available data
    [deleteRequest setPredicate:[NSPredicate predicateWithFormat:@"age == %d", age]];
    Person *deletePerson = [[[self managedObjectContext]executeFetchRequest:deleteRequest error:&error]lastObject];
    if (deletePerson)
    {
        [[self managedObjectContext]deleteObject:deletePerson];
        [[self managedObjectContext]save:&error];
    }
}

@end
