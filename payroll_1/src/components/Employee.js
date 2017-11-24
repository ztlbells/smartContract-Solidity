import React, {Component} from 'react'
import { Card, Col, Row, Layout, Alert, message, Button} from 'antd'

import Common from './Common';

class Employee extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    componentDidMount() {
        this.checkEmployee;
    }

    checkEmpoyee = () => {
        const { payroll, account, web3 } = this.props;
        payroll.employees.call(account, {
            from: account,
            gas: 1000000
        }).then((result) => {
            console.log(result)
            this.setState({
                salary: web3.fromWei(result[1].toNumber()),
                lastPaidDate: new Date(result[2].toNumber() * 1000)
            });
        });

        web3.eth.getBalance(account, (err, result) => {
            this.setState({
                balance: web3.fromWei(result.toNumber())
            });
        });
    }

    getPaid = () => {
        const { payroll, employee } = this.props;
        payroll.getPaid({
            from: employee,
            gas: 1000000
        }).then((result) => {
            alert('you have been paid');
        });
    }

    renderContent() {
        const {salary, lastPaidDate, balance} = this.state;
        if (!salary || salary === '0') {
            return <Alert message="You are not an employee" type="error" showIcon />
        }
        return (
            <div>
                <Row gutter={16}>
                    <Col span={8}>
                        <Card title="Salary">{salary} ether</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="LastPayDay">{lastPaidDate}</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="Account Balance">{balance} ether</Card>
                    </Col> 
                </Row> 
                <Button 
                    type="primary" 
                    icon="bank" 
                    onClick={this.getPaid}>
                    Get paid
                </Button>
            </div>
        );
    }

    render() {
        const {account, payroll, web3} = this.props;
        
        return (
            <Layout style={{ padding: '0 24px', background: '#fff'}}>
                <Common account={account} payroll={payroll} web3={web3} />
                <h2>Personal Info</h2>
                {this.renderContent()}
            </Layout>
        );
    }
}
export default Employee;