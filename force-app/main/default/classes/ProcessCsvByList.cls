public with sharing class ProcessCsvByList implements Database.Batchable<String>,Database.Stateful{

    public String header;
    public Backup_Configuration__c objConfig;
    public list<string> toItrerate;
    public string csvString = '';

    public Iterable<String> start(Database.BatchableContext bc){
        ProvideCsv__e pe = new ProvideCsv__e();
        pe.ObjectName__c = objConfig.Object_Name__c;
        pe.csvString__c = this.csvString;
        pe.IsLast__c = false;
        pe.endCheck__c = 1;
        EventBus.publish(pe);
        return toItrerate;
    }
    public void execute(Database.BatchableContext bc, List<String> objectList){
        toItrerate.clear();
        createCsv(objectList[0],objConfig.Mapping_S2B__c,header);
    }
    public void finish(Database.BatchableContext bc){
            ProvideCsv__e pe = new ProvideCsv__e();
            pe.ObjectName__c = objConfig.Object_Name__c;
            pe.csvString__c = this.csvString;
            pe.IsLast__c = true;
            pe.endCheck__c = -1;
            EventBus.publish(pe);
    }

    public void createCsv(String sObjectList, String mapbToS,String header){
        Map<String,String> sToB = (Map<String,String>)JSON.deserialize(mapbToS, Map<String,String>.class);
        List<SObject> bigObjList = (List<SObject>)JSON.deserialize(sObjectList, List<SObject>.class);
        List<String> fieldNameList = header.removeEnd('\r\n').split(',');
        Integer noOfFields = fieldNameList.size();
        Integer noOfRecords = bigObjList.size();
        Integer i = 0;
        Integer j = 0;
        while (j<noOfFields){
            if(bigObjList[i].get(sToB.get(fieldNameList[j])) != null){
                this.csvString +=  '"' +( String.valueOf(bigObjList[i].get(sToB.get(fieldNameList[j]))).replaceAll('"', '') )+ '",';
            }else{
                this.csvString +=  '"' + '",';
            }
            if(j == noOfFields-1){
                this.csvString = this.csvString.removeEndIgnoreCase(',') + '\n';
                if(i!=noOfRecords-1){
                    j = 0;
                    i++;
                    continue;
                }
            }
            j++; 
        }

        System.debug(this.csvString.length());
        if(this.csvString.length() > 60000){
            ProvideCsv__e pe = new ProvideCsv__e();
            pe.ObjectName__c = objConfig.Object_Name__c;
            pe.csvString__c = csvString;
            pe.IsLast__c = false;
            pe.endCheck__c = 0;
            Database.SaveResult re = EventBus.publish(pe);
            System.debug(re.isSuccess());
            this.csvString = '';
        }
    }
}