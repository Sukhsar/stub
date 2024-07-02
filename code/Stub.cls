@isTest
public class Stub implements System.StubProvider {
    
    public Type type                         {get; private set;}
    public Object instance                   {get; private set;}
    private Set<String> invokedMethods;
    private Map<String, Exception> exceptions;
    private Map<String, Object> returnValues;
    
    public Stub(Type typeToMock) {
        this.Type           = typeToMock;
        this.instance       = Test.createStub(this.Type, this);
        this.invokedMethods = new Set<String>();
        this.exceptions     = new Map<String, Exception>();
        this.returnValues   = new Map<String, Object>();
    }
    
    /**
     * Stub provider
     */
    public Object handleMethodCall (Object stubbedObject, 
                                    String stubbedMethodName,
                                    Type returnType,
                                    List<Type> listOfParamType, 
                                    List<String> listOfParamNames,
                                    List<Object> listofArgs) {
        this.invokedMethods.add(stubbedMethodName);                                
        if(exceptions.containsKey(stubbedMethodName)) {
            throw exceptions.get(stubbedMethodName);
        } else if(returnvalues.containsKey(stubbedMethodName)){
            return returnValues.get(stubbedMethodName);
        }
		if(String.valueOf(returnType) == 'void') {
            return null;
        }
        // Non-void method without configured response, throw an exception
        throw new Error.NoReturnValueException(String.format(
            'No return value or exception has been configured for method' +
            '\'\'{0}\'\' on stubbed class \'\'{1}\'\'',
            new String[]{ stubbedMethodName, String.valueOf(type)}));
    }
    
    public void setReturnValue(String methodName, Object returnValue) {
        returnValues.put(methodName, returnValue);
    }
    
    public void setException(String methodName) {
        exceptions.put(methodName, new Error.MockException('Mock Exception'));
    }
    
    public void setException(String methodName, Exception exceptionToThrow) {
        exceptions.put(methodName, exceptionToThrow);
    }
    
    /**
     * Assertions
     */
    public void assertInvoked(String methodName) {
        if(!invokedMethods.contains(methodName)) {
            throw new Error.MethodNotInvokedException(String.format(
				'Method {0}.{1}() not invoked',
				new String[] { type.getName(), methodName }
			));
        }
    }
    
    public void assertNotInvoked(String methodName) {
        if(invokedMethods.contains(methodName)) {
			throw new Error.MethodInvokedException(String.format(
				'Method {0}.{1}() invoked',
				new String[] { type.getName(), methodName }
			));
		}
    }
}

/* Sample usage

    Stub stub = new Stub(ExternalAuthFactory.class);
    stub.setReturnValue('getAuth', new DummyAuth());
    ExternalAuthFactory.instance = (ExternalAuthFactory)stub.instance;  

*/
