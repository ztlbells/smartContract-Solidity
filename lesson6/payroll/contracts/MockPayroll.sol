import './Payroll.sol';

contract MockPayroll is Payroll {
    uint _now;

    function MockPayroll() {
        _now = now;
    }

    function addTime(uint moreTime) {
        _now += moreTime;
    }

    function currentTime() returns (uint) {
        return _now;
    }
}