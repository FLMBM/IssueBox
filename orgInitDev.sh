#For development and creating package
sfdx force:org:create -f config/project-scratch-def.json  -d 30 -a HelpDeskScratchOrg -s 
#-v LabsDevHub

sfdx force:source:push -f -u HelpDeskScratchOrg

sfdx force:user:permset:assign -n  HelpDesk_Admin -u HelpDeskScratchOrg

sfdx force:apex:execute -f config/create-demo-data.apex -u HelpDeskScratchOrg

sfdx force:data:tree:import --plan data/helpdesk-Ticket__c-plan.json -u HelpDeskScratchOrg

sfdx force:org:open -u HelpDeskScratchOrg

#sfdx force:lightning:lwc:start 

#sfdx force:data:tree:export --query  "SELECT Details__c,ContactName__c,EmailNotification__c,ExpectedOutcome__c,Priority__c,ReportedObject__c,ReportedRecord__c, StepstoReproduce__c,Status__c,Type__c,Department__c from Ticket " --prefix issuebox --outputdir data --plan

#Create package - ONE TIME - in Dev Hub
#sfdx force:package:create -n "Help Desk" -r force-app  -t Managed -v LabsDevHub
#sfdx force:package:create -n "Help Desk" -r force-app  -t Managed

#Create package - Version - in Dev Hub
#sfdx force:package:version:create -p "Help Desk" -k test1234 --wait 10 -v LabsDevHub -c -f config/project-scratch-def.json
#sfdx force:package:version:create -p "Help Desk" -k test1234 --wait 10 -c -f config/project-scratch-def.json
#sfdx force:package:version:create:list --createdlastdays 0 -v LabsDevHub


#INSTALL - in pkg test scratch org
#sfdx force:package:install -p "Help Desk@0.1.0-1" -u HelpDeskScratchOrgPkg -k test1234 -w 10 -b 10

#Deploy to Dev Org: Use -c to check only first
#If in MDAPI format
#sfdx force:mdapi:deploy -d src -u HelpDeskDevOrg -w 100 
#If in SFDX format, comma separated list
#sfdx force:source:deploy -u HelpDeskDevOrg -p "force-app/main/default/"