/**
 * Testing NFT Manager
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {getTokensOfOwner} from 'erc721-balance';
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const tokensVestingAddress = '0x920d3F1557bE1e3AF2077a76A10cB400b99EB798';//'0x456EACCf71a8AFD0369AE1B91Be7Af3b40D2e865';
const tokensVestingJson = require('../build/contracts/TokensVesting.json');
const tokensVesting = new web3.eth.Contract(tokensVestingJson.abi, tokensVestingAddress);

tokensVesting.methods.total().call().then((total) => console.log('总量', total / 1e18));
tokensVesting.methods.privateSale().call().then((total) => console.log('私募总量', total / 1e18));
tokensVesting.methods.team().call().then((total) => console.log('Team总量', total / 1e18));

tokensVesting.methods.getBeneficiaryCount().call().then((total) => console.log('受益人数量', total));
tokensVesting.methods.getIndex('0xC4BFA07776D423711ead76CDfceDbE258e32474A').call().then((index) => {
	console.log('index', index);
	tokensVesting.methods.releasable(index).call().then((total) => console.log('我的可提现总量', total / 1e18));
	tokensVesting.methods.getBeneficiary(index).call().then((beneficiary) => console.log(beneficiary));
})
// tokensVesting.methods.getAllBeneficiaries().call({from: '0x615b80388E3D3CaC6AA3a904803acfE7939f0399'}).then((all) => console.log('所有受益人', all));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

 /** transfer testing
	* 																								 genesis 		totoalAmount							tgeAmount 							cliff		duration		participant		basis
	* Acc#0 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 1642607300	100000_000000000000000000 0												24*3600 30*24*3600	1							2*3600(2h)
	* Acc#1 0xC4BFA07776D423711ead76CDfceDbE258e32474A 1642607300 200000_000000000000000000 5000_000000000000000000	24*3600 20*24*3600  3							2*3600
	* Acc#2 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 1642607300 300000_000000000000000000 5000_000000000000000000	48*3600 20*24*3600  4							2*3600
	* kov#3 0x3FE7995Bf0a505a51196aA11218b181c8497D236 1642607300 400000_000000000000000000 8000_000000000000000000	48*3600 20*24*3600  5							2*3600
	* kov#4 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 1642607300 500000_000000000000000000 8000_000000000000000000	48*3600 20*24*3600  6							2*3600
	* kov#5 0x3444E23231619b361c8350F4C83F82BCfAB36F65 1642607300 600000_000000000000000000 5000_000000000000000000	12*3600 20*24*3600  7							2*3600
	*/

// let sendEncodeABI = tokensVesting.methods.addBeneficiaryWithBasis(
// 	'0x3444E23231619b361c8350F4C83F82BCfAB36F65',
// 	'1642607300',
// 	'600000000000000000000000',
// 	'5000000000000000000000',
// 	(12*3600).toString(),
// 	(20*24*3600).toString(),
// 	7,
// 	(2*3600).toString()
// ).encodeABI();

// let sendEncodeABI = tokensVesting.methods.activateAll().encodeABI();

// 确保TokenVesting合约已经获取DARE代币的 MINTER_ROLE 权限
// let sendEncodeABI = tokensVesting.methods.release(1).encodeABI();
// callContract(sendEncodeABI, tokensVestingAddress);
