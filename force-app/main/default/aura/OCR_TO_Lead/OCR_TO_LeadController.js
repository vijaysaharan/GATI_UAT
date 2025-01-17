({
        getChildValues : function(component, event, helper) {
             var message = event.getParam("Values");
            component.set("v.datas",message.data)
            console.log("child+ "+JSON.stringify(message.data));
            console.log("data"+ JSON.stringify(message.record));
            let s={};
            s.LastName=message.record.LastName;
            s.Company=message.record.Company;
                s.Phone=message.record.Phone;
                s.Email=message.record.Email;
                s.Street=message.record.Street;
            s.PostalCode=message.record.PostalCode;
            
    component.set("v.leadFields",s);        
            component.set("v.disable",false);
        },
        handleSaveRecord:function(component,event,helper)
        {
            //alert("here");
            let message=component.get("v.leadFields");
    let s=component.get("v.leadFieldss");
        //    console.log('HEre2'+JSON.stringify(s));
          //  console.log('here3'+JSON.stringify(message))
              s.LastName=message.LastName;
            s.Company=message.Company;
                s.Phone=message.Phone;
                s.Email=message.Email;
                s.Street=message.Street;
            s.PostalCode=message.PostalCode;
              //console.log('line 31')
           if(helper.validateContactForm(component))
            {
                //console.log("here2")
                helper.saveRecord(component,event,helper);
            }
            else
            {
                alert('Please resolve all errors');
                return;
            }
          //  console.log(here);
        }
        ,
          init: function (cmp, event, helper) {
              let s={};
              s.LeadSource='OCR';
              cmp.set("v.leadFields",s);
               cmp.set('v.columns', [
                {label: 'Tag  Name', fieldName: 'response', type: 'text'},
                {label: 'data', fieldName: 'result', type: 'text'},
               
            ]);
                   
        cmp.find("forceRecord").getNewRecord(
        "Lead",
        null,
        false,
        $A.getCallback(function() {
            var rec = cmp.get("v.leadFields");
            var recordobj=cmp.get("v.leadRecord");
            cmp.set("v.leadFieldss.LeadSource","OCR")
            var error = cmp.get("v.leadError");
            if (error || (rec === null)) {
                console.log("Error initializing record template: " + error);
                return;
            }
        
            cmp.set("v.loaded",true);
        }));
    }
    })