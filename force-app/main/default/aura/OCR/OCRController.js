({
	myAction : function(component, event, helper) {
		
	},
    handleUploadFinished: function (component, event,helper) {
        
        var uploadedFiles = event.getParam("files");
       console.log(JSON.stringify(uploadedFiles));
        component.set("v.filename",uploadedFiles[0].name);
        component.set("v.cardDetails",uploadedFiles[0].documentId.substring(0, 15) )
        
helper.helperMethod(component,event,helper,uploadedFiles[0].contentVersionId,uploadedFiles[0].documentId);
     
    }
})