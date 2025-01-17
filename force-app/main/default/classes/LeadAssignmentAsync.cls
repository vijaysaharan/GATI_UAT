public without sharing class LeadAssignmentAsync {

    @InvocableMethod
    public static void callAsyncMethod(List<List<String>> LeadData)
    {
        
        Map<String,String> LeadList = new Map<String,String> ();
        for (List<String> lst:LeadData){
        	LeadList.put(lst[0],lst[1]);
        }
        SetLeadOwner(LeadList);
    }
    
    @future()
    public static void SetLeadOwner( Map<String,String> leadList)
    {
        List<Lead> leadstoUpdate = new List<Lead>();
        List<String> Leadids = new List<string>();
        Leadids.addAll(leadList.keySet());
        Map<Id,Lead> LeadCreators = new  Map<Id,Lead>([SELECT CreatedById FROM Lead where Id in :Leadids]);
        List<String> leadCreatorIds =  new List<String>();
       
        for(String Ids:leadList.keySet()){
			 if(leadList.get(Ids)!=null && leadList.get(Ids)!='' )
             {
                 leadstoUpdate.add(new Lead(Id=Ids,OwnerId=leadList.get(Ids)));
             }
        }
		update leadstoUpdate;
        /*List<LeadShare> ls = new List<LeadShare>();
        for (Id lc:LeadCreators.keySet()){
            ls.add(new LeadShare(LeadId=LeadCreators.get(lc).Id,UserOrGroupId=LeadCreators.get(lc).CreatedById,LeadAccessLevel='Read',RowCause='Creator'));
            //leadCreatorIds.add(LeadCreators.get(lc).CreatedById);
        }
        List<LeadShare> ls = [Select Id, LeadId,UserOrGroupId ,LeadAccessLevel, RowCause 
                              from LeadShare 
                              where LeadId in :Leadids];
		List<LeadShare> lshrnew = new List<LeadShare> ();
        for (LeadShare l:ls)
        {
            if(LeadCreators.get(l.LeadId).CreatedById == l.UserOrGroupId)
            {
                l.LeadAccessLevel='Read';
            }
            else
        }*/
        //update ls;
    }
    
    
}