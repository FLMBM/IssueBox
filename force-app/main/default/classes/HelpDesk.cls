/**
 * @description       : 
 * @author            : brandon@flavorman.com
 * @group             : 
 * @last modified on  : 02-05-2022
 * @last modified by  : brandon@flavorman.com
**/
public with sharing class HelpDesk {
     @AuraEnabled (cacheable = true)
    /**
     * Return list of tickets; result will be paginated so records will be sent based on calculation of pageNumber and pageSize
     * totalrecords is NOT used but we pass it so we can refresh Wire method on lwc size when this changes
     * 
     * This method is cached because it's used in wire
     */
    public static List<Ticket__c> getTicketList(Integer pageNumber, Integer pageSize, Integer totalRecords) {
        List<Ticket__c> ticketList = new List<Ticket__c>(); 

        try{
            Integer offset = (pageSize * (pageNumber - 1));
            ticketList = [SELECT 
                    ID, Name, Details__c, ExpectedOutcome__c, Priority__c, ReportedObject__c,
                    ReportedRecord__c, StepstoReproduce__c, Type__c, Department__c, AssignedTo__c, ContactName__c, AssignedTo__r.Name
                    FROM Ticket__c WITH SECURITY_ENFORCED
                    ORDER BY Name DESC
                    limit :pageSize OFFSET :offset
                ];
        }catch(Exception e){ Util.log('HelpDesk:getTicketList():Exception' + e.getMessage());}
        return ticketList;
    }
	/**
	 * Return total ticket records
	 * This count will be used for pagination
     * 
     * This method is cached because it's used in wire
	 */
    @AuraEnabled (cacheable = true)
    public static Integer getTicketCount() {  
        Integer count = 0;
        try{
            count = [SELECT count()  FROM Ticket__c WITH SECURITY_ENFORCED];
        }catch(Exception e){ Util.log('HelpDesk:getTicketList():Exception' + e.getMessage());}
        return count; 
    } 
}