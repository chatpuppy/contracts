/**
 * Testing Item Factory
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {getTokensOfOwner} from 'erc721-balance';
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

// const rpcUrl = 'https://bsc-dataseed1.binance.org';
const rpcUrl = 'https://data-seed-prebsc-1-s1.binance.org:8545';
const chainId = 97;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const itemFactoryAddress = '0x883427733fD8C30C6619cFED646d3cFEa5E3a1FB';
const itemFactoryJson = require('../build/contracts/ItemFactory.json');

const itemFactory = new web3.eth.Contract(itemFactoryJson.abi, itemFactoryAddress);

itemFactory.methods.owner().call().then((owner) => console.log('owner of contract', owner));
itemFactory.methods.supportedBoxTypes().call().then((types) => console.log('box types', types));
itemFactory.methods.supportedItemTypes().call().then((types) => console.log('item types', types));
itemFactory.methods.totalSupply(1).call().then((response) => console.log('total supply', response));
itemFactory.methods.artifactsLength(3).call().then((response) => console.log('artifactsLength', response));

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress) => execContract(web3, chainId, priKey, encodeABI, contractAddress, null, null, null, null);	
// let sendEncodeABI = itemFactory.methods.addItem(3, 3, 7, 30).encodeABI();
// callContract(sendEncodeABI, itemFactoryAddress);
