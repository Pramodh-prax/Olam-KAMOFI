<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Notification_for_Addition_of_New_users_on_Opportunity_Team</fullName>
        <description>Email Notification for Addition of New users on Opportunity Team</description>
        <protected>false</protected>
        <recipients>
            <field>UserId</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notification_on_person_added_to_the_opportunity_teams</template>
    </alerts>
    <rules>
        <fullName>Notification on person added to the opportunity teams</fullName>
        <actions>
            <name>Email_Notification_for_Addition_of_New_users_on_Opportunity_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification on person added to the opportunity teams</description>
        <formula>isnew()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
