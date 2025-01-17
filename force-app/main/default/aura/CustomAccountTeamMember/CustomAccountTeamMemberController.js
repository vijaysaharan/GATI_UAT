({  
    doInit : function (component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
     // alert('test');
     component.set("v.showcard", false);
    },
     // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    CreateRecord: function (component, event, helper) {
        component.set("v.spinner",true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //alert(file);
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) { 
                //console.log("EVT FN");
                var csv = evt.target.result;
                //console.log('csv file contains'+ csv);
                var result = helper.CSV2JSON(component,csv);
                helper.CreateAccount(component,result);
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }
        
    },
    
    showfiledata :  function (component, event, helper){        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
            component.set("v.showcard", true);
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                var rows = csv.split("\n");
                for (var i = 0; i < rows.length; i++) {
                    var cells = rows[i].split(",");
                    if (cells.length > 1) {
                        var row = table.insertRow(-1);
                        for (var j = 0; j < cells.length; j++) {
                            var cell = row.insertCell(-1);
                            cell.innerHTML = cells[j];
                        }
                    }
                }
                var divCSV = document.getElementById("divCSV");
                divCSV.innerHTML = "";
                divCSV.appendChild(table);
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }
    },  
    download : function (component, event, helper){
        var baseUrl = 'https://' + location.host; 
        var profUrl = $A.get('$Resource.BulkAccountTeamMember');
         window.open(baseUrl + profUrl);
    }
    
})