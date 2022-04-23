/**
 * Testing TokenVesting
 */

import {execContract, execEIP1559Contract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method
const BN = require('bn.js');

const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));
const senderAddress = (web3.eth.accounts.privateKeyToAccount('0x' + priKey)).address;
console.log('发起地址', senderAddress);

// const tokensVestingAddress = '0x76624c221287b1552a379e597166CA8fAA06dF9D'; // kovan
// const tokensVestingAddress = '0xF886e6336f752F7c4aA496c33A5F77079fcc7a0E'; // bscTestnet old
// const tokensVestingAddress = '0xeF6eDD351a233B347abDc8d272222ae09EFdc491'; // bscTestnet
// const tokensVestingAddress = '0xe070F6F21EE7DeDF06E4F4157F0057fDd30112f6'; // bscTestnet add 48 hours after donation
const tokensVestingAddress = '0x757F671d84560D4Bb5d39A66d6dC1b63D9504D65'; // bsc mainnet

const tokensVestingJson = require('../build/contracts/TokensVesting.json');
const tokensVesting = new web3.eth.Contract(tokensVestingJson.abi, tokensVestingAddress);

const participant = 2;
tokensVesting.methods.total().call().then((total) => console.log('已发行量', total / 1e18));
tokensVesting.methods.getBeneficiaryCount().call().then((total) => console.log('受益人数量', total));

tokensVesting.methods.releasableAll().call().then((releasable) => console.log('总可提现', releasable/1e18));
tokensVesting.methods.participantReleasable(participant).call().then((participantReleasable) => console.log('participantReleasable', participantReleasable / 1e18));
tokensVesting.methods.token().call().then((token) => console.log('CPT token', token));

tokensVesting.methods.getIndex(participant, senderAddress).call().then((response) => {
	console.log('index', response, response[0] ? response[1] : 'no');
	if(response[0]) {
		tokensVesting.methods.releasable(response[1]).call().then((total) => console.log('我的可提现总量', total / 1e18));
		tokensVesting.methods.getBeneficiary(response[1]).call().then((beneficiary) => console.log(beneficiary));	
	}
})

tokensVesting.methods.redeemable(participant, senderAddress).call().then((response) => {
	console.log('redeemable', response);
})

// tokensVesting.methods.getAllBeneficiaries().call({from: senderAddress}).then((all) => console.log('所有受益人', all));
tokensVesting.methods.getTotalAmountByParticipant(participant).call({from: senderAddress}).then((all) => console.log('类型总金额', all/1e18));

tokensVesting.methods.participantReleased(participant).call({from: senderAddress}).then((all) => console.log('类型已提现', all/1e18));
// tokensVesting.methods.getBeneficiary(0).call({from: senderAddress}).then((all) => console.log('getBeneficiary', all/1e18));
tokensVesting.methods.revokedAmount().call({from: senderAddress}).then((all) => console.log('revokedAmount', all / 1e18));
tokensVesting.methods.revokedAmountWithdrawn().call({from: senderAddress}).then((all) => console.log('revokedAmountWithdrawn', all/1e18));

console.log('======================================================');
// tokensVesting.methods.crowdFundingParams(participant).call({from: senderAddress}).then((res) => console.log('crowdFundingParams', res));
// tokensVesting.methods.priceRange(participant).call({from: senderAddress}).then((res) => console.log('price range', res));

// tokensVesting.methods.getPriceForAmount(2, 300000).call({from: senderAddress}).then((res) => console.log('price', res));

