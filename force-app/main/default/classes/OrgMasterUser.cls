public class OrgMasterUser {
    public static Boolean bypassOrgMasterTrigger = false;
    @future
    public static void comparision(map<id,string> us)
    {
        if (!bypassOrgMasterTrigger) {
            try     
            { 
                list<Org_Master_User__c> org= new list<Org_Master_User__c>();
                map<string,id> ou= new map<string,id>();
                list<Organization_Master__c> orgMasterObj=[Select id,Name,REF_Code__c from organization_Master__c where ref_code__c in :us.values()];
                for(Organization_Master__c om:orgMasterObj)
                {
                    ou.put(om.REF_Code__c,om.id);
                }
                //  System.debug(ou);
                // System.debug(us);
                
                for(id i:us.keyset())
                {
                    if(ou.containskey(us.get(i)))
                    {
                        Org_Master_User__c masteruser= new Org_Master_User__c();
                        masteruser.User__c=i;
                        masteruser.Organization_Unit__c=ou.get(us.get(i));
                        org.add(masteruser);
                    }
                }
                if(org.size()>0)
                {
                    insert org;
                }
                
            }
            Catch(Exception e){
                system.debug(e.getMessage());
                
            }
        }
    }
    public static void comparision(List<User> userList, Map<Id, User> oldMap){
        
        map<id,string> us= new map<id,string> ();
        if (!bypassOrgMasterTrigger) {
            for(User u : UserList)
            {
                
                user oldu = oldMap.get(u.id);    //Get Old Values
                
                
                if(oldu.Organi__c != u.Organi__c)        //Check if value is updated
                {
                    
                    us.put(u.id,u.Organi__c);
                }
                
            } 
            OrgMasterUser.myfuture(us); 
        }
    }
    
    @future
    public static void myfuture(map<id,string> us)
    {   
        if (!bypassOrgMasterTrigger) {
            try     
            { 
                map<string,id> ou= new map<string,id>();
                list<Organization_Master__c> orgMasterObj=[Select id,Name,ref_code__c from organization_Master__c where ref_code__c in :us.values()];
                for(Organization_Master__c om:orgMasterObj)
                {
                    ou.put(om.ref_code__c,om.id);
                }
                System.debug(ou);
                system.debug(us);
                
                
                
                list<Org_Master_User__c>  orgUserobj=[Select Organization_Unit__c,User__c from Org_Master_User__c where User__c=:us.keyset()];
                
                for(Org_Master_User__C omu:orgUserobj )
                {
                    omu.Organization_Unit__c=ou.get(us.get(omu.User__c));
                    // system.debug(omu.User__c);
                }    
                
                Update orgUserobj;
            }
            Catch(Exception e){
                system.debug(e.getMessage()+' '+e.getLineNumber()+' '+e.getCause());
                
            }
        }
    }
}