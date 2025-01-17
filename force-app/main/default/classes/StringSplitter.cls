public with sharing class StringSplitter {
    @InvocableMethod(label='Split String' description='Splits a string into substrings with a maximum length')
    public static List<SplitStringResult> splitString(List<SplitStringInput> inputList) {
        List<SplitStringResult> results = new List<SplitStringResult>();
        
        for (SplitStringInput input : inputList) {
            List<String> words = input.inputString.split('[,\\s]+');
            List<String> result = new List<String>();
            String currentLine = '';
            
            for (String word : words) {
                if (currentLine.length() + word.length() + 1 <= input.maxLength) {
                    if (currentLine != '') {
                        currentLine += ' ' + word;
                    } else {
                        currentLine = word;
                    }
                } else {
                    result.add(currentLine);
                    currentLine = word;
                }
            }
            
            if (currentLine != '') {
                result.add(currentLine);
            }
            
            SplitStringResult splitResult = new SplitStringResult();
            splitResult.substrings = result;
            results.add(splitResult);
        }
        
        return results;
    }
    
    public class SplitStringInput {
        @InvocableVariable(required=true description='The input string to be split')
        public String inputString;
        
        @InvocableVariable(required=true description='The maximum length of each substring')
        public Integer maxLength;
    }
    
    public class SplitStringResult {
        @InvocableVariable(description='The resulting substrings')
        public List<String> substrings;
    }
}