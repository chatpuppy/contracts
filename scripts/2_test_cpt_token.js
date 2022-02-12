/**
 * Testing CPT Token
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

const cptContractAddress = '0x7C4b6E294Fd0ae77B6E1730CBEb1B8491859Ee24';
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

// let sendEncodeABI = cptContract.methods.mint('0x1A81FCbe4a7b9d43B831Ed47A1100262D47eB8cD', '100000000000000000000000000').encodeABI(); 
// let sendEncodeABI = dareContract.methods.transfer('0x3444E23231619b361c8350F4C83F82BCfAB36F65', '72000000000000000000').encodeABI();

// Grand TokenVesting contract as MINT_ROLE
const TokenVestingAddress = '0xd0190d8367486Cd81d966748B35013952CB77Df8';
let sendEncodeABI = cptContract.methods.grantRole(
	'0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6', 
	TokenVestingAddress).encodeABI();

callContract(sendEncodeABI, cptContractAddress);
