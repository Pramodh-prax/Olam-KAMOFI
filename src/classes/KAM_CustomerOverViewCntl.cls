public with sharing class KAM_CustomerOverViewCntl implements KAM_AccountPlan{
    
    public String getDetails (String data) {
        return JSON.serialize(new Map<String, Object> {'fields' => getDisplayableAccountFields ()});
    }

    private static List<FieldWrapper> getDisplayableAccountFields () {
        Map<String, Schema.FieldSet> accountFieldSetMap = Schema.SObjectType.Account.fieldSets.getMap();
        Schema.FieldSet fieldSet = SObjectType.Account.FieldSets.Default;
        if (accountFieldSetMap.containsKey (Label.CustomerOverViewSectionFieldSetName)) {
            fieldSet = accountFieldSetMap.get (Label.CustomerOverViewSectionFieldSetName);
        }
        List<FieldWrapper> listOfFieldsToShow = new List<FieldWrapper> ();
        for(Schema.FieldSetMember f : fieldSet.getFields ()) {
            listOfFieldsToShow.add (
                new FieldWrapper (
                    f.getLabel(),
                    f.getFieldPath()
                ));
        }
        return listOfFieldsToShow;
    }
}