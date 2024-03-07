// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotAuthorized();
error AlreadyMinted();
error NotMintPeriod();

contract ReadyPlayerClub is ERC721, Ownable, ReentrancyGuard {
    /**
     * @dev token metadata link
     */
    string internal _baseUri;
        /**
     * @dev next mintable token id
     */
    uint256 internal _nextTokenId;
    /**
     * @dev record whitelisted user
     */
    bytes32 internal _whitelistMerkleRoot;
    /**
     * @dev mint start-time
     */
    uint256 constant public START_MINTABLE_TIME = 0;
    /**
     * @dev mint end-time
     */
    uint256 public END_MINTABLE_TIME;
    /**
     * @dev prevent duplicate mint
     */
    mapping(address => bool) public minted;

    event UpdateBaseURI(string _uri);
    event UpdateWhitelistMerkleTreeRoot(bytes32 _root);

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_, address initialOwner_) ERC721(name_, symbol_) Ownable(initialOwner_){
        _whitelistMerkleRoot = merkleRoot_;
        END_MINTABLE_TIME = block.timestamp + 6048000;
    }

    /**
     * @dev mint NFT
     * @param merkleProof_ merkle proof
     */
    function claim(uint256 amount_, bytes32[] calldata merkleProof_) public nonReentrant returns (bool) {
        if (isValidProof(_msgSender(), amount_, merkleProof_) == false) revert NotAuthorized();
        if(block.timestamp < START_MINTABLE_TIME || END_MINTABLE_TIME < block.timestamp) revert NotMintPeriod();
        if (minted[_msgSender()] == true) revert AlreadyMinted();
        minted[_msgSender()] = true;
        for(uint i=0; i<amount_; i++) {
            uint256 tokenId = _nextTokenId++;
            _mint(_msgSender(), tokenId);
        }

        return true;
    }

    /**
     * @dev setting up base URI
     * @param _uri new URI
     */
    function setBaseURI(string memory _uri) external onlyOwner {
        _baseUri = _uri;

        emit UpdateBaseURI(_uri);
    }

    /**
     * @dev setting up mintable end-time
     * @param _newTime new end-time
     */
    function setMintableEndTime(uint256 _newTime) external onlyOwner {
        if(_newTime != END_MINTABLE_TIME) {
            END_MINTABLE_TIME = _newTime;
        }
    }
    /**
     * @dev update whitelist
     */
    function updateWhitelisteMerkleTree(bytes32 _root) external onlyOwner {
        if(_whitelistMerkleRoot != _root) {
            _whitelistMerkleRoot = _root;

            emit UpdateWhitelistMerkleTreeRoot(_root);
        }
    }

    //--------------------------- INTERNAL FUNCTION ----------------------------------------
    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    //--------------------------- VIEW FUNCTION ----------------------------------------
    function isValidProof(
        address user_,
        uint256 amount_,
        bytes32[] calldata merkleProof_
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(user_, amount_));
        return
            MerkleProof.verify(merkleProof_, _whitelistMerkleRoot, leaf);
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}