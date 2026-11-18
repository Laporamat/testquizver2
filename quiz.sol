// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RentalManagement {
    
    // โครงสร้างข้อมูลทรัพย์สิน
    struct Property {
        uint256 propertyId;
        address payable owner;
        string propertyDetails;
        uint256 monthlyRent; // เป็น Wei หรือหน่วยย่อยของ ETH
        uint256 securityDepositAmount;
        bool isRegistered;
    }

    // โครงสร้างข้อมูลสัญญาเช่า
    struct Agreement {
        uint256 agreementId;
        uint256 propertyId;
        address payable landlord;
        address payable tenant;
        uint256 startDate;
        uint256 endDate;
        uint256 depositBalance;
        bool isConfirmedByTenant;
        bool isConfirmedByLandlord;
        bool isActive;
        bool isTerminated;
    }

    mapping(uint256 => Property) public properties;
    mapping(uint256 => Agreement) public agreements;
    
    address public arbiter; // ผู้มีอำนาจจัดการข้อพิพาท (Dispute Arbiter)
    uint256 public propertyCounter;
    uint256 public agreementCounter;

    event PropertyRegistered(uint256 indexed propertyId, address owner);
    event AgreementCreated(uint256 indexed agreementId, uint256 propertyId, address tenant);
    event AgreementConfirmed(uint256 indexed agreementId);
    event DepositPaid(uint256 indexed agreementId, uint256 amount);
    event RentPaid(uint256 indexed agreementId, uint256 amount);
    event DepositRefunded(uint256 indexed agreementId, uint256 amountToTenant, uint256 amountToLandlord);
    event DisputeResolved(uint256 indexed agreementId, string reason);

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this");
        _;
    }

    constructor(address _arbiter) {
        arbiter = _arbiter;
    }

    // 1. ลงทะเบียนทรัพย์สิน (Register Property)
    function registerProperty(string memory _details, uint256 _rent, uint256 _deposit) external {
        propertyCounter++;
        properties[propertyCounter] = Property({
            propertyId: propertyCounter,
            owner: payable(msg.sender),
            propertyDetails: _details,
            monthlyRent: _rent,
            securityDepositAmount: _deposit,
            isRegistered: true
        });

        emit PropertyRegistered(propertyCounter, msg.sender);
    }

    // 2. สร้างสัญญาเช่า (Create Rental Agreement)
    function createAgreement(uint256 _propertyId, address payable _tenant, uint256 _startDate, uint256 _endDate) external {
        Property memory prop = properties[_propertyId];
        require(prop.isRegistered, "Property does not exist");
        require(msg.sender == prop.owner, "Only property owner can create agreement");

        agreementCounter++;
        agreements[agreementCounter] = Agreement({
            agreementId: agreementCounter,
            propertyId: _propertyId,
            landlord: prop.owner,
            tenant: _tenant,
            startDate: _startDate,
            endDate: _endDate,
            depositBalance: prop.securityDepositAmount,
            isConfirmedByTenant: false,
            isConfirmedByLandlord: false,
            isActive: false,
            isTerminated: false
        });

        emit AgreementCreated(agreementCounter, _propertyId, _tenant);
    }

    // 3. ยืนยันสัญญา (Confirm Agreement) ด้วย Wallet ของคู่สัญญา
    function confirmAgreement(uint256 _agreementId) external {
        Agreement storage ag = agreements[_agreementId];
        require(!ag.isActive && !ag.isTerminated, "Agreement already active or terminated");

        if (msg.sender == ag.tenant) {
            ag.isConfirmedByTenant = true;
        } else if (msg.sender == ag.landlord) {
            ag.isConfirmedByLandlord = true;
        } else {
            revert("Not a party to this agreement");
        }

        if (ag.isConfirmedByTenant && ag.isConfirmedByLandlord) {
            ag.isActive = true;
            emit AgreementConfirmed(_agreementId);
        }
    }

    // 4. ฝากเงินประกัน (Deposit Security) - ผู้เช่าโอน ETH เข้า Smart Contract
    function depositSecurity(uint256 _agreementId) external payable {
        Agreement storage ag = agreements[_agreementId];
        require(msg.sender == ag.tenant, "Only tenant can deposit security");
        Property memory prop = properties[ag.propertyId];
        require(msg.value == prop.securityDepositAmount, "Incorrect deposit amount");

        emit DepositPaid(_agreementId, msg.value);
    }

    // 5. บันทึกค่าเช่า (Record Rental Payment)
    function payRent(uint256 _agreementId) external payable {
        Agreement storage ag = agreements[_agreementId];
        require(ag.isActive, "Agreement is not active");
        require(msg.sender == ag.tenant, "Only tenant can pay rent");
        
        Property memory prop = properties[ag.propertyId];
        require(msg.value == prop.monthlyRent, "Incorrect rent amount");

        // โอนเงินค่าเช่าให้เจ้าของห้องทันที
        ag.landlord.transfer(msg.value);

        emit RentPaid(_agreementId, msg.value);
    }

    // 6. คืนเงินประกัน (Refund Deposit) - เมื่อสิ้นสุดสัญญาและตกลงกันได้
    function refundDeposit(uint256 _agreementId, uint256 _amountToTenant, uint256 _amountToLandlord) external {
        Agreement storage ag = agreements[_agreementId];
        require(msg.sender == ag.landlord || msg.sender == ag.tenant, "Unauthorized");
        require(ag.isActive, "Agreement not active");
        
        // กฎทางธุรกิจ: ห้ามคืนเงินเกินยอดคงเหลือของเงินประกัน
        require(_amountToTenant + _amountToLandlord <= ag.depositBalance, "Exceeds deposit balance");

        ag.isActive = false;
        ag.isTerminated = true;
        ag.depositBalance = 0;

        if (_amountToTenant > 0) {
            ag.tenant.transfer(_amountToTenant);
        }
        if (_amountToLandlord > 0) {
            ag.landlord.transfer(_amountToLandlord);
        }

        emit DepositRefunded(_agreementId, _amountToTenant, _amountToLandlord);
    }

    // 7. จัดการข้อโต้แย้ง (Rental Dispute) โดยผู้มีอำนาจ (Arbiter)
    function resolveDispute(uint256 _agreementId, uint256 _amountToTenant, uint256 _amountToLandlord, string memory _reason) external onlyArbiter {
        Agreement storage ag = agreements[_agreementId];
        require(!ag.isTerminated, "Already terminated");
        require(_amountToTenant + _amountToLandlord <= ag.depositBalance, "Exceeds deposit balance");

        ag.isActive = false;
        ag.isTerminated = true;
        ag.depositBalance = 0;

        if (_amountToTenant > 0) {
            ag.tenant.transfer(_amountToTenant);
        }
        if (_amountToLandlord > 0) {
            ag.landlord.transfer(_amountToLandlord);
        }

        emit DisputeResolved(_agreementId, _reason);
    }
}