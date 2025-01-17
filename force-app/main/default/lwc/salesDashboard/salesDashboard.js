import { LightningElement , track , wire , api} from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNBDCustomerData from '@salesforce/apex/SalesDashboardController.getNBDCustomerData';
import getOpportunityClosedData from '@salesforce/apex/SalesDashboardController.getOpportunityClosedData';
import getTargets from '@salesforce/apex/SalesDashboardController.getTargets';

export default class SalesDashboard extends LightningElement {
  @api dateList;

  isSpinner = false;
  isCurrentYearOpen = false;
  isCurrentYear = false;
  isCurrentMonth = false;
  isCustomerConnect = false;

  selectedMonth = null;
  currentMonthStart;
  currentMonthEnd;
  lastMonthStart;
  lastMonthEnd;
  lastMonthTillStart;
  lastMonthTillEnd;
  currentYearStart;
  currentYearEnd;
  salesKraStart;
  salesKraEnd;
  numOfDaysInCurrentMonth;
    
  @track dashboardData = {
    'OpportunityCreated' : {
      'MTDPotential': 0,
      'LMTD':0,
      'LMTDPotential':0,
      'MTD':0,
      'OVERALL':0,
      'OVERALLPotential':0
    },
    'OpportunityClosed' : {
      'MTDPotential': 0,
      'LMTD':0,
      'LMTDPotential':0,
      'MTD':0,
      'OVERALL':0,
      'OVERALLPotential':0
    },
    'Lead' : {
      'MTDPotential': 0,
      'LMTD':0,
      'LMTDPotential':0,
      'MTD':0,
      'OVERALL':0,
      'OVERALLPotential':0
      }
    };
  @track customerData = {
        'Customer360' : {
          'TGT' : 0,
          'TGT_TOTAL' : 0,
          'ACHV' : 0,
          'ACHV_TOTAL' : 0,
          'MTD_KEA' : 0,
          'MTD_OTHER' : 0,
          'MTD' : 0,
          'MTD_TOTAL' : 0,
          'LMTD_KEA' : 0,
          'LMTD_OTHER' : 0,
          'LMTD' : 0,
          'LMTD_TOTAL' : 0,
          'YTD' : 0,
          'YTD_TOTAL' : 0,
          'MTD_STRING' : '',
          'LMTD_STRING' : '',
          'YTD_STRING' : '',
          'MTD_TOTAL_STRING' : '',
          'LMTD_TOTAL_STRING' : '',
          'YTD_TOTAL_STRING' : '',
          'TGT_STRING' : '',
          'ACHV_STRING' : '',
          'TGT_TOTAL_STRING' : '',
          'ACHV_TOTAL_STRING' : ''
        },
        'Customer360NBD' : {
          'TGT' : 0,
          'ACHV' : 0,
          'MTD' : 0,
          'MTD_KEA' : 0,
          'MTD_OTHER' : 0,
          'LMTD' : 0,
          'LMTD_KEA' : 0,
          'LMTD_OTHER' : 0,
          'YTD' : 0,
          'MTD_STRING' : '',
          'LMTD_STRING' : '',
          'YTD_STRING' : '',
          'TGT_STRING' : '',
          'ACHV_STRING' : ''
        },
        'CustomerConnect' : {
          'TGT' : 0,
          'ACHV' : 0,
          'MTD' : 0,
          'LMTD' : 0,
          'YTD' : 0,
          'TGT_STRING' : '',
          'ACHV_STRING' : '',
          'MTD_STRING' : '',
          'LMTD_STRING' : '',
          'YTD_STRING' : '',
          'MTD_TOTAL' : 0,
          'LMTD_TOTAL' : 0,
          'YTD_TOTAL' : 0
        },
        'CustomerConnectNBD' : {
          'TGT' : 0,
          'ACHV' : 0,
          'MTD' : 0,
          'LMTD' : 0,
          'YTD' : 0,
          'TGT_STRING' : '',
          'ACHV_STRING' : '',
          'MTD_STRING' : '',
          'LMTD_STRING' : '',
          'YTD_STRING' : ''
        }
    };
      
  whereOppYearOpen = `where : {}
  `;
  whereLeadYearOpen = `where : {}
  `;
  whereOppYear = `where : {}
  `;
  whereLeadYear = `where : {}
  `;
  whereOppMonth = `where : {}
  `;
  whereLeadMonth = `where : {}
  `;
    
  whereCustomerConnectMonth = `where : {}
  `;
  whereCustomerConnectYear = `where : {}
  `;
  whereCustomerConnectLastMonth = `where : {}
  `;
  whereSalesKRA = `where : {}
  `;
  whereSalesKRAYTD = `where : {}
  `;
  whereSalesKRAForKEA = `where : {}
  `;
  userVisitCountWhere = `where : {}
  `;
      
