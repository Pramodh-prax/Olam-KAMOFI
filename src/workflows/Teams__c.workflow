<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_for_User_on_Account_Teams_Added</fullName>
        <description>Notification for User on Account Teams Added</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notification_on_Person_Added_to_the_Account_Teams</template>
    </alerts>
    <rules>
        <fullName>Notification on Person Added in Account Teams</fullName>
        <actions>
            <name>Notification_for_User_on_Account_Teams_Added</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Sent notification to new account team member</description>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
