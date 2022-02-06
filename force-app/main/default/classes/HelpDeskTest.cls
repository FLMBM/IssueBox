/**
 * @description       : 
 * @author            : brandon@flavorman.com
 * @group             : 
 * @last modified on  : 02-05-2022
 * @last modified by  : brandon@flavorman.com
**/
@isTest
public with sharing class HelpDeskTest {
    private static void createTestData(Integer numberRecords){
        List<Ticket__c> ticketList = new List<Ticket__c>();
        for(Integer i=0; i< numberRecords; i++){
            Ticket__c ticket = new Ticket__c();
            ticket.Details__c = 'Ticket #' + i;
            ticket.URL__c = 'http://www.test.com';
            ticketList.add(ticket);
        }
        insert ticketList;
    }
    private static User setupUser(String profileName){
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User u = new User(Alias = 'standt', Email='standarduser@helpdesk.app',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        insert u;
        return u;
    }
    private static void assignPermissionSet(String permSetName, Id userId){
        PermissionSet ps = [select id, name from PermissionSet where name=:permSetName];
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = ps.Id
        );
        insert psa;
    }
    
    @isTest 
    static void helpDesk_getTicketCount_Test_runAs_negative(){
        User u = setupUser('Standard User');
        //No permission set assignment as we want to raise exception
        //assignPermissionSet('HelpDesk_User', u.Id);

        System.runAs(u) {
            try{
            	createTestData(10);
            }Catch(Exception e){
                //Because user doens't have permission set assigned, user cannot even create records
                System.assertEquals(0, [select count() from Ticket__c]);
            } 

            //This should fail becasue we didn't assign permission set
            //Need to run this outside of try so we can trigger exception in HelpDesk and also for code coverage
            System.assertEquals(0, HelpDesk.getTicketCount());
        }
    }
    
    @isTest
    //Test to make sure ticket Count is returned properly
    private static void helpDesk_getTicketList_Test_runAs_negative() {
        User u = setupUser('Standard User');
        //No permission set assignment as we want to raise exception
        //assignPermissionSet('HelpDesk_User', u.Id);

        System.runAs(u) {
            try{
                createTestData(10);
            }Catch(Exception e){
                //Because user doens't have permission set assigned, user cannot even create records
                System.assertEquals(0, [select count() from Ticket__c]);
            }
            
            List<Ticket__c> ticketList = HelpDesk.getTicketList(1, 10, 10);
            //Need to run this outside of try so we can trigger exception in HelpDesk and also for code coverage
            //Because no permission set is assigned, this should fail
            System.assertEquals(0, ticketList.size());
        }
    }
    
    @isTest
    //Test to make sure ticket Count is returned properly
    private static void helpDesk_getTicketList_Test_runAs() {
        User u = setupUser('Standard User');
        assignPermissionSet('HelpDesk_User', u.Id);

        System.runAs(u) {
            createTestData(10);
            List<Ticket__c> ticketList = HelpDesk.getTicketList(1, 10, 10);
            
            System.assertEquals(10, ticketList.size());
            //Tickets are sorted in descending order based on Ticket Number (auto number) so last ticket inserted will show up first
            System.assertEquals('Ticket #9', ticketList[0].Details__c);
            //Checking trigger coverage, Protocol from URL is removed in trigger and replaced with "/"
            System.assertEquals('/www.test.com', ticketList[0].URL__c);
            
            
            createTestData(5);
            //Even though we requested 10 tickets, it's second page. Becasue there are total 15 records, it will only return 5
            ticketList = HelpDesk.getTicketList(2, 10, 20);
            System.assertEquals(5, ticketList.size());
            System.assertEquals('Ticket #4', ticketList[0].Details__c);
        }
    }
    @isTest
    //Test to make sure ticket Count is returned properly
    private static void helpDesk_getTicketList_Test() {
        User u = setupUser('System Administrator');
        assignPermissionSet('HelpDesk_Admin', u.Id);
        System.runAs(u){
            createTestData(10);
            List<Ticket__c> ticketList = HelpDesk.getTicketList(1, 10, 10);
            
            System.assertEquals(10, ticketList.size());
            //Tickets are sorted in descending order based on Ticket Number (auto number) so last ticket inserted will show up first
            System.assertEquals('Ticket #9', ticketList[0].Details__c);
            //Checking trigger coverage, Protocol from URL is removed in trigger and replaced with "/"
            System.assertEquals('/www.test.com', ticketList[0].URL__c);
            
            
            createTestData(5);
            //Even though we requested 10 tickets, it's second page. Becasue there are total 15 records, it will only return 5
            ticketList = HelpDesk.getTicketList(2, 10, 20);
            System.assertEquals(5, ticketList.size());
            System.assertEquals('Ticket #4', ticketList[0].Details__c);
        }
    }
    
    
    @isTest static void helpDesk_getTicketCount_Test_runAs(){
        User u = setupUser('Standard User');
        assignPermissionSet('HelpDesk_User', u.Id);

        System.runAs(u) {
            createTestData(10);
            System.assertEquals(10, HelpDesk.getTicketCount());
            
            createTestData(10);
            System.assertEquals(20, HelpDesk.getTicketCount());
        }
    }
    
    @isTest
    //Test to make sure ticket Count is returned properly
    private static void helpDesk_getTicketCount_Test_positive() {
        User u = setupUser('System Administrator');
        assignPermissionSet('HelpDesk_Admin', u.Id);
        System.runAs(u){
            createTestData(10);
            System.assertEquals(10, HelpDesk.getTicketCount());
            
            createTestData(10);
            System.assertEquals(20, HelpDesk.getTicketCount());
        }
    }
/**/
}