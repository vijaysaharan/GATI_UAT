({
    commentLoopHelper: function (lstOfSelectedObject) {
        var listOfEmail = [];
        if (lstOfSelectedObject && lstOfSelectedObject.length > 0) {
            for (var i = 0; i < lstOfSelectedObject.length; i++) {
                console.log(lstOfSelectedObject[i].Email);
                listOfEmail.push(lstOfSelectedObject[i].Email);
            }
        }
        return listOfEmail;
    },
    
    sendMailCallServerAndAttachFile: function (component, event, toAddress, ccAddress, bccAddress, FilesData, Subject, Body, RecordId) {
        console.log(RecordId);
        console.log(FilesData);
        var lstTOEnteredEmail = component.get("v.lstToEnteredEmail");
        var lstCCEnteredEmail = component.get("v.lstCCEnteredEmail");
        var lstBCCEnteredEmail = component.get("v.lstBCCEnteredEmail");
        var action = component.get("c.sendMailToSelectedContact");
        action.setParams({
            "toAddress": toAddress,
            "ccAddress": ccAddress,
            "bccAddress": bccAddress,
            "fileData": FilesData,
            "subject": Subject,
            "body": Body,
            "recordId": RecordId,
            "lstTOEnteredEmail": lstTOEnteredEmail,
            "lstCCEnteredEmail": lstCCEnteredEmail,
            "lstBCCEnteredEmail": lstBCCEnteredEmail,
            "binaryExcel" : component.find("xlsx").getGeneratedExcel()
            //"binaryExcel" : null
        });
        action.setCallback(this, function (result) {
			console.log('result.getState()',result.getState());
            if (result.getState() === "SUCCESS") {
                var toastEvent = $A.get('e.force:showToast');
                if (toastEvent) {
                    toastEvent.setParams({
                        "type": "success",
                        "message": "MOM send successfully!"
                    });
                    toastEvent.fire();


                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": RecordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();

                }
                else {
                    alert('MoM Sent!');
                }
                component.set("v.Spinner", false);
                $A.get('e.force:closeQuickAction').fire();
            }
            else {
                component.set("v.Spinner", false);
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    "type": "success",
                    "message": "There is some error sending the sending mail."
                });
                toastEvent.fire();

            }
        });
        $A.enqueueAction(action);
    },
    
    UndefineOrNullChecker: function (CheckData) {
        var returnValue = false;
        if (typeof CheckData !== "undefined" && CheckData != null && CheckData !== "" && CheckData.length > 0) {
            returnValue = true;
        }
        return returnValue;
    },
})