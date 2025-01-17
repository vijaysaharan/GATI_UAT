public without sharing class RoundRobinAssigner {
	public static void assign(list<RoundRobinAssignment> rras, boolean isUpdate) {
        Map<String,List<GroupMember>> nameToMembersMap = New Map<String,List<GroupMember>>();
        List<RoundRobin__c> RRSettings = [select id, GroupName__c, FieldName__c, Object__c, IndexOfLastUsed__c from RoundRobin__c];
        List<GroupMember> groupNameToMember = [SELECT Group.Name, Group.DeveloperName, GroupId, UserOrGroupId 
                                               FROM GroupMember
                                               WHERE Group.Name != null
                                              ];
        if(groupNameToMember != null && groupNameToMember.size()>0){
            for(GroupMember gm : groupNameToMember){
                if(nameToMembersMap.containsKey(gm.Group.DeveloperName)){
                    nameToMembersMap.get(gm.Group.DeveloperName).add(gm);
                }else{
                    nameToMembersMap.put(gm.Group.DeveloperName,new List<GroupMember>{gm});
                }
            }
        }
        Set<Id> recordIds = New Set<Id>();
        Map<String, List<GroupMember>> usersByGroup = New Map<String, List<GroupMember>>();
        List<SObject> objectList = new List<SObject>();
        for (RoundRobinAssignment rra:rras){
            List<groupMember> groupUsers = New List<groupMember>();
            if (rra.fieldName == null){
                rra.fieldName = 'OwnerId';
            }
            
            if (usersByGroup.get(rra.groupName) == null){
                usersByGroup.put(rra.groupName, nameToMembersMap.get(rra.groupName));
                groupUsers = nameToMembersMap.get(rra.groupName);
            } 
            else {
                groupUsers = usersByGroup.get(rra.groupName);
            }
            
			String Obj = rra.recordId.Id.getSObjectType().getDescribe().getName();
            RoundRobin__c matchingRR = recordMatcher(RRSettings, rra.fieldName, Obj, rra.groupName);
            
            Integer nextIndex = getNextIndex(matchingRR, groupUsers);
            rra.recordId.put(rra.fieldName, groupUsers[nextIndex].UserOrGroupId);
            objectList.add(rra.recordId);
            matchingRR.IndexOfLastUsed__c = nextIndex;
            boolean isNew = true;
            for (RoundRobin__c rr: RRSettings){
                if (rr.Id == matchingRR.Id){
                    rr.IndexOfLastUsed__c = matchingRR.IndexOfLastUsed__c;
                    isNew = false;
                }
            }
            if (isNew){
                RRSettings.add(matchingRR);
            }
		}
        update RRSettings;
        if(objectList != null && objectList.size()>0 && isUpdate){
            try{
             	Database.update(objectList, false);   
            }catch(Exception e){}
        }
	}

    public static integer getNextIndex(RoundRobin__c match, list<GroupMember> groupUsers){
        if (match.IndexOfLastUsed__c == null){
            return 0;
        } else if (match.IndexOfLastUsed__c >= groupUsers.size()-1){
            system.debug(match.IndexOfLastUsed__c + ' is the last match, which is >= the group size of ' + groupUsers.size() + 'so we are going back to 0' );
            return 0;
        } else {
            return integer.valueOf(match.IndexOfLastUsed__c + 1);
        }
    }

    public static RoundRobin__c recordMatcher(list<RoundRobin__c> records, string FieldName, string Obj, string GroupName){
        for (RoundRobin__c rr:records){
            if (rr.FieldName__c == FieldName && rr.Object__c == Obj && rr.GroupName__c == GroupName){
                return rr;
            }
        }
        RoundRobin__c rrNew = new RoundRobin__c();
        rrNew.FieldName__c = FieldName;
        rrNew.Object__c = Obj;
        rrNew.GroupName__c = GroupName;
        rrNew.Name = Obj + '-' + FieldName + '-' + GroupName;
        insert rrNew;
        return rrNew;
    }

	public class RoundRobinAssignment {
		public string groupName;
		public SObject recordId;
		public string fieldName;
	}
}