({
    CheckGeoLocation: function(component, event, helper) {
        var action = component.get("c.CheckGeoLocation");        
        var recId = component.get("v.recordId");

        action.setParams({
            "recordId": recId
        });

        action.setCallback(this, function(response) {
            console.log('Response=== ',response.getReturnValue());
            if (response.getState() === 'SUCCESS' && (response.getReturnValue() != null || response.getReturnValue() != undefined)) {
                var geoLocWrap = response.getReturnValue();
                console.log('geoLocWrap=== ',geoLocWrap);
                if(geoLocWrap.isAlreadyCaptured == false){
                    helper.fetchGeoLocation(component, event, helper);
                }else{
                    helper.showToast(component, event, 'Info', $A.get("$Label.c.Check_In_Already"));                                                 
                }
            } else {
                helper.showToast(component, event, 'Error' ,$A.get("$Label.c.Check_In_Error")+' : ' + response.responseText);                
            }
        });

        $A.enqueueAction(action);
    },

    fetchGeoLocation: function(component, event, helper) {
        var geoObj = {};
        var errorReason = "";
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                //success handler
                function(position) {
                geoObj.latitude = position.coords.latitude;
                geoObj.longitude = position.coords.longitude;
                console.log('location is captured.');
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info",
                    "type": "Info",
                    "message": "Saving location"
                });
                toastEvent.fire();*/
                helper.updateGeoLocation(component, event, helper, geoObj);
            	}, 
                //error handler
                function(error) {
                switch (error.code) {
                    case error.PERMISSION_DENIED:
                        console.log("User denied the request for Geolocation.");
                        errorReason = $A.get("$Label.c.Check_In_Permission_Denied");
                        break;
                    case error.POSITION_UNAVAILABLE:
                        console.log("Location information is unavailable.");
                        errorReason = $A.get("$Label.c.Check_In_Position_Unavailable");
                        break;
                    case error.TIMEOUT:
                        console.log("Unable to capture Geolocation. Please ensure location services are turned on.");
                        errorReason = $A.get("$Label.c.Check_In_Timeout");
                        break;
                    case error.UNKNOWN_ERROR:
                        console.log("An unknown error occurred.");
                        errorReason = $A.get("$Label.c.Check_In_Unknown_Error");
                        break;
                }
                helper.showToast(component, event, 'Error', errorReason);
            },
            //set timeout
            {timeout:3000}
            );
        } else {
            errorReason = $A.get("$Label.c.Check_In_Not_Supported");
            helper.showToast(component, event, 'Error', errorReason);
        }
    },

    updateGeoLocation: function(component, event, helper, geoObj) {
        var action = component.get("c.UpdateCheckInLocation");
        var recId = component.get("v.recordId");
        //action.setAbortable();
        action.setParams({
            "recordId": recId,
            "latitude": geoObj.latitude,
            "longitude": geoObj.longitude
        });
        
        action.setCallback(this, function(response) {            
            var wrapReponse = response.getReturnValue();
            console.log('Response......', wrapReponse);
            if (response.getState() === 'SUCCESS' &&  response.getReturnValue() != null) {
                if(wrapReponse.isSuccess == true){
                    helper.showToast(component, event, 'Success', wrapReponse.message);                    
                }else if(wrapReponse.isSuccess == false){
                    helper.showToast(component, event, 'Error', wrapReponse.message);
                }
                 
                $A.get('e.force:refreshView').fire();
               
            } else {
                helper.showToast(component, event, 'Error' ,$A.get("$Label.c.Check_In_Error ")+ ' : '+ response.responseText);  
                
            }
        });
		console.log('Waiting for Update response........');
        $A.enqueueAction(action);

        //Variable update to execute Enqueue Actions
        component.set("v.forceUpdate", true);  
        component.set("v.currentStatus","Performing CheckIn....");
    },

    showToast: function(component, event, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": title,
            "message": message
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})