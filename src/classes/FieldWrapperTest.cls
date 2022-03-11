@isTest
public class FieldWrapperTest {
    @isTest
    static void testParse() {
		FieldWrapper wrapper = new FieldWrapper (
        	'Account Name',
            'Name'
        );
		System.assertEquals('Account Name', wrapper.label);
		System.assertEquals('Name', wrapper.apiName);        
    }
}