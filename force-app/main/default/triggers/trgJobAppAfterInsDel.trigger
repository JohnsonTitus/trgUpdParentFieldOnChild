trigger trgJobAppAfterInsDel on Job_Application (after insert, after delete) {

    //Use Case: Count number of applications against a position
    //on insert add and on delete subtract the count
    //Update the field - Application_Count__c on object Position

    //retrieve the the inserted or deleted application record
    Set<Id> positionId = new Set<Id>();

    List<Job_Application> applications = Trigger.isDelete ? Trigger.old : Trgger.new;

    //retrieve the position id from the retrieved application record
    for(Job_Application application : applications){
        positionId.add(application.Position__c);
    }

    //create a map collection based on the retrieved position id
    Map<Id, Position__c> positionMap = new Map<Id, Position__c>([select Id, Application_Count__c from Position__c where Id in :positionId]);

    //retrieve the position and its relevant job applications child records based on the map collection
    List<Position__c> positions = [select Name, Application_Count__c, (select Id from Job_Application__r)  from Position__c where Id in :positionId];
    List<Position__c> positionsToUpdate = new List<Position__c>();

    //update the field - Application_Count__c of that Position record stored in the map
    //and add to the list
    for(Position__c position : positions){
        positionMap.get(position.Id).Application_Count__c = position.Job_Application__r.size();
        positionsToUpdate.add(positionMap.get(position.Id));
    }

    //update the list
    update positionsToUpdate;

}