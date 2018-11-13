<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_ID</fullName>
        <field>Unique_Id__c</field>
        <formula>Skill__c +  User__c</formula>
        <name>Update Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Prevent Duplicate Skill Assignment</fullName>
        <actions>
            <name>Update_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL( Skill__c )) &amp;&amp;  NOT(ISNULL(  User__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
