#!/bin/bash

### Requirement 3 ##
#automate the process of creating, assigning, deleting a directory user
#include: azure, must be admin, add role of reader or contributor to subscription, 
#remove role of reader or contributor to subscription, delete non-admin only

# the username of the admin
adminUserName=$1

# checks to see if az is currently installed
if [ -z "$(which az)" ]; then
    echo "azure does not exist"
    exit 1
fi

## Create Function ##
create()
{
    # the variables you need to use for the create function 
    # name you want to give the person
    userdisplayname=$1
    DOMAIN=mschw90gmail.onmicrosoft.com
    userprincipalname=$userdisplayname@$DOMAIN
    password=Thereisnopassword123!
    # the name of the subscription you want to give the user
    usersubscription=$2

    # uses the user list to query the array and return the object with that username if it exist 
    # and then isolates the user principal names into an array and then checks to see if the username exist
    result=$(az ad user list --query [].userPrincipalName | grep -E $userprincipalname)

    # if the user does not currently exist then create user
    if [ -n "$result" ]; then
        echo "This user already exist"
        exit 1
    fi

    ## the create call ##
     az ad user create \
        --display-name $userdisplayname \
        --user-principal-name $userprincipalname \
        --force-change-password-next-login \
        --password $password \
        --subscription $usersubscription
    echo "you have successfully created the user"
}

## Assign Function ##
assign() 
{
    # username is the user principle name of the user you want to add role for
    displayname=$1
    username=$displayname@mschw90gmail.onmicrosoft.com
    # the action you want to use "create" or "delete" a role
    action=$2
    # the role you want to give the user "reader" or "contributor"
    role=$3

    # uses the user list to query the array and return the object with that username if it exist 
    # and then isolates the user principal names into an array and then checks to see if the username exist
    result=$(az ad user list --query [].userPrincipalName | grep -E $username)

    # checks to see if the user exist
    if [ -z "$result" ]; then
        echo "this user does not exist try different user"
        exit 1
    fi

    # checks to see if you wrote create or delete as your action
    if [ $action != "create" ] && [ $action != "delete" ]; then 
        echo "not a valid action"
        exit 1
    fi
    # checks to see if you wrote "reader" or "contributor"
    if [ $role != "reader" ] && [ $role != "contributor" ]; then 
        echo "this is not a valid role to assign"
        exit 1
    fi

    ## the assign call ##
    az role assignment $action \
    --assignee $username \
    --role $role
    echo "you have have successfully used assign"

}

## Delete Function ##
delete()
{
    # name of the username you want to delete
    username=$1
    userprincipalname=$username@mschw90gmail.onmicrosoft.com

    # uses the user list to query the array and return the object with that username if it exist 
    # and then isolates the user principal names into an array and then checks to see if the username exist
    result=$(az ad user list --query [].userPrincipalName | grep -E $userprincipalname)

    if [ -z "$result" ]; then
        echo "the user does not currently exist"
        exit 1
    fi

    #looks into the role assignment list and using jmespath to see if the user has an id with 
    #NA(classic admin) and returns the user-priciple-name, After you use grep to see if the
    #userprincipalname var is in the rturned array
    admin=$(az role assignment list \
    --include-classic-administrators \
    --query "[?id=='NA(classic admins)'].principalName" | grep -E $userprincipalname)

    # checks to see if the user is an admin
    if [ -n "$admin" ]; then
        echo "can not delete user that is an admin"
        exit 1
    fi

    ## the delete call ##
    az ad user delete \
    --upn-or-object-id $userprincipalname
    echo "you have successfully deleted user"
}

#looks into the role assignment list and using jmespath to see if the user has an id with 
#NA(classic admin) and returns the user-priciple-name, After you use grep to see if the
#userprincipalname var is in the rturned array
admin=$(az role assignment list \
    --include-classic-administrators \
    --query "[?id=='NA(classic admins)'].principalName" | grep -E $adminUserName)

# checks to see if the user is an admin
if [ -z "$admin" ]; then 
    echo "you must be an admin to access this file"
    exit 1
fi

# where you call the functions create, assign and delete
command=$2
$command $3 $4 $5

exit 0