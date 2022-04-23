pragma solidity ^0.8.8;


// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _potentialOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerNominated(address potentialOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current potentialOwner.
     */
    function potentialOwner() public view returns (address) {
        return _potentialOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function nominatePotentialOwner(address newOwner) public virtual onlyOwner {
        _potentialOwner = newOwner;
        emit OwnerNominated(newOwner);
    }

    function acceptOwnership () public virtual {
        require(msg.sender == _potentialOwner, 'You must be nominated as potential owner before you can accept ownership');
        emit OwnershipTransferred(_owner, _potentialOwner);
        _owner = _potentialOwner;
        _potentialOwner = address(0);
    }
}

/**
 * @dev Interface of the TokensVesting contract.
 */
interface ITokensVesting {
    /**
     * @dev Returns the total amount of tokens in vesting plan.
     */
    function total() external view returns (uint256);

    /**
     * @dev Returns the total releasable amount of tokens.
     */
    function releasableAll() external view returns (uint256);

    /**
     * @dev Returns the releasable of given index
     */
    function releasable(uint256 index_) external view returns (uint256);

    /**
     * @dev Returns the total released amount of tokens.
     */
    function released() external view returns (uint256);

    /**
     * @dev Unlocks all releasable amount of tokens.
     *
     * Emits a {TokensReleased} event.
     */
    function releaseAll() external;

    function setPriceRange(uint8 participant, uint256 fromAmount, uint256 price) external;

    function setCrowdFundingParams(
        uint8   participant,
        uint256 genesisTimestamp,
        uint256 tgeAmountRatio,
        uint256 cliff,
        uint256 duration,
        uint256 eraBasis,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 highest,
        uint256 lowest,
        bool    acceptOverCap,
        bool    allowRedeem
    ) external;

    function updatePriceRange(
        uint8 participant,
        uint256 index,
        uint256 fromAmount,
        uint256 price
    ) external;

    function getPriceForAmount(uint8 participant, uint256 amount) external view returns(uint256, uint256);
    function crowdFunding(uint8 participant) external payable;

    function addBeneficiary(
        address beneficiary,
        uint256 genesisTimestamp,
        uint256 totalAmount,
        uint256 tgeAmount,
        uint256 cliff,
        uint256 duration,
        uint8   participant,
        uint256 eraBasis,
        uint256 price
    ) external;
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 amount) external;
    function decimals() external returns (uint256);
}

/**
 * @dev Implementation of the {ITokenVesting} interface.
 */
