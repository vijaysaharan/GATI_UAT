public class ChatWindowNameController {
    @AuraEnabled
    public static String getContactInfo(String recordId){
        List<LiveChatTranscript> tcList = [select ContactId from LiveChatTranscript where id =: recordId];
        List<Contact> clist = [select id, name from Contact where id =:tcList[0].ContactId];
        return clist[0].Name;
    }
}