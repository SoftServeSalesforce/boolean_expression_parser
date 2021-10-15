# Salesforce App
Simple parser for boolen expressions. Example of usage: 
```java
new LogicParser('false OR (false OR (NOT true OR (false OR true)))').evaluateCriteria();
new LogicParser('false | (false | (!true | (false | true)))').evaluateCriteria();
new LogicParser('NOT true').evaluateCriteria();
```

