var Payroll = artifacts.require("./Payroll.sol");

// like describe, but generate a clean environment
contract('Payroll', function(accounts) {

  it("(1) Add employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      var salary = 3;
      return payrollInstance.addEmployee(accounts[1], salary, {from: accounts[0]});
    }).then(function() {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function(employees) {
      assert.equal(employees[0], accounts[1], "Address matched. Add successfully");
    });
  });

  it("(2) Remove employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;

      return payrollInstance.removeEmployee(accounts[1], {from: accounts[0]});
    }).then(function() {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function(employees) {
      assert.equal(employees[0], "0x0000000000000000000000000000000000000000", "Remove successfully");
    });
  });


});