  @track userOptionSelected = [];
  @track zoneOptionSelected = [];
  @track accountTypesSelected = [];
  @track productListSelected = [];
      
  get isDashboardData(){    
    return this.isCurrentYearOpen && this.isCurrentYear && this.isCurrentMonth;
  }    
    
  @api refreshDashboard(){
    this.currentMonthStart = this.dateList?.currentMonthStart;
    this.currentMonthEnd = this.dateList?.currentMonthEnd;
    this.lastMonthStart = this.dateList?.lastMonthStart;
    this.lastMonthEnd = this.dateList?.lastMonthEnd;
    this.lastMonthTillStart = this.dateList?.lastMonthStartTill;
    this.lastMonthTillEnd = this.dateList?.lastMonthEndTill;
    this.currentYearStart = this.dateList?.currentYearStart;
    this.currentYearEnd = this.dateList?.currentYearEnd;
    this.salesKraStart = this.dateList?.salesKraStart;
    this.salesKraEnd = this.dateList?.salesKraEnd;
    this.userOptionSelected = this.dateList?.userOptionSelected;
    this.zoneOptionSelected = this.dateList?.zoneOptionSelected;
    this.accountTypesSelected = this.dateList?.accountTypesSelected;
    this.productListSelected = this.dateList?.productListSelected;
    this.selectedMonth = this.dateList?.selectedMonth;
    this.numOfDaysInCurrentMonth = this.countWeekDays(this.currentMonthStart.substring(0,4), parseInt(this.selectedMonth) - 1, new Date(this.currentMonthStart.substring(0,4), parseInt(this.selectedMonth), 0).getDate());
    this.makeZeroToRefresh();
    setTimeout(() => {
      this.graphqlDataFunctions();
    }, 100);
  }

