public class CloseDuplicateCasesInvocable {
	@InvocableMethod(label='Close Duplicate Cases')
    public static void closeStatusDuplicateCases(List<Case> caseRecord){
        Set<String> suppliedEmails = new Set<String>();
        Set<String> subjects = new Set<String>();
        List<Case> caseToUpdate = new List<Case>();
        for(Case cs : caseRecord){
            if(cs.Subject != null){
                subjects.add(cs.Subject);
            }
            if(cs.SuppliedEmail != null){
                suppliedEmails.add(cs.SuppliedEmail);
            }
        }
        List<Case> duplicateRecords = [SELECT Id, Status,CaseNumber,OwnerId,Subject FROM Case 
                                       WHERE SuppliedEmail IN: suppliedEmails
                                       AND Subject IN: subjects
                                       AND RecordTypeId =: caseRecord[0].RecordTypeId
                                       AND CreatedDate <: (caseRecord[0].CreatedDate.addMinutes(1)) 
                                       AND CreatedDate >: (caseRecord[0].CreatedDate.addMinutes(-1))
                                       AND Status != 'Closed'
                                       FOR UPDATE
                                      ];
        
        List<Group> archiveGroup = [SELECT Id,DeveloperName 
                                    FROM Group 
                                    WHERE DeveloperName = 'Archive'
                                   ];
        
        if(duplicateRecords != null && duplicateRecords.size()>0){
            Map<String, String> subjectToCaseNumber = new Map<String, String>();
            String lastCreatedCaseNumber = null;
            for(Case cs : duplicateRecords){
                if(subjectToCaseNumber.containsKey(cs.Subject) && subjectToCaseNumber.get(cs.Subject) < cs.CaseNumber){
                    subjectToCaseNumber.put(cs.Subject, cs.CaseNumber);
                }
                else if(!subjectToCaseNumber.containsKey(cs.Subject)){
                   subjectToCaseNumber.put(cs.Subject, cs.CaseNumber); 
                }                
            }
            for(Case cs : duplicateRecords){
                if(subjectToCaseNumber.containsKey(cs.Subject) && cs.CaseNumber != subjectToCaseNumber.get(cs.Subject)){
					cs.Status = 'Closed';
                    if(archiveGroup != null && archiveGroup.size() > 0){
                        cs.OwnerId = archiveGroup[0].Id;
                    }
                    caseToUpdate.add(cs);
                }
            }
        }
        
        if(caseToUpdate != null && caseToUpdate.size()>0){
            update caseToUpdate;
        }
    }
}