/************************************************************************************************************************************
        Author              : Alex Vashchenko
        Description         : https://github.com/SoftServeSalesforce/boolean_expression_parser
********************************************************************************************************************************/
@isTest
private class LogicParserTest {

	@isTest
	public static void testInvalidStrings(){
		try {
    		new LogicParser('true ||').evaluateCriteria();
    		System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}
    	
    	try {
    		new LogicParser('true &&').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}

    	try {
    		new LogicParser('').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}

    	try {
    		new LogicParser('true not true').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}

    	try {
    		new LogicParser('(true AND true').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}

    	try {
    		new LogicParser('(true AND false))))))').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}

    	try {
    		new LogicParser('true false').evaluateCriteria();
			System.assert(false);
    	} catch (Exception e) {
			System.assert(true);
    	}
	}
	
	@isTest 
	public static void testWithoutTranslation() {
		System.assertEquals(true, (new LogicParser('true')).evaluateCriteria());
		System.assertEquals(false, (new LogicParser('!true')).evaluateCriteria());
		System.assertEquals(true, (new LogicParser('!false')).evaluateCriteria());
		System.assertEquals(false, (new LogicParser('false')).evaluateCriteria());
		System.assertEquals(false, (new LogicParser('true & !true')).evaluateCriteria());
		System.assertEquals(true, (new LogicParser('false | !false')).evaluateCriteria());
		System.assertEquals(true, (new LogicParser('false | (false | (!true | (false | true)))')).evaluateCriteria());
	}
	
	@IsTest
    static void testWithTranslation() {
		System.assertEquals(true, new LogicParser('true').evaluateCriteria());
		System.assertEquals(false, new LogicParser('NOT true').evaluateCriteria());
		System.assertEquals(true, new LogicParser('NOT false').evaluateCriteria());
		System.assertEquals(false, new LogicParser('false').evaluateCriteria());
		System.assertEquals(false, new LogicParser('true AND !true').evaluateCriteria());
		System.assertEquals(true, new LogicParser('false OR NOT false').evaluateCriteria());
		System.assertEquals(true, new LogicParser('false OR (false OR (NOT true OR (false OR true)))').evaluateCriteria());
		System.assertEquals(true, (new LogicParser('true or false and not true')).evaluateCriteria());
    }
}