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

const cptContractAddress = '0xcAd78BFCE45549214EA2F68dc1f3E6DB9D8F8792';
const cptContractJson = require('../build/contracts/CPTToken.json');

const cptContract = new web3.eth.Contract(cptContractJson.abi, cptContractAddress);

cptContract.methods.name().call().then((response) => console.log('token name', response));
cptContract.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1e18));

cptContract.methods.balanceOf('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').call().then((response) => console.log('balanceOf', response / 1e18));
cptContract.methods.owner().call().then((owner) => console.log('owner', owner));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

let sendEncodeABI = cptContract.methods.mint('0x615b80388E3D3CaC6AA3a904803acfE7939f0399', '10000000000000000000000').encodeABI(); 
// let sendEncodeABI = dareContract.methods.transfer('0x3444E23231619b361c8350F4C83F82BCfAB36F65', '72000000000000000000').encodeABI();

callContract(sendEncodeABI, cptContractAddress);
