// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/Ownable.sol";
import "./interfaces/ITokensVesting.sol";
import "./lib/Token/IERC20Mintable.sol";

/**
 * @dev Implementation of the {ITokenVesting} interface.
 */
contract TokensVesting is Ownable, ITokensVesting {
    IERC20Mintable public immutable token;

    uint256 public basis = 30 days;
    uint256 public revokedAmount = 0;
    uint256 public revokedAmountWithdrawn = 0;

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
        uint256 genesisTimestamp;
        uint256 totalAmount;
        uint256 tgeAmount;
        uint256 cliff;
        uint256 duration;
        uint256 releasedAmount;
        uint256 basis;
        address beneficiary;
        Participant participant;
        Status status;
    }

    VestingInfo[] private _beneficiaries;

    /**
     * @dev Setting crowd funding params
     */
    struct PriceRange {
        uint256 fromAmount;
        uint256 toAmount;
        uint256 price;
    }
    mapping(uint256 => PriceRange[]) public _priceRange;

    mapping(uint256 => uint256) public _genesisTimestamp;
    mapping(uint256 => uint256) public _tgeAmountRatio;
    mapping(uint256 => uint256) public _ratioDecimals; // default is 2, if _tgeAmountRatio is 50, the ratio is 50 / 10**2 = 50%
    mapping(uint256 => uint256) public _cliff;
    mapping(uint256 => uint256) public _duration;
    mapping(uint256 => uint256) public _basis;

    event BeneficiaryAdded(address indexed beneficiary, uint256 amount);
    event BeneficiaryActivated(uint256 index, address indexed beneficiary);
    event BeneficiaryRevoked(
        uint256 index,
        address indexed beneficiary,
        uint256 amount
    );

    /**
     * @dev Sets the value for {token}.
     *
     * This value are immutable: it can only be set once during
     * construction.
     */
    constructor(address token_) {
        require(
            token_ != address(0),
            "TokensVesting: token_ is the zero address!"
        );

        token = IERC20Mintable(token_);
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
    function getIndex(address beneficiary_) public view returns(uint256) {
        uint256 index = 0;
        for(uint256 i = 0; i < _beneficiaries.length; i++) {
            if(_beneficiaries[i].beneficiary == beneficiary_) {
                index = i;
                break;
            }
        }
        return index;
    }

    /**
     * @dev Get total beneficiaries amount
     */
    function getBeneficiaryCount() public view returns (uint256) {
        return _beneficiaries.length;
    }

    /**
     * @dev Get all beneficiaries, only called by owner
     */
    function getAllBeneficiaries() public view onlyOwner returns (VestingInfo[] memory) {
        return _beneficiaries;
    }
    
    function setCrowdFundingParams(
        uint8   participant_,
        uint256 genesisTimestamp_,
        uint256 tgeAmountRatio_,
        uint256 ratioDecimals_,
        uint256 cliff_,
        uint256 duration_,
        uint256 basis_,
        uint256 price_
    ) external onlyOwner {
        require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale) 
            && genesisTimestamp_ > 0 && tgeAmountRatio_ >= 0 && cliff_ >= 0 && duration_ >=0 && basis_ >= 0 && price_ >= 0,
            "TokensVesting: invalid params");
        _genesisTimestamp[participant_] = genesisTimestamp_;
        _tgeAmountRatio[participant_] = tgeAmountRatio_;
        _ratioDecimals[participant_] = ratioDecimals_;
        _cliff[participant_] = cliff_;
        _duration[participant_] = duration_;
        _basis[participant_] = basis_;
    }

    /**
     * @dev add the price for each phase
     */
    function setPriceRange (
        uint8   participant_,
        uint256 fromAmount_,
        uint256 toAmount_,
        uint256 price_
    ) external onlyOwner {
        require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale), 
         'TokensVesting: participant shoud only be PrivateSale or PublicSale');
        require(fromAmount_ > 0 && toAmount_ > 0 && toAmount_ > fromAmount_ && price_ > 0, 'TokensVesting: price or fromAmount or toAmount is wrong');

        PriceRange storage priceRange_ = _priceRange[participant_].push();
        priceRange_.fromAmount = fromAmount_;
        priceRange_.toAmount = toAmount_;
        priceRange_.price = price_;

        emit PriceRangeAdded(participant_, fromAmount_, toAmount_, price_);
    }

    /**
     * @dev update the price for each phase
     * If 1BNB = 1000CPT, the price should be 1000, not 1000 * 1e18!
     */
    function updatePriceRange (
        uint8 participant_, 
        uint256 index_, 
        uint256 fromAmount_, 
        uint256 toAmount_, 
        uint256 price_
    ) external onlyOwner {
        require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale), 
         'TokensVesting: participant shoud only be PrivateSale or PublicSale');
        require(fromAmount_ > 0 && toAmount_ > 0 && toAmount_ > fromAmount_ && price_ > 0, 'TokensVesting: price or fromAmount or toAmount is wrong');
        require(_priceRange[participant_][index_].price > 0, 'TokensVesting: price of index not set');

        _priceRange[participant_][index_].fromAmount = fromAmount_;
        _priceRange[participant_][index_].toAmount = toAmount_;
        _priceRange[participant_][index_].price = price_;
    }

    /**
     * @dev get current price according to the raised amount
     */
    function getPriceForAmount (
        uint8 participant_,
        uint256 amount_
    ) external view returns(uint256 price_, uint256 index_) {
        (price_, index_) = _getPriceForAmount(participant_, amount_);
    }

    function getCurrentPrice (uint8 participant_) external view returns (uint256 price_, uint256 index_) {
        (price_, index_) = _getPriceForAmount(participant_, _getTotalAmount());
    }

    /**
     * @dev Donator pay ETH/BNB and get quota of token(need donator claim after cliff)
     */
    function crowdFunding(uint8 participant_) external payable {
        (uint256 price_, ) = _getPriceForAmount(participant_, _getTotalAmount());
        require(price_ > 0, 'TokensVesting: price must be greater than 0');
        uint256 decimals = token.decimals();
        uint256 tokenAmount = msg.value * price_ / 10**(18 - decimals);
        require(tokenAmount > 0, 'TokensVesting: token amount must be greater than 0');

        // add beneficiary ######
        _addBeneficiary(
            msg.sender,
            _genesisTimestamp[participant_],
            tokenAmount,
            tokenAmount * _tgeAmountRatio[participant_] / 10 ** _ratioDecimals[participant_],
            _cliff[participant_],
            _duration[participant_],
            participant_,
            _basis[participant_]
        );

        emit CrowdFundingAdded(participant_, msg.sender, price_, tokenAmount);
    }

    function _getPriceForAmount(uint8 participant_, uint256 amount_) internal view returns(uint256 price_, uint256 index_) {
        require((Participant(participant_) == Participant.PrivateSale || Participant(participant_) == Participant.PublicSale), 
         'TokensVesting: participant shoud only be PrivateSale or PublicSale');
        for(uint256 i = 0; i < _priceRange[participant_].length; i++) {
            PriceRange memory range = _priceRange[participant_][i];
            if(range.fromAmount <= amount_ && range.toAmount >= amount_) {
                price_ = range.price;
                index_ = i;
            }
        }
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
     * @param basis_ basis duration for linear vesting.
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
        uint256 basis_
    ) external onlyOwner {
        _addBeneficiary(
            beneficiary_,
            genesisTimestamp_,
            totalAmount_,
            tgeAmount_,
            cliff_,
            duration_,
            participant_,
            basis_
        );
    }

    function _addBeneficiary(
        address beneficiary_,
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        uint8   participant_,
        uint256 basis_
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
            basis_ > 0,
            "TokensVesting: basis_ must be greater than 0!"
        );

        VestingInfo storage info = _beneficiaries.push();
        info.beneficiary = beneficiary_;
        info.genesisTimestamp = genesisTimestamp_;
        info.totalAmount = totalAmount_;
        info.tgeAmount = tgeAmount_;
        info.cliff = cliff_;
        info.duration = duration_;
        info.participant = Participant(participant_);
        info.status = Status.Inactive;
        info.basis = basis_;

        emit BeneficiaryAdded(beneficiary_, totalAmount_);
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
        require(Participant(participant_) > Participant.Unknown &&
                Participant(participant_) < Participant.OutOfRange,
            "TokensVesting: participant out of range!");
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
    function releasable() public view returns (uint256) {
        uint256 _releasable = 0;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            VestingInfo storage info = _beneficiaries[i];
            _releasable =
                _releasable +
                _releasableAmount(
                    info.genesisTimestamp,
                    info.totalAmount,
                    info.tgeAmount,
                    info.cliff,
                    info.duration,
                    info.releasedAmount,
                    info.status,
                    info.basis
                );
        }

        return _releasable;
    }

    /**
     * @dev Returns the total releasable amount of tokens for the specific beneficiary by index.
     */
    function releasable(uint256 index_) public view returns (uint256) {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting: index out of range!"
        );

        VestingInfo storage info = _beneficiaries[index_];
        uint256 _releasable = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        return _releasable;
    }

    function participantReleasable(uint8 participant_) public view returns (uint256) {
        require(Participant(participant_) > Participant.Unknown &&
            Participant(participant_) < Participant.OutOfRange,
        "TokensVesting: participant out of range!");
        return _getReleasableByParticipant(Participant(participant_));
    }

    /**
     * @dev See {ITokensVesting-released}.
     */
    function released() public view returns (uint256) {
        return _getReleasedAmount();
    }

    function participantReleased(uint8 participant_) public view returns (uint256) {
        require(Participant(participant_) > Participant.Unknown &&
            Participant(participant_) < Participant.OutOfRange,
        "TokensVesting: participant out of range!");
        return _getReleasedAmountByParticipant(Participant(participant_));
    }

    /**
     * @dev See {ITokensVesting-releaseAll}.
     */
    function releaseAll() public onlyOwner {
        uint256 _releasable = releasable();
        require(
            _releasable > 0,
            "TokensVesting: no tokens are due!"
        );

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _release(i);
        }
    }

    function releaseParticipant(uint8 participant_) public onlyOwner {
        require(Participant(participant_) > Participant.Unknown &&
            Participant(participant_) < Participant.OutOfRange,
        "TokensVesting: participant out of range!");
        return _releaseParticipant(Participant(participant_));
    }

    /**
     * @dev Release all releasable amount of tokens for the sepecific beneficiary by index.
     *
     * Emits a {TokensReleased} event.
     */
    function release(uint256 index_) public {
        require(
            index_ >= 0 && index_ < _beneficiaries.length,
            "TokensVesting: index out of range!"
        );

        VestingInfo storage info = _beneficiaries[index_];
        require(
            _msgSender() == owner() || _msgSender() == info.beneficiary,
            "TokensVesting: unauthorised sender!"
        );

        uint256 unreleased = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
        );

        require(unreleased > 0, "TokensVesting: no tokens are due!");

        info.releasedAmount = info.releasedAmount + unreleased;
        token.mint(info.beneficiary, unreleased);
        emit TokensReleased(info.beneficiary, unreleased);
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
     * @dev Update basis_
     */
    function updateBasic(uint256 basis_) public onlyOwner {
        require(basis_ > 0, "TokensVesting: basic must be greater than 0");
        basis = basis_;
    }

    /**
     * @dev Release all releasable amount of tokens for the sepecific beneficiary by index.
     *
     * Emits a {TokensReleased} event.
     */
    function _release(uint256 index_) private {
        VestingInfo storage info = _beneficiaries[index_];
        uint256 unreleased = _releasableAmount(
            info.genesisTimestamp,
            info.totalAmount,
            info.tgeAmount,
            info.cliff,
            info.duration,
            info.releasedAmount,
            info.status,
            info.basis
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
        returns (uint256)
    {
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

    function _getReleasedAmountByParticipant(Participant participant_)
        private
        view
        returns (uint256)
    {
        require(
            Participant(participant_) > Participant.Unknown &&
                Participant(participant_) < Participant.OutOfRange,
            "TokensVesting: participant out of range!"
        );

        uint256 releasedAmount = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i].participant == participant_)
                releasedAmount =
                    releasedAmount +
                    _beneficiaries[i].releasedAmount;
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
        uint256 basis_
    ) private view returns (uint256) {
        if (status_ == Status.Inactive) {
            return 0;
        }

        if (status_ == Status.Revoked) {
            return totalAmount_ - releasedAmount_;
        }

        return
            _vestedAmount(genesisTimestamp_, totalAmount_, tgeAmount_, cliff_, duration_, basis_) -
            releasedAmount_;
    }

    function _vestedAmount(
        uint256 genesisTimestamp_,
        uint256 totalAmount_,
        uint256 tgeAmount_,
        uint256 cliff_,
        uint256 duration_,
        uint256 basis_
    ) private view returns (uint256) {
        require(
            totalAmount_ >= tgeAmount_,
            "TokensVesting: Bad params!"
        );

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

        uint256 releaseMilestones = (timeLeftAfterStart - cliff_) / basis_ + 1;
        uint256 totalReleaseMilestones = (duration_ + basis_ - 1) / basis_ + 1;
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
            info.basis
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

    function _getReleasableByParticipant(Participant participant_)
        private
        view
        returns (uint256)
    {
        uint256 _releasable = 0;

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            VestingInfo storage info = _beneficiaries[i];
            if (info.participant == participant_) {
                _releasable =
                    _releasable +
                    _releasableAmount(
                        info.genesisTimestamp,
                        info.totalAmount,
                        info.tgeAmount,
                        info.cliff,
                        info.duration,
                        info.releasedAmount,
                        info.status,
                        info.basis
                    );
            }
        }

        return _releasable;
    }

    function _releaseParticipant(Participant participant_) private {
        uint256 _releasable = _getReleasableByParticipant(participant_);
        require(
            _releasable > 0,
            "TokensVesting: no tokens are due!"
        );

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            if (_beneficiaries[i].participant == participant_) {
                _release(i);
            }
        }
    }
}
