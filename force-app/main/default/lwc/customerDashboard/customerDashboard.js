import { LightningElement , track , wire} from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRoleSubordinateUsers from '@salesforce/apex/RoleHierarchyUtility.getRoleSubordinateUsers';
import userId from '@salesforce/user/Id';

export default class CustomerDashboard extends LightningElement {
    zoneMapping = {
      'BOMZ' : 'West',
      'CCUZ' : 'East',
      'BLRZ' : 'South',
      'DELZ' : 'North'
    };
    isSearched = false;
    isDetailedData = false;
    DetailedData = {};
    columns = [
      {
          label: 'Account Name',
          fieldName: 'nameUrl',
          type: 'url',
          typeAttributes: {label: { fieldName: 'AccountName' }, 
          target: '_blank'}
      },
      {
          label :'Account Contract',
          fieldName : 'AccountContract'
      },
      {
          label :'Account Zone',
          fieldName : 'AccountZone'
      },
      {
          label :'Account Owner',
          fieldName : 'AccountOwnerName'
      },
      {
          label :'Owner RM',
          fieldName : 'AccountManagerOwnerName'
      },
      {
          label :'Super RM',
          fieldName : 'AccountSuperManager'
      },
    ];
    isSpinner = false;
    firstAfter = `first: 10
                  after: null
                  `;
    whereClause = `where : {}`;
    contractSearchString = '';
    contractNameSearchString = '';
    pageInfo;
    totalCount;
    currPage = 1;
    totalPage;
    dashboardData = [];
    tempDashboardData = [];

    @track userOptions = [];
    @track userOptionSelected = [];
    @track zoneList = [
        {
            label : 'All',
            value : 'ALL',
            selected : true
        },
        {
            label : 'BLRZ',
            value : 'BLRZ',
            selected : true
        },
        {
            label : 'BOMZ',
            value : 'BOMZ',
            selected : true
        },
        {
            label : 'CCUZ',
            value : 'CCUZ',
            selected : true
        },
        {
            label : 'DELZ',
            value : 'DELZ',
            selected : true
        }
    ];
    @track zoneOptionSelected = ['DELZ','CCUZ','BOMZ','BLRZ'];
    @track calculatedValues = {};
    
    get searchDisable(){
      return !((this.contractNameSearchString != '' && this.contractNameSearchString != null) || (this.contractSearchString != '' && this.contractSearchString != null));
    }
    get isUserList(){
        return this.userOptions.length > 0 ? true : false;
    }
    get isZoneList(){
        return this.zoneList.length > 0 ? true : false;
    }
    get isDashboardData(){
        return this.dashboardData.length > 0 ? true : false;
    }
    get isContractSelected(){
        return this.contractSelected.length > 0 ? true : false;
    }
    get isDashboardData(){
        return this.dashboardData.length > 0 ? true : false;
    }
    get isNext(){
      return this.pageInfo?.hasNextPage ? false : true;
    }
    get isPervious(){
      return this.pageInfo?.hasPreviousPage ? false : true;
    }
    get isNoData(){
      return (this.isSearched && !this.isDashboardData) ? true : false;
    }

    connectedCallback(){
        this.getUserList();
    }

    getUserList(){
      var zoneToUser = [];
      this.zoneOptionSelected.forEach(el => {
        if(el != 'ALL' && el !=''){
          zoneToUser.push(this.zoneMapping[el]);
        }
      });
      if(zoneToUser.length > 0){
        this.userOptions = [];
        this.userOptionSelected = [];
        getRoleSubordinateUsers({userId : userId, zoneList : zoneToUser, isSalesDashBoard : false, isSalesDashboardUser : true}).then(users => {
            this.userOptions.push({'label' : 'All', 'value' : 'ALL', 'selected' : true});
            users.forEach(ele => {
                let value = ele.Name;
                let key = ele.Id;
                this.userOptions.push({'label' : value, 'value' : key, 'selected' : true});
                this.userOptionSelected.push(key);
            });
        }).catch(error => {
            this.toastMessageDispatch('Role Query Exception!',error?.body?.message,'error');
        });
      }
      else{
        this.userOptions = [];
        this.userOptionSelected = [];
      }
    }

