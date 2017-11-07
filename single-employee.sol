pragma solidity ^0.4.14;
contract payroll {
    uint salary = 1 ether;
    address employer = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address employee = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    uint payDuration = 10 seconds;
    uint lastPayday = now;
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    function calculateRunway() returns (uint){
        if(salary == 0) revert();
        return this.balance/salary;
    }
    
    function hasEnoughFund() returns(bool){
        return calculateRunway() > 0;
    }
    
    function updateEmployment(address _employee, uint _lastPayday, uint _salary, uint _payDuration){
        //access control && revert if the address is invalid 
        //input format:"0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "now", "20", "5 seconds"
        if(msg.sender != employer || _employee == 0x0) revert();
        employee = _employee;
        lastPayday = _lastPayday;
        salary = _salary * 1 ether;
        payDuration = _payDuration;
  
    }
    function getPaid(){
        if(msg.sender != employee) revert();
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) revert();
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}