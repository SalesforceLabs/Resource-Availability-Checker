public with sharing class EventScheduler {
	@AuraEnabled
    public static Event getEventInfo(string eventId) {
        List<string> eventFields = new List<string> {
            'Id',
            'StartDateTime',
            'EndDateTime' 
        };
        boolean isAccessible = checkEventFieldLevelSecurity(eventFields);
        if (isAccessible) {
            List<Event> events = [Select Id, StartDateTime, EndDateTime from Event where Id =:eventId];
            if (events.size() > 0) {
                return events[0];
            }
        }
        return null;
    }
    
    private static boolean checkEventUpdateFieldLevelSecurity(List<string> fields) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Event.fields.getMap();
        
        for (String fieldToCheck : fields) {
            if (!fieldMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    } 
    
    private static boolean checkEventFieldLevelSecurity(List<string> fields) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.Event.fields.getMap();
        
        for (String fieldToCheck : fields) {
            if (!fieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
                return false;
            }
        }
        return true;
    }
    
    private static boolean checkUserFieldLevelSecurity(List<string> fields) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.User.fields.getMap();
        
        for (String fieldToCheck : fields) {
            if (!fieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
                return false;
            }
        }
        return true;
    }

	@AuraEnabled
    public static List<User> getAvailableUsers(Datetime startDateTime, Datetime endDateTime, List<String> skillIds)
    {
        List<User> users = new List<User>();
        List<string> eventFields = new List<string> {
            'OwnerId',
            'StartDateTime',
            'EndDateTime'
        };
        boolean isEventAccessible = checkEventFieldLevelSecurity(eventFields);
        if (isEventAccessible) {
            List<Event> conflictingEvents = [SELECT OwnerId FROM Event 
                                             Where (StartDateTime <= :startDateTime and EndDateTime >:startDateTime)
                                             OR (StartDateTime < :endDateTime and EndDateTime >=:endDateTime)
                                            ];
            List<string> unavailableUserIds = new List<string>();
            for (Event event : conflictingEvents) {
                unavailableUserIds.add(event.OwnerId);
            }
            List<string> userFields = new List<string> {
                	'Id',
                    'Name',
                    'SmallPhotoUrl',
                    'UserType',
                    'IsActive',
                    'UserRoleId'
                    };
            boolean isUserAccessible = checkUserFieldLevelSecurity(userFields);
            boolean isSkillQualicationAccessible = checkSkillQuanlificationFieldLevelSecurity(
                new List<string> {'cxu_scheduler__Skill__c', 'cxu_scheduler__User__c'}
            );
            if (isUserAccessible && isSkillQualicationAccessible) {
                List<User> allUsers = [Select Id, Name, SmallPhotoUrl, 
                                       (SELECT cxu_scheduler__Skill__c 
                                        FROM cxu_scheduler__Skill_Qualifications__r 
                                        WHERE cxu_scheduler__Skill__c IN :skillIds)
                         from User 
                         where Id NOT IN :unavailableUserIds and UserType = 'Standard'
                         and IsActive = true ];
                for (User user : allUsers) {
                    if (user.Skill_Qualifications__r.size() >= skillIds.size()) {
                        // user does not have all skills
                        users.add(user);
                    }
                }
            }
        }
        return users;
    }
    
	@AuraEnabled
    public static string assignUserToEvent(string userId, string eventId, Datetime startDateTime, Datetime endDateTime) {
        
        List<string> eventFields = new List<string> {'OwnerId', 'StartDateTime', 'EndDateTime'};

        List<Event> events = [Select Id, OwnerId from Event where Id =:eventId];
        if (events.size() > 0) {
            Event event = events[0];
            event.OwnerId = userId;
            event.StartDateTime = startDateTime;
            event.EndDateTime = endDateTime;
            try {
                boolean isEventUpdatable = checkEventUpdateFieldLevelSecurity(eventFields);
                if (isEventUpdatable) {
                	update event;
                } else {
                    return 'You do not have access to update event ownership.';
                }
            } catch (Exception e) {
                system.debug(e.getMessage());
                return e.getMessage();
            }
        	return '';
        } else {
        	return 'Record is not of type "Event".';
        }
    }
    
    
	@AuraEnabled
    public static List<cxu_scheduler__Skill__c> getSkills() {

        List<string> skillFields = new List<string> {'Id','Name'};  
        if (checkSkillFieldLevelSecurity(skillFields)) {
            List<cxu_scheduler__Skill__c> skills = [SELECT Id, Name FROM cxu_scheduler__Skill__c];
            return skills;
        } else {
            return null;
        }
    }
    
    
    private static boolean checkSkillFieldLevelSecurity(List<string> fields) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.cxu_scheduler__Skill__c.fields.getMap();
        
        for (String fieldToCheck : fields) {
            if (!fieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
                return false;
            }
        }
        return true;
    } 
    private static boolean checkSkillQuanlificationFieldLevelSecurity(List<string> fields) {
        Map<String,Schema.SObjectField> fieldMap = Schema.SObjectType.cxu_scheduler__Skill_Qualification__c.fields.getMap();
        
        for (String fieldToCheck : fields) {
            if (!fieldMap.get(fieldToCheck).getDescribe().isAccessible()) {
                return false;
            }
        }
        return true;
    } 
}