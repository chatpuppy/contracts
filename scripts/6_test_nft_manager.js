/**
 * Testing NFT Manager(Mystery box)
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

// const nftManagerAddress = '0x0528E41841b8BEdD4293463FAa061DdFCC5E41bd'; // kovan
// const nftManagerAddress = '0xd3eE8844847403a3160A4b1a9322F5CdebDF7F4c'; // bscTestnet
const nftManagerAddress = '0xCCAcc7F68bC4498CeA4Ee4D71e0AC0d824ca4513'; // mumbai

const nftManagerJson = require('../build/contracts/ChatPuppyNFTManager.json');
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const nftManager = new web3.eth.Contract(nftManagerJson.abi, nftManagerAddress);
const user = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';

const tokenId = 2;
nftManager.methods.boxStatus(tokenId).call().then((result) => console.log('boxStatus ' + result));
nftManager.methods.boxPrice().call().then((result) => console.log('boxPrice ' + result));

nftManager.methods.randomWords(tokenId).call().then((result) => console.log('randomWords', result));

nftManager.methods.nftCore().call().then((nftAddress) => {
	console.log('nft Address', nftAddress);
	const nft = new web3.eth.Contract(nftJson.abi, nftAddress);
	nft.methods.name().call().then((response) => console.log('nft name', response));
	nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
	nft.methods.owner().call().then((owner) => console.log('owner of nft contract', owner));
	nft.methods.balanceOf(user).call().then((response) => console.log('balanceOf ' + user, response / 1));
	nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));
	
	nft.methods.tokenURI(tokenId).call().then((res) => console.log('tokenUri of ' + tokenId, res));
	nft.methods.ownerOf(tokenId).call().then((owner) => console.log('owner of nft ' + tokenId, owner));
	nft.methods.tokenMetaData(tokenId).call().then((metaData) => console.log('metadata of nft ' + tokenId, metaData));

	/**
	* ==== Following testing methods is Send Tx ====
	*/
	const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	
	const callEIP1559Contract = (encodeABI, contractAddress, value) => execEIP1559Contract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

	let sendEncodeABI = nft.methods.increaseCap(50).encodeABI();
	
	// let sendEncodeABI = nft.methods.updateBaseTokenURI("https://nft.chatpuppy.com/token/").encodeABI();
	// let sendEncodeABI = nft.methods.mint(user).encodeABI();

	// let sendEncodeABI = nft.methods.updateTokenMetaData(1, 256).encodeABI();
	
	/** transfer testing
		* Acc#1 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 30 id2=>acc#2
		* Acc#2 0xC4BFA07776D423711ead76CDfceDbE258e32474A 
		* Acc#3 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 
		* kov#1 0x3FE7995Bf0a505a51196aA11218b181c8497D236 
		* kov#2 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 
		* kov#3 0x3444E23231619b361c8350F4C83F82BCfAB36F65 
	*/

	// let sendEncodeABI = nft.methods.safeTransferFrom('0x615b80388E3D3CaC6AA3a904803acfE7939f0399', '0xC4BFA07776D423711ead76CDfceDbE258e32474A', 2).encodeABI();
	// callEIP1559Contract(sendEncodeABI, nftAddress, 0)

	// let sendEncodeABI = nftManager.methods.updateBoxPrice('10000000000000000').encodeABI();//set price 0.01ETH

	// let sendEncodeABI = nftManager.methods.updateRandomGenerator('0x20679a9a3c519e63f0cde838a050c3716838c796').encodeABI();

	// let sendEncodeABI = nftManager.methods.updateNFTCoreContract('0xA28D90320005C8c043Ee79ae59e82fDd5f983f30').encodeABI();
	/**
	 * Transfer nft manager contract address to super account as owner to nft token, to manager the NFT
	 * This step is very important and sencitive !!!
	 * =========
	 * IMPORTANT:
	 * If you want to manager NFT as mystery box, the owner of nft must be nft-manager contract address, and use mint method to add mystery box
	 */
	// let sendEncodeABI = nftManager.methods.upgradeContract('0x8d3fc53883d89f359dE81c90bb26A729a01FdE09').encodeABI();

	// let sendEncodeABI = nftManager.methods.updateItemFactory('0x21C0Dd93f1c00c9741504D4640EDd5C4a8E3f128').encodeABI();

	// Update projectId if meet: random number for token is already exist
	// let sendEncodeABI = nftManager.methods.updateProjectId(120).encodeABI();

	// Withdraw from contract
	// const withdrawAmount = (0.02 * 1e18).toString();
	// let sendEncodeABI = nftManager.methods.withdraw('0xC4BFA07776D423711ead76CDfceDbE258e32474A', withdrawAmount).encodeABI();

	// Mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.mint(user, 1).encodeABI();

	// Buy and mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyAndMint(1).encodeABI();
	// callEIP1559Contract(sendEncodeABI, nftManagerAddress, '10000000000000000');

	// Buy, mint and unbox mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyMintAndUnbox(1).encodeABI();
	// callEIP1559Contract(sendEncodeABI, nftManagerAddress, '10000000000000000');

	// Batch mint mystery box NFT
	// BUG: Can only batch mint 3 nfts one time.
	// let sendEncodeABI = nftManager.methods.mintBatch(user, 3).encodeABI();
	
	// let sendEncodeABI = nftManager.methods.upgradeNFTCoreOwner('0xCCAcc7F68bC4498CeA4Ee4D71e0AC0d824ca4513').encodeABI();

	// Unbox mystery box
	// let sendEncodeABI = nftManager.methods.unbox(tokenId).encodeABI();
	callEIP1559Contract(sendEncodeABI, nftManagerAddress);

	// Batch buy and mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyAndMintBatch(1, 3).encodeABI();
	// callEIP1559Contract(sendEncodeABI, nftManagerAddress, '30000000000000000');

});

