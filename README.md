# todo_app_solidity
todo app smart contract

We will look into the following concepts in this contract-
* structs
* mapping
* events
* errors
* constructor
* modifier
* functions
* transfer eth

What this contract does?
* create a task, pay the taks creation fees (refundable after deducting 1% charges) and emit an event.
* check what tasks are there for a particular user.
* if any of the task is completed, toggle the task status.
* if all the tasks are completed, deduct 1% of all the reward as charges and transfer it back to the user and collect the charges as revenue.
* only owner can check the collected revenue.
* only owner can withdraw the revenue.
* only owner can set the new owner.