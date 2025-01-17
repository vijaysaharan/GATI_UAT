public with sharing class QueueCreateCSV implements Queueable{
    public List<SObject> bigObjList;
    public Id fileId;
    public String header;
    public Backup_Configuration__c objConfig;


    public void execute(QueueableContext context) {
        createCsv(JSON.serialize(bigObjList),objConfig.Mapping_S2B__c,fileId,header);
    }

    public void createCsv(String sObjectList, String mapbToS, String fileId,String header){
        Map<String,String> sToB = (Map<String,String>)JSON.deserialize(mapbToS, Map<String,String>.class);
        List<SObject> bigObjList = (List<SObject>)JSON.deserialize(sObjectList, List<SObject>.class); 
        String csvString = '';
        
        List<String> fieldNameList = header.split(',');
        Integer noOfFields = fieldNameList.size();
        Integer noOfRecords = bigObjList.size();
        Integer i = 0;
        Integer j = 0;
        while (j<noOfFields){
            if(bigObjList[i].get(sToB.get(fieldNameList[j])) != null){
                csvString +=  '"' + String.valueOf(bigObjList[i].get(sToB.get(fieldNameList[j])))+ '",';
            }else{
                csvString +=  '"' + '",';
            }
            if(j == noOfFields-1){
                csvString = csvString.removeEndIgnoreCase(',') + '\n';
                if(i!=noOfRecords-1){
                    j = 0;
                    i++;
                    continue;
                }
            }
            j++; 
        }
        List<ContentVersion> clist = [Select VersionData,id from ContentVersion where Id = : this.fileId];
        String oldString =  clist[0].VersionData.toString();
        oldString += csvString;
        clist[0].VersionData = Blob.valueOf(oldString);
        update clist;
    }
}