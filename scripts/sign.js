/**
 * Testing Sign
 */

import {execContract, sign} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

// const rpcUrl = 'https://bsc-dataseed1.binance.org';
const rpcUrl = 'https://data-seed-prebsc-1-s1.binance.org:8545';
const chainId = 97;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));
const address = (web3.eth.accounts.privateKeyToAccount('0x' + priKey)).address;

console.log(address);
const signature = sign("hello", priKey);
console.log(signature);

/**
f8498080808080801ca0bbd38d123d3f0d07631feeae898c9096a1eb994a6a18d073e27d35869eb06440a0502cbe1d44d6ac95c1c59d79e803cce0ba1cdaade9277579c75826a0bf4de15d
*/
