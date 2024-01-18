// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CharlesToken is ERC20Burnable, AccessControl  {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint8 currentDecimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) ERC20(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
        _mint(_msgSender(), _initialSupply * 10**_decimals);
        currentDecimals = _decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return currentDecimals;
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "CharlesToken ERC20: must have minter role to mint");
        _mint(to, amount);
    }
}