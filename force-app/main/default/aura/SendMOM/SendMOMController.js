({
    doInit: function (component, event, helper) {
        try {
            var recordId = component.get('v.recordId');
            var getContactDetails = component.get('c.getDefaultEmailIds');
            getContactDetails.setParams({
                connectId: recordId
            })
            getContactDetails.setCallback(this, function (res) {
                if (res.getState() === "SUCCESS") {
                    var result =  res.getReturnValue();
                    if(result != null){
                        component.set('v.lstToEnteredEmail', result.toList.length > 0 ? result.toList : []);
                        component.set('v.lstCCEnteredEmail', result.ccList.length > 0 ? result.ccList : []);
                        component.set('v.lstBCCEnteredEmail', result.bccList.length > 0 ? result.bccList : []);
                    }
                    else{
                        alert('Add Actionable before send MoM.');
                        $A.get('e.force:closeQuickAction').fire();
                    }
                }
            })

            var getOpportunityDefaultTemplate = component.get("c.getDefaultTemplateId");
            getOpportunityDefaultTemplate.setParams({
                templateName : 'CustomerConnectMOM'
            })
            getOpportunityDefaultTemplate.setCallback(this, function (res) {
                if (res.getReturnValue()) {
                    var obj = JSON.parse(res.getReturnValue());
                    component.set("v.selItem", { objName: 'EmailTemplate', text: obj.Name, val: obj.Id });
                    var setBodyNAdSubject = component.get("c.getSubjectAndBody");
                    setBodyNAdSubject.setParams({ "TempId": component.get("v.selItem").val, "objectId": recordId, "contactId": null });
                    setBodyNAdSubject.setCallback(this, function (result) {
                        var state = result.getState();
                        if (state === "SUCCESS") {
                            var responseNew = result.getReturnValue();
                            if (responseNew.length > 0) {
                                component.set("v.EmailSubject", responseNew[0].subject);
                                component.set("v.EmailBody", responseNew[0].body);
                            }
                            console.log(responseNew[0].body);
                        }
                    });
                    $A.enqueueAction(setBodyNAdSubject);
                }
            })
            $A.enqueueAction(getContactDetails);
            $A.enqueueAction(getOpportunityDefaultTemplate);
        } catch (error) {
            console.log(error);
        }
    },

    getValueFormEvent: function (component, event, helper) {

        var getEventValue = event.getParam("templateId");
        var recordId = component.get("v.recordId");
        var contactList = component.get("v.toSelectedLookUpRecords")
        if (typeof getEventValue === "Undefined" || getEventValue === "") {
            component.set("v.EmailSubject", "");
            component.set("v.EmailBody", "");
        }
        try {
            var action = component.get("c.getSubjectAndBody");
            action.setParams({ "TempId": getEventValue, "objectId": recordId, "contactId": contactList[0].Id });
            action.setCallback(this, function (result) {
                var state = result.getState();
                if (state === "SUCCESS") {
                    var responseNew = result.getReturnValue();
                    if (responseNew.length > 0) {
                        component.set("v.EmailSubject", responseNew[0].subject);
                        component.set("v.EmailBody", responseNew[0].body);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (error) {

        }
    },

    sendMail: function (component, event, helper) {
        var lstTOEnteredEmail = component.get("v.lstToEnteredEmail");
        component.set("v.Spinner", true);
        var listOfContactEmail = component.get("v.toSelectedLookUpRecords");
        var listOfCc = component.get("v.CCselectedLookUpRecords");
        var listOfBcc = component.get("v.BCCselectedLookUpRecords");
        if ((typeof listOfContactEmail === "undefined" || listOfContactEmail.length <= 0) && (typeof lstTOEnteredEmail === "undefined" || lstTOEnteredEmail.length <= 0)) {
            alert("Please select at least one contact to send Quote");
            component.set("v.Spinner", false);
        }
        else {
            var toEmail = helper.commentLoopHelper(listOfContactEmail);
            var ccEmail = helper.commentLoopHelper(listOfCc);
            var bccEmail = helper.commentLoopHelper(listOfBcc);
            
            if (!helper.UndefineOrNullChecker(component.get("v.EmailSubject")) || !helper.UndefineOrNullChecker(component.get("v.EmailBody"))) {
                alert("Please enter Mail subject and Body");
                component.set("v.Spinner", false);
                return false;
            }
            else {
                helper.sendMailCallServerAndAttachFile(component, event, toEmail, ccEmail, bccEmail, null, component.get("v.EmailSubject"), component.get("v.EmailBody"), component.get("v.recordId"));
            }
        }
    },

    closeQuickAction: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})