// tokensVesting.methods.redeemFee().call().then((res) => console.log('redeemFee', res));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

 /** transfer testing
	* 																								 genesis 		totoalAmount							tgeAmount 							cliff		duration		participant		basis
	* Acc#0 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 1642607300	100000_000000000000000000 0												24*3600 30*24*3600	1							2*3600(2h)
	* Acc#1 0xC4BFA07776D423711ead76CDfceDbE258e32474A 1642607300 200000_000000000000000000 5000_000000000000000000	24*3600 20*24*3600  3							2*3600
	* Acc#2 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 1642607300 300000_000000000000000000 5000_000000000000000000	48*3600 20*24*3600  4							2*3600
	* kov#3 0x3FE7995Bf0a505a51196aA11218b181c8497D236 1642607300 400000_000000000000000000 8000_000000000000000000	48*3600 20*24*3600  5							2*3600
	* kov#4 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 1642607300 500000_000000000000000000 8000_000000000000000000	48*3600 20*24*3600  6							2*3600
	* kov#5 0x3444E23231619b361c8350F4C83F82BCfAB36F65 1642607300 600000_000000000000000000 5000_000000000000000000	12*3600 20*24*3600  7							2*3600
	*/

// !!!!!!!!!!!!!!
// let sendEncodeABI = tokensVesting.methods.activateAll().encodeABI();
// !!!!!!!!!!!!!!

// let sendEncodeABI = tokensVesting.methods.updateToken('0x7C4b6E294Fd0ae77B6E1730CBEb1B8491859Ee24').encodeABI();

// 确保TokenVesting合约已经获取CPT代币的 MINTER_ROLE 权限
// let sendEncodeABI = tokensVesting.methods.release(2).encodeABI();

// let sendEncodeABI = tokensVesting.methods.releaseAll().encodeABI();

// let sendEncodeABI = tokensVesting.methods.releaseParticipant(7).encodeABI();

// let sendEncodeABI = tokensVesting.methods.revoke(0).encodeABI();

// let sendEncodeABI = tokensVesting.methods.withdraw('10000000000000000000000000').encodeABI();

// setCrowdFundingParams
/** 
 * testing: 
 * genesis timestamp = now + 20min
 * starttimestamp = now + 10min
 * endtimestamp = now + 15min
 * 
 * participant	genesisTimestamp	tgeAmountRatio	ratioDecimals	cliff		duration	basis	startTimestamp				endTimestamp				limitation
 * 1						1644422134				20							2							60*10		60*5			60		1644421800(23:50)			1644424200(00:30)		1000000000000000000
 * 2						1644423300				10							2							60*10		60*5			60		1644422400(00:00)			1644425100(00:45)		500000000000000000
 */


// Set public sale params
// const now = new Date().getTime();
// const tgeAmountRatio = 1000; // on genesisTimestamp 10% of total amount will be release
// const startTimestamp = Math.floor(now / 1000) + 0 * 24 * 3600; // start when deploy the contract
// const endTimestamp = Math.floor(now / 1000) + 2 * 24 * 3600; // sale will be over 2 days later
// const genesisTimestamp = Math.floor(now / 1000) + 2.5 * 24 * 3600; // genesisTimestamp is 2.5 days after deploy
// const cliff = 0; // 0 minutes
// const duration = 90 * 24 * 3600; // Vesting tokens will be released during 90 days
// const basis = 0 * 3600; // The buyer can release the releasable tokens every 1 hour
// const highest = '1000000000000000000'; // highest purchasing amount is 1 BNB/ETH
// const lowest = '25000000000000000'; // lowest purchasing amount is 0.025 BNB/ETH

// let sendEncodeABI = tokensVesting.methods.setCrowdFundingParams(
// 	1, genesisTimestamp, 2000, cliff, duration, basis, startTimestamp, endTimestamp, '50000000000000000000', '25000000000000000000', false, false
// ).encodeABI();

// Set public sale params
const participantId = 2;
const now = new Date().getTime();
const tgeAmountRatio = 2000; // on genesisTimestamp 20% of total amount will be release
const startTimestamp = 1650931200; // Math.floor(now / 1000) + 0.2 * 3600; // start when deploy the contract
const endTimestamp = 1654473600; // Math.floor(now / 1000) +  0.5 * 3600; // sale will be over 2 days later
const genesisTimestamp = 1654819200;// Math.floor(now / 1000) + 1 * 3600; // genesisTimestamp is 2.5 days after deploy
const cliff = 0 * 3600; // 12 hours
const duration = 365 * 24 * 3600; // Vesting tokens will be released during 90 days
const basis = 24 * 3600; // The buyer can release the releasable tokens every 1 hour
const highest = '600000000000000000'; // highest purchasing amount is 0.5 BNB/ETH
const lowest =  '300000000000000000'; // lowest purchasing amount is 0.3 BNB/ETH

