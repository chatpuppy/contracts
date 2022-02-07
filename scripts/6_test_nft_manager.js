/**
 * Testing NFT Manager(Mystery box)
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

const nftManagerAddress = '0x0528E41841b8BEdD4293463FAa061DdFCC5E41bd';
const nftManagerJson = require('../build/contracts/ChatPuppyNFTManager.json');
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const nftManager = new web3.eth.Contract(nftManagerJson.abi, nftManagerAddress);
const user = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';

const tokenId = 8;
nftManager.methods.boxStatus(tokenId).call().then((result) => console.log('boxStatus ' + result));
nftManager.methods.boxPrice().call().then((result) => console.log('boxPrice ' + result));

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

	// TokenId 5: 0x26 07 001f 06 0017 05 0011 04 000f 03 0008 02 0000 01 000001 003c 0006 0005 01 01
	// TokenId 4: 0x27 07 001e 06 0017 05 0011 04 000d 03 0009 02 0005 01 000002 003c 0006 0005 01 01
	// TokenId 7: 0x23 07 001f 06 0017 05 0014 04 0010 03 0009 02 0002 01 000003 003c 0006 0005 01 01
	// TokenId 8: 0x25 07 001e 06 0018 05 0011 04 000d 03 000a 02 0003 01 000004 003c 0006 0005 01 01
	// TokenId 9: 0x26 07 0021 06 0017 05 0016 04 000c 03 0009 02 0001 01 000002 0046 0007 0004 01 01
	/**
	* ==== Following testing methods is Send Tx ====
	*/
	const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

	// let sendEncodeABI = nft.methods.increaseCap(1).encodeABI();
	// let sendEncodeABI = nft.methods.updateBaseTokenURI("https://dragonaire.com/").encodeABI();
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
	// callContract(sendEncodeABI, nftAddress, 0)

	// let sendEncodeABI = nftManager.methods.updateBoxPrice('10000000000000000').encodeABI();//set price 0.01ETH
	/**
	 * Transfer nft manager contract address to super account as owner to nft token, to manager the NFT
	 * This step is very important and sencitive !!!
	 * =========
	 * IMPORTANT:
	 * If you want to manager NFT as mystery box, the owner of nft must be nft-manager contract address, and use mint method to add mystery box
	 */
	// let sendEncodeABI = nftManager.methods.upgradeContract('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').encodeABI();

	// Update projectId if meet: random number for token is already exist
	// let sendEncodeABI = nftManager.methods.updateProjectId(120).encodeABI();

	// Withdraw from contract
	// const withdrawAmount = (0.008 * 1e18).toString();
	// let sendEncodeABI = nftManager.methods.withdraw('0xC4BFA07776D423711ead76CDfceDbE258e32474A', withdrawAmount).encodeABI();

	// Mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.mint(user, 1).encodeABI();

	// Buy and mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyAndMint(1).encodeABI();
	// callContract(sendEncodeABI, nftManagerAddress, '10000000000000000');

	// Buy, mint and unbox mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyMintAndUnbox(1).encodeABI();
	// callContract(sendEncodeABI, nftManagerAddress, '10000000000000000');

	// Batch mint mystery box NFT
	// BUG: Can only batch mint 3 nfts one time.
	// let sendEncodeABI = nftManager.methods.mintBatch(user, 1, 3).encodeABI();
	
	// Unbox mystery box
	// let sendEncodeABI = nftManager.methods.unbox(3).encodeABI();
	// callContract(sendEncodeABI, nftManagerAddress);

	// Batch buy and mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.buyAndMintBatch(1, 3).encodeABI();
	// callContract(sendEncodeABI, nftManagerAddress, '30000000000000000');

});

