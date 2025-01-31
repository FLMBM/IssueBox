/**
 * @description       : 
 * @author            : brandon@flavorman.com
 * @group             : 
 * @last modified on  : 02-05-2022
 * @last modified by  : brandon@flavorman.com
**/
trigger Ticket on Ticket__c (before insert, before update) {
    //Replace protocol from URL__c field to keep it secure
    //E.g. change ftp://www to /www
	String regExp = '(^.*:|^)//';
	Pattern p = Pattern.compile(regExp); 
    for(Ticket__c i: Trigger.new){
        //Check if URL has an value
        //If null then don't process otherwise it will result in exception
        if(!String.isBlank(i.URL__c)){
            Matcher m = p.matcher(i.URL__c);
            i.URL__c = m.replacefirst('/');
        }
    }
}