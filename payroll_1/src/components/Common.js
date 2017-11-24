import React, {Component} from 'react'

import { Card, Col, Row} from 'antd'

class Common extends Component {
    constructor(props) {
        super(props);

        this.state = {};
    }

    componentDidMount() {
        const { payroll, web3, account } = this.props;
        payroll.checkInfo.call({
            from: account,
        }).then((result) => {
            this.setState({
                balance: web3.fromWei(result[0].toNumber()),
                runway: result[1].toNumber().account,
                employeeCount: result[2].toNumber()
            })
        });
    }

    render() {
        const { runway, balance, employeeCount } = this.state;
        return (
            <div>
                <h2>Common Info</h2>
                <Row gutter={16}>
                    <Col span={8}>
                        <Card title="Contract Balance:">{balance} ether</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="Number of Employees:">{employeeCount}</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="Times Current Balance can pay:">{runway}</Card>
                    </Col>
                </Row>
            </div>
        );
    }
}
export default Common