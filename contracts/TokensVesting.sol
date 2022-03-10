// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/Ownable.sol";
import "./interfaces/ITokensVesting.sol";
import "./lib/Token/IERC20Mintable.sol";

/**
 * @dev Implementation of the {ITokenVesting} interface.
 */
contract TokensVesting is Ownable, ITokensVesting {
    IERC20Mintable public token;

    uint256 public revokedAmount = 0;
    uint256 public revokedAmountWithdrawn = 0;
    uint256 private _redeemFee = 500; // 500 means 500 / 10000 = 5%

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

        // If dont limit the following, the crowd funding time can be extended event after genesis start
        // require(genesisTimestamp_ > block.timestamp && startTimestamp_ > block.timestamp && endTimestamp_ > block.timestamp,
        //     "TokensVesting: time must after now");
        // require(genesisTimestamp_ > endTimestamp_, "TokensVesting: genesis timestamp must later than end");

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
        require(Participant(participant_) > Participant.Unknown &&
            Participant(participant_) < Participant.OutOfRange,
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
            _releasable = _releasable +
                _releasableAmount(
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
        uint256 balance = address(this).balance;
        require(balance >= amount_, "TokensVesting: withdraw amount must smaller than balance");
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
        require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale),
            'TokensVesting: redeem participant should only be PrivateSale or PublicSale');
        require(_crowdFundingParams[participant_].allowRedeem, 'TokensVesting: redeem not available');
        
        // get the public sale price
        address to_ = _msgSender();
        (bool has_, uint index_) = getIndex(participant_, to_);
        require(has_, "TokensVesting: not beneficiary");
        require(index_ >= 0 && index_ < _beneficiaries.length, "TokensVesting: index out of range!");

        VestingInfo memory info = getBeneficiary(index_);
        uint256 price_ = info.price;
        require(price_ > 0, "TokensVesting: price can not be zero");

        // revoke and get revoke amoount
        uint256 oldRevokedAmount = revokedAmount;
        _revoke(index_);
        uint256 revokeAmount_ = revokedAmount - oldRevokedAmount;

        // get redeem amount
        uint256 redeemAmount_ = revokeAmount_  / price_ * (10000 - _redeemFee) / 10000;
        (bool sent, ) = to_.call{value: redeemAmount_}("");
        require(sent, "TokensVesting: Fail to redeem Ether");

        emit Redeem(participant_, to_, redeemAmount_, revokeAmount_);
    }

    function updateRedeemFee(uint256 fee_) public onlyOwner {
        require(fee_ > 0 && fee_ <= 10000, "TokensVesting: fee can not be zero and bigger than 10000");
        _redeemFee = fee_;
    }

    function redeemFee() public view returns(uint256) {
        return _redeemFee;
    }

    function setAllowRedeem(uint8 participant_, bool status) public onlyOwner {
        require(
            Participant(participant_) > Participant.Unknown &&
                Participant(participant_) < Participant.OutOfRange,
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

    function _getTotalAmountByParticipant(Participant participant_)
        private
        view
        returns (uint256) {
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
            if (_beneficiaries[i].participant == participant_)
                releasedAmount = releasedAmount + _beneficiaries[i].releasedAmount;
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
        Status status_,
        uint256 eraBasis_
    ) private view returns (uint256) {
        if (status_ == Status.Inactive) {
            return 0;
        }

        if (status_ == Status.Revoked) {
            return totalAmount_ - releasedAmount_;
        }

        return
            _vestedAmount(genesisTimestamp_, totalAmount_, tgeAmount_, cliff_, duration_, eraBasis_) - releasedAmount_;
    }

    function _vestedAmount(
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        uint256 eraBasis_
    ) private view returns (uint256) {
        if(totalAmount_ < tgeAmount_) {
            return 0;
        }

        if (block.timestamp < genesisTimestamp_) {
            return 0;
        }

        uint256 timeLeftAfterStart = block.timestamp - genesisTimestamp_;

        if (timeLeftAfterStart < cliff_) {
            return tgeAmount_;
        }

        uint256 linearVestingAmount = totalAmount_ - tgeAmount_;
        if (timeLeftAfterStart >= cliff_ + duration_) {
            return linearVestingAmount + tgeAmount_;
        }

        uint256 releaseMilestones = (timeLeftAfterStart - cliff_) / eraBasis_ + 1;
        uint256 totalReleaseMilestones = (duration_ + eraBasis_ - 1) / eraBasis_ + 1;
        return
            (linearVestingAmount / totalReleaseMilestones) *
            releaseMilestones +
            tgeAmount_;
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
        if (info.status == Status.Revoked) {
            return;
        }

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
                _releasable = _releasable +
                    _releasableAmount(
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
            if (info.participant == participant_) {
                _release(info);
            }
        }
    }
}
