public class ContactTiggerHelper {
    
    public static void duplicateContact(List<Contact> newContacts) {
        try {
            Set<String> phoneSet = new Set<String>();
            
            for (Contact con : newContacts) {
                phoneSet.add(con.MobilePhone);
            }
            
            List<Contact> existingContacts = [SELECT MobilePhone FROM Contact WHERE MobilePhone IN :phoneSet];
            
            for (Contact con : newContacts) {
                if (existingContacts.size() > 0) {
                    con.MobilePhone.addError('Duplicate Contact Found. Use Existing Contact.');
                }
            }
        } catch (Exception e) {
            // Handle the exception here
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
}