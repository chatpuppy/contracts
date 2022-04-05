/**
 * Testing Randomness
 */

import {execContract, execEIP1559Contract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const randomTestAddress = '0x8959B390602bA65704DD2Cfb6f32d7e4A9268c3c'; // mumbai
const randomTestJson = require('../build/contracts/RandomTest.json');

const randomTest = new web3.eth.Contract(randomTestJson.abi, randomTestAddress);

// ===========================================================================
const tokenId = 109;
randomTest.methods.getData(tokenId).call().then((number) => console.log('Random Number', number));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

// 必须将本合约地址授权给ChainLinkRandomGenerator合约的CONSUMER_ROLE角色
// TokenId is insteatd of RequestId, it can not be duplicated.
// let sendEncodeABI = randomTest.methods.requestRandomness(4).encodeABI();

// let sendEncodeABI = randomTest.methods.getRandoms(tokenId).encodeABI();
// callEIP1559Contract(sendEncodeABI, randomTestAddress);

// 89886278219382825804356556120021526408645684544726589290238326514905869994371
// 11000110101110011101010010100000
// 01010110010111001111001010001110
// 10000001010011111001110011001001
// 10010011111011010101010100001100
// 00010001100001110010011100100011
// 10110111100110110101001101110011
// 01011001000001011110110000000100
// 11011111011110000100100110000011