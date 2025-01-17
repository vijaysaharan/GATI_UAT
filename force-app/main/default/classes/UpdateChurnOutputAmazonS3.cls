global class UpdateChurnOutputAmazonS3 implements Database.batchable<String>, database.stateful{
    public String csvbody = '';
    public String header;
    
    global UpdateChurnOutputAmazonS3(String csvData){
        csvbody = csvData;
    }
    
    global Iterable<string> start(Database.BatchableContext bc) {
        List<String> rowList = new List<String>();
        Utility_RowIterator rowIterator = new Utility_RowIterator(csvbody, '\n');
        Iterator<String> iterator = rowIterator.iterator();
        while (iterator.hasNext()) {
            rowList.add(iterator.next());
        }
        list<string> rows = new list<string>();
        header = rowList[0];        
        for(integer row = 1; row < rowList.size(); row++) {
            string rowWithHeader = rowList[row] + '\n'; 
            rows.add(rowWithHeader);
        }        
        return rows;
    }
    
    global void execute(database.BatchableContext bc, List<String> rowsData) {
        List<String> columnList = new List<String>{'EDC__c','Contract_Number__c','Calib_End__c','First_Trans__c','Last_Trans__c','Time_Last_Trans_Recency__c','Active_Freq__c','Churn_Factor__c','Total_Revenue__c','Last_Month_Revenue__c','Current_Month_Revenue__c','Last_Month_Volume__c','Current_Month_Volume__c','Rank__c','Softchurn_Indicator__c','Days_Till_Churn__c','Code_Blocked__c','SLA__c','Top_3_Default_OU__C'};
        
        List<Churn_Output__c> churnListToUpdate = new List<Churn_Output__c>();
        Set<String> contractNumberSet = new Set<String>();
        Set<String> recordToBeCreate = new Set<String>();
        
        if(rowsData != null && rowsData.size() > 0){
            for(Integer i=0; i<rowsData.size(); i++){
                List<String> cellData = rowsData[i].replace('\n','').split(',');
                if(cellData != null && cellData.size() >= 1 && cellData[1] != null && cellData[1] != ''){
                 	contractNumberSet.add(cellData[1]);   
                }
            }
            List<Churn_Output__c> churnList = [SELECT Id, Contract_Number__c FROM Churn_Output__c WHERE Contract_Number__c IN :contractNumberSet];
            if(churnList != null && churnList.size() > 0){
                for(Churn_Output__c churn : churnList){
                    recordToBeCreate.add(churn.Contract_Number__c);
                }
            }
            for(Integer i=0; i<rowsData.size(); i++){
                List<String> cellData = rowsData[i].replace('\n','').split(',');
                if(cellData != null && cellData.size() > 0 && (cellData[1] != null && cellData[1] != '') && recordToBeCreate.contains(cellData[1])){
                    Churn_Output__c newChurn = new Churn_Output__c();
                    if(cellData != null && cellData.size() >= 1){
                        newChurn.EDC__c = (cellData[0] != null && cellData[0] != '') ? cellData[0] : '';
                    }
                    if(cellData != null && cellData.size() >= 2){
                        newChurn.Contract_Number__c = (cellData[1] != null && cellData[1] != '') ? cellData[1] : '';
                    }
                    if(cellData != null && cellData.size() >= 3){
                        newChurn.Calib_End__c = (cellData[2] != null && cellData[2] != '') ? Date.valueOf(cellData[2].split(' ')[0]) : null;
                    }
                    if(cellData != null && cellData.size() >= 4){
                        newChurn.First_Trans__c = (cellData[3] != null && cellData[3] != '') ?  Date.valueOf(cellData[3].split(' ')[0]) : null;
                    }
                    if(cellData != null && cellData.size() >= 5){
                        newChurn.Last_Trans__c = (cellData[4] != null && cellData[4] != '') ? Date.valueOf(cellData[4].split(' ')[0]) : null;
                    }
                    if(cellData != null && cellData.size() >= 6){
                        newChurn.Time_Last_Trans_Recency__c = (cellData[5] != null && cellData[5] != '') ? Decimal.valueOf(cellData[5]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 7){
                        newChurn.Active_Freq__c = (cellData[6] != null && cellData[6] != '') ? Decimal.valueOf(cellData[6]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 8){
                        newChurn.Churn_Factor__c = (cellData[7] != null && cellData[7] != '') ? Decimal.valueOf(cellData[7]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 9){
                        newChurn.Category__c = (cellData[8] != null && cellData[8] != '') ? cellData[8] : '';
                    }
                    if(cellData != null && cellData.size() >= 10){
                        newChurn.Total_Revenue__c = (cellData[9] != null && cellData[9] != '') ?  Decimal.valueOf(cellData[9]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 11){
                        newChurn.Last_Month_Revenue__c = (cellData[10] != null && cellData[10] != '') ? Decimal.valueOf(cellData[10]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 12){
                        newChurn.Current_Month_Revenue__c = (cellData[11] != null && cellData[11] != '') ? Decimal.valueOf(cellData[11]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 13){
                        newChurn.Last_Month_Volume__c = (cellData[12] != null && cellData[12] != '') ? Decimal.valueOf(cellData[12]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 14){
                        newChurn.Current_Month_Volume__c = (cellData[13] != null && cellData[13] != '') ? Decimal.valueOf(cellData[13]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 15){
                        newChurn.Rank__c = (cellData[14] != null && cellData[14] != '') ? Decimal.valueOf(cellData[14]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 16){
                        newChurn.Softchurn_Indicator__c = (cellData[15] != null && cellData[15] != '') ? cellData[15] : '';
                    }
                    if(cellData != null && cellData.size() >= 17){
                        newChurn.Days_Till_Churn__c = (cellData[16] != null && cellData[16] != '') ? Decimal.valueOf(cellData[16]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 18){
                        newChurn.Code_Blocked__c = (cellData[17] != null && cellData[17] != '') ? cellData[17] : '';
                    }
                    if(cellData != null && cellData.size() >= 19){
                        newChurn.SLA__c = (cellData[18] != null && cellData[18] != '') ? Decimal.valueOf(cellData[18]) : 0;
                    }
                    if(cellData != null && cellData.size() >= 20){
                        newChurn.Top_3_Default_OU__C = (cellData[19] != null && cellData[19] != '') ? cellData[19] : '';
                    }
                    churnListToUpdate.add(newChurn);
                }
            }
        }
        if(churnListToUpdate != null && churnListToUpdate.size() > 0){
            upsert churnListToUpdate Contract_Number__c; 
        }
    }
    
    global void finish(database.BatchableContext bc) {}
    
    public static String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new List<String>(bytesCount);
        for (Integer i = 0; i < bytesCount; ++i)
            bytes[i] = hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
}