public with sharing class UploadComplaintsRecordFromCSV {

    
    @AuraEnabled
    public static string insertData(String strfromle){
        String returnresponse ='';
        List<Case> caseListtoInsert = new List<Case>();
        //system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        //system.debug('datalist = ' + datalist);
        //system.debug('datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist){
            Case c =new Case();
            c.subject = wrapper.subject;
            c.status = wrapper.origin;
            c.origin = wrapper.status;
            
            CaseListtoInsert.add(c);            
        }
        
        if(CaseListtoInsert.size() > 0){
            try {
                insert CaseListtoInsert;
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                returnresponse = 'ERROR';
            }
        }
        return returnresponse;
    }
    
    public class FieldWrapper{        
        public String subject;        
        public String origin;        
        public String status;
        
    } 
    
}