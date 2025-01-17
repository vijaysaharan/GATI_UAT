@IsTest
public class StringSplitterTest {
    
    @IsTest
    static void testSimpleString() {
        // Arrange
        StringSplitter.SplitStringInput input = new StringSplitter.SplitStringInput();
        input.inputString = 'Hello world';
        input.maxLength = 20;
        
        List<StringSplitter.SplitStringInput> inputList = new List<StringSplitter.SplitStringInput>();
        inputList.add(input);
        
        // Act
        List<StringSplitter.SplitStringResult> results = StringSplitter.splitString(inputList);
        
        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(1, results[0].substrings.size());
        System.assertEquals('Hello world', results[0].substrings[0]);
    }
    
    
    @IsTest
    static void testEmptyString() {
        // Arrange
        StringSplitter.SplitStringInput input = new StringSplitter.SplitStringInput();
        input.inputString = '';
        input.maxLength = 10;
        
        List<StringSplitter.SplitStringInput> inputList = new List<StringSplitter.SplitStringInput>();
        inputList.add(input);
        
        // Act
        List<StringSplitter.SplitStringResult> results = StringSplitter.splitString(inputList);
        
        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(0, results[0].substrings.size());
    }

}