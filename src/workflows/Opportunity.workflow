<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_on_Inactive_Opportunity_past_14_Days</fullName>
        <description>Notification on Inactive Opportunity past 14 Days</description>
        <protected>false</protected>
        <recipients>
            <recipient>Cocoa Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Dairy Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Edible Nuts Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>PD&amp;I Member</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>PD&amp;I Project Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>R&amp;D Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Scientist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Spice Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notification_on_Person_Added_to_the_Account_Teams</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Stage_Update</fullName>
        <description>Opportunity Stage Update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_Stage_Update</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_sent_for_approval_is_approved</fullName>
        <description>Opportunity sent for approval is approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_sent_for_approval_is_approved</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_sent_for_approval_is_rejected</fullName>
        <description>Opportunity sent for approval is rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_sent_for_approval_is_rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Capture_Cocoa_First_Deal_Date</fullName>
        <field>Cocoa_First_Deal_Date__c</field>
        <formula>TODAY()</formula>
        <name>Capture Cocoa First Deal Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update</fullName>
        <field>StageName</field>
        <literalValue>Development</literalValue>
        <name>Update Opportunity Stage to Develpment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sampling_Stage_Change</fullName>
        <field>Project_Status__c</field>
        <literalValue>Sampling</literalValue>
        <name>Sampling Stage Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_Move_to_Offering_For_Dairy_Sales</fullName>
        <field>StageName</field>
        <literalValue>Offering</literalValue>
        <name>Stage Move to Offering For Dairy Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Briefing_Evaluation_Change</fullName>
        <description>This will stamp the current time as the Briefing Evaluation Time change</description>
        <field>Briefing_Evaluvation_Change__c</field>
        <formula>NOW()</formula>
        <name>Update Briefing Evaluation Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Development_Status_Change</fullName>
        <description>This field update will stamp the time when the project status is changed to Development</description>
        <field>Development_Stage_Change__c</field>
        <formula>NOW()</formula>
        <name>Update Development Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PDNI_Approval_Status_to_Approved</fullName>
        <field>PDNI_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update PDNI Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PDNI_Approval_Status_to_InProgres</fullName>
        <field>PDNI_Approval_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update PDNI Approval Status to InProgres</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PDNI_Approval_Status_to_Rejected</fullName>
        <field>PDNI_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update PDNI Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PLM_Approval_Status_to_Approved</fullName>
        <field>PLM_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update PLM Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PLM_Approval_Status_to_InProgress</fullName>
        <field>PLM_Approval_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update PLM Approval Status to InProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PLM_Approval_Status_to_Rejected</fullName>
        <field>PLM_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update PLM Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Status_to_Development</fullName>
        <field>Project_Status__c</field>
        <literalValue>Development</literalValue>
        <name>Update Project Status to Development</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Project_Status_to_Project_Cancell</fullName>
        <field>Project_Status__c</field>
        <literalValue>Project Cancelled</literalValue>
        <name>Update Project Status to Project Cancell</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Development</fullName>
        <field>StageName</field>
        <literalValue>Development</literalValue>
        <name>Update Stage to Development</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Briefing_Evaluation</fullName>
        <field>Project_Status__c</field>
        <literalValue>Briefing Evaluation</literalValue>
        <name>Update to Briefing Evaluation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Development</fullName>
        <field>Project_Status__c</field>
        <literalValue>Development</literalValue>
        <name>Update to Development</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Project_Cancelled</fullName>
        <field>Project_Status__c</field>
        <literalValue>Project Cancelled</literalValue>
        <name>Update to Project Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Opportunity Stage Change to Development</fullName>
        <actions>
            <name>Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Project_Type__c</field>
            <operation>contains</operation>
            <value>Sample,Match,Develop,Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ContactId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Stage Change to Offering for Dairy Sales</fullName>
        <actions>
            <name>Stage_Move_to_Offering_For_Dairy_Sales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Development</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Project_Type__c</field>
            <operation>equals</operation>
            <value>Sample</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>Dairy Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sample_Accepted_Flag__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>Allows Dairy user to edit the Project Type to Sample and helps to change the Stage conversion</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Project Status Changes to Sampling</fullName>
        <actions>
            <name>Sampling_Stage_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Sample_Sent_Flag__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>The project status is changed to Sampling when the product sample status is on &quot; sample sent &quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Cocoa First Deal Date</fullName>
        <actions>
            <name>Capture_Cocoa_First_Deal_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closing Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Cocoa_First_Deal_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If first Gain Opportunity for Cocoa business unit is closed won then update the date field on Account level</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