  countWeekDays(year,month,totalDays){
    let weekdaysCount = 0;
    for (let day = 1; day <= totalDays; day++) {
        let currentDate = new Date(year, month, day);
        let dayOfWeek = currentDate.getDay();
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            weekdaysCount++;
        }
    }
    return weekdaysCount;
  }

  makeZeroToRefresh(){
    this.isCurrentYearOpen = false;
    this.isCurrentMonth = false;
    this.customerData.Customer360.TGT = 0;
    this.customerData.Customer360.TGT_TOTAL = 0;
    this.customerData.Customer360NBD.TGT = 0;
    this.customerData.Customer360.MTD_TOTAL = 0;
    this.customerData.Customer360NBD.MTD = 0;
    this.customerData.Customer360.MTD = 0;
    this.customerData.Customer360.LMTD_TOTAL = 0;
    this.customerData.Customer360NBD.LMTD = 0;
    this.customerData.Customer360.LMTD = 0;
    this.customerData.Customer360.ACHV = 0;
    this.customerData.Customer360NBD.ACHV = 0;
    this.customerData.Customer360.ACHV_TOTAL = 0;
    this.customerData.CustomerConnect.MTD = 0;
    this.customerData.CustomerConnect.ACHV = 0;
    this.customerData.CustomerConnectNBD.ACHV = 0;
    this.customerData.CustomerConnect.LMTD = 0;
    this.customerData.CustomerConnect.YTD = 0;
  }
    
  graphqlDataFunctions(){
    this.makeWhereForFinancialYearOpen();
    this.makeWhereForFinancialYear();
    this.makeWhereForFinancialMonth();
    this.handleNBDCustomerVisits();
    this.handleOpportunityClosed();
    this.handleGetTargets();
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

  handleNBDCustomerVisits(){
    var whereData = {
      'thisMonthStartDate' : this.currentMonthStart,
      'thisMonthEndDate' : this.currentMonthEnd,
      'lastMonthStartDate' : this.lastMonthTillStart,
      'lastMonthEndDate' : this.lastMonthTillEnd,
      'userSelectedIds' : this.userOptionSelected,
      'zoneSelectedList' : this.zoneOptionSelected,
      'accountTypesSelected' : this.accountTypesSelected
    };
    getNBDCustomerData({inpData : whereData}).then(cusData => {     
      this.customerData.CustomerConnectNBD.MTD = cusData?.THIS_MONTH;
      this.customerData.CustomerConnectNBD.LMTD = cusData?.LAST_MONTH;
      this.customerData.CustomerConnectNBD.YTD = cusData?.FISCAL_YEAR;
    });
  }
  handleOpportunityClosed(){
    var whereData = {
      'thisMonthStartDate' : this.currentMonthStart,
      'thisMonthEndDate' : this.currentMonthEnd,
      'lastMonthStartTillDate' : this.lastMonthTillStart,
      'lastMonthEndTillDate' : this.lastMonthTillEnd,
      'userSelectedIds' : this.userOptionSelected,
      'accountTypesSelected' : this.accountTypesSelected
    };
    getOpportunityClosedData({whrClause : whereData}).then(oppData => {
      this.dashboardData.OpportunityClosed.MTD = oppData.THIS_MONTH_MTD ? (oppData.THIS_MONTH_MTD).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
      this.dashboardData.OpportunityClosed.MTDPotential = oppData.THIS_MONTH_REVENUE ? (oppData.THIS_MONTH_REVENUE).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
      this.dashboardData.OpportunityClosed.LMTD = oppData.LAST_MONTH_MTD ? (oppData.LAST_MONTH_MTD).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
      this.dashboardData.OpportunityClosed.LMTDPotential = oppData.LAST_MONTH_REVENUE ? (oppData.LAST_MONTH_REVENUE).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
      this.dashboardData.OpportunityClosed.OVERALL = oppData.THIS_YEAR_MTD ? (oppData.THIS_YEAR_MTD).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
      this.dashboardData.OpportunityClosed.OVERALLPotential = oppData.THIS_YEAR_REVENUE ? (oppData.THIS_YEAR_REVENUE).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
    }).catch(err => {
      this.toastMessageDispatch('Opp Data Error',err?.body?.message,'error');
    });
  }
  handleGetTargets(){
    let whereData = {
      'salesKRAStartDate' : this.salesKraStart,
      'salesKRAEndDate' : this.salesKraEnd,
      'userSelectedIds' : this.userOptionSelected,
      'zoneSelectedList' : this.zoneOptionSelected,
      'productList' : this.productListSelected,
      'accountTypes' : this.accountTypesSelected
    };
    getTargets({whereClause : whereData}).then(result => {
      this.customerData.Customer360.TGT = result?.Target ? result?.Target : 0;
      this.customerData.Customer360.TGT_TOTAL = result?.Total_Target ? result?.Total_Target : 0;
      this.customerData.Customer360NBD.TGT = result?.NBD_Target ? result?.NBD_Target : 0;
      this.calculateTotalRevenue();
    }).catch(error => {
      this.toastMessageDispatch('Error In Target Calculation!!',JSON.stringify(error),'error');
    });
  }

  calculateTotalRevenue(){
    if(this.isCurrentYearOpen && this.isCurrentYear && this.isCurrentMonth){
      this.customerData.CustomerConnect.MTD = this.customerData?.CustomerConnect?.MTD_TOTAL - parseFloat(this.customerData?.CustomerConnectNBD?.MTD);
      this.customerData.CustomerConnect.ACHV = this.customerData?.CustomerConnect?.TGT != 0 ? ((this.customerData?.CustomerConnect?.MTD / this.customerData?.CustomerConnect?.TGT)*100) : 0;
      this.customerData.CustomerConnectNBD.ACHV = this.customerData?.CustomerConnectNBD?.TGT != 0 ? ((parseFloat(this.customerData?.CustomerConnectNBD?.MTD) / this.customerData?.CustomerConnectNBD?.TGT)*100) : 0;
      this.customerData.CustomerConnect.LMTD = this.customerData?.CustomerConnect?.LMTD_TOTAL - parseFloat(this.customerData?.CustomerConnectNBD.LMTD);
      this.customerData.CustomerConnect.YTD = this.customerData?.CustomerConnect?.YTD_TOTAL - parseFloat(this.customerData?.CustomerConnectNBD?.YTD);

      this.customerData.Customer360.MTD_TOTAL = this.customerData?.Customer360?.MTD_KEA + this.customerData?.Customer360?.MTD_OTHER;
      this.customerData.Customer360NBD.MTD = this.customerData?.Customer360NBD?.MTD_KEA + this.customerData?.Customer360NBD?.MTD_OTHER;
      this.customerData.Customer360.MTD = this.customerData?.Customer360?.MTD_TOTAL - this.customerData?.Customer360NBD?.MTD;        
      this.customerData.Customer360.LMTD_TOTAL = this.customerData?.Customer360?.LMTD_KEA + this.customerData?.Customer360?.LMTD_OTHER;
      this.customerData.Customer360NBD.LMTD = this.customerData?.Customer360NBD?.LMTD_KEA + this.customerData?.Customer360NBD?.LMTD_OTHER;
      this.customerData.Customer360.LMTD = this.customerData?.Customer360?.LMTD_TOTAL - this.customerData?.Customer360NBD?.LMTD;
      this.customerData.Customer360.YTD_TOTAL = this.customerData?.Customer360?.YTD + this.customerData?.Customer360NBD?.YTD;
      this.customerData.Customer360.ACHV = this.customerData?.Customer360?.TGT != 0 ? ((this.customerData?.Customer360?.MTD / this.customerData?.Customer360?.TGT) * 100) : 0;        
      this.customerData.Customer360NBD.ACHV = this.customerData?.Customer360NBD?.TGT != 0 ? ((this.customerData?.Customer360NBD?.MTD / parseFloat(this.customerData?.Customer360NBD?.TGT)) * 100) : 0;        
      this.customerData.Customer360.ACHV_TOTAL = this.customerData?.Customer360?.TGT_TOTAL != 0 ? ((this.customerData?.Customer360?.MTD_TOTAL / parseFloat(this.customerData?.Customer360?.TGT_TOTAL)) * 100) : 0;
      this.makeCustomerDataFormatted();
    }
  }
  makeCustomerDataFormatted(){
    this.customerData.Customer360.MTD_STRING = (this.customerData?.Customer360?.MTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.LMTD_STRING = (this.customerData?.Customer360?.LMTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.YTD_STRING = (this.customerData?.Customer360?.YTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.MTD_TOTAL_STRING = (this.customerData?.Customer360?.MTD_TOTAL).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.LMTD_TOTAL_STRING = (this.customerData?.Customer360?.LMTD_TOTAL).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.YTD_TOTAL_STRING = (this.customerData?.Customer360?.YTD_TOTAL).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.TGT_STRING = (parseFloat(this.customerData?.Customer360?.TGT)).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.ACHV_STRING = (this.customerData?.Customer360?.ACHV).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.TGT_TOTAL_STRING = (parseFloat(this.customerData?.Customer360?.TGT_TOTAL)).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360.ACHV_TOTAL_STRING = (this.customerData?.Customer360?.ACHV_TOTAL).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360NBD.MTD_STRING = (this.customerData?.Customer360NBD?.MTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360NBD.LMTD_STRING = (this.customerData?.Customer360NBD?.LMTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360NBD.YTD_STRING = (this.customerData?.Customer360NBD?.YTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360NBD.TGT_STRING = (parseFloat(this.customerData?.Customer360NBD?.TGT)).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.Customer360NBD.ACHV_STRING = (this.customerData?.Customer360NBD?.ACHV).toLocaleString('en-IN', {maximumFractionDigits: 0});

    this.customerData.CustomerConnect.TGT_STRING = (this.customerData.CustomerConnect.TGT).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnect.ACHV_STRING = (this.customerData.CustomerConnect.ACHV).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnect.MTD_STRING = (this.customerData.CustomerConnect.MTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnect.LMTD_STRING = (this.customerData.CustomerConnect.LMTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnect.YTD_STRING = (this.customerData.CustomerConnect.YTD).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnectNBD.TGT_STRING = (this.customerData?.CustomerConnectNBD?.TGT).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnectNBD.ACHV_STRING = (this.customerData?.CustomerConnectNBD?.ACHV).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnectNBD.MTD_STRING = (parseFloat(this.customerData?.CustomerConnectNBD?.MTD)).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnectNBD.LMTD_STRING = (parseFloat(this.customerData?.CustomerConnectNBD?.LMTD)).toLocaleString('en-IN', {maximumFractionDigits: 0});
    this.customerData.CustomerConnectNBD.YTD_STRING = (parseFloat(this.customerData?.CustomerConnectNBD?.YTD)).toLocaleString('en-IN', {maximumFractionDigits: 0});
  }

  makeWhereForFinancialYearOpen(){
      var tempOpp = `where : {
            Opportunity_Type_Contract__c : {eq : "New Contract"}
          `;
      var tempLead = `where : {
          `;
      var tempConnect = `where : {
            Call_Type__c : {ne : "Branch / OU Visit"}
          `;
      var tempSales = `where : {
        `;
      var tempUserVisit = `where : {
        `;
      if(this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
          tempOpp += `OwnerId : {in :[`;
          tempLead += `OwnerId : {in :[`;
          tempConnect += `OwnerId : { in : [`;
          tempSales += `KAM_KAE__c : {in : [`;
          tempUserVisit += `Id : {in : [`;
          this.userOptionSelected.forEach(elm => {
              tempOpp += `"`+elm+`",`;
              tempLead += `"`+elm+`",`;
              tempConnect += `"`+elm+`",`;
              tempSales += `"`+elm+`",`;
              tempUserVisit += `"`+elm+`",`;
          });
          tempOpp = tempOpp.slice(0,-1);
          tempOpp += `]}
          `;
          tempLead = tempLead.slice(0,-1);
          tempLead += `]}
          `;
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
          tempSales = tempSales.slice(0,-1);
          tempSales += `]}
          `;
          tempUserVisit = tempUserVisit.slice(0,-1);
          tempUserVisit += `]}
          `;
      }        
      if(this.lastMonthTillStart && this.lastMonthTillEnd){
        tempOpp += `and : [
          {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.lastMonthTillEnd+`"}}}},
        `;
        tempOpp += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.lastMonthTillStart+`"}}}}]
        `;
        tempLead += `and : [
          {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.lastMonthTillEnd+`"}}}},
        `;
        tempLead += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.lastMonthTillStart+`"}}}}]
        `;
      }
      if(this.lastMonthTillStart && this.lastMonthTillEnd){
          tempConnect += `and : [
            {Visit_Date__c : {lte : {value : "`+this.lastMonthTillEnd+`"}}},
          `;
          tempConnect += `{Visit_Date__c : {gte : {value : "`+this.lastMonthTillStart+`"}}}]
          `;
      }
      if(this.salesKraStart && this.salesKraEnd){
        tempSales += `and : [
          `;
        tempSales += `{ Date__c : {gte : {value : "`+this.salesKraStart+`"}} },
        `;
        tempSales += `{ Date__c : {lte : {value : "`+this.salesKraEnd+`"}} }
        `;
        tempSales += `]
        `;
      }
      var keaType = this.accountTypesSelected.filter(ele => (ele=='KEA' || ele=='MSME'));
      if(keaType.length > 0 && keaType[0] != ''){
        tempSales += `Account_Type__c : {in: [`;
        keaType.forEach(ele => {
          if(ele == 'KEA' || ele == 'MSME'){             
            tempSales += `"`+ele+`",`;
          }
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      else{
        tempSales += `Account_Type__c : {in: [`;
        tempSales += `"",`;
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
        tempSales += `Zone__c : {in: [`;
        this.zoneOptionSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.productListSelected.length > 0 && this.productListSelected[0] != ''){
        tempSales += `Product__c : {in: [`;
        this.productListSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if((this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '') || (this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != '')){
        if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
          tempConnect += `Zone__c : {in : [`;
          this.zoneOptionSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
        if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
          tempConnect += `Vertical__c : {in : [`;
          this.accountTypesSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
      }
      /*Lead Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempLead += `Customer_Type__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempLead += `"`+ele+`",`;
        });
        tempLead = tempLead.slice(0,-1);
        tempLead += `]}
        `;
      }
      /*Opportunity Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempOpp += `Account : {
                  Customer_Category__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempOpp += `"`+ele+`",`;
        });
        tempOpp = tempOpp.slice(0,-1);
        tempOpp += `]}}
        `;
      }
      /*User Account Type Added In Visit Targets */
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempUserVisit += `Account_Type__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempUserVisit += `"`+ele+`",`;
        });
        tempUserVisit = tempUserVisit.slice(0,-1);
        tempUserVisit += `]}
        `;
      }

      tempOpp += `}
      `;
      tempLead += `}
      `;
      tempConnect += `}
      `;
      tempSales += `}
      `;
      tempUserVisit += `}
      `;
      this.whereOppYearOpen = tempOpp;
      this.whereLeadYearOpen = tempLead;
      this.whereCustomerConnectLastMonth = tempConnect;
      this.whereSalesKRAForKEA = tempSales;
      this.userVisitCountWhere = tempUserVisit;
  }
  makeWhereForFinancialYear(){
      var tempOpp = `where : {
            Opportunity_Type_Contract__c : {eq : "New Contract"}
          `;
      var tempLead = `where : {
          `;
      var tempConnect = `where : {
        Call_Type__c : {ne : "Branch / OU Visit"}
      `;
      var tempSales = `where : {
      `;
      if(this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
          tempOpp += `OwnerId : {in :[`;
          tempLead += `OwnerId : {in :[`;
          tempConnect += `OwnerId : { in : [`;
          tempSales += `KAM_KAE__c : {in : [`;
          this.userOptionSelected.forEach(elm => {
              tempOpp += `"`+elm+`",`;
              tempLead += `"`+elm+`",`;
              tempConnect += `"`+elm+`",`;
              tempSales += `"`+elm+`",`;
          });
          tempOpp = tempOpp.slice(0,-1);
          tempOpp += `]}
          `;
          tempLead = tempLead.slice(0,-1);
          tempLead += `]}
          `;
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
          tempSales = tempSales.slice(0,-1);
          tempSales += `]}
          `;
      }
      if(this.currentYearStart && this.currentYearEnd){
          tempOpp += `and : [
            {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.currentYearEnd+`"}}}},
          `;
          tempOpp += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.currentYearStart+`"}}}}]
          `;
          tempLead += `and : [
            {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.currentYearEnd+`"}}}}
          `;
          tempLead += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.currentYearStart+`"}}}}]
          `;
          tempConnect += `and : [
            { Visit_Date__c : {lte : {value : "`+this.currentYearEnd+`"}}},
          `;
          tempConnect += `{Visit_Date__c : {gte : {value : "`+this.currentYearStart+`"}}}]
          `;
          tempSales += `and : [
            {Date__c : {gte : {value : "`+this.currentYearStart+`"}}},
            `;
          tempSales += `{ Date__c : {lte : {value : "`+this.currentYearEnd+`"}} }]
          `;
      }
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempSales += `Account_Type__c : {in: [`;
        this.accountTypesSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
        tempSales += `Zone__c : {in: [`;
        this.zoneOptionSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.productListSelected.length > 0 && this.productListSelected[0] != ''){
        tempSales += `Product__c : {in: [`;
        this.productListSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if((this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '') || (this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != '')){
        if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
          tempConnect += `Zone__c : {in : [`;
          this.zoneOptionSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
        if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
          tempConnect += `Vertical__c : {in : [`;
          this.accountTypesSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
      }
      /*Lead Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempLead += `Customer_Type__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempLead += `"`+ele+`",`;
        });
        tempLead = tempLead.slice(0,-1);
        tempLead += `]}
        `;
      }
      /*Opportunity Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempOpp += `Account : {
                  Customer_Category__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempOpp += `"`+ele+`",`;
        });
        tempOpp = tempOpp.slice(0,-1);
        tempOpp += `]}}
        `;
      }
      tempOpp += `}
      `;
      tempLead += `}
      `;
      tempConnect += `}
      `;
      tempSales += `}
      `;
      this.whereOppYear = tempOpp;
      this.whereLeadYear = tempLead;
      this.whereCustomerConnectYear = tempConnect;
      this.whereSalesKRAYTD = tempSales;
  }
  makeWhereForFinancialMonth(){
      var tempOpp = `where : {
            Opportunity_Type_Contract__c : {eq : "New Contract"}
          `;
      var tempLead = `where : {
          `;
      var tempConnect = `where : {
        Call_Type__c : {ne : "Branch / OU Visit"}
      `;
      var tempSales = `where : {
        `;
      if(this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
          tempOpp += `OwnerId : {in :[`;
          tempLead += `OwnerId : {in :[`;
          tempConnect += `OwnerId : { in : [`;
          tempSales += `KAM_KAE__c : {in : [`;
          this.userOptionSelected.forEach(elm => {
              tempOpp += `"`+elm+`",`;
              tempLead += `"`+elm+`",`;
              tempConnect += `"`+elm+`",`;
              tempSales += `"`+elm+`",`;
          });
          tempOpp = tempOpp.slice(0,-1);
          tempOpp += `]}
          `;
          tempLead = tempLead.slice(0,-1);
          tempLead += `]}
          `;
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
          tempSales = tempSales.slice(0,-1);
          tempSales += `]}
          `;
      }
      if(this.currentMonthStart && this.currentMonthEnd){
          tempOpp += `and : [
            {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.currentMonthEnd+`"}}}},
          `;
          tempOpp += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.currentMonthStart+`"}}}}]
          `;
          tempLead += `and : [
            {CreatedDate : {DAY_ONLY : {value : {lte : "`+this.currentMonthEnd+`"}}}},
          `;
          tempLead += `{CreatedDate : {DAY_ONLY : {value : {gte : "`+this.currentMonthStart+`"}}}}]
          `;
          tempConnect += `and : [
            { Visit_Date__c : {lte : {value : "`+this.currentMonthEnd+`"}} },
          `;
          tempConnect += `{ Visit_Date__c : {gte : {value : "`+this.currentMonthStart+`"}} }]
          `;
      }
      if(this.salesKraStart && this.salesKraEnd){
        tempSales += `and : [
          `;
        tempSales += `{ Date__c : {gte : {value : "`+this.salesKraStart+`"}} },
        `;
        tempSales += `{ Date__c : {lte : {value : "`+this.salesKraEnd+`"}} }
        `;
        tempSales += `]
        `;
      }
      var otherType = this.accountTypesSelected.filter(ele => (ele!='KEA' && ele!='MSME'));
      if(otherType.length > 0 && otherType[0] != ''){
        tempSales += `Account_Type__c : {in: [`;
        otherType.forEach(ele => {
          if(ele != 'KEA' && ele != 'MSME'){
            tempSales += `"`+ele+`",`;
          }
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      else{
        tempSales += `Account_Type__c : {in: [`;
        tempSales += `"",`;
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
        tempSales += `Zone__c : {in: [`;
        this.zoneOptionSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if(this.productListSelected.length > 0 && this.productListSelected[0] != ''){
        tempSales += `Product__c : {in: [`;
        this.productListSelected.forEach(ele => {
          tempSales += `"`+ele+`",`;
        }); 
        tempSales = tempSales.slice(0,-1);
        tempSales += `]}
        `;
      }
      if((this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '') || (this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != '')){
        if(this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != ''){
          tempConnect += `Zone__c : {in : [`;
          this.zoneOptionSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
        if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
          tempConnect += `Vertical__c : {in : [`;
          this.accountTypesSelected.forEach(ele => {
            tempConnect += `"`+ele+`",`;
          });
          tempConnect = tempConnect.slice(0,-1);
          tempConnect += `]}
          `;
        }
      }
      /*Lead Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempLead += `Customer_Type__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempLead += `"`+ele+`",`;
        });
        tempLead = tempLead.slice(0,-1);
        tempLead += `]}
        `;
      }
      /*Opportunity Account Type*/
      if(this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != ''){
        tempOpp += `Account : {
                  Customer_Category__c : {in : [`;
        this.accountTypesSelected.forEach(ele => {
          tempOpp += `"`+ele+`",`;
        });
        tempOpp = tempOpp.slice(0,-1);
        tempOpp += `]}}
        `;
      }
      tempOpp += `}
      `;
      tempLead += `}
      `;
      tempConnect += `}
      `;
      tempSales += `}
      `;
      this.whereOppMonth = tempOpp;
      this.whereLeadMonth = tempLead;
      this.whereCustomerConnectMonth = tempConnect;
      this.whereSalesKRA = tempSales;
  }
    
  @wire(graphql, { query: '$dynamicCurrentYearOpen' })
  getCurrentYearOpenDashboardData({data, errors}){
      if(data && this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
        this.dashboardData.OpportunityCreated.LMTD = data?.uiapi?.aggregate?.Opportunity?.totalCount ? (data?.uiapi?.aggregate?.Opportunity?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
        this.dashboardData.OpportunityCreated.LMTDPotential = data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value ? (data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
        this.dashboardData.Lead.LMTD = data?.uiapi?.aggregate?.Lead?.totalCount ? (data?.uiapi?.aggregate?.Lead?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
        this.dashboardData.Lead.LMTDPotential = data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value ? (data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
        this.customerData.CustomerConnect.LMTD_TOTAL = data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount ? (data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount) : 0;
        this.customerData.Customer360.MTD_KEA = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value) : 0;
        this.customerData.Customer360.LMTD_KEA = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.LM_TD__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.LM_TD__c?.sum?.value) : 0;
        this.customerData.Customer360NBD.MTD_KEA = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value) : 0;
        this.customerData.Customer360NBD.LMTD_KEA = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBD_LMTD__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBD_LMTD__c?.sum?.value) : 0;
        this.customerData.CustomerConnect.TGT = data?.uiapi?.aggregate?.User?.edges[0]?.node?.aggregate?.NumberOfVisits__c?.sum?.value ? ((data?.uiapi?.aggregate?.User?.edges[0]?.node?.aggregate?.NumberOfVisits__c?.sum?.value)*(this.numOfDaysInCurrentMonth)) : 0;
        this.customerData.CustomerConnectNBD.TGT = data?.uiapi?.aggregate?.User?.edges[0]?.node?.aggregate?.NumberOfVisitsNBD__c?.sum?.value ? ((data?.uiapi?.aggregate?.User?.edges[0]?.node?.aggregate?.NumberOfVisitsNBD__c?.sum?.value) * (this.numOfDaysInCurrentMonth)) : 0;
        this.isCurrentYearOpen = true;
        this.calculateTotalRevenue();
      }
      if(data){
        this.isSpinner = false;
      }
  }
  @wire(graphql, { query: '$dynamicCurrentYear' })
  getCurrentYearDashboardData({data, errors}){
      if(data && this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
          this.dashboardData.OpportunityCreated.OVERALL = data?.uiapi?.aggregate?.Opportunity?.totalCount ? (data?.uiapi?.aggregate?.Opportunity?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.OpportunityCreated.OVERALLPotential = data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value ? (data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.Lead.OVERALL = data?.uiapi?.aggregate?.Lead?.totalCount ? (data?.uiapi?.aggregate?.Lead?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.Lead.OVERALLPotential = data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value ? (data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.customerData.Customer360.YTD = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value - data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value) : 0;
          this.customerData.Customer360NBD.YTD = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value) : 0;
          this.customerData.CustomerConnect.YTD_TOTAL = data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount ? (data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount) : 0;
          this.isCurrentYear = true;      
          this.calculateTotalRevenue();
      }
      if(data){
        this.isSpinner = false;
      }
  }
  @wire(graphql, { query: '$dynamicCurrentMonth' })
  getCurrentMonthDashboardData({data, errors}){
      if(data && this.userOptionSelected.length > 0 && this.userOptionSelected[0] != ''){
          this.dashboardData.OpportunityCreated.MTD = data?.uiapi?.aggregate?.Opportunity?.totalCount ? (data?.uiapi?.aggregate?.Opportunity?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.OpportunityCreated.MTDPotential = data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value ? (data?.uiapi?.aggregate?.Opportunity?.edges[0]?.node?.aggregate?.Commited_Gati_Potentail__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.Lead.MTD = data?.uiapi?.aggregate?.Lead?.totalCount ? (data?.uiapi?.aggregate?.Lead?.totalCount).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.dashboardData.Lead.MTDPotential = data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value ? (data?.uiapi?.aggregate?.Lead?.edges[0]?.node?.aggregate?.Expected_Business_Per_Month__c?.sum?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}) : 0;
          this.customerData.Customer360.MTD_OTHER = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.Achievement_Amount_INR__c?.sum?.value) : 0;
          this.customerData.Customer360.LMTD_OTHER = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.LM_TD__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.LM_TD__c?.sum?.value) : 0;
          this.customerData.Customer360NBD.MTD_OTHER = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBDNetBiz__c?.sum?.value) : 0;
          this.customerData.Customer360NBD.LMTD_OTHER = data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBD_LMTD__c?.sum?.value ? (data?.uiapi?.aggregate?.Sales_KRA__c?.edges[0]?.node?.aggregate?.NBD_LMTD__c?.sum?.value) : 0;
          this.customerData.CustomerConnect.MTD_TOTAL = data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount ? data?.uiapi?.aggregate?.Customer_Connect__c?.totalCount : 0;
          this.isCurrentMonth = true;       
          this.calculateTotalRevenue();
          this.isSpinner = false;
      }
      if(data){
        this.isSpinner = false;
      }
  }
    
  get dynamicCurrentYearOpen() {
    this.isSpinner = true;
    //console.log('currentFinancialYearOpen',this.currentFinancialYearOpen);
    return gql`${this.currentFinancialYearOpen}`;
  }
  get dynamicCurrentYear() {
    this.isSpinner = true;
    console.log('currentFinancialYear',this.currentFinancialYear);
    return gql`${this.currentFinancialYear}`;
  }
  get dynamicCurrentMonth() {
    this.isSpinner = true;
    //console.log('currentFinancialMonth',this.currentFinancialMonth);
    return gql`${this.currentFinancialMonth}`;
  }

  get currentFinancialYearOpen(){
      return `query getSalesDashboardData { 
          uiapi{
            aggregate {
              User(`+
              this.userVisitCountWhere+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      NumberOfVisits__c{
                        sum{
                          value
                        }
                      }
                      NumberOfVisitsNBD__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Opportunity(`+
                this.whereOppYearOpen +
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Commited_Gati_Potentail__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Lead(`+
              this.whereLeadYearOpen+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Expected_Business_Per_Month__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Customer_Connect__c(`+
              this.whereCustomerConnectLastMonth+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Id{
                        count{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Sales_KRA__c(`+
              this.whereSalesKRAForKEA+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Target__c{
                        sum{
                          value
                        }
                      }
                      Achievement_Percentage__c{
                        avg{
                          value
                        }
                      }
                      Achievement_Amount_INR__c{
                        sum{
                          value
                        }
                      }
                      LM_TD__c{
                        sum{
                          value
                        }
                      }
                      NBDNetBiz__c{
                        sum{
                          value
                        }
                      }
                      NBD_LMTD__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }`;
  }
  get currentFinancialYear(){
      return `query getSalesDashboardData { 
          uiapi{
            aggregate {
              Opportunity(`+
                this.whereOppYear +
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Commited_Gati_Potentail__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Lead(`+
              this.whereLeadYear+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Expected_Business_Per_Month__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Customer_Connect__c(`+
              this.whereCustomerConnectYear+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Id{
                        count{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Sales_KRA__c(`+
              this.whereSalesKRAYTD+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Achievement_Amount_INR__c{
                        sum{
                          value
                        }
                      }
                      NBDNetBiz__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }`;
  }
  get currentFinancialMonth(){
      return `query getSalesDashboardData { 
          uiapi{
              aggregate {
              Opportunity(`+
                this.whereOppMonth +
              `){
                totalCount 
                edges{
                  node{
                    aggregate{
                      Commited_Gati_Potentail__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }                 
              }
              Lead(`+
              this.whereLeadMonth+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Expected_Business_Per_Month__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Customer_Connect__c(`+
              this.whereCustomerConnectMonth+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Id{
                        count{
                          value
                        }
                      }
                    }
                  }
                }
              }
              Sales_KRA__c(`+
              this.whereSalesKRA+
              `){
                totalCount
                edges{
                  node{
                    aggregate{
                      Target__c{
                        sum{
                          value
                        }
                      }
                      Achievement_Percentage__c{
                        avg{
                          value
                        }
                      }
                      Achievement_Amount_INR__c{
                        sum{
                          value
                        }
                      }
                      LM_TD__c{
                        sum{
                          value
                        }
                      }
                      NBDNetBiz__c{
                        sum{
                          value
                        }
                      }
                      NBD_LMTD__c{
                        sum{
                          value
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }`;
  }
}