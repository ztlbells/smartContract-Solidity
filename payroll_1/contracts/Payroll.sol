pragma solidity ^0.4.14;

import './Ownable.sol';
import './SafeMath.sol';

contract Payroll is Ownable {
    using SafeMath for uint;
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 10 seconds;
    uint totalSalary;
    uint totalEmployee;
    address[] public EmployeeList;

    mapping(address => Employee) public employees;

    /////////////////// modifiers /////////////////////
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0X0);
        _;
    }
    
    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0X0);
        _;
    }
    
    //////////////////////////////////////////////////

    // visibitliy: private
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(currentTime().sub(employee.lastPayDay)).div(payDuration);
        employee.id.transfer(payment);
    }

    function currentTime() returns (uint) {
        return now;
    }
    
    function addEmployee(address employeeId, uint salary) onlyOwner employeeNotExist(employeeId) {
        var employee = employees[employeeId];
        // check duplicates
        totalSalary = totalSalary.add(salary.mul(1 ether));
        totalEmployee = totalEmployee.add(1);
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), currentTime());
        EmployeeList.push(employeeId);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        totalEmployee = totalEmployee.sub(1);

         for(var i = 0; i < EmployeeList.length; i++) {
            if (EmployeeList[i] == employeeId) {
                EmployeeList[i] = EmployeeList[EmployeeList.length - 1];
                EmployeeList.length -= 1;
                break;
            }
        }       
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary).add(salary.mul(1 ether));
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayDay = currentTime();
    }
    
    function changePaymentAddress(address newEmployeeId) employeeExist(msg.sender) employeeNotExist(newEmployeeId) {
        employees[newEmployeeId] = Employee(newEmployeeId, employees[msg.sender].salary, employees[msg.sender].lastPayDay);
        delete employees[msg.sender];
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function checkEmployee(address employeeId) returns (uint salary, uint lastPayDay) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
        // no explicit "return" here
    }
    
    function getPaid() employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        
        uint nextPayday = employee.lastPayDay.add(payDuration);
        assert(nextPayday < currentTime());
        
        employee.lastPayDay = nextPayday;
        employee.id.transfer(employee.salary);
    }

    function changePaymentAddress(address newAddress) employeeExist(msg.sender) employeeNotExist(newAddress){
        var employee = employees[msg.sender];
        employees[newAddress] = Employee(newAddress, employee.salary, employee.lastPayday);
        delete employees[msg.sender];
    }
    
    function checkInfo() returns (uint balance, uint runway, uint employeeCount) {
        balance = this.balance;
        if (totalSalary > 0) {
            runway = calculateRunway();
        }
        employeeCount = totalEmployee;
    }
}