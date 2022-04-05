/**
 * Testing NFT Marketplace
 */

import {execContract, execEIP1559Contract} from './web3.js';
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

// const marketplaceAddress = '0xc60a6AE3a85838D3bAAf359219131B1e33103560'; // kovan
// const marketplaceAddress = '0x29a1D6404aa907a53b07eFdf0F70cC2A8815EC60'; // bscTestnet
// const marketplaceAddress = '0x22e42fea04f12de858Ce807FE863227486dCE9c3'; // bscTestnet
// const marketplaceAddress = '0x206d806872E78e70Ef6ed7Df24983b6bB378eB87'; // mumbai
const marketplaceAddress = '0xb7a8eBbB8f57ffCBDC2230F2b1C34CFA4Bf22D45'; // bsc mainnet

const marketplaceJson = require('../build/contracts/ChatPuppyNFTMarketplace.json');
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const paymentToken = process.env.CPT_TOKEN_ADDRESS;
const erc20Json = require('../build/contracts/CPTToken.json');

const marketplace = new web3.eth.Contract(marketplaceJson.abi, marketplaceAddress);
const erc20 = new web3.eth.Contract(erc20Json.abi, paymentToken);

marketplace.methods.nftCore().call().then((nftAddress) => {
	console.log('nft Address', nftAddress);
	// const address = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';
	// const nft = new web3.eth.Contract(nftJson.abi, nftAddress);
	// nft.methods.name().call().then((response) => console.log('nft name', response));
	// nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
	// nft.methods.owner().call().then((owner) => console.log('owner of contract', owner));
	// nft.methods.balanceOf(address).call().then((response) => console.log('balanceOf', response / 1));
	// nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));
	// nft.methods.tokenURI(2).call().then((res) => console.log('tokenUri', res));
	// nft.methods.ownerOf(2).call().then((owner) => console.log('owner of nft', owner));

	// marketplace.methods.nextOrderId().call().then((orderId) => console.log('nextOrderId', orderId));

	// Get all onsale list
	// marketplace.methods.onSaleOrderCount().call().then((orderAccount) => { 
	// 	console.log('onSaleOrderCount', orderAccount);
	// 	for(let i = 0; i < orderAccount; i++) {
	// 		marketplace.methods.onSaleOrderAt(i).call().then((orderId) => {
	// 			console.log('orderId', orderId);
	// 			marketplace.methods.orders(orderId).call().then((orderDetails) => console.log('orderId', orderId, 'details', orderDetails));
	// 		});
	// 	}
	// });

	// marketplace.methods.isSeller(1, address).call().then((isSeller) => console.log('isSeller', isSeller));

	/**
	 * ==== Following testing methods is Send Tx ====
	 */
	const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
	const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

	let sendEncodeABI = marketplace.methods.addPaymentToken('0xa747Ba9BbF79E165Cd71c4376B72eBc06CA735CB').encodeABI();

	// let sendEncodeABI = marketplace.methods.updateNftCore('0xA28D90320005C8c043Ee79ae59e82fDd5f983f30').encodeABI();

	// let sendEncodeABI = marketplace.methods.updateFeeRecipient('0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833').encodeABI();

	// const tokenId = 141;

	// Approve marketplace to the NFT
	// let sendEncodeABI = nft.methods.approve(marketplaceAddress, tokenId).encodeABI();
	// callEIP1559Contract(sendEncodeABI, nftAddress);

	// add order nft
	// let sendEncodeABI = marketplace.methods.addOrder(tokenId, paymentToken, '120000000000000000000').encodeABI();

	// update price
	// let sendEncodeABI = marketplace.methods.updatePrice(1, '200000000000000000').encodeABI();

	// cancel order
	// let sendEncodeABI = marketplace.methods.cancelOrder(4).encodeABI();

	// match order
	// let sendEncodeABI = erc20.methods.approve(marketplaceAddress, '1200000000000000000000').encodeABI();
	// callEIP1559Contract(sendEncodeABI, paymentToken);

	// let sendEncodeABI = marketplace.methods.matchOrder(3, '15000000000000000000').encodeABI();

	// let sendEncodeABI = marketplace.methods.cancelAllOrders().encodeABI();
	// let sendEncodeABI = marketplace.methods.pause(false).encodeABI();
	callContract(sendEncodeABI, marketplaceAddress);
});
