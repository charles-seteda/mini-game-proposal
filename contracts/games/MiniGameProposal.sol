// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MiniGameProposal is Initializable, PausableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    using SafeERC20 for IERC20;
    IERC20 public _token;

    struct ProposalData {
        uint256 proposal_id;
        uint256 total_voted;
        uint256 created_time;
        uint256 last_update_time;
    }

    struct UserData {
        uint256 user_id;
        uint256 total_credit;
        uint256 reputation_point;
        uint256 created_time;
        uint256 last_update_time;
    }

    struct UserIndexData {
        uint256 user_index;
        bool is_value;
    }

    struct ProposalIndexData {
        uint256 proposal_index;
        bool is_value;
    }

    address[] public _owners;
    mapping(address => bool) public _isOwner;

    ProposalData[] public _proposalData;
    mapping(uint256 => ProposalIndexData) public _proposalIdToProposalDataIndex;

    UserData[] public _userData;
    mapping(uint256 => UserIndexData) public _userIdToUserDataIndex;

    uint256 _version;

    modifier onlyOwner() {
        require(_isOwner[msg.sender], "not owner");
        _;
    }

    modifier userExists(uint256 userIndex) {
        require(userIndex < _userData.length, "User ID does not exist");
        _;
    }

    modifier proposalExists(uint256 proposalIndex) {
        require(proposalIndex < _proposalData.length, "Deal ID does not exist");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address token,
        address[] memory owners
    ) initializer public {
        require(owners.length > 0, "");
        for (uint i = 0; i < owners.length; i++) {
            address owner = owners[i];
            require(owner != address(0), "invalid owner");
            require(!_isOwner[owner], "owner not unique");
            _isOwner[owner] = true;
            _owners.push(owner);
        }
        __Pausable_init();
        _grantRole(ADMIN_ROLE, _msgSender());
        _version = 1;
        _token = IERC20(token);
    }

    function setVersion(uint256 version) public onlyOwner {
        _version = version;
    }

    function createNewVoting(uint256 userId, uint256 proposalId, uint256 amount, bool isVoted) public returns (uint256) {
        uint256 currentTotalVoted = 0;
        if (_proposalIdToProposalDataIndex[proposalId].is_value) {
            uint256 proposalIndex = _proposalIdToProposalDataIndex[proposalId].proposal_index;
            if (isVoted == true) {
                _proposalData[proposalIndex].total_voted += amount;
            } else {
                if (_proposalData[proposalIndex].total_voted > amount) {
                    _proposalData[proposalIndex].total_voted -= amount;
                } else {
                    _proposalData[proposalIndex].total_voted = 0;
                }
            }
            _proposalData[proposalIndex].last_update_time = block.timestamp;
            currentTotalVoted = _proposalData[proposalIndex].total_voted;
        } else {
            if (isVoted == true) {
                currentTotalVoted = amount;
            } else {
                currentTotalVoted = 0;
            }
            _proposalData.push(ProposalData({
                proposal_id: proposalId,
                total_voted: currentTotalVoted,
                created_time: block.timestamp,
                last_update_time: block.timestamp
            }));
            _proposalIdToProposalDataIndex[proposalId] = ProposalIndexData({
                proposal_index : _proposalData.length - 1,
                is_value : true
            });
        }
        return currentTotalVoted;
    }

    function updateReputationPoint(uint256 userId, uint256 reasonId, uint256 amount, bool isIncrease) public returns (uint256) {
        uint256 currentReputationPoint = 0;
        if (_userIdToUserDataIndex[userId].is_value) {
            uint256 userIndex = _userIdToUserDataIndex[userId].user_index;
            if (isIncrease == true) {
                _userData[userIndex].reputation_point += amount;
            } else {
                if (_userData[userIndex].reputation_point > amount) {
                    _userData[userIndex].reputation_point -= amount;
                } else {
                    _userData[userIndex].reputation_point = 0;
                }
            }
            _userData[userIndex].last_update_time = block.timestamp;
            currentReputationPoint = _userData[userIndex].reputation_point;
        } else {
            if (isIncrease == true) {
                currentReputationPoint = amount;
            } else {
                currentReputationPoint = 0;
            }
            _userData.push(UserData({
                user_id: userId,
                total_credit: 0,
                reputation_point: currentReputationPoint,
                created_time: block.timestamp,
                last_update_time: block.timestamp
            }));
            _userIdToUserDataIndex[userId] = UserIndexData({
                user_index : _userData.length - 1,
                is_value : true
            });
        }
        return currentReputationPoint;
    }

    function updateCredit(uint256 userId, uint256 reasonId, uint256 amount, bool isIncrease) public returns (uint256) {
        uint256 currentCredit = 0;
        if (_userIdToUserDataIndex[userId].is_value) {
            uint256 userIndex = _userIdToUserDataIndex[userId].user_index;
            if (isIncrease == true) {
                _userData[userIndex].total_credit += amount;
            } else {
                if (_userData[userIndex].total_credit > amount) {
                    _userData[userIndex].total_credit -= amount;
                } else {
                    _userData[userIndex].total_credit = 0;
                }
            }
            _userData[userIndex].last_update_time = block.timestamp;
            currentCredit = _userData[userIndex].total_credit;
        } else {
            if (isIncrease == true) {
                currentCredit = amount;
            } else {
                currentCredit = 0;
            }
            UserData memory newUser = UserData({
                user_id: userId,
                total_credit: currentCredit,
                reputation_point: 0,
                created_time: block.timestamp,
                last_update_time: block.timestamp
            });
            _userData.push(newUser);
            _userIdToUserDataIndex[userId] = UserIndexData({
                user_index : _userData.length - 1,
                is_value : true
            });
        }
        return currentCredit;
    }

    function getOwners() public view returns (address[] memory) {
        return _owners;
    }

    function getUsersCount() public view returns (uint256) {
        return _userData.length;
    }

    function getProposalCount() public view returns (uint256) {
        return _proposalData.length;
    }

    function getUser(uint256 index)
    public
    view
    returns (
        uint256 userId,
        uint256 totalCredit,
        uint256 reputationPoint,
        uint256 createdTime,
        uint256 lastUpdateTime
    )
    {
        UserData storage userData = _userData[index];
        return (
            userData.user_id,
            userData.total_credit,
            userData.reputation_point,
            userData.created_time,
            userData.last_update_time
        );
    }

    function getUserById(uint256 userDataId)
    public
    view
    returns (
        uint256 userId,
        uint256 totalCredit,
        uint256 reputationPoint,
        uint256 createdTime,
        uint256 lastUpdateTime
    )
    {
        require(_userIdToUserDataIndex[userDataId].is_value, "Not found data!");
        UserData storage userData = _userData[_userIdToUserDataIndex[userDataId].user_index];
        return (
            userData.user_id,
            userData.total_credit,
            userData.reputation_point,
            userData.created_time,
            userData.last_update_time
        );
    }

    function getProposal(uint256 index) public view returns (
        uint256 proposalId,
        uint256 totalVoted,
        uint256 createdTime,
        uint256 lastUpdateTime
    ) {
        ProposalData storage proposalData = _proposalData[index];
        return (
            proposalData.proposal_id,
            proposalData.total_voted,
            proposalData.created_time,
            proposalData.last_update_time
        );
    }

    function getProposalById(uint256 proposalDataId) public view returns (
        uint256 proposalId,
        uint256 totalVoted,
        uint256 createdTime,
        uint256 lastUpdateTime
    ) {
        require(_proposalIdToProposalDataIndex[proposalDataId].is_value, "Not found data!");
        ProposalData storage proposalData = _proposalData[_proposalIdToProposalDataIndex[proposalDataId].proposal_index];
        return (
            proposalData.proposal_id,
            proposalData.total_voted,
            proposalData.created_time,
            proposalData.last_update_time
        );
    }

    function getUsers() public view returns (UserData[] memory) {
        return _userData;
    }

    function getProposals() public view returns (ProposalData[] memory) {
        return _proposalData;
    }

    function getUserByIndex(uint256 userIndex) public view returns (UserIndexData memory) {
        return _userIdToUserDataIndex[userIndex];
    }

    function getProposalByIndex(uint256 proposalIndex) public view returns (ProposalIndexData memory) {
        return _proposalIdToProposalDataIndex[proposalIndex];
    }
}