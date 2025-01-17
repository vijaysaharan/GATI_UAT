trigger OrgMaster on User (after update,after insert)
{
   /* map<id,string> us= new map<id,string> ();
    for(User u : trigger.new)
    {
        
        user oldu = trigger.oldMap.get(u.id);    //Get Old Values
        
        
        if(oldu.Organi__c != u.Organi__c)        //Check if value is updated
        {
            
            us.put(u.id,u.organi__c);
        }
            
        
        
    } */
    if(trigger.isafter && trigger.isupdate)
    {
        OrgMasterUser.bypassOrgMasterTrigger = true;
        OrgMasterUser.comparision(trigger.new, trigger.oldMap);
        OrgMasterUser.bypassOrgMasterTrigger = false;
    }
    map<id,string> us= new map<id,string> ();

    if(trigger.isafter && trigger.isinsert)
    {
        for(user u:trigger.new)
        {
            if(u.Organi__c!= null)
            {
               us.put(u.id,u.Organi__c); 
            }
        }
        OrgMasterUser.bypassOrgMasterTrigger = true;
        OrgMasterUser.comparision(us);
        OrgMasterUser.bypassOrgMasterTrigger = false;
        
    }
}