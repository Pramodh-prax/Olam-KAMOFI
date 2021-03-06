<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Integration_failed_update_to_Agent</fullName>
        <description>Integration failed update to Agent</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Integration_failed_update_notification</template>
    </alerts>
    <alerts>
        <fullName>Integration_failed_update_to_pdni</fullName>
        <description>Integration failed update to pdni</description>
        <protected>false</protected>
        <recipients>
            <field>PD_I_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Integration_failed_update_notification</template>
    </alerts>
    <alerts>
        <fullName>Product_sample_Sent_to_the_customer</fullName>
        <description>Product sample Sent to the customer</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Product_sample_Sent_to_the_customer</template>
    </alerts>
    <alerts>
        <fullName>Sampling_Status_Update</fullName>
        <description>Sampling Status Update</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sampling_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>Sampling_status_update_notification_to_agent</fullName>
        <description>Sampling_status_update_notification_to_agent</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sampling_status_update_notification_to_agent</template>
    </alerts>
    <alerts>
        <fullName>Sampling_status_update_notification_to_pdi</fullName>
        <description>Sampling_status_update_notification_to_pdi</description>
        <protected>false</protected>
        <recipients>
            <field>PD_I_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sampling_status_update_notification_to_pdi</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateCommercialisedCheckbox</fullName>
        <field>IsCommercialisedProduct__c</field>
        <literalValue>1</literalValue>
        <name>UpdateCommercialisedCheckbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IsCommericalisedProduct</fullName>
        <actions>
            <name>UpdateCommercialisedCheckbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.External_Product_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
