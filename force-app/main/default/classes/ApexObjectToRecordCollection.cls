public with sharing class ApexObjectToRecordCollection {

    @InvocableMethod(label='Convert JSON to Record Collection' description='Converts JSON object to Record Collection for Flow Data Table')
    public static List<responseClass> convertJSONToRecordCollection(List<String> jsonStrings) {
        List<responseClass> result = new List<responseClass>();
        
        for (String jsonString : jsonStrings) {
            MDMContractCreationResponse jsonObject = (MDMContractCreationResponse)JSON.deserialize(jsonString,MDMContractCreationResponse.Class);
            responseClass rc = new responseClass();
            rc.result = jsonObject;
            result.add(rc);
        }
        
        return result;
    }
    

    public class responseClass {
        @InvocableVariable public MDMContractCreationResponse result;
    }    
}