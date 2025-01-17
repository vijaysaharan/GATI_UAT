import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_TYPE from '@salesforce/schema/Sales_KRA__c.Account_Type__c';
import ZONE from '@salesforce/schema/Sales_KRA__c.Zone__c';
import PRODUCT from '@salesforce/schema/Sales_KRA__c.Product__c';
import MONTH from '@salesforce/schema/Sales_KRA__c.Month__c';
import getRoleSubordinateUsers from '@salesforce/apex/RoleHierarchyUtility.getRoleSubordinateUsers';
import userId from '@salesforce/user/Id';

export default class SalesDashboardParent extends LightningElement {
    userAllData = [];
    selectedSalesperson = userId;
    
    zoneMapping = {
    'BOMZ' : 'West',
    'CCUZ' : 'East',
    'BLRZ' : 'South',
    'DELZ' : 'North',
    'ALL'  : 'ALL'
    };
    matchingInfo = {
        primaryField: { fieldPath: "Name" }
    };
    displayInfo = {
        additionalFields: ["Name"],
    };
    filter = {
        criteria: [
            {
                fieldPath: "Id",
                operator: "in",
                value: [userId],
            }
        ],
    };
    
    @track userOptions = [];
    @track zoneList = [];
    @track accountTypes = [];
    @track productList = [];
    @track monthList = [];
    @track filterUserList = [];
    @track dateList = {
        'currentMonthStart' :   null, 
        'currentMonthEnd' : null, 
        'lastMonthStart' :  null, 
        'lastMonthEnd' :    null, 
        'lastMonthStartTill' :  null, 
        'lastMonthEndTill' :    null, 
        'currentYearStart' :    null, 
        'currentYearEnd' :  null, 
        'salesKraStart' :   null, 
        'salesKraEnd' : null, 
        'selectedMonth' : null,
        'userOptionSelected' : [],
        'zoneOptionSelected' : [],
        'accountTypesSelected' : [],
        'productListSelected' : []
    };

