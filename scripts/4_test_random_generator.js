/**
 * Testing Random Generator(ChainLink)
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

// 必须将一定数量的LINK打到RandomGenerator合约
const randomGeneratorAddress = '0xA28D90320005C8c043Ee79ae59e82fDd5f983f30';
const randomGeneratorJson = require('../build/contracts/ChainLinkRandomGenerator.json');

const randomGenerator = new web3.eth.Contract(randomGeneratorJson.abi, randomGeneratorAddress);

// randomGenerator.methods.OPERATOR_ROLE().call().then((response) => console.log('OPERATOR_ROLE', response));
randomGenerator.methods.CONSUMER_ROLE().call().then((response) => console.log('CONSUMER_ROLE', response));

randomGenerator.methods.linkToken().call().then((response) => console.log('LINK Token', response));

// randomGenerator.methods.getRoleMember('0x9d56108290ea0bc9c5c59c3ad357dca9d1b29ed7f3ae1443bef2fa2159bdf5e8', 0).call().then((address) => console.log('Role address', address));
randomGenerator.methods.hasRole(
	'0x9d56108290ea0bc9c5c59c3ad357dca9d1b29ed7f3ae1443bef2fa2159bdf5e8', 
	'0x9c9BAe663Ddf1e3F469359F90099B3699F56C26c')
	.call({from: '0x615b80388E3D3CaC6AA3a904803acfE7939f0399'}).then((has) => console.log('hasRole', has));

// getResultByTokenId
// randomGenerator.methods.getResultByTokenId(1).call().then((response) => console.log('random id', response));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress) => execContract(web3, chainId, priKey, encodeABI, contractAddress, null, null, null, null);	

// let sendEncodeABI = randomGenerator.methods.requestRandomNumber(1).encodeABI(); // 等待NFTManager合约部署完毕

let sendEncodeABI = randomGenerator.methods.grantRole(
	'0x9d56108290ea0bc9c5c59c3ad357dca9d1b29ed7f3ae1443bef2fa2159bdf5e8', 
	'0x9c9BAe663Ddf1e3F469359F90099B3699F56C26c').encodeABI();
callContract(sendEncodeABI, randomGeneratorAddress);
