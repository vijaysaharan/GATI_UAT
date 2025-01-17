public with sharing class CreateCsvFromFilter implements Database.Batchable<SObject>,Database.Stateful{
    dateTime fromDate;
    dateTime toDate;
    public Datetime fromDateInQuery;
    public Datetime toDateInQuery;
    List<String> parentList;
    Backup_Configuration__c objConfig;
    String bigObjectQuery;
    // Map<String,String> bToS;
    List<SObject> bigObjList;
    public boolean headerGenrated = false;
    public String header;
    public CreateCsvFromFilter(){}

    public CreateCsvFromFilter(Datetime fDate, Datetime tDate, List<String> pList, Backup_Configuration__c oconfig) {
        fromDate = fDate;
        toDate = tDate;
        parentList = pList;
        objConfig = oconfig;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        ProvideCsv__e pe = new ProvideCsv__e();
        pe.ObjectName__c = objConfig.Object_Name__c;
        pe.csvString__c = '';
        pe.IsLast__c = false;
        pe.endCheck__c = 1;
        EventBus.publish(pe);
        Map<String,String> bToS = (Map<String,String>)JSON.deserialize(objConfig.Mapping_S2B__c , Map<String,String>.class);
        bigObjectQuery = 'Select ';
        bigObjectQuery += String.join(new List<String>(bToS.values()), ',');
        if(header == null){
            header = String.join(new List<String>(bToS.keySet()), ',') + '\r\n';
        }
        List<String> indexList = this.objConfig.Big_Object_Index__c.split(',');
        if(!indexList.isEmpty() && indexList.size() >= 2 ){
            System.debug(' where ' + indexList[0] + ' IN :parentList AND ' + indexList[1] + ' >= :'+fromDateInQuery + ' AND ' + indexList[1] + ' < :'+toDateInQuery);
            bigObjectQuery += ' from '+ objConfig.Big_Object_Name__c+ ' where ' + indexList[0] + ' IN :parentList AND ' + indexList[1] + ' >= :fromDateInQuery AND ' + indexList[1] + ' < :toDateInQuery'; 
        }else{
            return Database.getQueryLocator('Select Id from case where CreatedDate = Today And  CreatedDate <> Today');
        }
        return Database.getQueryLocator('Select Id from case limit 1');
    }


    public void execute(Database.BatchableContext bc, List<Sobject> dummy){
        bigObjList = Database.query(bigObjectQuery);
        if(!headerGenrated){
            ProvideCsv__e pe = new ProvideCsv__e();
            pe.ObjectName__c = objConfig.Object_Name__c;
            pe.isHeader__c = true;
            pe.csvString__c = header;
            pe.endCheck__c = 0;
            pe.IsLast__c = false;
            EventBus.publish(pe);
            headerGenrated = true;
        }
    }

    public void finish(Database.BatchableContext bc){
            if(!bigObjList.isEmpty() || Test.isRunningTest()){
                List<String> toIterate = new List<String>();
                List<SObject> newlist = new List<SObject>();
                for (SObject s : bigObjList) {
                    newlist.add(s);
                    if(newlist.size() > 50){ 
                        toIterate.add(JSON.serialize(newlist));
                        newlist.clear();
                    }
                }
                if(!newlist.isEmpty()){
                    toIterate.add(JSON.serialize(newlist));
                }
                
                ProcessCsvByList p = new ProcessCsvByList();
                p.header = header;
                p.objConfig = objConfig;
                p.toItrerate = toIterate;
                Database.executeBatch(p, 1);
            }
            
        if(!(toDateInQuery.addHours(Integer.valueOf(System.Label.queryHours)) > toDate)){
            CreateCsvFromFilter c = new CreateCsvFromFilter(fromDate, toDate, parentList, objConfig);
            c.fromDateInQuery = fromDateInQuery.addHours(Integer.valueOf(System.Label.queryHours));
            c.toDateInQuery = toDateInQuery.addHours(Integer.valueOf(System.Label.queryHours));
            c.header = header;
            c.headerGenrated = true;
            Database.executeBatch(c, 1);
        }

        ProvideCsv__e pe = new ProvideCsv__e();
        pe.ObjectName__c = objConfig.Object_Name__c;
        pe.csvString__c = '';
        pe.IsLast__c = true;
        pe.endCheck__c = -1;
        EventBus.publish(pe);
    }

}