contract TokensVesting is Ownable, ITokensVesting {
	IERC20Mintable public token;

	uint256 public revokedAmount = 0;
	uint256 public revokedAmountWithdrawn = 0;
	uint256 private _redeemFee = 500; // 500 means 500 / 10000 = 5%
	uint256 private _redeemableTime = 48 * 3600; 

	enum Participant {
		Unknown,
		PrivateSale,
		PublicSale,
		Team,
		Advisor,
		Liquidity,
		Incentives,
		Marketing,
		Reserve,
		OutOfRange
	}

	enum Status {
		Inactive,
		Active,
		Revoked
	}

	struct VestingInfo {
		uint256 timestamp;
		uint256 genesisTimestamp;
		uint256 totalAmount;
		uint256 tgeAmount;
		uint256 cliff;
		uint256 duration;
		uint256 releasedAmount;
		uint256 eraBasis;
		address beneficiary;
		Participant participant;
		Status status;
		uint256 price;
	}
	VestingInfo[] private _beneficiaries;

	struct PriceRange {
		uint256 fromAmount;     // Token amount, not BNB/ETH amount
		uint256 price;          // if 0.5BNB change to 10000 CPT, the price is 10000 / 0.5 = 20000
	}
	mapping(uint256 => PriceRange[]) private _priceRange;

	struct CrowdFundingParams {
		uint256 genesisTimestamp;
		uint256 tgeAmountRatio; // 0-10000, if _tgeAmountRatio is 50, the ratio is 50 / 10**2 = 50%
		uint256 cliff;
		uint256 duration;
		uint256 eraBasis;          // seconds
		uint256 startTimestamp; // funding start
		uint256 endTimestamp;   // funding end
		uint256 highest;        // investment max, this limitation is ETH/BNB amount, not token amount
		uint256 lowest;         // investment min, this limitation is ETH/BNB amount, not token amount
		bool    acceptOverCap;  // if amount more than cap, can accept?
		bool    allowRedeem;
	}
	mapping(uint256 => CrowdFundingParams) private _crowdFundingParams;

	event BeneficiaryAdded(address indexed beneficiary, uint256 amount);
	event BeneficiaryActivated(uint256 index, address indexed beneficiary);
	event BeneficiaryRevoked(uint256 index, address indexed beneficiary, uint256 amount);

	event TokensReleased(address indexed beneficiary, uint256 amount);
	event Withdraw(address indexed receiver, uint256 amount);

	event CrowdFundingAdded(uint8 participant, address account, uint256 price, uint256 amount);
	event Redeem(uint8 participant, address account, uint256 amount, uint256 revokeAmount);


	constructor(address token_) {
		updateToken(token_);
	}

	receive() external payable {
	}

	/**
		* @dev Get beneficiary by index_.
		*/
	function getBeneficiary(uint256 index_) public view returns (VestingInfo memory) {
		return _beneficiaries[index_];
	}

	/**
		* @dev Get index by beneficiary
		*/
	function getIndex(uint8 participant_, address beneficiary_) public view returns(bool, uint256) {
		bool has = false;
		uint256 index = 0;
		for(uint256 i = 0; i < _beneficiaries.length; i++) {
			if(_beneficiaries[i].beneficiary == beneficiary_ 
				&& _beneficiaries[i].participant == Participant(participant_)) {
				index = i;
				has = true;
				break;
			}
		}
		return (has, index);
	}

	/**
		* @dev Get total beneficiaries amount
		*/
	function getBeneficiaryCount() public view returns (uint256) {
		return _beneficiaries.length;
	}

	function getBeneficiaryCountParticipant(uint8 participant_) public view returns (uint256) {
		uint256 count = 0;
		for(uint256 i = 0; i < _beneficiaries.length; i++) {
			if(_beneficiaries[i].participant == Participant(participant_)) count++;
		}
		return count;
	}

	/**
		* @dev Get all beneficiaries, only called by owner
		*/
	function getAllBeneficiaries() public view onlyOwner returns (VestingInfo[] memory) {
		return _beneficiaries;
	}

	/**
		* @dev Set crowd funding params
		*/
	function setCrowdFundingParams(
		uint8   participant_,
		uint256 genesisTimestamp_,
		uint256 tgeAmountRatio_,
		uint256 cliff_,
		uint256 duration_,
		uint256 eraBasis_,
		uint256 startTimestamp_,
		uint256 endTimestamp_,
		uint256 highest_,
		uint256 lowest_,
		bool    acceptOverCap_,
		bool    allowRedeem_
	) external onlyOwner {
		require(Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale, 
				"TokensVesting: participant shoud only be PrivateSale or PublicSale");
		require(tgeAmountRatio_ >= 0 && tgeAmountRatio_ <= 10000, "TokensVesting: tge ratio is more than 10000");
		require(eraBasis_ <= duration_, "TokensVesting: eraBasis_ smaller than duration_");
		require(endTimestamp_ > startTimestamp_, "TokensVesting: end time is later than start");

		_crowdFundingParams[participant_].genesisTimestamp = genesisTimestamp_;
		_crowdFundingParams[participant_].tgeAmountRatio = tgeAmountRatio_;
		_crowdFundingParams[participant_].cliff = cliff_;
		_crowdFundingParams[participant_].duration = duration_;
		_crowdFundingParams[participant_].eraBasis = eraBasis_;
		_crowdFundingParams[participant_].startTimestamp = startTimestamp_;
		_crowdFundingParams[participant_].endTimestamp = endTimestamp_;
		_crowdFundingParams[participant_].highest = highest_;
		_crowdFundingParams[participant_].lowest = lowest_;
		_crowdFundingParams[participant_].acceptOverCap = acceptOverCap_;
		_crowdFundingParams[participant_].allowRedeem = allowRedeem_;
	}

	/**
		* @dev Get crowd funding params
		*/
	function crowdFundingParams(uint256 participant_) public view returns(CrowdFundingParams memory) {
		return _crowdFundingParams[participant_];
	}

	/**
		* @dev add the price for each phase
		*/
	function setPriceRange (
		uint8   participant_,
		uint256 fromAmount_,
		uint256 price_
	) external onlyOwner {
		require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale),
			'TokensVesting: participant shoud only be PrivateSale or PublicSale');
		require(price_ > 0, 'TokensVesting: price can not be zero');

		PriceRange storage priceRange_ = _priceRange[participant_].push();
		priceRange_.fromAmount = fromAmount_;
		priceRange_.price = price_;
	}

	/**
		* @dev Get the price range list
		*/
	function priceRange(uint256 participant_) public view returns(PriceRange[] memory) {
		return _priceRange[participant_];
	}

	/**
		* @dev Get the cap of type of participant
		*/
	function getCap(uint8 participant_) public view returns(uint256) {
		PriceRange[] memory priceRanges_ = _priceRange[participant_];
		return priceRanges_[priceRanges_.length - 1].fromAmount;
	}

	/**
		* @dev update the price for each phase
		* If 1BNB = 1000CPT, the price should be 1000, not 1000 * 1e18!
		*/
	function updatePriceRange (
		uint8 participant_,
		uint256 index_,
		uint256 fromAmount_,
		uint256 price_
	) external onlyOwner {
		require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale),
			'TokensVesting: participant shoud only be PrivateSale or PublicSale');
		require(index_ >= 0 && index_ < _priceRange[participant_].length, 'TokensVesting: index is out of price range');
		require(price_ > 0, 'TokensVesting: price can not be zero');
		require(_priceRange[participant_][index_].price > 0, 'TokensVesting: price of index not set');

		_priceRange[participant_][index_].fromAmount = fromAmount_;
		_priceRange[participant_][index_].price = price_;
	}

	/**
		* @dev get current price according to the raised amount and amount want to donate.
		*/
	function getPriceForAmount (uint8 participant_, uint256 amount_) external view returns(uint256 price_, uint256 index_) {
		// the price must be according to the after-donation amount
		(price_, index_) = _getPriceForAmount(participant_, getTotalAmountByParticipant(participant_) + amount_);
	}

	/**
		* @dev Donator pay ETH/BNB and get quota of token(need donator claim after cliff)
		*/
	function crowdFunding(uint8 participant_) external payable {
		require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale),
				'TokensVesting: crowdFunding participant should only be PrivateSale or PublicSale');
		require(_crowdFundingParams[participant_].highest >= msg.value, 'TokensVesting: more than highest');
		require(_crowdFundingParams[participant_].lowest <= msg.value, 'TokensVesting: less than lowest');

		require(_crowdFundingParams[participant_].startTimestamp <= block.timestamp,
				'TokensVesting: crowd funding is not start');
		require(_crowdFundingParams[participant_].endTimestamp >= block.timestamp,
				'TokensVesting: crowd funding is end');

		(bool has_, ) = getIndex(participant_, _msgSender());
		require(!has_, 'TokensVesting: one address only once');

		uint256 total_ = getTotalAmountByParticipant(participant_);
		(uint256 price_, ) = _getPriceForAmount(participant_, total_);
		require(price_ > 0, 'TokensVesting: price must be greater than 0');
		uint256 decimals = token.decimals();
		uint256 tokenAmount = msg.value * price_ / 10**(18 - decimals);
		require(tokenAmount > 0, 'TokensVesting: token amount must be greater than 0');

		// Recalculate the the price and tokenAmount according the after-donation amount
		(price_, ) = _getPriceForAmount(participant_, total_ + tokenAmount);
		tokenAmount = msg.value * price_ / 10**(18 - decimals);

		if(!_crowdFundingParams[participant_].acceptOverCap) {
			PriceRange[] memory priceRange_ = _priceRange[participant_];
			require(
				total_ + tokenAmount <= priceRange_[priceRange_.length - 1].fromAmount,
				'TokensVesting: more than cap of this participant type');
		}

		// add beneficiary
		_addBeneficiary(
			_msgSender(),
			_crowdFundingParams[participant_].genesisTimestamp,
			tokenAmount,
			tokenAmount * _crowdFundingParams[participant_].tgeAmountRatio / 10000,
			_crowdFundingParams[participant_].cliff,
			_crowdFundingParams[participant_].duration,
			participant_,
			_crowdFundingParams[participant_].eraBasis,
			price_
		);
		emit CrowdFundingAdded(participant_, _msgSender(), price_, tokenAmount);
	}

	/**
		* @dev Add beneficiary to vesting plan by owner.
		* @param beneficiary_ recipient address.
		* @param genesisTimestamp_ genesis timestamp
		* @param totalAmount_ total amount of tokens will be vested.
		* @param tgeAmount_ an amount of tokens will be vested at tge.
		* @param cliff_ cliff duration.
		* @param duration_ linear vesting duration.
		* @param participant_ specific type of {Participant}.
		* @param eraBasis_ duration for linear vesting.
		* @param price_ price of buying token
		* Waring: Convert vesting monthly to duration carefully
		* eg: vesting in 9 months => duration = 8 months = 8 * 30 * 24 * 60 * 60
		*/
	function addBeneficiary(
		address beneficiary_,
		uint256 genesisTimestamp_,
		uint256 totalAmount_,
		uint256 tgeAmount_,
		uint256 cliff_,
		uint256 duration_,
		uint8   participant_,
		uint256 eraBasis_,
		uint256 price_
	) external onlyOwner {
		_addBeneficiary(
			beneficiary_,
			genesisTimestamp_,
			totalAmount_,
			tgeAmount_,
			cliff_,
			duration_,
			participant_,
			eraBasis_,
			price_ 
		);
	}

	/**
		* @dev See {ITokensVesting-total}.
		*/
	function total() public view returns (uint256) {
		return _getTotalAmount();
	}

	/**
		* @dev get total amount by participant
		*/
	function getTotalAmountByParticipant(uint8 participant_) public view returns (uint256) {
		return _getTotalAmountByParticipant(Participant(participant_));
	}

	/**
		* @dev Activate specific beneficiary by index_.
		*
		* Only active beneficiaries can claim tokens.
		*/
	function activate(uint256 index_) public onlyOwner {
		require(
			index_ >= 0 && index_ < _beneficiaries.length,
			"TokensVesting: index out of range!"
		);
		_activate(index_);
	}

	/**
		* @dev Activate all of beneficiaries.
		*
		* Only active beneficiaries can claim tokens.
		*/
	function activateAll() public onlyOwner {
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			_activate(i);
		}
	}

	/**
		* @dev Active specific beneficiary by participant
		* onlyOwner
		*/

	function activeParticipant(uint8 participant_) public onlyOwner {
		require(Participant(participant_) > Participant.Unknown && Participant(participant_) < Participant.OutOfRange,
			"TokensVesting: participant out of range!");
		return _activateParticipant(Participant(participant_));
	}

	/**
		* @dev Revoke specific beneficiary by index_.
		*
		* Revoked beneficiaries cannot vest tokens anymore.
		*/
	function revoke(uint256 index_) public onlyOwner {
		require(
			index_ >= 0 && index_ < _beneficiaries.length,
			"TokensVesting: index out of range!"
		);
		_revoke(index_);
	}
	
	/**
		* @dev See {ITokensVesting-releasable}.
		*/
	function releasableAll() public view returns (uint256) {
		uint256 _releasable = 0;
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			VestingInfo storage info = _beneficiaries[i];
			_releasable = _releasable + _releasableAmount(
				info.genesisTimestamp,
				info.totalAmount,
				info.tgeAmount,
				info.cliff,
				info.duration,
				info.releasedAmount,
				info.status,
				info.eraBasis
			);
		}
		return _releasable;
	}

	/**
		* @dev Returns the total releasable amount of tokens for the specific beneficiary by index.
		*/
	function releasable(uint256 index_) public view returns (uint256) {
		VestingInfo storage info = _beneficiaries[index_];
		uint256 _releasable = _releasableAmount(
			info.genesisTimestamp,
			info.totalAmount,
			info.tgeAmount,
			info.cliff,
			info.duration,
			info.releasedAmount,
			info.status,
			info.eraBasis
		);
		return _releasable;
	}

	function participantReleasable(uint8 participant_) public view returns (uint256) {
		return _getReleasableByParticipant(Participant(participant_));
	}

	/**
		* @dev See {ITokensVesting-released}.
		*/
	function released() public view returns (uint256) {
		return _getReleasedAmount();
	}

	function participantReleased(uint8 participant_) public view returns (uint256) {
		return _getReleasedAmountByParticipant(Participant(participant_));
	}

	/**
		* @dev See {ITokensVesting-releaseAll}.
		*/
	function releaseAll() public onlyOwner {
		uint256 _releasable = releasableAll();
		require(_releasable > 0, "TokensVesting: no tokens are due!");

		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			_release(_beneficiaries[i]);
		}
	}

	function releaseParticipant(uint8 participant_) public onlyOwner {
		require(Participant(participant_) > Participant.Unknown &&
			Participant(participant_) < Participant.OutOfRange,
		"TokensVesting: participant out of range!");
		return _releaseParticipant(Participant(participant_));
	}

	/**
		* @dev Release all releasable amount of tokens
		*/
	function release(uint8 participant_) public {
		(bool has_, uint256 index_) = getIndex(participant_, _msgSender());
		require(has_, "TokensVesting: user not found in beneficiary list");
		require(index_ >= 0 && index_ < _beneficiaries.length, "TokensVesting: index out of range!");

		VestingInfo storage info = _beneficiaries[index_];
		require(_msgSender() == info.beneficiary, "TokensVesting: unauthorised sender!");
		_release(info);
	}

	/**
		* @dev Withdraw revoked tokens out of contract.
		*
		* Withdraw amount of tokens upto revoked amount.
		*/
	function withdraw(uint256 amount_) public onlyOwner {
		require(amount_ > 0, "TokensVesting: Bad params!");
		require(
			amount_ <= revokedAmount - revokedAmountWithdrawn,
			"TokensVesting: Amount exceeded revoked amount withdrawable!"
		);
		revokedAmountWithdrawn = revokedAmountWithdrawn + amount_;
		token.mint(_msgSender(), amount_);
		emit Withdraw(_msgSender(), amount_);
	}

	/**
		* @dev Withdraw ETH/BNB from contract.
		*/
	function withdrawCoin(address to_, uint256 amount_) public onlyOwner {
		require(to_ != address(0), "TokensVesting: withdraw address is the zero address");
		require(amount_ > uint256(0), "TokensVesting: withdraw amount is zero");
		require(address(this).balance >= amount_, "TokensVesting: withdraw amount must smaller than balance");
		(bool sent, ) = to_.call{value: amount_}("");
		require(sent, "TokensVesting: Failed to send Ether");
	}

	function updateToken(address token_) public onlyOwner {
		require(token_ != address(0), "TokensVesting: token_ is the zero address!");
		token = IERC20Mintable(token_);
	}

	/**
		* @dev Revoke and return back ETH/BNB to the token buyer from contract
		*/
	function redeem(uint8 participant_) public {
		address to_ = _msgSender();
		(bool redeemable_, string memory message, uint256 index_, VestingInfo memory info) = redeemable(participant_, to_);
		require(redeemable_, message);

		// revoke and get revoke amoount
		uint256 oldRevokedAmount = revokedAmount;
		_revoke(index_);
		uint256 revokeAmount_ = revokedAmount - oldRevokedAmount;

		// get redeem amount
		uint256 price_ = info.price;
		uint256 redeemAmount_ = revokeAmount_  / price_ * (10000 - _redeemFee) / 10000;
		require(address(this).balance >= redeemAmount_, "TokensVesting: balance is not enough");
		(bool sent, ) = to_.call{value: redeemAmount_}("");
		require(sent, "TokensVesting: Fail to redeem Ether");

		emit Redeem(participant_, to_, redeemAmount_, revokeAmount_);
	}

	/**
		* @dev 
		* @param
		* @return canRedeemable
		* @return errorMessage
		* @return index
		* @return vestingInfo
		*/
	function redeemable(uint8 participant_, address address_ ) public view returns(bool, string memory, uint256, VestingInfo memory) {
		VestingInfo memory info;
		if((Participant(participant_) != Participant.PrivateSale && Participant(participant_) != Participant.PublicSale)) 
			return (false, 'TokensVesting: redeem participant should only be PrivateSale or PublicSale', 0, info);
		if(!_crowdFundingParams[participant_].allowRedeem) return(false, 'TokensVesting: redeem not available', 0, info);

		(bool has_, uint index_) = getIndex(participant_, address_);
		if(!has_) return(false, 'TokensVesting: not beneficiary', index_, info);
		if(index_ >= _beneficiaries.length) return(false, "TokensVesting: index out of range!", index_, info);

		info = getBeneficiary(index_);
		if(info.price == 0) return(false, 'TokensVesting: price can not be zero', index_, info);
		if(block.timestamp > info.timestamp + _redeemableTime) return(false, 'TokensVesting: redeem is timeout', index_, info);

		return (true, '', index_, info);
	}

	function updateRedeemFee(uint256 fee_) public onlyOwner {
		require(fee_ > 0 && fee_ <= 10000, "TokensVesting: fee can not be zero and bigger than 10000");
		_redeemFee = fee_;
	}

	function redeemFee() public view returns(uint256) {
		return _redeemFee;
	}

	function updateRedeemableTime(uint256 seconds_) public onlyOwner {
		_redeemableTime = seconds_;
	}

	function redeemableTime() public view returns(uint256) {
		return _redeemableTime;
	}

	function setAllowRedeem(uint8 participant_, bool status) public onlyOwner {
		require(
			Participant(participant_) > Participant.Unknown && Participant(participant_) < Participant.OutOfRange,
			"TokensVesting: participant_ out of range!"
		);
		_crowdFundingParams[participant_].allowRedeem = status;
	}


	/**
		* =================================================================
		* Private methods
		* =================================================================
		*/

	function _addBeneficiary(
		address beneficiary_,
		uint256 genesisTimestamp_,
		uint256 totalAmount_,
		uint256 tgeAmount_,
		uint256 cliff_,
		uint256 duration_,
		uint8   participant_,
		uint256 eraBasis_,
		uint256 price_ 
	) internal {
		require(
			genesisTimestamp_ >= block.timestamp,
			"TokensVesting: genesis too soon!"
		);
		require(
			beneficiary_ != address(0),
			"TokensVesting: beneficiary_ is the zero address!"
		);
		require(
			totalAmount_ >= tgeAmount_,
			"TokensVesting: totalAmount_ must be greater than or equal to tgeAmount_!"
		);
		require(
			Participant(participant_) > Participant.Unknown &&
				Participant(participant_) < Participant.OutOfRange,
			"TokensVesting: participant_ out of range!"
		);
		require(
			genesisTimestamp_ + cliff_ + duration_ <= type(uint256).max,
			"TokensVesting: out of uint256 range!"
		);
		require(
			eraBasis_ > 0,
			"TokensVesting: eraBasis_ must be greater than 0!"
		);

		(bool has_, ) = getIndex(participant_, beneficiary_);
		require(!has_, "TokensVesting: beneficiary exist in this participant");

		VestingInfo storage info = _beneficiaries.push();
		info.timestamp = block.timestamp;
		info.beneficiary = beneficiary_;
		info.genesisTimestamp = genesisTimestamp_;
		info.totalAmount = totalAmount_;
		info.tgeAmount = tgeAmount_;
		info.cliff = cliff_;
		info.duration = duration_;
		info.participant = Participant(participant_);
		info.status = Status.Inactive;
		info.eraBasis = eraBasis_;
		info.price = price_; 

		emit BeneficiaryAdded(beneficiary_, totalAmount_);
	}

	function _getPriceForAmount(uint8 participant_, uint256 amount_) internal view returns(uint256 price_, uint256 index_) {
		if(Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale) {
			PriceRange[] memory priceRange_ = _priceRange[participant_];
			if(amount_ >= priceRange_[priceRange_.length - 1].fromAmount) {
				price_ = priceRange_[priceRange_.length - 1].price;
				index_ = priceRange_.length - 1;
			} else {
				for(uint256 i = 1; i < priceRange_.length; i++) {
					if(priceRange_[i].fromAmount > amount_) {
						price_ = priceRange_[i-1].price;
						index_ = i - 1;
						break;
					}
				}
			}
		}
	}

	/**
		* @dev Release all releasable amount of tokens for the sepecific beneficiary by index.
		*/
	function _release(VestingInfo storage info) private {
		uint256 unreleased = _releasableAmount(
			info.genesisTimestamp,
			info.totalAmount,
			info.tgeAmount,
			info.cliff,
			info.duration,
			info.releasedAmount,
			info.status,
			info.eraBasis
		);

		if (unreleased > 0) {
			info.releasedAmount = info.releasedAmount + unreleased;
			token.mint(info.beneficiary, unreleased);
			emit TokensReleased(info.beneficiary, unreleased);
		}
	}

	function _getTotalAmount() private view returns (uint256) {
		uint256 totalAmount = 0;
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			totalAmount = totalAmount + _beneficiaries[i].totalAmount;
		}
		return totalAmount;
	}

	function _getTotalAmountByParticipant(Participant participant_)	private view returns (uint256) {
		uint256 totalAmount = 0;
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			if (_beneficiaries[i].participant == participant_) {
					totalAmount = totalAmount + _beneficiaries[i].totalAmount;
			}
		}
		return totalAmount;
	}

	function _getReleasedAmount() private view returns (uint256) {
		uint256 releasedAmount = 0;
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			releasedAmount = releasedAmount + _beneficiaries[i].releasedAmount;
		}
		return releasedAmount;
	}

	function _getReleasedAmountByParticipant(Participant participant_) private view returns (uint256) {
		uint256 releasedAmount = 0;
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			if (_beneficiaries[i].participant == participant_) releasedAmount = releasedAmount + _beneficiaries[i].releasedAmount;
		}
		return releasedAmount;
	}

	function _releasableAmount(
		uint256 genesisTimestamp_,
		uint256 totalAmount_,
		uint256 tgeAmount_,
		uint256 cliff_,
		uint256 duration_,
		uint256 releasedAmount_,
		Status 	status_,
		uint256 eraBasis_
	) private view returns (uint256) {
		if (status_ == Status.Inactive) return 0;
		if (status_ == Status.Revoked) return totalAmount_ - releasedAmount_;
		return _vestedAmount(genesisTimestamp_, totalAmount_, tgeAmount_, cliff_, duration_, eraBasis_) - releasedAmount_;
	}

	function _vestedAmount(
		uint256 genesisTimestamp_,
		uint256 totalAmount_,
		uint256 tgeAmount_,
		uint256 cliff_,
		uint256 duration_,
		uint256 eraBasis_
	) private view returns (uint256) {
		if(totalAmount_ < tgeAmount_) return 0;
		if (block.timestamp < genesisTimestamp_) return 0;
		uint256 timeLeftAfterStart = block.timestamp - genesisTimestamp_;

		if (timeLeftAfterStart < cliff_) return tgeAmount_;
		uint256 linearVestingAmount = totalAmount_ - tgeAmount_;
		if (timeLeftAfterStart >= cliff_ + duration_) return linearVestingAmount + tgeAmount_;

		uint256 releaseMilestones = (timeLeftAfterStart - cliff_) / eraBasis_ + 1;
		uint256 totalReleaseMilestones = (duration_ + eraBasis_ - 1) / eraBasis_ + 1;
		return (linearVestingAmount / totalReleaseMilestones) * releaseMilestones + tgeAmount_;
	}

	function _activate(uint256 index_) private {
		VestingInfo storage info = _beneficiaries[index_];
		if (info.status == Status.Inactive) {
			info.status = Status.Active;
			emit BeneficiaryActivated(index_, info.beneficiary);
		}
	}

	function _activateParticipant(Participant participant_) private {
		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			VestingInfo storage info = _beneficiaries[i];
			if (info.participant == participant_) {
				_activate(i);
			}
		}
	}

	function _revoke(uint256 index_) private {
		VestingInfo storage info = _beneficiaries[index_];
		if (info.status == Status.Revoked) return;

		uint256 _releasable = _releasableAmount(
			info.genesisTimestamp,
			info.totalAmount,
			info.tgeAmount,
			info.cliff,
			info.duration,
			info.releasedAmount,
			info.status,
			info.eraBasis
		);

		uint256 oldTotalAmount = info.totalAmount;
		info.totalAmount = info.releasedAmount + _releasable;

		uint256 revokingAmount = oldTotalAmount - info.totalAmount;
		if (revokingAmount > 0) {
			info.status = Status.Revoked;
			revokedAmount = revokedAmount + revokingAmount;
			emit BeneficiaryRevoked(index_, info.beneficiary, revokingAmount);
		}
	}

	function _getReleasableByParticipant(Participant participant_) private view returns (uint256) {
		uint256 _releasable = 0;

		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			VestingInfo storage info = _beneficiaries[i];
			if (info.participant == participant_) {
				_releasable = _releasable + _releasableAmount(
					info.genesisTimestamp,
					info.totalAmount,
					info.tgeAmount,
					info.cliff,
					info.duration,
					info.releasedAmount,
					info.status,
					info.eraBasis
				);
			}
		}
		return _releasable;
	}

	function _releaseParticipant(Participant participant_) private {
		uint256 _releasable = _getReleasableByParticipant(participant_);
		require(_releasable > 0, "TokensVesting: no tokens are due!");

		for (uint256 i = 0; i < _beneficiaries.length; i++) {
			VestingInfo storage info = _beneficiaries[i];
			if (info.participant == participant_) _release(info);
		}
	}
}