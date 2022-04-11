/**
 * Testing NFT Core
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

// const nftAddress = '0xAb50F84DC1c8Ef1464b6F29153E06280b38fA754'; // Issued by nft core
// const nftAddress = '0x1BE54fdAF59d369f8d7bE296C227F208CF5FF7AF'; // bscTestnet
// const nftAddress = '0x87Be7a62d608d29003ec1Ec292F65Df3913C8E34'; // bscTestnet
// const nftAddress = '0xA28D90320005C8c043Ee79ae59e82fDd5f983f30'; // mumbai
// const nftAddress = '0x1923a9F2e255F8AE56ff0acD5c9a3793e38eEcB5'; // bscMainnet
const nftAddress = '0x2c0AAB23e0fC64629623B48Bf9ab1C3a64860A41'; // bscTestnet
// const nftAddress = '0x4F3402D05822E435C27D1B80aee6edD639E681d7'; // Ethereum to bscMainnet by bridge
// const nftAddress = '0x18A1e002958EbAc355102ec84fCbc24C7957B001'; // rinkeby
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const nft = new web3.eth.Contract(nftJson.abi, nftAddress);

nft.methods.name().call().then((response) => console.log('nft name', response));
// nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
// nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));

const tokenId = 1;
if(tokenId > 0) {
	const nftOwner = '0x569f5199C35D569cb9C4B61Bf1b95152aD941960';
	nft.methods.balanceOf(nftOwner).call().then((response) => console.log('balanceOf', response / 1));
	nft.methods.owner().call().then((owner) => console.log('owner of contract', owner));
	nft.methods.tokenURI(tokenId).call().then((res) => console.log('tokenUri', res));
	nft.methods.ownerOf(tokenId).call().then((owner) => console.log('owner of nft', owner));
	nft.methods.tokenMetaData(tokenId).call().then((metadata) => console.log('metadata', metadata));
	// getTokensOfOwner(web3, '0xAb50F84DC1c8Ef1464b6F29153E06280b38fA754', '0xC4BFA07776D423711ead76CDfceDbE258e32474A').then((res) => console.log('getTokensOfOwner', res));	
}

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

// let sendEncodeABI = nft.methods.increaseCap(50).encodeABI();
// let sendEncodeABI = nft.methods.updateBaseTokenURI("https://nft.chatpuppy.com/token/").encodeABI();
// const testAcc = '0x9980947e60A8F61f537B38Aa80Ef7d9a3879aF28';
// let sendEncodeABI = nft.methods.mint(testAcc).encodeABI();
// let sendEncodeABI = nft.methods.updateTokenMetaData(1, 256).encodeABI();

// let sendEncodeABI = nft.methods.mintBatch(testAcc, 3).encodeABI();

/** transfer testing
 * Acc#1 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 30 id2=>acc#2
 * Acc#2 0xC4BFA07776D423711ead76CDfceDbE258e32474A 
 * Acc#3 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 
 * kov#1 0x3FE7995Bf0a505a51196aA11218b181c8497D236 
 * kov#2 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 
 * kov#3 0x3444E23231619b361c8350F4C83F82BCfAB36F65 
 */
// let sendEncodeABI = nft.methods.safeTransferFrom('0xC4BFA07776D423711ead76CDfceDbE258e32474A', '0x3444E23231619b361c8350F4C83F82BCfAB36F65', 2).encodeABI();

// ATTN. Update the owner of the NFTCore to NFTManager contract.
// let sendEncodeABI = nft.methods.transferOwnership('0xb932D3A7cfB81CE4F459Af303793cDC4fe23cd6a').encodeABI();
// callContract(sendEncodeABI, nftAddress);
