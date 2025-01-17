public class CountAttachedFiles {
    public static map<id,integer> CountFiles(set<id> EntityIds,set<id> deleteddocuments){
        aggregateresult[] dcs = [Select LinkedEntityid, count(id)dcount from ContentDocumentLink where isDeleted=false and contentdocument.isdeleted = false                                       and LinkedEntityid in :EntityIds                                			 and contentdocumentid not in :deleteddocuments                                             group by LinkedEntityid];
        map<id,integer> filecountmap = new map<id,integer>();
        for(aggregateresult dc: dcs){
            id leid = string.valueof(dc.get('LinkedEntityid'));
            integer dcount = integer.valueof(dc.get('dcount'));
            filecountmap.put(leid,dcount);
        }
        
        for(id eid: entityids){
            if(!filecountmap.containskey(eid)){
                filecountmap.put(eid,0);
            }
        }
        
        return filecountmap;
        
    }
}