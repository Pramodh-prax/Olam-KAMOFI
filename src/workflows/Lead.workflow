<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_on_Inactive_Lead_past_30_Days</fullName>
        <description>Notification on Inactive Lead past 30 Days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Cocoa_Global_OCPRO_Head</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Unattended_lead_notification</template>
    </alerts>
</Workflow>
