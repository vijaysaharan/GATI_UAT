({
    CSV2JSON: function (component,csv) {
        //  console.log('Incoming csv = ' + csv);
        
        //var array = [];
        var arr = []; 
        
        arr =  csv.split('\n');
        //console.log('Array  = '+array);
        // console.log('arr = '+arr);
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                //console.log('obj headers = ' + obj[headers[j].trim()]);
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        //console.log('json = '+ json);
        return json;
        
        
    },
    
    CreateAccount : function (component,jsonstr){
        // console.log('jsonstr' + jsonstr);
        var action = component.get('c.insertData');
        //  alert('Server Action' + action);    
        action.setParams({
            strfromle : jsonstr
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {  
                var result=response.getReturnValue();
                alert("Case Inserted Succesfully");
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                    //alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
})