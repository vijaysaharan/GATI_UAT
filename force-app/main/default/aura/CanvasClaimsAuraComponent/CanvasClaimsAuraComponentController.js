({
	doInit : function(cmp, evt, helper) {
        if (cmp.get("v.callServer")==true)
        {
             helper.CallServer(cmp,event,helper);
            //setTimeout(function(){ cmp.set("v.serverCallSuccess",true); }, 2000);
        }
        else
        {
            var requid = cmp.get("v.requid");
            var authorization= cmp.get("v.authorization");
            var puser = cmp.get("v.puser");
            var action= cmp.get("v.action");
            action = (typeof action === 'undefined') ? null : action;
            var cid= cmp.get("v.cid");
            cid = (typeof cid === 'undefined') ? null : cid;
            var p1= cmp.get("v.p1");
            p1 = (typeof p1 === 'undefined') ? null : p1;
            var p2= cmp.get("v.p2");
            p2 = (typeof p2 === 'undefined') ? null : p2;
            var p3= cmp.get("v.p3");
            p3 = (typeof p3 === 'undefined') ? null : p3;
           cmp.set("v.canvasParameters", 
                   JSON.stringify({"requid":requid,
                                   "authorization":authorization,
                                   "puser":puser,
                                   "action":action,
                                   "cid":cid,
                                   "p1":p1,
                                   "p2":p2,
                                   "p3":p3}));
        }

	},
    refresh : function(cmp, evt, helper) {
        debugger;
		//this.rerender();
    }
})