public with sharing class CaseCountInvocable {
    
    @InvocableMethod(label='Query Case Count' description='Returns the count of cases from a GraphQL query')
    public static List<Integer> queryCaseCount() {
        List<Integer> caseCounts = new List<Integer>();
        
        // Define the GraphQL query
        String graphQLQuery = 'query CaseCount { ' +
                                  'uiapi { ' +
                                      'aggregate { ' +
                                          'Integration_Log__c { ' +
                                              'edges { ' +
                                                  'node { ' +
                                                      'aggregate { ' +
                                                          'Id { count { value } } ' +
                                                      '} ' +
                                                  '} ' +
                                              '} ' +
                                          '} ' +
                                      '} ' +
                                  '} ' +
                              '}';
        
        // Assuming you have logic to execute the GraphQL query and receive the response
        // Replace the below placeholder with your actual GraphQL execution logic
        
        // Mocking the response for demonstration purpose
        Map<String, Object> graphQLResponse = new Map<String, Object>{
            'data' => new Map<String, Object>{
                'uiapi' => new Map<String, Object>{
                    'aggregate' => new Map<String, Object>{
                        'Integration_Log__c' => new Map<String, Object>{
                            'edges' => new List<Object>{
                                new Map<String, Object>{
                                    'node' => new Map<String, Object>{
                                        'aggregate' => new Map<String, Object>{
                                            'Id' => new Map<String, Object>{
                                                'count' => new Map<String, Object>{
                                                    'value' => 100 // Sample count value
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        };
        
        // Parse the response to extract the count value
        Integer count = Integer.valueOf((String)graphQLResponse.get('data.uiapi.aggregate.Integration_Log__c.edges[0].node.aggregate.Id.count.value'));
        
        // Add the count value to the list
        caseCounts.add(count);
        
        // Return the list of counts
        return caseCounts;
    }
}