#For Package Testing
sfdx force:org:create -f config/project-scratch-def.json  -d 3 -a HelpDeskScratchOrgPkg -s
#sfdx force:org:create -f config/project-scratch-def.json  -d 30 -a HelpDeskScratchOrgPkg -s -v LabsDevHub

#Test 2GP Package
#sfdx force:package:install -p  -u HelpDeskScratchOrgPkg -k test1234 -w 10 -b 10

#Test 1GP Package
sfdx force:package:install -p 04t3h0000010kW5  -w 10

sfdx force:user:permset:assign -n  helpdesk__HelpDesk_Admin

sfdx force:apex:execute -f config/create-demo-data.apex

sfdx force:data:tree:import --plan data/helpdesk-Ticket__c-plan.json

sfdx force:org:open 
