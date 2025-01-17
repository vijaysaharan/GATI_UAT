public class GetRecord {
    static final integer MAX_QUERY_RECORDS_LIMIT = 50000;
    
    /* Class definition for throwing custom exceptions */
    public class FlowApexActionException extends Exception{}
    
    @InvocableMethod(label='Get N records with WHERE clause filter')
    public static FlowOutputParameters[] filterRecords(FlowInputParameters[] input){
        FlowOutputParameters[] result = new FlowOutputParameters[]{};
            
        if(input[0].numberOfRecords > MAX_QUERY_RECORDS_LIMIT)
            throw new FlowApexActionException('You cannot query more than 50000 records.');
        
        string query = 'Select '+ input[0].fieldsToQuery + ' FROM ' +  input[0].objectApiName + ' WHERE '+input[0].whereClause +' LIMIT ' + input[0].numberOfRecords;
        system.debug(query);
        
        try{
            sObject[] recordList = database.query(query);
            
            FlowOutputParameters obj = new FlowOutputParameters();
            obj.records = recordList;
            
            result.add(obj);
        } catch(Exception e){
            //system.debug(e.getMessage());
            throw e;
        }
       return result;
    }
    
    /* Input parameters for the Apex action */
    public class FlowInputParameters{
        @InvocableVariable(label='Api name of the Object' required = true )
        public string objectApiName;
        
        @InvocableVariable(label='Fields to query(Comma separated)' required = true)
        public string fieldsToQuery;
        
        @InvocableVariable(label='Where Clause' required = true)
        public string whereClause;
        
        @InvocableVariable(label='Number of records to query' required = true)
        public integer numberOfRecords;
    }
    
    /* Output parameters of the Apex action */
    public class FlowOutputParameters{
        @InvocableVariable(label='Record Collection')
        public sObject[] records;
    }
    
}