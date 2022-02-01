// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

import "./lib/SafeMath.sol";
import "./lib/Ownable.sol";
import "./lib/Token/ERC20.sol";
import "./lib/Address.sol";

/// DARE Token
contract CPTToken is
    ERC20("ChatPuppy Token", "CPT"),
    Ownable {
    using Address for address;
    using SafeMath for uint256;

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    /// @notice Burn `_amount` token from `_from`. Must only be called by the owner
    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    /// @notice Override ERC20.transfer
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        super.transfer(recipient, amount);
        return true;
    }

    /// @notice Override ERC20.transferFrom
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    function transferByOwner(address _to, uint256 _amount) external onlyOwner {
        require(balanceOf(address(this)) >= _amount, "out of balance");
        this.transfer(_to, _amount);
    }
}