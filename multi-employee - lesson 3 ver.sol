pragma solidity ^0.4.14;

import './Ownable.sol';
import './SafeMath.sol';

contract Payroll is Ownable{
    using SafeMath for uint;
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint totalSalary = 0;
    uint constant payDuration  = 10 seconds;
    mapping(address => Employee) public employees;
    
/////////////////// modifiers /////////////////////

     modifier employeeExist(address employeeId){
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    modifier  employeeNotExist(address employeeId){
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }
    
    //just like inline?? / decorator
    modifier onlyOwner{
        require(msg.sender == owner);
        // add at beginning
        _;
        // copy the following codes
    }
    
//////////////////////////////////////////////////
    function Payroll(){
        //constructor
        owner = msg.sender;
    }
    
    // visibitliy: private
    function _partialPaid(Employee employee) private employeeExist(employee.id){
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    
   
    
    
    function addEmployee(address employeeId, uint salary) onlyOwner employeeNotExist(employeeId){
        // check duplicates
        totalSalary += (salary * 1 ether);
        employees[employeeId] = Employee(employeeId, salary, now);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId){
        // find the Employee
        var employee = employees[employeeId];
        
        // pay
        _partialPaid(employee);
        
        // delete
        totalSalary -= employee.salary;
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId){
        // find the Employee
        var employee = employees[employeeId];
        
        // pay
        _partialPaid(employee);
        uint currSalary = salary * 1 ether;
        totalSalary -= employees[employeeId].salary;
        totalSalary += currSalary;
        employees[employeeId].salary = currSalary;
        employees[employeeId].lastPayday = now;
    }
    
    function addFund() payable returns(uint){
        return this.balance;
    }
    
    function calculateRunway() returns(uint){
        return this.balance / totalSalary;   
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    // naming returns
    function checkEmployee(address employeeId) employeeExist(employeeId) returns (uint salary, uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
        // no explicit "return" here
    }
    
    function getPaid() employeeExist(msg.sender){
        var employee = employees[msg.sender];
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        
        //storage var
        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
    function changePaymentAddress(address newAddress) employeeExist(msg.sender) employeeNotExist(newAddress){
        var employee = employees[msg.sender];
        employees[newAddress] = Employee(newAddress, employee.salary, employee.lastPayday);
        delete employees[msg.sender];
    }
}