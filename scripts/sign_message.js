/**
 * Testing Sign
 */

import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method
const Web3 = require('web3');
const web3 = new Web3();

const priKey = process.env.PRI_KEY;
const msg = "Hello, chatpuppy!";
const address = (web3.eth.accounts.privateKeyToAccount('0x' + priKey)).address;

console.log(address);
const signature = web3.eth.accounts.sign(msg, priKey);
console.log(signature);

const messageHash = web3.eth.accounts.hashMessage(msg);
console.log('messageHash', messageHash);

const recover = web3.eth.accounts.recover(
	msg,
	signature.signature
)
console.log('recover', recover);

/**
f8498080808080801ca0bbd38d123d3f0d07631feeae898c9096a1eb994a6a18d073e27d35869eb06440a0502cbe1d44d6ac95c1c59d79e803cce0ba1cdaade9277579c75826a0bf4de15d
*/