    makeWhereClause(){
       this.currPage = 1;
        this.isSpinner = true;
        this.firstAfter = `first: 15
                            after: null
                            `;
        var temp = `where : {`;
        if((this.userOptionSelected.length > 0 && this.userOptionSelected[0] != '') || (this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '') || (this.contractSearchString != '')){
            temp += ` AccountName__r: {
                `;
            if(this.contractSearchString != ''){
              temp += `Contract_Number__c : {like : "%`+this.contractSearchString+`%"}
              `;
            }
            if(this.contractNameSearchString != ''){
              temp += `Name : {like : "%`+this.contractNameSearchString+`%"}
              `;
            }
            if(this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
                temp += `OwnerId : {in : [`;
                this.userOptionSelected.forEach(elm => {
                    temp += `"`+elm+`",`;
                });
                temp = temp.slice(0,-1);
                temp += `]}
                `;
            }
            if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
                temp += `Zone_Name__c : {in : [`;
                this.zoneOptionSelected.forEach(elm => {
                    temp += `"`+elm+`",`;
                });
                temp = temp.slice(0,-1);
                temp += `]}
                `;
            }
            temp += `}
            `;
        }
        temp +=`}`;
        this.whereClause = temp;
    }

    handleZoneSelection(event){
        var tempList = event.detail.value.split(';');
        this.zoneOptionSelected = tempList.filter(ele => ele != 'ALL');
        this.getUserList();
    }
    handleUsersSelection(event){
        var tempList = event.detail.value.split(';');
        this.userOptionSelected = tempList.filter(ele => ele != 'ALL');
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
    handleContractSearch(event){
      this.contractSearchString = event.detail.value;
    }
    handleContractNameSearch(event){
      this.contractNameSearchString = event.detail.value;
    }
    handleSearchClick(){
      this.dashboardData = [];
      this.isDetailedData = false;
      this.DetailedData = {};
      this.calculatedValues = {};
      this.whereClause = `where : {}`;
      this.isSearched = true;
      this.makeWhereClause();
    }
    handleRowSelection(event){
      this.isDetailedData = false;
      var temp = event.detail.selectedRows;
      if(temp && temp.length > 0){
        let totalLength = temp.length;
        this.calculatedValues = {
          DIFOTMTD__c : 0,
          DIFOTLM__c : 0,      
          DIFOTL3M__c : 0,
          DIFOTL12M__c : 0,     
          DIFOTYTD__c : 0,
          TOTALDIFOTMTD__c : 0,
          TOTALDIFOTLM__c : 0,
          TOTALDIFOTL3M__c : 0,
          TOTALDIFOTL12M__c : 0,
          TOTALDIFOTYTD__c : 0,
          ABSLInboundMTD__c : 0,
          ABSLInboundLM__c : 0,
          ABSLInboundL3M__c : 0,
          ABSLInboundL12M__c : 0,
          ABSLInboundYTD__c : 0,
          TOTALABSLInboundMTD__c : 0,
          TOTALABSLInboundLM__c : 0,
          TOTALABSLInboundL3M__c : 0,
          TOTALABSLInboundL12M__c : 0,
          TOTALABSLInboundYTD__c : 0,
          ABSLOutboundMTD__c : 0,
          ABSLOutboundLM__c : 0,
          ABSLOutboundL3M__c : 0,
          ABSLOutboundL12M__c : 0,      
          ABSLOutboundYTD__c : 0,
          DocketMTD__c : 0,
          DocketLMTD__c : 0,
          DocketLM__c : 0,
          DocketL3M__c : 0,
          DocketL12M__c : 0,
          DocketYTD__c : 0,
          VolumeMTD__c : 0,
          VolumeLM__c : 0,
          VolumeLMTD__c : 0,
          VolumeL3M__c : 0,
          VolumeL12M__c : 0,
          VolumeYTD__c : 0,
          RevenueMTD__c : 0,
          Revenue_LMTD__c : 0,
          RevenueLM__c : 0,
          RevenueL3M__c : 0,
          RevenueL12M__c : 0,
          RevenueYTD__c : 0,
          VisitsMTD__c : 0,
          VisitsLMTD__c : 0,
          VisitsLM__c : 0,
          VisitsL3M__c : 0,
          VisitsL12M__c : 0,
          VisitsYTD__c : 0,
          CasesOpenMTD__c : 0,
          CasesOpenLM__c : 0,
          CasesOpenL3M__c : 0,
          CasesOpenL12M__c : 0,
          CasesOpenYTD__c : 0,
          CasesClosedMTD__c : 0,
          CasesClosedLM__c : 0,
          CasesClosedL3M__c : 0,
          CasesClosedL12M__c : 0,
          CasesClosedYTD__c : 0,
          OutstandingMTD__c : 0,      
          OutstandingLM__c : 0,      
          OutstandingL3M__c : 0,      
          OutstandingL12M__c : 0,
          OutstandingYTD__c : 0,
          CollectionMTD__c : 0,
          CollectionLM__c : 0,
          CollectionL3M__c : 0,
          CollectionL12M__c : 0,
          CollectionYTD__c : 0,
          YieldMTD__c : 0,
          YieldLM__c : 0,
          YieldL3M__c : 0,
          YieldL12M__c : 0,
          YieldYTD__c : 0,
          Yield_LMTD__c : 0,
          On_time_arrival_Dockets_MTD__c : 0,
          Total_Assured_Dockets_MTD__c : 0,
          On_Time_Delivered_With_Out_Deps_MTD__c : 0,
          Total_Assured_Dockets_LM__c : 0,
          On_time_arrival_Dockets_LM__c : 0,
          On_Time_Delivered_With_Out_Deps_LM__c : 0,
          Total_Assured_Dockets_L3M__c : 0,
          On_time_arrival_Dockets_L3M__c : 0,
          On_Time_Delivered_With_Out_Deps_L3M__c : 0,
          Total_Assured_Dockets_L12M__c : 0,
          On_time_arrival_Dockets_L12M__c : 0,
          On_Time_Delivered_With_Out_Deps_L12M__c : 0
        };
        temp.forEach(elm => {
          this.calculatedValues.DocketMTD__c += parseInt(elm?.DocketMTD__c);
          this.calculatedValues.DocketLMTD__c += parseInt(elm?.DocketLMTD__c);
          this.calculatedValues.DocketLM__c += parseInt(elm?.DocketLM__c);
          this.calculatedValues.DocketL3M__c += parseInt(elm?.DocketL3M__c);
          this.calculatedValues.DocketL12M__c += parseInt(elm?.DocketL12M__c);
          this.calculatedValues.DocketYTD__c += parseInt(elm?.DocketYTD__c);
          this.calculatedValues.VolumeMTD__c += parseFloat(elm?.VolumeMTD__c);
          this.calculatedValues.VolumeLM__c += parseFloat(elm?.VolumeLM__c);
          this.calculatedValues.VolumeLMTD__c += parseFloat(elm?.VolumeLMTD__c);
          this.calculatedValues.VolumeL3M__c += parseFloat(elm?.VolumeL3M__c);
          this.calculatedValues.VolumeL12M__c += parseFloat(elm?.VolumeL12M__c);
          this.calculatedValues.VolumeYTD__c += parseFloat(elm?.VolumeYTD__c);
          this.calculatedValues.RevenueMTD__c += parseFloat(elm?.RevenueMTD__c);
          this.calculatedValues.Revenue_LMTD__c += parseFloat(elm?.Revenue_LMTD__c);
          this.calculatedValues.RevenueLM__c += parseFloat(elm?.RevenueLM__c);
          this.calculatedValues.RevenueL3M__c += parseFloat(elm?.RevenueL3M__c);
          this.calculatedValues.RevenueL12M__c += parseFloat(elm?.RevenueL12M__c);
          this.calculatedValues.RevenueYTD__c += parseFloat(elm?.RevenueYTD__c);
          this.calculatedValues.VisitsMTD__c += parseInt(elm?.VisitsMTD__c);
          this.calculatedValues.VisitsLMTD__c += parseInt(elm?.VisitsLMTD__c);
          this.calculatedValues.VisitsLM__c += parseInt(elm?.VisitsLM__c);
          this.calculatedValues.VisitsL3M__c += parseInt(elm?.VisitsL3M__c);
          this.calculatedValues.VisitsL12M__c += parseInt(elm?.VisitsL12M__c);
          this.calculatedValues.VisitsYTD__c += parseInt(elm?.VisitsYTD__c);
          this.calculatedValues.CasesOpenMTD__c += parseInt(elm?.CasesOpenMTD__c);
          this.calculatedValues.CasesOpenLM__c += parseInt(elm?.CasesOpenLM__c);
          this.calculatedValues.CasesOpenL3M__c += parseInt(elm?.CasesOpenL3M__c);
          this.calculatedValues.CasesOpenL12M__c += parseInt(elm?.CasesOpenL12M__c);
          this.calculatedValues.CasesOpenYTD__c += parseInt(elm?.CasesOpenYTD__c);
          this.calculatedValues.CasesClosedMTD__c += parseInt(elm?.CasesClosedMTD__c);
          this.calculatedValues.CasesClosedLM__c += parseInt(elm?.CasesClosedLM__c);
          this.calculatedValues.CasesClosedL3M__c += parseInt(elm?.CasesClosedL3M__c);
          this.calculatedValues.CasesClosedL12M__c += parseInt(elm?.CasesClosedL12M__c);
          this.calculatedValues.CasesClosedYTD__c += parseInt(elm?.CasesClosedYTD__c);
          this.calculatedValues.OutstandingMTD__c += parseFloat(elm?.OutstandingMTD__c);
          this.calculatedValues.OutstandingLM__c += parseFloat(elm?.OutstandingLM__c);
          this.calculatedValues.OutstandingL3M__c += parseFloat(elm?.OutstandingL3M__c);
          this.calculatedValues.OutstandingL12M__c += parseFloat(elm?.OutstandingL12M__c);
          this.calculatedValues.OutstandingYTD__c += parseFloat(elm?.OutstandingYTD__c);
          this.calculatedValues.CollectionMTD__c += parseFloat(elm?.CollectionMTD__c);
          this.calculatedValues.CollectionLM__c += parseFloat(elm?.CollectionLM__c);
          this.calculatedValues.CollectionL3M__c += parseFloat(elm?.CollectionL3M__c);
          this.calculatedValues.CollectionL12M__c += parseFloat(elm?.CollectionL12M__c);
          this.calculatedValues.CollectionYTD__c += parseFloat(elm?.CollectionYTD__c);
          this.calculatedValues.Total_Assured_Dockets_MTD__c += parseFloat(elm?.Total_Assured_Dockets_MTD__c);
          this.calculatedValues.On_Time_Delivered_With_Out_Deps_MTD__c += parseFloat(elm?.On_Time_Delivered_With_Out_Deps_MTD__c);
          this.calculatedValues.On_time_arrival_Dockets_MTD__c += parseFloat(elm?.On_time_arrival_Dockets_MTD__c);
          this.calculatedValues.Total_Assured_Dockets_LM__c += parseFloat(elm?.Total_Assured_Dockets_LM__c);
          this.calculatedValues.On_time_arrival_Dockets_LM__c += parseFloat(elm?.On_time_arrival_Dockets_LM__c);
          this.calculatedValues.On_Time_Delivered_With_Out_Deps_LM__c += parseFloat(elm?.On_Time_Delivered_With_Out_Deps_LM__c);
          this.calculatedValues.Total_Assured_Dockets_L3M__c += parseFloat(elm?.Total_Assured_Dockets_L3M__c);
          this.calculatedValues.On_time_arrival_Dockets_L3M__c += parseFloat(elm?.On_time_arrival_Dockets_L3M__c);
          this.calculatedValues.On_Time_Delivered_With_Out_Deps_L3M__c += parseFloat(elm?.On_Time_Delivered_With_Out_Deps_L3M__c);
          this.calculatedValues.Total_Assured_Dockets_L12M__c += parseFloat(elm?.Total_Assured_Dockets_L12M__c);
          this.calculatedValues.On_time_arrival_Dockets_L12M__c += parseFloat(elm?.On_time_arrival_Dockets_L12M__c);
          this.calculatedValues.On_Time_Delivered_With_Out_Deps_L12M__c += parseFloat(elm?.On_Time_Delivered_With_Out_Deps_L12M__c);
          this.calculatedValues.TOTALDIFOTMTD__c += parseFloat(elm?.DIFOTMTD__c);
          this.calculatedValues.TOTALDIFOTLM__c += parseFloat(elm?.DIFOTLM__c);
          this.calculatedValues.TOTALDIFOTL3M__c += parseFloat(elm?.DIFOTL3M__c);
          this.calculatedValues.TOTALDIFOTL12M__c += parseFloat(elm?.DIFOTL12M__c);
          this.calculatedValues.TOTALABSLInboundMTD__c += parseFloat(elm?.ABSLInboundMTD__c);
          this.calculatedValues.TOTALABSLInboundLM__c += parseFloat(elm?.ABSLInboundLM__c);
          this.calculatedValues.TOTALABSLInboundL3M__c += parseFloat(elm?.ABSLInboundL3M__c);
          this.calculatedValues.TOTALABSLInboundL12M__c += parseFloat(elm?.ABSLInboundL12M__c);
        });
        this.calculatedValues.DIFOTMTD__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_MTD__c) > 0) ? ((this.calculatedValues?.On_Time_Delivered_With_Out_Deps_MTD__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_MTD__c))*100).toFixed(2) : 0;
        this.calculatedValues.DIFOTLM__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_LM__c) > 0) ? ((this.calculatedValues?.On_Time_Delivered_With_Out_Deps_LM__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_LM__c))*100).toFixed(2) : 0;
        this.calculatedValues.DIFOTL3M__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_L3M__c) > 0) ? ((this.calculatedValues?.On_Time_Delivered_With_Out_Deps_L3M__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_L3M__c))*100).toFixed(2) : 0;
        this.calculatedValues.DIFOTL12M__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_L12M__c) > 0) ? ((this.calculatedValues?.On_Time_Delivered_With_Out_Deps_L12M__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_L12M__c))*100).toFixed(2) : 0;
        // this.calculatedValues.DIFOTLM__c = (parseFloat(this.calculatedValues?.TOTALDIFOTLM__c) / totalLength).toFixed(2);
        // this.calculatedValues.DIFOTL3M__c = (parseFloat(this.calculatedValues?.TOTALDIFOTL3M__c) / totalLength).toFixed(2);
        // this.calculatedValues.DIFOTL12M__c = (parseFloat(this.calculatedValues?.TOTALDIFOTL12M__c) / totalLength).toFixed(2);
        this.calculatedValues.ABSLInboundMTD__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_MTD__c) > 0) ? ((this.calculatedValues?.On_time_arrival_Dockets_MTD__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_MTD__c))*100).toFixed(2) : 0;
        this.calculatedValues.ABSLInboundLM__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_LM__c) > 0) ? ((this.calculatedValues?.On_time_arrival_Dockets_LM__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_LM__c))*100).toFixed(2) : 0;
        this.calculatedValues.ABSLInboundL3M__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_L3M__c) > 0) ? ((this.calculatedValues?.On_time_arrival_Dockets_L3M__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_L3M__c))*100).toFixed(2) : 0;
        this.calculatedValues.ABSLInboundL12M__c = (parseFloat(this.calculatedValues?.Total_Assured_Dockets_L12M__c) > 0) ? ((this.calculatedValues?.On_time_arrival_Dockets_L12M__c / parseFloat(this.calculatedValues?.Total_Assured_Dockets_L12M__c))*100).toFixed(2) : 0;
        // this.calculatedValues.ABSLInboundLM__c = (parseFloat(this.calculatedValues?.TOTALABSLInboundLM__c) / totalLength).toFixed(2);
        // this.calculatedValues.ABSLInboundL3M__c = (parseFloat(this.calculatedValues?.TOTALABSLInboundL3M__c) / totalLength).toFixed(2);
        // this.calculatedValues.ABSLInboundL12M__c = (parseFloat(this.calculatedValues?.TOTALABSLInboundL12M__c) / totalLength).toFixed(2);
        this.calculatedValues.YieldMTD__c = (parseFloat(this.calculatedValues?.VolumeMTD__c) > 0) ? (this.calculatedValues?.RevenueMTD__c / parseFloat(this.calculatedValues?.VolumeMTD__c)).toFixed(2) : 0;
        this.calculatedValues.YieldLM__c = (parseFloat(this.calculatedValues?.VolumeLM__c) > 0) ? (this.calculatedValues?.RevenueLM__c / parseFloat(this.calculatedValues?.VolumeLM__c)).toFixed(2) : 0;
        this.calculatedValues.Yield_LMTD__c = (parseFloat(this.calculatedValues?.VolumeLMTD__c) > 0) ? (this.calculatedValues?.Revenue_LMTD__c / parseFloat(this.calculatedValues?.VolumeLMTD__c)).toFixed(2) : 0;
        this.calculatedValues.YieldL3M__c = (parseFloat(this.calculatedValues?.VolumeL3M__c) > 0) ? (this.calculatedValues?.RevenueL3M__c / parseFloat(this.calculatedValues?.VolumeL3M__c)).toFixed(2) : 0;
        this.calculatedValues.YieldL12M__c = (parseFloat(this.calculatedValues?.VolumeL12M__c) > 0) ? (this.calculatedValues?.RevenueL12M__c / parseFloat(this.calculatedValues?.VolumeL12M__c)).toFixed(2) : 0;
        this.calculatedValues.YieldYTD__c = (parseFloat(this.calculatedValues?.VolumeYTD__c) > 0) ? (this.calculatedValues?.RevenueYTD__c / parseFloat(this.calculatedValues?.VolumeYTD__c)).toFixed(2) : 0;
        this.calculatedValues.RevenueMTD__c = (this.calculatedValues.RevenueMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.Revenue_LMTD__c = (this.calculatedValues.Revenue_LMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.RevenueLM__c = (this.calculatedValues.RevenueLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.RevenueL3M__c = (this.calculatedValues.RevenueL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.RevenueL12M__c = (this.calculatedValues.RevenueL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.RevenueYTD__c = (this.calculatedValues.RevenueYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketMTD__c = (this.calculatedValues.DocketMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketLMTD__c = (this.calculatedValues.DocketLMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketLM__c = (this.calculatedValues.DocketLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketL3M__c = (this.calculatedValues.DocketL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketL12M__c = (this.calculatedValues.DocketL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.DocketYTD__c = (this.calculatedValues.DocketYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeMTD__c = (this.calculatedValues.VolumeMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeLM__c = (this.calculatedValues.VolumeLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeLMTD__c = (this.calculatedValues.VolumeLMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeL3M__c = (this.calculatedValues.VolumeL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeL12M__c = (this.calculatedValues.VolumeL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VolumeYTD__c = (this.calculatedValues.VolumeYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsMTD__c = (this.calculatedValues.VisitsMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsLMTD__c = (this.calculatedValues.VisitsLMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsLM__c = (this.calculatedValues.VisitsLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsL3M__c = (this.calculatedValues.VisitsL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsL12M__c = (this.calculatedValues.VisitsL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.VisitsYTD__c = (this.calculatedValues.VisitsYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesOpenMTD__c = (this.calculatedValues.CasesOpenMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesOpenLM__c = (this.calculatedValues.CasesOpenLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesOpenL3M__c = (this.calculatedValues.CasesOpenL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesOpenL12M__c = (this.calculatedValues.CasesOpenL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesOpenYTD__c = (this.calculatedValues.CasesOpenYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesClosedMTD__c = (this.calculatedValues.CasesClosedMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesClosedLM__c = (this.calculatedValues.CasesClosedLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesClosedL3M__c = (this.calculatedValues.CasesClosedL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesClosedL12M__c = (this.calculatedValues.CasesClosedL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CasesClosedYTD__c = (this.calculatedValues.CasesClosedYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.OutstandingMTD__c = (this.calculatedValues.OutstandingMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.OutstandingLM__c = (this.calculatedValues.OutstandingLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.OutstandingL3M__c = (this.calculatedValues.OutstandingL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.OutstandingL12M__c = (this.calculatedValues.OutstandingL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.OutstandingYTD__c = (this.calculatedValues.OutstandingYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CollectionMTD__c = (this.calculatedValues.CollectionMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CollectionLM__c = (this.calculatedValues.CollectionLM__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CollectionL3M__c = (this.calculatedValues.CollectionL3M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CollectionL12M__c = (this.calculatedValues.CollectionL12M__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        this.calculatedValues.CollectionYTD__c = (this.calculatedValues.CollectionYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0});
        //console.log('Calculated ',JSON.stringify(this.calculatedValues,null,2));
      }
      else{
        this.calculatedValues = null;
      }
      if(this.calculatedValues){
        this.isDetailedData = true;
      }
    }  
    
    handleNext(){
      this.isSpinner = true;
      this.isDetailedData = false;
      this.DetailedData = {};
      this.calculatedValues = {};
      this.currPage += 1;
      this.dashboardData = [];
      let temp = `first: 10
                  after: "`;
                    temp += this.pageInfo?.endCursor;
                    temp += `"
                    `;
       this.firstAfter = temp;
    }
    handleFirst(){
      this.isSpinner = true;
      this.isDetailedData = false;
      this.DetailedData = {};
      this.calculatedValues = {};
      this.currPage = 1;
      this.dashboardData = [];
      this.firstAfter = `first: 15
                          after: null
                          `;
    }

    @wire(graphql, { query: '$dynamicQueryDashboard' })
    getDashboardData({data, errors}){
        if (data && this.userOptionSelected.length > 0 && this.userOptionSelected[0] != '' && this.isSearched){
            this.totalCount = data?.uiapi?.query?.CustomerDashboard__c?.totalCount;
            this.pageInfo = data?.uiapi?.query?.CustomerDashboard__c?.pageInfo;
            var tempData = [];
            tempData = data?.uiapi?.query?.CustomerDashboard__c?.edges.map(elm => {
              return {
                  AccountId : elm?.node?.AccountName__r?.Id,
                  AccountName : elm?.node?.AccountName__r?.Name?.value,
                  AccountZone : elm?.node?.AccountName__r?.Zone_Name__c?.value,
                  AccountContract : elm?.node?.AccountName__r?.Contract_Number__c?.value,
                  AccountOwnerName : elm?.node?.AccountName__r?.Owner?.Name?.value,
                  AccountManagerOwnerName : elm?.node?.AccountName__r?.Owner?.Manager?.Name?.value,
                  AccountSuperManager : elm?.node?.AccountName__r?.Owner?.Manager?.Manager?.Name?.value,
                  DocketYTD__c : elm?.node?.DocketYTD__c?.value,
                  VolumeYTD__c : (elm?.node?.VolumeYTD__c?.value),
                  RevenueYTD__c : (elm?.node?.RevenueYTD__c?.value),
                  VisitsYTD__c : (elm?.node?.VisitsYTD__c?.value),
                  CasesOpenYTD__c : (elm?.node?.CasesOpenYTD__c?.value),
                  CasesClosedYTD__c : (elm?.node?.CasesClosedYTD__c?.value),
                  DIFOTYTD__c : (elm?.node?.DIFOTYTD__c?.value),
                  ABSLInboundYTD__c : (elm?.node?.ABSLInboundYTD__c?.value),
                  ABSLOutboundYTD__c : (elm?.node?.ABSLOutboundYTD__c?.value),
                  OutstandingYTD__c : (elm?.node?.OutstandingYTD__c?.value),
                  CasesClosedMTD__c : (elm?.node?.CasesClosedMTD__c?.value),
                  CasesOpenMTD__c : (elm?.node?.CasesOpenMTD__c?.value),
                  VisitsMTD__c : (elm?.node?.VisitsMTD__c?.value),
                  ABSLInboundMTD__c : (elm?.node?.ABSLInboundMTD__c?.value),
                  ABSLOutboundMTD__c : (elm?.node?.ABSLOutboundMTD__c?.value),
                  DIFOTMTD__c : (elm?.node?.DIFOTMTD__c?.value),
                  DocketMTD__c : (elm?.node?.DocketMTD__c?.value),
                  OutstandingMTD__c : (elm?.node?.OutstandingMTD__c?.value),
                  RevenueMTD__c : (elm?.node?.RevenueMTD__c?.value),
                  VolumeMTD__c : (elm?.node?.VolumeMTD__c?.value),
                  CasesClosedLM__c : (elm?.node?.CasesClosedLM__c?.value),
                  CasesOpenLM__c : (elm?.node?.CasesOpenLM__c?.value),
                  VisitsLM__c : (elm?.node?.VisitsLM__c?.value),
                  ABSLInboundLM__c : (elm?.node?.ABSLInboundLM__c?.value),
                  ABSLOutboundLM__c : (elm?.node?.ABSLOutboundLM__c?.value),
                  DIFOTLM__c : (elm?.node?.DIFOTLM__c?.value),
                  DocketLM__c : (elm?.node?.DocketLM__c?.value),
                  DocketLMTD__c : (elm?.node?.DocketLMTD__c?.value) ? (elm?.node?.DocketLMTD__c?.value) : 0,
                  OutstandingLM__c : (elm?.node?.OutstandingLM__c?.value),
                  RevenueLM__c : (elm?.node?.RevenueLM__c?.value),
                  VolumeLM__c : (elm?.node?.VolumeLM__c?.value),
                  VolumeLMTD__c : (elm?.node?.VolumeLMTD__c?.value) ? (elm?.node?.VolumeLMTD__c?.value) : 0,
                  CasesClosedL3M__c : (elm?.node?.CasesClosedL3M__c?.value),
                  CasesOpenL3M__c : (elm?.node?.CasesOpenL3M__c?.value),
                  VisitsL3M__c : (elm?.node?.VisitsL3M__c?.value),
                  ABSLInboundL3M__c : (elm?.node?.ABSLInboundL3M__c?.value),
                  ABSLOutboundL3M__c : (elm?.node?.ABSLOutboundL3M__c?.value),
                  DIFOTL3M__c : (elm?.node?.DIFOTL3M__c?.value),
                  DocketL3M__c : (elm?.node?.DocketL3M__c?.value),
                  OutstandingL3M__c : (elm?.node?.OutstandingL3M__c?.value),
                  RevenueL3M__c : (elm?.node?.RevenueL3M__c?.value),
                  VolumeL3M__c : (elm?.node?.VolumeL3M__c?.value),
                  Revenue_LMTD__c : (elm?.node?.Revenue_LMTD__c?.value),
                  LastTradeDate__c : elm?.node?.LastTradeDate__c?.value,
                  MoM__c : (elm?.node?.MoM__c?.value),
                  nameUrl : '/'+ elm?.node?.AccountName__r?.Id,
                  CasesClosedL12M__c : (elm?.node?.CasesClosedL12M__c?.value) ? (elm?.node?.CasesClosedL12M__c?.value) : 0,
                  CasesOpenL12M__c : (elm?.node?.CasesOpenL12M__c?.value) ? (elm?.node?.CasesOpenL12M__c?.value) : 0,
                  ABSLInboundL12M__c : (elm?.node?.ABSLInboundL12M__c?.value) ? (elm?.node?.ABSLInboundL12M__c?.value) : 0,
                  ABSLOutboundL12M__c : (elm?.node?.ABSLOutboundL12M__c?.value) ? (elm?.node?.ABSLOutboundL12M__c?.value) : 0,
                  DIFOTL12M__c : (elm?.node?.DIFOTL12M__c?.value) ? (elm?.node?.DIFOTL12M__c?.value) : 0,
                  DocketL12M__c : (elm?.node?.DocketL12M__c?.value) ? (elm?.node?.DocketL12M__c?.value) : 0,
                  OutstandingL12M__c : (elm?.node?.OutstandingL12M__c?.value) ? (elm?.node?.OutstandingL12M__c?.value) : 0,
                  RevenueL12M__c : (elm?.node?.RevenueL12M__c?.value) ? (elm?.node?.RevenueL12M__c?.value) : 0,
                  VisitsL12M__c : (elm?.node?.VisitsL12M__c?.value) ? (elm?.node?.VisitsL12M__c?.value) : 0,
                  VisitsLMTD__c : (elm?.node?.VisitsLMTD__c?.value) ? (elm?.node?.VisitsLMTD__c?.value) : 0,
                  VolumeL12M__c : (elm?.node?.VolumeL12M__c?.value) ? (elm?.node?.VolumeL12M__c?.value) : 0,
                  Revenue_LMTD__c : (elm?.node?.Revenue_LMTD__c?.value) ? (elm?.node?.Revenue_LMTD__c?.value) : 0,
                  CollectionMTD__c : (elm?.node?.CollectionMTD__c?.value) ? (elm?.node?.CollectionMTD__c?.value) : 0,
                  CollectionLM__c : (elm?.node?.CollectionLM__c?.value) ? (elm?.node?.CollectionLM__c?.value) : 0,
                  CollectionL3M__c : (elm?.node?.CollectionL3M__c?.value) ? (elm?.node?.CollectionL3M__c?.value) : 0,
                  CollectionL12M__c : (elm?.node?.CollectionL12M__c?.value) ? (elm?.node?.CollectionL12M__c?.value) : 0,
                  CollectionYTD__c : (elm?.node?.CollectionYTD__c?.value) ? (elm?.node?.CollectionYTD__c?.value) : 0,
                  YieldMTD__c : (elm?.node?.YieldMTD__c?.value) ? (elm?.node?.YieldMTD__c?.value) : 0,
                  YieldLM__c : (elm?.node?.YieldLM__c?.value) ? (elm?.node?.YieldLM__c?.value) : 0,
                  YieldL3M__c : (elm?.node?.YieldL3M__c?.value) ? (elm?.node?.YieldL3M__c?.value) : 0,
                  YieldL12M__c : (elm?.node?.YieldL12M__c?.value) ? (elm?.node?.YieldL12M__c?.value) : 0,
                  YieldYTD__c : (elm?.node?.YieldYTD__c?.value) ? (elm?.node?.YieldYTD__c?.value) : 0,
                  Yield_LMTD__c : (elm?.node?.Yield_LMTD__c?.value) ? (elm?.node?.Yield_LMTD__c?.value) : 0,
                  Total_Assured_Dockets_MTD__c : (elm?.node?.Total_Assured_Dockets_MTD__c?.value) ? (elm?.node?.Total_Assured_Dockets_MTD__c?.value) : 0,
                  On_Time_Delivered_With_Out_Deps_MTD__c : (elm?.node?.On_Time_Delivered_With_Out_Deps_MTD__c?.value) ? (elm?.node?.On_Time_Delivered_With_Out_Deps_MTD__c?.value) : 0,
                  On_time_arrival_Dockets_MTD__c : (elm?.node?.On_time_arrival_Dockets_MTD__c?.value) ? (elm?.node?.On_time_arrival_Dockets_MTD__c?.value) : 0,
                  Total_Assured_Dockets_LM__c : (elm?.node?.Total_Assured_Dockets_LM__c?.value) ? (elm?.node?.Total_Assured_Dockets_LM__c?.value) : 0,
                  On_time_arrival_Dockets_LM__c : (elm?.node?.On_time_arrival_Dockets_LM__c?.value) ? (elm?.node?.On_time_arrival_Dockets_LM__c?.value) : 0,
                  On_Time_Delivered_With_Out_Deps_LM__c : (elm?.node?.On_Time_Delivered_With_Out_Deps_LM__c?.value) ? (elm?.node?.On_Time_Delivered_With_Out_Deps_LM__c?.value) : 0,
                  Total_Assured_Dockets_L3M__c : (elm?.node?.Total_Assured_Dockets_L3M__c?.value) ? (elm?.node?.Total_Assured_Dockets_L3M__c?.value) : 0,
                  On_time_arrival_Dockets_L3M__c : (elm?.node?.On_time_arrival_Dockets_L3M__c?.value) ? (elm?.node?.On_time_arrival_Dockets_L3M__c?.value) : 0,
                  On_Time_Delivered_With_Out_Deps_L3M__c : (elm?.node?.On_Time_Delivered_With_Out_Deps_L3M__c?.value) ? (elm?.node?.On_Time_Delivered_With_Out_Deps_L3M__c?.value) : 0,
                  Total_Assured_Dockets_L12M__c : (elm?.node?.Total_Assured_Dockets_L12M__c?.value) ? (elm?.node?.Total_Assured_Dockets_L12M__c?.value) : 0,
                  On_time_arrival_Dockets_L12M__c : (elm?.node?.On_time_arrival_Dockets_L12M__c?.value) ? (elm?.node?.On_time_arrival_Dockets_L12M__c?.value) : 0,
                  On_Time_Delivered_With_Out_Deps_L12M__c : (elm?.node?.On_Time_Delivered_With_Out_Deps_L12M__c?.value) ? (elm?.node?.On_Time_Delivered_With_Out_Deps_L12M__c?.value) : 0
              }
            });
            this.dashboardData = JSON.parse(JSON.stringify(tempData));
            this.isSpinner = false;
            this.totalPage = Math.ceil(this.totalCount / 15);
        }
    }

    get dynamicQueryDashboard() {
      return gql`${this.queryStringDashboard}`;
    }
    
    get queryStringDashboard(){
        return `query getCustomerDashboardData {
            uiapi {
              query {
                CustomerDashboard__c(`+
                this.firstAfter+
                this.whereClause+
                `) {
                  totalCount
                  pageInfo{
                    hasNextPage
                    endCursor
                    hasPreviousPage
                    startCursor
                  }
                  edges {
                    node {
                      AccountName__r {
                        Id,
                        Name{
                          value
                        }
                        Contract_Number__c{
                          value
                        }
                        Zone_Name__c{
                          value
                        }
                        Owner{
                          Name{
                            value
                          }
                          Manager{
                            Name{
                              value
                            }
                            Manager{
                              Name{
                                  value
                              }
                            }
                          }
                        }
                      }
                      DocketYTD__c {
                        value
                      }
                      VolumeYTD__c {
                        value
                      }
                      RevenueYTD__c {
                        value
                      }
                      VisitsYTD__c {
                        value
                      }
                      CasesOpenYTD__c {
                        value
                      }
                      CasesClosedYTD__c {
                        value
                      }
                      DIFOTYTD__c {
                        value
                      }
                      ABSLInboundYTD__c {
                        value
                      }
                      ABSLOutboundYTD__c {
                        value
                      }
                      OutstandingYTD__c {
                        value
                      }
                      CasesClosedMTD__c {
                        value
                      }
                      CasesOpenMTD__c {
                        value
                      }
                      VisitsMTD__c {
                        value
                      }
                      ABSLInboundMTD__c {
                        value
                      }
                      ABSLOutboundMTD__c {
                        value
                      }
                      DIFOTMTD__c {
                        value
                      }
                      DocketMTD__c {
                        value
                      }
                      DocketLMTD__c {
                        value
                      }
                      OutstandingMTD__c {
                        value
                      }
                      RevenueMTD__c {
                        value
                      }
                      VolumeMTD__c {
                        value
                      }
                      VolumeLMTD__c {
                        value
                      }
                      CasesClosedLM__c {
                        value
                      }
                      CasesOpenLM__c {
                        value
                      }
                      VisitsLM__c {
                        value
                      }
                      ABSLInboundLM__c {
                        value
                      }
                      ABSLOutboundLM__c {
                        value
                      }
                      DIFOTLM__c {
                        value
                      }
                      DocketLM__c {
                        value
                      }
                      OutstandingLM__c {
                        value
                      }
                      RevenueLM__c {
                        value
                      }
                      VolumeLM__c {
                        value
                      }
                      CasesClosedL3M__c {
                        value
                      }
                      CasesOpenL3M__c {
                        value
                      }
                      VisitsL3M__c {
                        value
                      }
                      ABSLInboundL3M__c {
                        value
                      }
                      ABSLOutboundL3M__c {
                        value
                      }
                      DIFOTL3M__c {
                        value
                      }
                      DocketL3M__c {
                        value
                      }
                      OutstandingL3M__c {
                        value
                      }
                      RevenueL3M__c {
                        value
                      }
                      VolumeL3M__c {
                        value
                      }
                      Revenue_LMTD__c {
                        value
                      }
                      LastTradeDate__c {
                        value
                      }
                      MoM__c {
                        value
                      }
                      CasesClosedL12M__c {
                        value
                      }
                      CasesOpenL12M__c {
                          value
                      }
                      ABSLInboundL12M__c {
                          value
                      }
                      ABSLOutboundL12M__c {
                          value
                      }
                      DIFOTL12M__c {
                          value
                      }
                      DocketL12M__c {
                          value
                      }
                      OutstandingL12M__c {
                          value
                      }
                      RevenueL12M__c {
                          value
                      }
                      VisitsL12M__c {
                          value
                      }
                      VolumeL12M__c {
                          value
                      }
                      Revenue_LMTD__c {
                        value
                      }
                      CollectionMTD__c{
                        value
                      }
                      CollectionLM__c{
                          value
                      }
                      CollectionL3M__c{
                          value
                      }
                      CollectionL12M__c{
                          value
                      }
                      CollectionYTD__c{
                          value
                      }
                      YieldMTD__c{
                          value
                      }
                      Yield_LMTD__c{
                          value
                      }
                      YieldLM__c{
                          value
                      }
                      YieldL3M__c{
                          value
                      }
                      YieldL12M__c{
                          value
                      }
                      YieldYTD__c{
                          value
                      }
                      VisitsLMTD__c{
                        value
                      }
                      Total_Assured_Dockets_MTD__c{
                        value
                      }
                      On_time_arrival_Dockets_MTD__c{
                        value
                      }
                      On_Time_Delivered_With_Out_Deps_MTD__c{
                        value
                      }
                      Total_Assured_Dockets_LM__c{
                        value
                      }
                      On_time_arrival_Dockets_LM__c{
                        value
                      }
                      On_Time_Delivered_With_Out_Deps_LM__c{
                        value
                      }
                      Total_Assured_Dockets_L3M__c{
                        value
                      }
                      On_time_arrival_Dockets_L3M__c{
                        value
                      }
                      On_Time_Delivered_With_Out_Deps_L3M__c{
                        value
                      }
                      Total_Assured_Dockets_L12M__c{
                        value
                      }
                      On_time_arrival_Dockets_L12M__c{
                        value
                      }
                      On_Time_Delivered_With_Out_Deps_L12M__c{
                        value
                      }
                    }
                  }
                }
              }
            }
          }
        `;
    }
}