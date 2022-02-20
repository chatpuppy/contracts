/**
 * Testing Randomness
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

const randomTestAddress = '0x7ea8f6177f49E1b54e816eD5DdCeD7Db4172014A';
const randomTestJson = require('../build/contracts/RandomTestV2.json');

const randomTest = new web3.eth.Contract(randomTestJson.abi, randomTestAddress);

randomTest.methods.requestId().call().then((id) => console.log('Request ID', id));
randomTest.methods.randomWords().call().then((words) => console.log('Random', words));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

// 必须将本合约地址添加到V2的consumer列表中，否则将执行失败

// let sendEncodeABI = randomTest.methods.requestRandomness(20).encodeABI();
// callContract(sendEncodeABI, randomTestAddress);
