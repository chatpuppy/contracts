/**
 * Testing Item Factory
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

const randomTestAddress = '0x4cc463c78E09C7EC45276D911c29688579E32818';
const randomTestJson = require('../build/contracts/RandomTest.json');

const randomTest = new web3.eth.Contract(randomTestJson.abi, randomTestAddress);

randomTest.methods.randomNumber().call().then((number) => console.log('Random Number', number));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress) => execContract(web3, chainId, priKey, encodeABI, contractAddress, null, null, null, null);	

// 必须将本合约地址授权给ChainLinkRandomGenerator合约的CONSUMER_ROLE角色
// TokenId is insteatd of RequestId, it can not be duplicated.
// let sendEncodeABI = randomTest.methods.requestRandomness(4).encodeABI();

// let sendEncodeABI = randomTest.methods.updateRandomFee(0).encodeABI();
// callContract(sendEncodeABI, randomTestAddress);
