/**
 * Testing Price Consumer
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

const priceConsumerAddress = '0x2ca7fd3310082eb0DF4eF6d6bA76180517D1177c';
const priceConsumerJson = require('../build/contracts/PriceConsumerV3.json');

// Must run on BSC Mainnet
const priceConsumer = new web3.eth.Contract(priceConsumerJson.abi, priceConsumerAddress);
priceConsumer.methods.getLatestPrice().call().then((price) => console.log('last price', price));
