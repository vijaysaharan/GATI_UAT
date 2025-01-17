public class GatiMDMInvocable {
	@InvocableMethod(label='MDM Actions' description='This action can perform tasks related to MDM module.')
    public static List<GatiMDMUtil.ActionOutput> convertJSONToRecordCollection(List<GatiMDMUtil.ActionInput> input) {
        String action = input[0].action;
        Switch on action {
            when 'Convert-Creation-Response' {
                return GatiMDMUtil.convertCreationResponse(input[0].jsonString);
            }
            when 'Approval-Request' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.sendApprovalRequest(input[0]);
                List<GatiMDMUtil.ActionOutput> outputs = new List<GatiMDMUtil.ActionOutput>();
                outputs.add(output);
                return outputs;
            }
            when 'CS-Update' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.sendCsRequest(input[0]);
                List<GatiMDMUtil.ActionOutput> outputs = new List<GatiMDMUtil.ActionOutput>();
                outputs.add(output);
                return outputs;
            }
            when 'Sub-Code-Creation' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.sendSubCodeCreationRequest(input[0]);
                List<GatiMDMUtil.ActionOutput> outputs = new List<GatiMDMUtil.ActionOutput>();
                outputs.add(output);
                return outputs;
            }
            when 'Create-LOF-Account' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.sendLOFCreateWithAccount(input[0].account, input[0].authorizationHeader, input[0].quoteData);
                return new List<GatiMDMUtil.ActionOutput>{output};
            }
            when 'Update-CON-Account' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.sendCONUpdatedAccount(input[0].account, input[0].authorizationHeader, input[0].quoteData);
                return new List<GatiMDMUtil.ActionOutput>{output};
            }
            when 'Delete-CS-Mapping' {
                GatiMDMUtil.ActionOutput output = GatiMDMIntegration.deleteServiceResourceFromMDM(input[0]);
                return new List<GatiMDMUtil.ActionOutput>{output};
            }
            when else {
                return null;
            }
        }
    }   
}