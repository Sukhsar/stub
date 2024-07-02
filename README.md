# Stub

I borrwed this code from internet and forgot from whom. The real credit goes to him. I hope he read this message.

This little utility class is to stub a class which is getting instantiated and exectured from another class(i.e. parent class). 
During unti testing, it helped to isolate the parent class. for example see code sample below

## Child.cls
```apex
public class Child {

    public Account createAccount() {
        // TODO: business logic
        Account anAccount = new Account(name = 'Sukhendu Sarkar');
        insert anAccount;
        return anAccount;
    }
}
```
## Parent.cls
```apex
public class Parent {

    @TestVisible
    private Child child;
    
    public Account main() {
        // TODO: Business logic
        return this.getChild().createAccount();
    }
    
    private Child getChild() {
        if(Verify.isNull(this.child)) {
            this.child = new Child();
        }
        return child;
    }
}
```
Now, the unit test class for ParentTest.cls will look like this:
## ParentTest.cls
```apex
@isTest
public class ParentTest {

    @isTest
    static void testMainSuccess() {
        // Prepare fake stub data
        Account aFakeAccount = new Account();
        aFakeAccount.Id = FakeId.get(Account.SObjectType);
        aFakeAccount.Name = 'Sukhendu Sarkar';
        
        // Stub Child.createAccount();
        Stub stub = new Stub(Child.class);
        stub.setReturnValue('createAccount', aFakeAccount);
        
        Parent parent = new Parent();
        parent.child = (Child)stub.instance;
        
        System.Test.startTest();
        Account testAccount = parent.main();
        System.Test.stopTest();

        System.Assert.areEqual(aFakeAccount.Name, testAccount.Name);
    }
}
```

If the child is implementing an interface then we can use the child's polymorphic nature to provide a fake implementation of the child at unit test run time and we can achieve the same result.

## Interface Childable.cls
``` apex
public interface Childable {
	Account createAccount();
}
```
## Now Child.cls implements Childable interface
```apex
public class Child implements Childable {

    public Account createAccount() {
        // TODO: business logic
        Account anAccount = new Account(name = 'Sukhendu Sarkar');
        insert anAccount;
        return anAccount;
    }
}
```
## Parent.cls is refering to interface childable.cls instead of concreate Child.cls
```apex
public class Parent {

    @TestVisible
    private Childable child;
    
    public Account main() {
        // TODO: Business logic
        return this.getChild().createAccount();
    }
    
    private Childable getChild() {
        if(Verify.isNull(this.child)) {
            this.child = new Child();
        }
        return child;
    }
}
```

## The ParentTest.cls is creating and suppling a fake implemnation of child to isolate the parent
```apex
@isTest
public class ParentTest {

    @isTest
    static void testMainSuccess() {
        // Prepare fake stub data
        Account aFakeAccount = new Account();
        aFakeAccount.Id = FakeId.get(Account.SObjectType);
        aFakeAccount.Name = 'Sukhendu Sarkar';
        
        Parent parent = new Parent();
        parent.child = new Child(aFakeAccount);
        
        System.Test.startTest();
        Account testAccount = parent.main();
        System.Test.stopTest();
        
        System.Assert.areEqual(aFakeAccount.Name, testAccount.Name);
    }
    
    // A fake implementation of Child
    private class Child implements Childable {
        private Account fakeAccount;
        
        public Child(Account fakeAccount) {
            this.fakeAccount = fakeAccount;
        }
        
        public Account createAccount() {
            return this.FakeAccount;
        }
    }
}
```

## Concolussion: There is a reason why the silver bullet of object oriented programming is so powerfull.
