/************************************************************************************************************************************
        Author              : Alex Vashchenko
        Description         : https://github.com/SoftServeSalesforce/boolean_expression_parser
********************************************************************************************************************************/
public with sharing class LogicParser {
    private String expression;
    private Integer position;
    private static final List<String> VALID_EXPR= new List<String>{
            '1',
            '0',
            'true',
            'false',
            'not',
            '!',
            'and',
            'or',
            '\\|',
            '&',
            ' ',
            '\\(',
            '\\)'
    };
    private static final Set<String> INVALID_EXPRESSIONS = new Set<String> {
        '()',
        ')(',
        '(and)',
        '(or)',
        '(not)',
        '(!)',
        '(&)',
        '(|)'
    };

    public LogicParser(String expression) {
        if (String.isBlank(expression)) {
            throw new LogicParserException ('Empty expression.');
        }
        if (!isExpressionValid(expression)) {
            throw new LogicParserException ('Wrong expression.');
        }
        this.expression = expression.toLowerCase().replaceAll(' ', '');
        this.expression = this.expression.replaceAll('and', '&');
        this.expression = this.expression.replaceAll('or', '|');
        this.expression = this.expression.replaceAll('true', '1');
        this.expression = this.expression.replaceAll('false', '0');
        this.expression = this.expression.replaceAll('not', '!');

        Integer leftParenthesisCount = 0;
        Integer rightParenthesisCount = 0;

        for (Integer i = 0; i < expression.length(); i++) {
            String ch = expression.substring(i, i + 1);
            if (ch == '(') {
                leftParenthesisCount++;
            }
            if (ch == ')') {
                rightParenthesisCount++;
            }
        }

        if (leftParenthesisCount != rightParenthesisCount) {
            throw new LogicParserException ('Wrong parenthesis arrangement.');
        }

        for (String item : INVALID_EXPRESSIONS) {
            if (this.expression.contains(item) ) {
                throw new LogicParserException (String.format('Wrong expressions: ', new List<String>{item}));
            }
        }

        if (Pattern.matches('(1|0)!(1|0)', this.expression)) {
            throw new LogicParserException ('Wrong expression.');
        }

        if (Pattern.matches('(1|0){2,}', this.expression)) {
            throw new LogicParserException ('Wrong expression.');
        }

        this.position = 0;
    }

    public Boolean evaluateCriteria() {
        return this.formula() == 1 ? true : false;
    }

    @AuraEnabled
    public static Boolean isExpressionValid(String exp) {
        String expressionCopy = exp.toLowerCase();
        for (String str: VALID_EXPR) {
            expressionCopy = expressionCopy.replaceAll(str, '');
        }
        if (String.isEmpty(expressionCopy)) {
            return true;
        }
        return false;
    }

    private Integer formula() {
        String ch = getChar();
        if (ch.equals('(')) {
            Integer result = formula();
            if (getChar() == ')') {
                return expression(result);
            }
            throw new LogicParserException ('Wrong expression.');

        } else if (this.isDigit(ch)) {
            return expression(term(getValue(ch)));
        } else if (ch == '!') {
            return expression( term( notOperation( factor() ) ) );
        }
        throw new LogicParserException ('Wrong expression.');
    }

    private String getChar() {
        if (position == expression.length()) {
            return '';
        }
        String result = expression.substring(position, position + 1);
        position++;
        return result;
    }

    private void returnChar() {
        position --;
    }

    private Boolean isDigit(String ch) {
        return ch.equals('1') || ch.equals('0');
    }

    private Integer getValue (String ch) {
        return Integer.valueOf(ch);
    }

    private Integer factor () {
        String ch = getChar();
        if (isDigit (ch)) return getValue(ch);
        if (ch == '(') {
            Integer result = formula();
            if (getChar() == ')') {
                return result;
            }
            throw new LogicParserException ('Wrong expression.');
        }
        if (ch == '!') {
            return notOperation(factor());
        }
        throw new LogicParserException ('Wrong expression.');
    }

    private Integer notOperation(Integer value) {
        return value == 1 ? 0 : 1;
    }

    private Integer term (Integer left) {
        String ch = getChar();
        Integer right;
        if (ch != '&') {
            returnChar();
            return left;
        }
        right = factor();
        return term(andExpression (left, right));
    }

    private Integer expression (Integer left) {
        String ch = getChar ();
        Integer right;
        if (ch != '|') {
            returnChar();
            return left;
        }
        // here we need to calculate the value of the right operand
        right = term(factor());
        return expression(orExpression(left,right));
    }

    private Integer andExpression (Integer left, Integer right) {
        return left * right;
    }

    private Integer orExpression (Integer left, Integer right) {
        if (left + right >= 1) {
            return 1;
        }
        return 0;
    }

    public class LogicParserException extends Exception {}
}