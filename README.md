🏢 SmartLiving Property - Smart Property Rental & Deposit Management

ระบบบริหารจัดการสัญญาเช่าอสังหาริมทรัพย์และเงินประกันผ่านเทคโนโลยี Blockchain (Smart Contract) เพื่อสร้างความโปร่งใส ตรวจสอบได้ และลดข้อโต้แย้งระหว่างเจ้าของห้องพัก (Landlord) และผู้เช่า (Tenant)

📋 ภาพรวมโปรเจกต์ (Project Overview)

บริษัท SmartLiving Property ให้บริการบริหารจัดการห้องพักและอพาร์ตเมนต์ให้เช่า ระบบนี้ถูกออกแบบมาเพื่อแก้ปัญหาการจัดเก็บเงินประกัน ความไม่ชัดเจนของเงื่อนไขการคืนเงิน และข้อพิพาทเมื่อสิ้นสุดสัญญา โดยใช้ Smart Contract ทำหน้าที่เป็นตัวกลางถือครองเงินประกัน (Escrow) และบังคับใช้เงื่อนไขตามที่ตกลงกันโดยอัตโนมัติ

✨ ฟีเจอร์หลัก (Functional Requirements)

ลงทะเบียนทรัพย์สิน (registerProperty): เจ้าของห้องสามารถเพิ่มข้อมูลห้องเช่า กำหนดค่าเช่ารายเดือน และจำนวนเงินประกัน

สร้างสัญญาเช่า (createAgreement): เจ้าของห้องสร้างสัญญาเช่าระบุ Wallet Address ของผู้เช่า วันเริ่มต้น และวันสิ้นสุดสัญญา

ยืนยันสัญญา (confirmAgreement): ทั้งเจ้าของห้องและผู้เช่าต้องกดยืนยันการยอมรับเงื่อนไขด้วย Wallet ของตนเองเพื่อให้สัญญามีผลบังคับใช้

ฝากเงินประกัน (depositSecurity): ผู้เช่าโอนเงินประกันในรูปแบบ ETH เข้าไปเก็บรักษาไว้ใน Smart Contract (Escrow)

บันทึกค่าเช่า (payRent): ผู้เช่าชำระค่าเช่ารายเดือน โดยระบบจะโอนเงินตรงไปยังเจ้าของห้องและบันทึกประวัติบน Blockchain

คืนเงินประกัน (refundDeposit): เมื่อสิ้นสุดสัญญา สามารถคืนเงินประกันให้ผู้เช่า (และหักค่าเสียหายให้เจ้าของห้องหากตกลงกันได้) โดยระบบป้องกันไม่ให้คืนเงินเกินยอดคงเหลือ

จัดการข้อโต้แย้ง (resolveDispute): กรณีเกิดข้อพิพาทเรื่องความเสียหาย ผู้มีอำนาจที่กำหนดไว้ (Arbiter) สามารถเข้ามาพิจารณาตัดสิน บันทึกเหตุผล และสั่งจ่ายเงินตามสัดส่วนที่เหมาะสม

🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

Smart Contract: Solidity (^0.8.20) - ไฟล์ quiz.sol

Frontend: HTML5, Tailwind CSS (CDN)

Blockchain Interaction: Ethers.js (v6.13.2)

Wallet: MetaMask

📂 โครงสร้างไฟล์ (Project Structure)

├── quiz.sol        # Smart Contract หลักสำหรับจัดการสัญญาเช่าและเงินประกัน
├── index.html      # หน้าเว็บไซต์ DApp (Frontend) สำหรับเชื่อมต่อกับ Smart Contract
└── README.md       # เอกสารคู่มือการใช้งานโปรเจกต์


🚀 ขั้นตอนการติดตั้งและใช้งาน (Getting Started)

1. Deploy Smart Contract (quiz.sol)

เปิด Remix IDE

สร้างไฟล์ใหม่ชื่อ quiz.sol และนำโค้ด Smart Contract ไปวาง

ไปที่แท็บ Solidity Compiler และกด Compile ไฟล์ quiz.sol (เลือก Compiler เวอร์ชัน 0.8.20 ขึ้นไป)

ไปที่แท็บ Deploy & Run Transactions:

เลือก Environment เป็น Injected Provider - MetaMask (แนะนำให้ใช้เครือข่ายทดสอบ เช่น Sepolia Testnet)

ในช่อง Deploy ให้ระบุ _arbiter เป็น Wallet Address ของผู้มีอำนาจตัดสินข้อพิพาท

กดปุ่ม Deploy และยืนยันธุรกรรมใน MetaMask

คัดลอก Contract Address ที่ได้หลังจาก Deploy สำเร็จ

2. ตั้งค่า Frontend (index.html)

เปิดไฟล์ index.html ด้วยโปรแกรมแก้ไขโค้ด (เช่น VS Code)

ค้นหาตัวแปร CONTRACT_ADDRESS ในส่วน <script> และนำ Contract Address ที่คัดลอกมาวางแทนที่:

const CONTRACT_ADDRESS = "0xYourDeployedContractAddressHere";


บันทึกไฟล์

3. เปิดใช้งาน DApp

เปิดไฟล์ index.html ผ่าน Web Server จำลอง (เช่น ส่วนเสริม Live Server ใน VS Code) ไม่แนะนำให้ดับเบิลคลิกเปิดไฟล์ .html โดยตรง เพราะ MetaMask อาจไม่ทำงาน

กดปุ่ม "🔗 เชื่อมต่อ MetaMask" ที่มุมขวาบนของหน้าเว็บ

เริ่มทดสอบการใช้งานฟังก์ชันต่างๆ ได้ทันที

🛡️ กฎทางธุรกิจและความปลอดภัย (Business Rules & Security)

Escrow Mechanism: เงินประกันจะถูกเก็บไว้ใน Smart Contract ไม่สามารถถูกถอนออกโดยฝ่ายใดฝ่ายหนึ่งเพียงลำพังได้จนกว่าสัญญาจะสิ้นสุดหรือมีการตัดสินข้อพิพาท

Over-refund Prevention: มีการตรวจสอบเงื่อนไข _amountToTenant + _amountToLandlord <= ag.depositBalance เสมอ เพื่อป้องกันการจ่ายเงินเกินยอดเงินประกันที่มีอยู่จริง

Immutable Audit Trail: ทุกธุรกรรมการสร้างสัญญา การยืนยัน การจ่ายค่าเช่า และการตัดสินข้อพิพาท จะถูกบันทึกเป็น Event บน Blockchain สามารถตรวจสอบย้อนหลังได้ตลอดเวลา
