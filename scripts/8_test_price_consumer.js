/**
 * Testing NFT Manager
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

const priceConsumerAddress = '0x2ca7fd3310082eb0DF4eF6d6bA76180517D1177c';
const priceConsumerJson = require('../build/contracts/PriceConsumerV3.json');

// Must run on BSC Mainnet
const priceConsumer = new web3.eth.Contract(priceConsumerJson.abi, priceConsumerAddress);
priceConsumer.methods.getLatestPrice().call().then((price) => console.log('last price', price));
	