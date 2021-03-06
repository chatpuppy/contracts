/**
 * Testing CPT Token
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

// const cptContractAddress = '0x7C4b6E294Fd0ae77B6E1730CBEb1B8491859Ee24'; // kovan
// const cptContractAddress = '0x014Eed0cb456FF95992A79D51ff7169ec44a5cFc'; // rinkeby
// const cptContractAddress = '0x6adb30205dd2D2902f32E40e0f2CE15c728F9492'; // bscTestnet
// const cptContractAddress = '0x5F9d7Dc9e56f7d182f3eFb1b48874C0512b4c40d'; // mumbai
const cptContractAddress = '0xa747Ba9BbF79E165Cd71c4376B72eBc06CA735CB'; // BSC Mainnet

const cptContractJson = require('../build/contracts/CPTToken.json');

const cptContract = new web3.eth.Contract(cptContractJson.abi, cptContractAddress);

cptContract.methods.name().call().then((response) => console.log('token name', response));
cptContract.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1e18));
cptContract.methods.cap().call().then((response) => console.log('cap', response));
// cptContract.methods.balanceOf('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').call().then((response) => console.log('balanceOf', response / 1e18));
cptContract.methods.owner().call().then((owner) => console.log('owner', owner));
cptContract.methods.MINTER_ROLE().call().then((response) => console.log('MINTER_ROLE', response));
cptContract.methods.BURNER_ROLE().call().then((response) => console.log('BURNER_ROLE', response));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

// let sendEncodeABI = cptContract.methods.mint(
// 	'0x569f5199C35D569cb9C4B61Bf1b95152aD941960', 
// 	'10000000000000000000').encodeABI(); 

	// let sendEncodeABI = dareContract.methods.transfer('0x3444E23231619b361c8350F4C83F82BCfAB36F65', '72000000000000000000').encodeABI();

// let sendEncodeABI = cptContract.methods.transferOwnership('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').encodeABI();

// Grand TokenVesting contract as MINT_ROLE
// const TokenVestingAddress = '0x76624c221287b1552a379e597166CA8fAA06dF9D'; // kovan
// const TokenVestingAddress = '0x3Fcf6Acb258B863c32533932d5FcFae2B51d03f8'; // bscTestnet
const TokenVestingAddress = '0x757F671d84560D4Bb5d39A66d6dC1b63D9504D65'; // bsc Mainnet
let sendEncodeABI = cptContract.methods.grantRole(
	'0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6', 
	TokenVestingAddress).encodeABI();

callContract(sendEncodeABI, cptContractAddress);
