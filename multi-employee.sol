pragma solidity ^0.4.14;

contract Payroll{
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }
    
    address owner;
    Employee[] employees;
    // totalSalary is a global var here
    // when adding/removing/update an employee, change the value of totalSalary
    // instead of using a loop to compute totalSalary in calculateRunway() 
    uint totalSalary = 0;
    
    uint constant payDuration  = 10 seconds;
    
    function Payroll(){
        //constructor
        owner = msg.sender;
    }
    
    // visibitliy: private
    function _partialPaid(Employee employee) private {
        assert(employee.id != 0x0);
        // thoughts: can we use a line like "if employee.id is in Employee" to check whether the employee is employed?
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint){
         for(uint i = 0; i < employees.length; i++)
              if(employees[i].id == employeeId) return (employees[i], i);
             
    }
    
    function addEmployee(address employeeId, uint salary){
        require(msg.sender == owner);
        // check duplicates
        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        totalSalary += (salary * 1 ether);
        employees.push(Employee(employeeId, salary, now));
    }
    
    function removeEmployee(address employeeId){
        require(msg.sender == owner);
        // find the Employee
        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        
        // pay
        _partialPaid(employee);
        
        // delete
        totalSalary -= employees[index].salary;
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function updateEmployee(address employeeId, uint salary){
        require(msg.sender == owner);
        // find the Employee
        var(employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        
        // pay
        _partialPaid(employee);
        uint currSalary = salary * 1 ether;
        totalSalary -= employees[index].salary;
        totalSalary += currSalary;
        employees[index].salary = currSalary;
        employees[index].lastPayday = now;
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
    
    function getPaid(){
        var(employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        
        //storage var
        employees[index].lastPayday = nextPayday;
        employees[index].id.transfer(employee.salary);
    }
    
}

/* Results:
tx gas  ||  exec gas
22987       1715
23757       2485
24527       3255
25297       4025
26067       4795
26837       5565
27607       6335
28377       7105
29147       7875
29917       8645
(+770 gas for each operation)

after modification:
22180       908
22180       908
..
*/