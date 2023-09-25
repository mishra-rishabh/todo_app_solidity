// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Todo {
    struct TaskTodo {
        string task;
        bool status;
    }

    uint collectedRevenue;
    address owner;

    mapping(address => TaskTodo[]) taskList;
    mapping(address => uint) rewardList;

    event TaskCreated(uint id, string task, bool status);
    event TaskToggled(uint id, string task, bool status);
    event TaskCompleted(address _addr);
    event WithdrawRevenue(uint value);

    error InvalidTask(uint taskId );
    error IncompleteTask(uint taskId );
    error TransactionFailed(uint value );
    error NotAnOwner(address _addr );

    constructor() {
        owner = msg.sender;
    }

    modifier ifTaskExist(uint _taskId) {
        if(taskList[msg.sender].length <= _taskId) {
            revert InvalidTask(_taskId);
        }

        _;
    }

    modifier onlyOwner() {
        if(msg.sender != owner) {
            revert NotAnOwner(msg.sender);
        }

        _;
    }

    function createTask(string calldata _task) external payable {
        require(msg.value == 0.0001 ether, "0.0001 eth required to create task");

        taskList[msg.sender].push(TaskTodo(_task, false));
        rewardList[msg.sender] += msg.value;

        emit TaskCreated(taskList[msg.sender].length - 1, _task, false);
    }

    function getTask() external view returns (TaskTodo[] memory) {
        return taskList[msg.sender];
    }

    function toggleTask(uint _taskId) external ifTaskExist(_taskId) {
        taskList[msg.sender][_taskId].status = ! taskList[msg.sender][_taskId].status;

        emit TaskToggled(_taskId, taskList[msg.sender][_taskId].task, taskList[msg.sender][_taskId].status);
    }

    function getReward() external view returns (uint) {
        return rewardList[msg.sender];
    }

    function completeTask() external payable {
        for(uint i = 0; i < taskList[msg.sender].length; i++) {
            if(!taskList[msg.sender][i].status) {
                revert IncompleteTask(i);
            }
        }

        uint reward = rewardList[msg.sender];
        uint charges = reward * 1/100;  // we need one percent as fees when rewarding user

        (bool sent, bytes memory data) = payable (msg.sender).call{value: reward - charges}("");

        if(!sent) {
            revert TransactionFailed(reward - charges);
        }

        collectedRevenue += charges;

        delete taskList[msg.sender];
        rewardList[msg.sender] = 0;

        emit TaskCompleted(msg.sender);
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function getRevenue() external view onlyOwner returns (uint) {
        return collectedRevenue;
    }

    function withdrawRevenue() external payable onlyOwner {
        (bool sent, bytes memory data) = payable (owner).call{value: collectedRevenue}("");

        if(!sent) {
            revert TransactionFailed(collectedRevenue);
        }

        emit WithdrawRevenue(collectedRevenue);
        
        collectedRevenue = 0;
    }
}