({
	doInit : function(cmp, event, helper) {
		var action = cmp.get("c.getEventInfo");
		action.setParams({ eventId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.event", response.getReturnValue());
                var myEvent = response.getReturnValue();
                if (myEvent !== null) {
                    cmp.set("v.startDate", myEvent.StartDateTime);
                    cmp.set("v.endDate", myEvent.EndDateTime);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
        
        helper.getAllSkills(cmp);
	},
    checkAvailableAssignee : function(cmp, event, helper) {
		var action = cmp.get("c.getAvailableUsers");
		action.setParams({ 
            startDateTime : cmp.get("v.startDate"), 
            endDateTime : cmp.get("v.endDate"),
            skillIds : cmp.get("v.selectedSkillIds")
        });
        helper.toggleSpinner(cmp);
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.users", response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            var noavailmessage = cmp.find("no-availability");
            $A.util.removeClass(noavailmessage, "slds-hide");
            helper.toggleSpinner(cmp);
        });
        
        $A.enqueueAction(action);
    },
    assignToEvent : function(cmp, event, helper) {
		var action = cmp.get("c.assignUserToEvent");
        
        console.log(event.target.id);
        var userId = event.target.id;
		action.setParams({ 
            userId : userId,
            eventId : cmp.get("v.recordId"),
            startDateTime : cmp.get("v.startDate"), 
            endDateTime : cmp.get("v.endDate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if (response.getReturnValue() === '') {
                    // succesful
                    helper.showToast('Success', 'Event has been assigned successfully.', 'success');
                } else {
                    // failed
                    helper.showToast('Error', 'Failed to assign event.', 'error');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    onSelectChange : function(cmp, event, helper) {
        var selected = cmp.find("skills").get("v.value");
        if (selected == '') {
            cmp.set("v.selectedSkillIds", []);
        } else {
        	cmp.set("v.selectedSkillIds", selected.split(";"));
        }
    }
})