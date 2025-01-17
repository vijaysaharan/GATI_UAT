public with sharing class QuoteTriggerHandler {
    public static void quoteCreationValidation(List<Quote> newQuoteList) {
        Set<Id> opportunityIds = new Set<Id>();
        if (newQuoteList != null && newQuoteList.size() > 0) {
            for (Quote q : newQuoteList) {
                if (q.OpportunityId != null)
                    opportunityIds.add(q.OpportunityId);
            }
        }
        
        if (opportunityIds != null && opportunityIds.size() > 0){
            Map<Id,Opportunity> quotesOpportunities = new Map<Id,Opportunity>([SELECT Account.Customer_Category__c,PAN_Card_Document__c,
                                                                               GSTIN_Documents__c
                                                                               FROM Opportunity
                                                                               WHERE ID IN: opportunityIds
                                                                              ]);
            
            if (quotesOpportunities != null && !quotesOpportunities.isEmpty()) {
                List<ContentDocumentLink> docUnderOpprtunity = [SELECT ContentDocument.Title, LinkedEntityId 
                                                                FROM ContentDocumentLink  
                                                                WHERE LinkedEntityId IN : quotesOpportunities.keySet()
                                                                AND (ContentDocument.Title Like '%PAN%'
                                                                     OR ContentDocument.Title Like '%GSTIN%')
                                                               ];
                
                Set<Id> opportunityWithPAN = new Set<Id>();
                Set<Id> opportunityWithGSTIN = new Set<Id>();
                
                if (docUnderOpprtunity != null && docUnderOpprtunity.size() > 0) {
                    for (ContentDocumentLink cv : docUnderOpprtunity) {
                        if ( cv.ContentDocument.Title.containsIgnoreCase('PAN') ) {
                            opportunityWithPAN.add(cv.LinkedEntityId);
                        }
                        
                        if ( cv.ContentDocument.Title.containsIgnoreCase('GSTIN') ) {
                            opportunityWithGSTIN.add(cv.LinkedEntityId);
                        }
                    }
                }
                
                for (Quote q : newQuoteList) {
                    if ( quotesOpportunities.get(q.OpportunityId)?.Account?.Customer_Category__c == 'Retail' 
                        && !((quotesOpportunities.get(q.OpportunityId)?.GSTIN_Documents__c && opportunityWithGSTIN.contains(q.OpportunityId)) 
                             || (quotesOpportunities.get(q.OpportunityId)?.PAN_Card_Document__c && opportunityWithPAN.contains(q.OpportunityId)))
                       ) {
                           q.addError('PAN or GST (KYC) details upload is mandatory to generate the Quote');
                       }
                }
            }
        }
    }
}