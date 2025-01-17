import { LightningElement, track, wire } from 'lwc';
import { gql, graphql } from "lightning/uiGraphQLApi";

export default class GraphQLTest extends LightningElement {
    columns = [
        {label : 'Industry', fieldName : 'Industry'},
        {label : 'Sum', fieldName : 'Sum'},
        {label : 'Avg', fieldName : 'Avg'},
        {label : 'Count', fieldName : 'Count'},
    ];
    @track resultData = [];
    get isData(){
        return this.resultData.length > 0 ? true : false;
    }
    whereClause = `where : {Industry : {ne : null}}`
    get str(){
  return `query getRevenue{
                uiapi{
                  aggregate{
                    Account(
                      groupBy : {Industry : {group : true}}`+
                      this.whereClause
                    +`) {
                      edges{
                        node{
                          aggregate{
                            Industry{
                              value
                            }
                            Amount__c{
                              sum {
                                value
                              }
                              count {
                                value
                              }
                              avg {
                                value
                              }
                            }
                          }
                        }
                      }
                      totalCount
                    }
                  }
                }
              }`;
        }

    // Wire decorator with dynamic query
    @wire(graphql, { query: '$dynamicQuery' })
    wiredGraphResult({data, error}) {
        if(data){
            this.resultData = data.uiapi?.aggregate?.Account?.edges.map(ele =>{
                return {
                    'Industry' : ele?.node?.aggregate?.Industry.value,
                    'Sum' : ele?.node?.aggregate?.Amount__c?.sum?.value,
                    'Avg' : ele?.node?.aggregate?.Amount__c?.avg?.value,
                    'Count' : ele?.node?.aggregate?.Amount__c?.count?.value
                }
            });
            console.log('YE LE DATA - ',JSON.stringify(this.resultData,null,2));
        } else if(error){
            console.log('DEKH KYA DIKKAT HAI - ',JSON.stringify(error,null,2));
        } else {
            console.log('KYA KAR RHA HAI BHAI...');
        }
    }

    // Method to return dynamic query
    get dynamicQuery() {
        return gql`${this.str}`;
    }
    handleChangeWhere(event){
      console.log('Clicked');
      this.whereClause = `where : {Industry : {eq : "FMCG"}}`
      console.log('String Now=>',this.str);
    }
}