#!/bin/bash

username=$1
password=$2

create()
{
    userdisplayname=$1
    DOMAIN=mschw90gmail.onmicrosoft.com
    userprincipalname=$userdisplayname@$DOMAIN
    random=Thereisnopassword123!
    usersubscription=$2

    # creates a new user if the user doesnt already exist 
    result=$(az ad user list --query [].userPrincipalName | grep -E /$userdisplayname/)

    if [ -n $result ]; then
        az ad user create \
        --display-name $userdisplayname \
        --user-principal-name $userprincipalname \
        --force-change-password-next-login \
        --password $random \
        --subscription $usersubscription
    else 
        echo "user already exist"
        exit 1
    fi
}

assign() 
{
    action=$1
    #username is the user principle name of the user you want to add role for
    username=$2
    role=$3

    result=$(az ad user list --query [].userPrincipalName | grep -E /$username/)

    if [ $action != "create" ] && [ $action != "delete" ]; then 
        echo "not a valid action"
        exit 1
    fi

    if [ -n $result ]; then
        echo "this user does not exist try different user"
        exit 1
    fi

    if [ $role != "reader" ] && [ $role != "contributor" ]; then 
        echo "this is not a valid role to assign"
    fi

    az role assignment $action --assignee $username --role $role

}

delete()
{
    
}

 # login to the admin
az login -u $username 

admin=$(az role assignment list \
    --include-classic-administrators \
    --query "[?id=='NA(classic admins)'].principalName" | grep -E $username)

echo $admin


if ! [ -z $admin ]; then 
    # where i call the functions assign delete
    command=$3
    $command $4 $5 $6
else 

    echo "you must be an admin to access this file"

    exit 1

fi

exit 0create