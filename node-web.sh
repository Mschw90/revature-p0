#!/bin/bash

start()
{
    filename=$1

    #check to see if node is currently installed if it isnt it will run the first script file ./linux-setup.sh
    if [ -z $(which node) ]; then
        echo "node is not installed yet"
        echo "installing "
        ./linux-setup.sh
    fi

    # -e check to see if the file exist if it does it will run the node command to fun the file else return an error
    if [ -e $filename ]; then
        node $filename
    else
        echo "file does not exist"
        exit 1
    fi

    
}

stop()
{

}

command=$1
$command $2

exit 0