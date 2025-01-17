global class LeadApexBodyUtility {
	@InvocableMethod(label='Get Body String')
    public static List<String> getStringFromRequestBody(List<requestBodyJSON> request){
        return new List<String>{JSON.serialize(request[0].requestBody)};
    }
    
    global class requestBodyJSON {
        @InvocableVariable global requestBodyWrapper requestBody;
    }
}