    get isSearchDisable(){
        return (this.selectedSalesperson != null && this.selectedSalesperson != '' && this.dateList.userOptionSelected.length > 0) ? false : true;
    }
    get isSalesperson(){
        return this.userAllData.length > 0 ? true : false;
    }
    get isUserList(){
        return this.userOptions.length > 0 ? true : false;
    }
    get isZoneList(){
        return this.zoneList.length > 0 ? true : false;
    }
    get isAccountTypes(){
        return this.accountTypes.length > 0 ? true : false;
    }
    get isProducts(){
        return this.productList.length > 0 ? true : false;
    }
    get isMonths(){
        return this.monthList.length > 0 ? true : false;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ACCOUNT_TYPE })
    getAccountType({ data, error }) {
        if (data) {
            let temp = [({label : 'All', value : 'ALL'}), ...data.values ];
            temp.forEach(ele => {
                this.accountTypes.push({label : ele.label, value : ele.value, selected : true});
                if(ele.value != 'ALL'){
                  this.dateList.accountTypesSelected.push(ele.value);
                }
            });
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ZONE })
    getZones({ data, error }) {
        if (data) {
            let temp = [({label : 'All', value : 'ALL'}), ...data.values ];
            temp.forEach(ele => {
                this.zoneList.push({label : ele.label, value : ele.value, selected : true});
                //if(ele.value != 'ALL'){
                  this.dateList.zoneOptionSelected.push(ele.value);
                //}
            });
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: PRODUCT })
    getProducts({ data, error }) {
        if (data) {
            let temp = [({label : 'All', value : 'ALL'}), ...data.values ];
            temp.forEach(ele => {
                this.productList.push({label : ele.label, value : ele.value, selected : true});
                if(ele.value != 'ALL'){
                  this.dateList.productListSelected.push(ele.value);
                }
            });
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MONTH })
    getMonths({ data, error }) {
        if (data) {
            let temp = [...data.values ];
            temp.forEach(ele => {
                this.monthList.push({label : ele.label, value : ele.value, selected : true});
            });
        }
    }
    
    connectedCallback(){
        const today = new Date();
        this.dateList.selectedMonth = ((new Date()).getMonth() + 1).toString();
        var range = this.getMonthChangeRange(this.dateList.selectedMonth);
        this.dateList.salesKraEnd = range.endDate;
        this.dateList.salesKraStart = range.startDate;
        var monthRange = this.getDateRange('M',today);
        var yearRange = this.getDateRange('Y',today);
        var lastMonth = this.getDateRange('LM',today);
        var lastMonthTill = this.getDateRange('LMTD',today);

        this.dateList.currentMonthStart = monthRange['start'];
        this.dateList.currentMonthEnd = monthRange['end'];
        this.dateList.currentYearStart = yearRange['start'];
        this.dateList.currentYearEnd = yearRange['end'];
        this.dateList.lastMonthStart = lastMonth['start'];
        this.dateList.lastMonthEnd = lastMonth['end'];
        this.dateList.lastMonthStartTill = lastMonthTill['start'];
        this.dateList.lastMonthEndTill = lastMonthTill['end'];
        var zonesForUser = [];

        Object.keys(this.zoneMapping).forEach(key => {
            zonesForUser.push(this.zoneMapping[key]);
        });
        if(zonesForUser.length > 0){
            getRoleSubordinateUsers({userId : userId, zoneList : zonesForUser, isSalesDashBoard : true, isSalesDashboardUser : true}).then(users => {
                this.userAllData = JSON.parse(JSON.stringify(users));
                this.userAllData.forEach(elm => {
                    this.filterUserList.push(elm.Id);
                });
                this.filter.criteria[0].value = this.filterUserList;
            }).catch(error => {
                this.toastMessageDispatch('Role Query Exception!',error?.body?.message,'error');
            });
            this.getUserSalesTeam(zonesForUser);
        }
    }

    handleSalespersonChange(event) {
        this.selectedSalesperson = event.detail.recordId;
        this.userOptions = [];
        this.dateList.userOptionSelected = [];
        if(this.selectedSalesperson){
            var zoneToUser = [];
            this.dateList.zoneOptionSelected.forEach(el => {
                //if(el != 'ALL' && el !=''){
                    zoneToUser.push(this.zoneMapping[el]);
                //}
            });
            this.getUserSalesTeam(zoneToUser);
        }
    }
    
    getUserList(){
        this.filterUserList = [];
        var zoneToUser = [];
        this.dateList.zoneOptionSelected.forEach(el => {
            if(el != 'ALL' && el !=''){
                zoneToUser.push(this.zoneMapping[el]);
            }
        });
        this.userAllData.forEach(ele => {
            if(zoneToUser.includes(ele)){
                this.filterUserList.push(ele.Id);
            }
        });
        this.filter.criteria[0].value = this.filterUserList;
    }

    getUserSalesTeam(zones){
        this.userOptions = [];
        this.dateList.userOptionSelected = [];
        if(zones.length > 0){
            getRoleSubordinateUsers({userId : this.selectedSalesperson, zoneList : zones, isSalesDashBoard : true, isSalesDashboardUser : false}).then(users => {
                this.userOptions.push({'label' : 'All', 'value' : 'ALL', 'selected' : true});
                users.forEach(elm => {
                    let key = elm.Id;
                    let value = elm.Name + ((elm?.IsActive)  ? ' (Active)' : ' (Inactive)');
                    this.userOptions.push({'label' : value, 'value' : key, 'selected' : true});
                    this.dateList.userOptionSelected.push(key);
                });
                console.log('this.dateList.userOptionSelected ',JSON.stringify(this.dateList.userOptionSelected, null, 2));
            }).catch(error => {
                this.toastMessageDispatch('Role Query Exception!',error?.body?.message,'error');
            });
        }
    }

    toastMessageDispatch(title,message,vari){
        const toastMessage = new ShowToastEvent({
            title: title,
            message: message ,
            variant: vari,
            mode: 'dismissable'
        });
        this.dispatchEvent(toastMessage);
    }

    getDateRange(conString,today) {
        let startDate, endDate;

        if (conString == 'M') {
            startDate = new Date(today.getFullYear(), today.getMonth(), 1);
            endDate = today;
        } 
        else if (conString == 'Y') {
            startDate = today.getMonth() < 3 ? new Date(today.getFullYear() - 1, 3, 1)  : new Date(today.getFullYear(),3,1);
            endDate = today.getMonth() < 3 ? new Date(today.getFullYear(),2,30) : new Date(today.getFullYear()+1,2,31);
        }
        else if (conString == 'LM') {
            startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            endDate = new Date(today.getFullYear(), today.getMonth(), 0);
        }
        else if (conString == 'LMTD') {
            startDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            if(new Date(today.getFullYear(), today.getMonth(), 0).getDate() < today.getDate()){
                endDate = new Date(today.getFullYear(), today.getMonth(), 0);
            }
            else{
                endDate = new Date(today.getFullYear(), today.getMonth() - 1, today.getDate());
            }
        }
        return { start: this.formatDate(startDate), end: this.formatDate(endDate)};
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}-${month}-${day}`;
    }

    handleUsersSelection(event){
        var tempList = event.detail.value.split(';');
        this.dateList.userOptionSelected = tempList.filter(ele => ele != 'ALL');
    }
    handleZoneSelection(event){
      var tempList = event.detail.value.split(';');
      this.dateList.zoneOptionSelected = tempList.filter(ele => ele != 'ALL');
      this.getUserList();
    }
    handleAccountTypeSelection(event){
      var tempList = event.detail.value.split(';');
      this.dateList.accountTypesSelected = tempList.filter(ele => ele != 'ALL');
    }
    handleProductSelect(event){
      var tempList = event.detail.value.split(';');
      this.dateList.productListSelected = tempList.filter(ele => ele != 'ALL');
    }
    handleMonthChange(event){
      this.dateList.selectedMonth = event.detail.value;
      var range = this.getMonthChangeRange(this.dateList.selectedMonth);
      this.dateList.salesKraEnd = range.endDate;
      this.dateList.salesKraStart = range.startDate;
      this.dateList.currentMonthStart = range.startDate;
      this.dateList.currentMonthEnd = range.endDate;
      this.dateList.lastMonthEnd = range.lastEndDate;
      this.dateList.lastMonthStart = range.lastStartDate;
      this.dateList.lastMonthStartTill = range.lastStartDate;      
      this.dateList.lastMonthEndTill = range.lastEndTill;
    }
    getMonthChangeRange(monthString) {
        var monthNumber = parseInt(monthString, 10);
        if (!isNaN(monthNumber) && monthNumber >= 1 && monthNumber <= 12) {
            var yearCurr = new Date().getFullYear();
            var monthCurr = new Date().getMonth() + 1;
            var year = yearCurr;
            if(monthCurr <= 3){
                year = monthNumber > 3 ? (yearCurr - 1) : (yearCurr);
            }
            else{
                year = monthNumber > 3 ? (yearCurr) : (yearCurr+1);
            }
            var startDate = year+'-'+monthNumber.toString().padStart(2, '0')+'-'+'01';
            var endDate = year+'-'+monthNumber.toString().padStart(2, '0')+'-'+(new Date((new Date(year, monthNumber, 1)) - 1)).getDate();
            var lastStart = this.formatDate(new Date(year, monthNumber - 2, 1));
            var lastEnd = this.formatDate(new Date(year, monthNumber - 1, 0));
            var lastTillEnd = lastEnd;
            if(monthNumber == ((new Date()).getMonth() + 1)){
                var lastTill = this.getDateRange('LMTD',new Date());
                lastTillEnd = lastTill.end;
            }            
            return {
              'startDate' : startDate,
              'endDate' : endDate,
              'lastStartDate' : lastStart,
              'lastEndDate' : lastEnd,
              'lastEndTill' : lastTillEnd
            };
        }
    }

    handleSearchClick(){
        this.callSalesDashboard();
        this.callTradeDashboard();
        this.callDoremateDashboard();
    }

    callSalesDashboard(){
        const salesDash = this.template.querySelector('c-sales-dashboard');
        if(salesDash){
            salesDash.refreshDashboard();
        }
    }
    callTradeDashboard(){
        const tradeDash = this.template.querySelectorAll('c-up-and-down-trade-dashboard');
        if(tradeDash){
            tradeDash.forEach(elm => {
                elm.refreshDashboard();
            });
        }
    }
    callDoremateDashboard(){
        const doremateDash = this.template.querySelectorAll('c-inactive-accounts-dashboard');
        if(doremateDash){
            doremateDash.forEach(elm => {
                elm.refreshDashboard();
            });
        }
    }
}