// ================================
// setCrowdFundingParams
// ================================
// let sendEncodeABI = tokensVesting.methods.setCrowdFundingParams(
// 	participantId,
// 	genesisTimestamp, 
// 	tgeAmountRatio,
// 	cliff, 
// 	duration, 
// 	basis, 
// 	startTimestamp, 
// 	endTimestamp, 
// 	highest, 
// 	lowest, 
// 	true, 
// 	true
// ).encodeABI();

// ================================
// Manual add beneficiary
// ================================
// const beneficiaryAddress = '0x94929D0Ca7A4666F21b0125c625A361aB74878F0';
// const donateAmount = '60000000000000000000';
// tokensVesting.methods.getPriceForAmount(participantId, donateAmount).call({from: senderAddress}).then((price) => {
// 	const totalAmount = (new BN(donateAmount)).mul(new BN(price[0]));
// 	const tgeAmount = totalAmount.mul(new BN(tgeAmountRatio.toString())).div(new BN('10000'));
// 	const options = [
// 		beneficiaryAddress,
// 		genesisTimestamp.toString(),
// 		totalAmount.toString(),
// 		tgeAmount.toString(),
// 		cliff.toString(),
// 		duration.toString(),
// 		participantId,
// 		basis.toString(),
// 		price[0]
// 	];
// 	console.log(options);
// 	let sendEncodeABI = tokensVesting.methods.addBeneficiary(
// 		beneficiaryAddress,
// 		genesisTimestamp,
// 		totalAmount.toString(),
// 		tgeAmount.toString(),
// 		cliff.toString(),
// 		duration.toString(),
// 		participantId,
// 		basis.toString(),
// 		price[0]
// 	).encodeABI();
// 	callContract(sendEncodeABI, tokensVestingAddress);
// });

// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, 0, 2666666).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '315000000000000000000000000', 2222222).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '705000000000000000000000000', 1851852).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '1170000000000000000000000000', 1543210).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '1710000000000000000000000000', 1286008).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '2325000000000000000000000000', 1071674).encodeABI();
// let sendEncodeABI = tokensVesting.methods.setPriceRange(2, '3000000000000000000000000000', 1071674).encodeABI();

// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 0, 0, 26666666).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 1, '315000000000000000000000000', 2222222).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 2, '705000000000000000000000000', 1851852).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 3, '1170000000000000000000000000', 1543210).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 4, '1710000000000000000000000000', 1286008).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 5, '2325000000000000000000000000', 1071674).encodeABI();
// let sendEncodeABI = tokensVesting.methods.updatePriceRange(2, 6, '3000000000000000000000000000', 1071674).encodeABI();

// let sendEncodeABI = tokensVesting.methods.withdrawCoin('0x615b80388E3D3CaC6AA3a904803acfE7939f0399', '490000000000000000').encodeABI();

// let sendEncodeABI = tokensVesting.methods.updateRedeemFee(500).encodeABI();
// let sendEncodeABI = tokensVesting.methods.redeem(2).encodeABI();

// let sendEncodeABI = tokensVesting.methods.setAllowRedeem(2, true).encodeABI();
// callEIP1559Contract(sendEncodeABI, tokensVestingAddress);

// let sendEncodeABI = tokensVesting.methods.crowdFunding(2).encodeABI();
// callEIP1559Contract(sendEncodeABI, tokensVestingAddress, '31000000000000000');

// let sendEncodeABI = tokensVesting.methods.updateRedeemableTime(0).encodeABI();
callContract(sendEncodeABI, tokensVestingAddress);

